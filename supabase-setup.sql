-- ════════════════════════════════════════════════════════════════
-- HK Trading Journal — Supabase setup
-- Already applied to the HK-Journal project (qocxnoxlamvhxfwgsqig) on 2026-11-13.
-- Kept here for reference / to rebuild the project if ever needed.
-- Safe to re-run.
-- ════════════════════════════════════════════════════════════════

-- 1. One table holds every journal record (trades, debriefs, payouts,
--    backtests, settings, plan…). Each trade/debrief is its own row,
--    so two devices never overwrite each other's work.
create table if not exists public.journal_records (
  user_id     uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  collection  text        not null,   -- e.g. hk_trades_p1, hk_debriefs, hk_plan
  record_id   text        not null,   -- trade id, debrief id, or '_' for settings
  data        jsonb       not null default '{}'::jsonb,
  deleted     boolean     not null default false,  -- soft delete so other devices learn about it
  updated_at  timestamptz not null default now(),
  primary key (user_id, collection, record_id)
);

create index if not exists journal_records_user_updated_idx
  on public.journal_records (user_id, updated_at);

-- 2. Server sets updated_at on every change (devices pull "what changed since X")
create or replace function public.journal_touch_updated_at()
returns trigger language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := pg_catalog.now();
  return new;
end $$;

drop trigger if exists journal_records_touch on public.journal_records;
create trigger journal_records_touch
  before insert or update on public.journal_records
  for each row execute function public.journal_touch_updated_at();

-- 3. Row Level Security: you can only ever see / change your own rows
alter table public.journal_records enable row level security;

drop policy if exists "own rows select" on public.journal_records;
drop policy if exists "own rows insert" on public.journal_records;
drop policy if exists "own rows update" on public.journal_records;
drop policy if exists "own rows delete" on public.journal_records;

create policy "own rows select" on public.journal_records
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "own rows insert" on public.journal_records
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own rows update" on public.journal_records
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own rows delete" on public.journal_records
  for delete to authenticated using ((select auth.uid()) = user_id);

-- 4. Private bucket for chart screenshots (debrief images).
--    Files live under <your user id>/debriefs/<debrief id>/...
insert into storage.buckets (id, name, public)
values ('journal-images', 'journal-images', false)
on conflict (id) do nothing;

drop policy if exists "journal images select" on storage.objects;
drop policy if exists "journal images insert" on storage.objects;
drop policy if exists "journal images update" on storage.objects;
drop policy if exists "journal images delete" on storage.objects;

create policy "journal images select" on storage.objects
  for select to authenticated
  using (bucket_id = 'journal-images' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "journal images insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'journal-images' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "journal images update" on storage.objects
  for update to authenticated
  using (bucket_id = 'journal-images' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "journal images delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'journal-images' and (storage.foldername(name))[1] = (select auth.uid())::text);
