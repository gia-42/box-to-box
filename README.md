# Box to Box

Four daily football games: **Mata-Mata**, **Tiki-Taka**, **Camisa 10** and **VAR**. In Portuguese and English, installable as an app, with optional accounts (email or Google) that keep stats and streaks on every device, plus friends and head-to-head comparisons.

## What's in this folder

| File | What it does |
|---|---|
| `index.html` | The game |
| `config.js` | Your account settings. **The only file you edit.** |
| `data/wmap.js` | The VAR world map |
| `img/var/` | The VAR photos |
| `manifest.webmanifest`, `sw.js`, `icons/` | Make it an installable app that works offline |
| `privacy.html` | Privacy policy (add your contact email) |
| `supabase-setup.sql` | Creates the database. Runs in Supabase, not on GitHub. |

Without any setup the game runs in guest mode: fully playable, stats saved per device. Accounts and the Friends tab switch on once `config.js` is filled in.

---

## Step 1: Put it on GitHub Pages

1. On github.com, click **+ > New repository**. Name it `box-to-box`, set it to **Public**, and click **Create repository**.
2. Click **uploading an existing file**. Drag in **everything** from this folder, including the `data`, `img` and `icons` folders. Click **Commit changes**.
3. Open **Settings > Pages**. Under **Branch**, choose `main` and `/ (root)`, then **Save**.
4. After a minute or two the game is live at `https://gia-42.github.io/box-to-box/`.

## Step 2: Create the database (Supabase, free)

1. On **supabase.com**, click **New project**. Name it `box-to-box`, set a database password (save it), pick **South America (São Paulo)**, and create it. The free plan allows two projects, so this sits next to Daily Dharma.
2. Open **SQL Editor > New query**, paste the whole of `supabase-setup.sql`, and click **Run**. If it warns about "destructive operations", that's only the `drop policy if exists` lines replacing its own rules; click **Run query**. You should see "Success. No rows returned", and **Table Editor** should list `profiles`, `results` and `friendships`.
3. Click **Connect** (top of the project page) and copy the **Project URL** and the **publishable key** (starts with `sb_publishable_`).
4. On GitHub, open `config.js`, click the pencil icon, paste them into `supabaseUrl` and `supabaseAnonKey`, and commit.
5. In Supabase, open **Authentication > URL Configuration**:
   - **Site URL:** `https://gia-42.github.io/box-to-box/`
   - **Redirect URLs:** add the same address.

## Step 3: Email login (6-digit code)

1. Open **Authentication > Emails > Templates**.
2. In both **Magic Link** and **Confirm signup**, put the code in the message, for example:
   `Seu código do Box to Box / Your Box to Box code: {{ .Token }}`
3. Save both.

Supabase's built-in sender only allows a few emails per hour. Fine for a beta; before launch, connect a free sender such as Resend under **Authentication > Emails > SMTP Settings**.

## Step 4: Google login

Use a **new** Google Cloud project, so the Google popup says "Box to Box" and not "Daily Dharma".

1. On **console.cloud.google.com**, create a project called `Box to Box`.
2. **Google Auth Platform > Branding** (the OAuth consent screen): app name `Box to Box`, your email, audience **External**.
   - Application home page: `https://gia-42.github.io/box-to-box/`
   - Privacy policy: `https://gia-42.github.io/box-to-box/privacy.html`
   - Authorized domain: `gia-42.github.io`
3. **Clients > Create client > Web application**:
   - **Authorized JavaScript origins:** `https://gia-42.github.io`
   - **Authorized redirect URIs:** copy the callback address shown in Supabase under **Authentication > Sign In / Providers > Google** (it looks like `https://YOUR-PROJECT.supabase.co/auth/v1/callback`).
4. Copy the **Client ID** and **Client secret** into Supabase's Google provider, and switch it on.
5. Put the same **Client ID** in `config.js` as `googleClientId` and commit.

## Step 5: Test it

1. Open the site, tap the person icon at the top, and log in. Pick a username.
2. Play a game, then open the site on another device and log in: your result and streak should be there.
3. Ask a friend to log in, then add each other in the **Friends** tab.

## Updating the game later

Upload the new files, then open `sw.js` and bump `VERSION` (`b2b-v1` → `b2b-v2`) so installed copies update. Never replace `config.js`: it holds your keys.
