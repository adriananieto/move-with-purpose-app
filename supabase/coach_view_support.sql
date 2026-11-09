-- Adds coach-level read access so Adriana's own account can see every client's
-- check-ins, body composition history, and progress photos. Safe to re-run.

-- ============================================================
-- 1. Mark who is a coach.
-- ============================================================
alter table public.profiles
  add column if not exists is_coach boolean not null default false;

-- Security-definer helper: checks the CURRENT logged-in user's own coach flag,
-- bypassing RLS internally so it can't recurse into the policies that use it.
create or replace function public.is_coach()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select is_coach from public.profiles where id = auth.uid()), false);
$$;

-- ============================================================
-- 2. Let a coach read every client's row on the tables the check-in view needs.
--    Additive: existing "owner only" policies stay, this just ORs in a second path.
-- ============================================================
drop policy if exists "profiles: coach select all" on public.profiles;
create policy "profiles: coach select all" on public.profiles
  for select using (public.is_coach());

drop policy if exists "checkins: coach select all" on public.checkins;
create policy "checkins: coach select all" on public.checkins
  for select using (public.is_coach());

drop policy if exists "body_weight_logs: coach select all" on public.body_weight_logs;
create policy "body_weight_logs: coach select all" on public.body_weight_logs
  for select using (public.is_coach());

drop policy if exists "progress_photos: coach select all" on public.progress_photos;
create policy "progress_photos: coach select all" on public.progress_photos
  for select using (public.is_coach());

-- ============================================================
-- 3. Link progress photos to the specific check-in they were uploaded with,
--    so the coach view can show exactly the right photos per check-in
--    (today they're only matched by upload date, which isn't reliable).
-- ============================================================
alter table public.progress_photos
  add column if not exists checkin_id bigint references public.checkins(id) on delete set null;

-- ============================================================
-- 4. Mark your own account as coach.
-- ============================================================
update public.profiles p
set is_coach = true
from auth.users u
where u.id = p.id and u.email = 'anietopr@gmail.com';

-- Confirm:
select id, full_name, is_coach from public.profiles where is_coach = true;
