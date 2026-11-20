-- ADHD Skills Lab: database setup for user accounts
-- Paste this whole file into Supabase > SQL Editor > New query, then click Run.
-- Safe to run more than once.

-- 1. One row of saved progress per user
create table if not exists public.progress (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  state      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint progress_state_size check (pg_column_size(state) < 262144) -- 256 KB cap per user
);

-- 2. Row Level Security: each person can only see and change their own row
alter table public.progress enable row level security;

drop policy if exists "read own progress"   on public.progress;
drop policy if exists "insert own progress" on public.progress;
drop policy if exists "update own progress" on public.progress;
drop policy if exists "delete own progress" on public.progress;

create policy "read own progress"   on public.progress for select to authenticated using ((select auth.uid()) = user_id);
create policy "insert own progress" on public.progress for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "update own progress" on public.progress for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "delete own progress" on public.progress for delete to authenticated using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.progress to authenticated;
revoke all on public.progress from anon;

-- 3. Let a signed-in user delete their own account (their progress row is removed with it)
create or replace function public.delete_user()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from auth.users where id = auth.uid();
$$;

revoke all on function public.delete_user() from public, anon;
grant execute on function public.delete_user() to authenticated;

-- 4. Optional: a quick look at your learners (run on its own in the SQL Editor; not exposed to the site)
-- select u.email, u.created_at, p.updated_at as last_active,
--        (select count(*) from jsonb_object_keys(coalesce(p.state->'done','{}'::jsonb))) as lessons_done
-- from auth.users u left join public.progress p on p.user_id = u.id
-- order by p.updated_at desc nulls last;
