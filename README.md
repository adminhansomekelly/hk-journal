# HK Trading Journal — cloud version

Single-page journal hosted on GitHub Pages, with data synced through Supabase.
Sign in with email + password on any browser or phone, and every device shows the same journal.

## How it works
- Every trade, debrief, payout and backtest is its own row in Supabase, so logging a trade on your phone never overwrites something you did on the desktop.
- Each device keeps a working copy, so the journal stays fast and still works with no signal. Changes sync within a couple of seconds, and also whenever the app comes back into focus.
- Debrief chart screenshots go into a private Supabase Storage bucket. Only your account can read them.
- The status box in the sidebar (and the dot in the phone's top bar) shows: green = synced, amber = waiting / can't reach the cloud, red = error.

## One-time setup

### 1. Supabase project — DONE
- Project **HK-Journal** (`qocxnoxlamvhxfwgsqig`, US East) in The Profit Society org.
- Table, security rules and the private image bucket are created (`supabase-setup.sql` is kept for reference).
- The project URL and public key are already in `index.html`.

### 2. Supabase auth links (you, ~1 min)
In the HK-Journal project, open **Authentication → URL Configuration**:
- Site URL: `https://adminhansomekelly.github.io/hk-journal/`
- Redirect URLs: add the same URL.

This makes the confirm-email and reset-password links open your journal.

### 3. GitHub Pages
1. Create a new repo named `hk-journal` under `adminhansomekelly`. It must be public for free GitHub Pages; your data still stays behind your login.
2. Upload: `index.html`, `sw.js`, `manifest.json`, `icon-192.png`, `icon-512.png` (`README.md` is optional).
3. Go to **Settings → Pages → Deploy from a branch → main / (root)**. After about a minute the site is live at the URL above.

### 4. Move your existing data in (office computer)
Your current trades live inside the old local file's browser storage, which the new site can't see. To move them over:
1. Open your **current local journal file** and click **Export backup**.
2. Open the new site, click **Create account**, confirm the email, then sign in.
3. Click **Restore backup** and pick the file from step 1. The journal reloads and uploads everything. Wait for the green "Synced" dot.

### 5. Lock it down
In Supabase go to **Authentication → Sign In / Providers** and turn off **Allow new users to sign up**. Your account keeps working, and nobody else can register on your project.

### 6. Phone
Open the URL, sign in, then **Add to Home Screen** (Safari: Share → Add to Home Screen; Chrome: ⋮ → Install app).

## Updating the journal later
When you upload a new `index.html`, also change `VERSION` in `sw.js` (e.g. `hk-v1` → `hk-v2`) so installed phones pick up the new version.

## Good to know
- **Export backup** still works, as an extra safety copy. Chart images stored in the cloud aren't inside the JSON.
- **Sign out** clears that device's copy. Everything stays in the cloud and comes back when you sign in again.
- **Reset journal** syncs too: resetting a phase clears it on every device.
- Supabase's free plan pauses a project after about a week with zero activity. Daily use keeps it awake; if it ever pauses, click "Restore" in the Supabase dashboard.
