# ADHD Skills Lab

Self-paced ADHD courses with exercises and brain games, in a single page (`index.html`) with no build step.

- 8 courses, 48 micro-lessons: Focus & Executive Function, Memory Boosters, Healthy Habits, Life Skills, Understanding ADHD, Emotions & Self-Regulation, Work & Study, Getting Support: Diagnosis & Treatment
- ADHD Library: 30 sourced reference articles (including a history of ADHD from 1775), glossary and search
- Research news: plain-language summaries of new ADHD research, guidelines and policy, plus a Landmark research archive
- 11 brain games: Color Clash, Square Recall, Pattern Echo, Green Light Red Light, Memory Match, Inner Clock, Odd One Out, Tower Planner, Quick Tap, Switch It, Night Watch
- Adaptive levels, a "My brain skills" profile (Attention, Memory, Inhibition, Planning, Speed) and a daily 10-minute workout
- Optional free user accounts (Supabase): progress, saved tools and game scores sync across devices
- Without accounts configured, progress is saved in each visitor's browser

Live: https://courses.magothymedia.com

---

## Hosting (GitHub Pages)

1. Repo **Settings → Pages**: Source **Deploy from a branch**, Branch **main**, Folder **/ (root)**.
2. **Custom domain**: `courses.magothymedia.com`, then tick **Enforce HTTPS** once the DNS check passes.
3. DNS (Squarespace → Domains → magothymedia.com → DNS Settings → Custom records):
   `CNAME` · host `courses` · data `<github-username>.github.io`

---

## Turning on user accounts (Supabase, one-time, ~15 minutes)

### 1. Create the project
1. Sign up at **supabase.com** (free plan).
2. **New project**: name `adhd-skills-lab`, set a strong database password (save it somewhere safe), region **East US**.
3. Wait a couple of minutes while it sets up.

### 2. Create the database table
1. Left sidebar → **SQL Editor** → **New query**.
2. Paste the whole contents of `supabase-setup.sql` and click **Run**. You should see "Success. No rows returned."

This creates one `progress` row per user, locked down with Row Level Security so each person can only read and write their own data, plus a `delete_user` function so people can delete their own account.

### 3. Tell Supabase where the site lives
**Authentication → URL Configuration**
- **Site URL:** `https://courses.magothymedia.com`
- **Redirect URLs** (add both):
  - `https://courses.magothymedia.com/**`
  - `https://<github-username>.github.io/adhd-skills-lab/**`

This makes the confirmation and password-reset links in emails send people back to the course.

### 4. Connect the site to Supabase
1. **Project Settings → API Keys** (or **API**): copy the **Project URL** and the **publishable** key (older projects call it the **anon public** key).
2. In `index.html`, find these two lines near the top of the main script and paste the values in:
   ```js
   const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   const SUPABASE_KEY = "sb_publishable_...";
   ```
3. Commit. A **Sign in** button appears in the header once the site redeploys.

The publishable/anon key is designed to be public; Row Level Security protects the data.
**Never** put the `secret` / `service_role` key in the site.

### 5. Set up email so real users can sign up (important)
Supabase's built-in email sender is for testing only: it sends very few emails per hour and may only deliver to your own team's addresses. Before sharing the course, either:

- **Recommended:** connect a free email service (for example Resend or Brevo) under **Authentication → Emails → SMTP Settings**, sending from an address like `no-reply@magothymedia.com`. The provider will give you a few DNS records to add in Squarespace so mail isn't marked as spam. Then raise the limit under **Authentication → Rate Limits**.
- **Quick start:** turn off **Confirm email** under **Authentication → Sign In / Providers → Email**. People can sign up instantly, but password-reset emails will still need working email.

Optional: edit the email wording under **Authentication → Emails → Templates** (for example "Confirm your ADHD Skills Lab account").

### 6. Things to know about the free plan
- Free projects can be **paused after about a week with no activity**. Restore them from the dashboard, or upgrade to Pro to prevent it.
- See your users under **Authentication → Users**. For a quick progress report, run the commented query at the bottom of `supabase-setup.sql` in the SQL Editor.

---

## How syncing works
- Signed out: progress is stored in the browser (localStorage).
- Signing in merges browser progress into the account (completed lessons are combined, best scores are kept).
- While signed in, every change saves to the account about a second later.
- Signing out clears progress from that browser, so shared computers stay private.
- **Account page:** change name or password, sync now, sign out, or permanently delete the account and its data.

## Editing content
All lesson text lives in the `COURSES` array inside `index.html`. Edit, commit, and Pages redeploys automatically.

Educational self-help content only; not a substitute for professional diagnosis or treatment.
