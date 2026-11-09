-- Lets a coach account read a client's exercise logs and meal logs, needed by
-- the "View as client" mode (Coach Dashboard -> client profile -> View as
-- client) which reuses the client's own Home/Workout/Nutrition screens with
-- the coach's session. Read-only: no insert/update/delete policy is added,
-- so the coach can never write into another user's rows here — the owner-only
-- "for all" policies already in place keep blocking that.
-- Builds on is_coach() from coach_view_support.sql. Safe to re-run.

drop policy if exists "exercise_logs: coach select all" on public.exercise_logs;
create policy "exercise_logs: coach select all" on public.exercise_logs
  for select using (public.is_coach());

drop policy if exists "meal_logs: coach select all" on public.meal_logs;
create policy "meal_logs: coach select all" on public.meal_logs
  for select using (public.is_coach());

-- profile_extras isn't in schema.sql (added directly earlier), so guard its
-- existence before touching it.
do $$
begin
  if to_regclass('public.profile_extras') is not null then
    execute 'drop policy if exists "profile_extras: coach select all" on public.profile_extras';
    execute 'create policy "profile_extras: coach select all" on public.profile_extras for select using (public.is_coach())';
  end if;
end $$;
