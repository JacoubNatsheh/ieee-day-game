# IEEE PPU Activities (live quiz) - free version

Files: `index.html` (the app), `logo.png`, `supabase-setup.sql`.
Runs on GitHub Pages + a free Supabase project. No credit card needed.

## 1. Supabase (free)
1. supabase.com -> sign in -> **New project** (free plan, any name/password/region).
2. **SQL Editor -> New query**, paste all of `supabase-setup.sql`, click **Run**.
3. **Project Settings -> API Keys**: copy the **Project URL** and the **anon / publishable key**.
4. Paste both at the top of `index.html` (`SUPABASE_URL`, `SUPABASE_KEY`).

## 2. GitHub Pages
Upload the three files to a public repo, then Settings -> Pages -> Deploy from branch -> main / root.
- Players: `https://YOUR-USER.github.io/YOUR-REPO/`
- Host: same link + `?host`

## Notes
- Free Supabase projects pause after a week of no use: open the dashboard and click Restore the day before an event.
- Players check for updates about every 1.2 seconds, so screens may lag about a second behind the host.
- Edit the `Q` array at the top of the script to change questions.
- Open database rules suit a club event but a determined person could cheat. Use **Close game** at the end.
