-- Lets a coach account read a client's training plan and daily nutrition target,
-- so you can preview a client's full profile before she ever logs in.
-- Builds on is_coach() from coach_view_support.sql. Safe to re-run.

drop policy if exists "workouts: coach select all" on public.workouts;
create policy "workouts: coach select all" on public.workouts
  for select using (public.is_coach());

drop policy if exists "workout_exercises: coach select all" on public.workout_exercises;
create policy "workout_exercises: coach select all" on public.workout_exercises
  for select using (public.is_coach());

drop policy if exists "nutrition_targets: coach select all" on public.nutrition_targets;
create policy "nutrition_targets: coach select all" on public.nutrition_targets
  for select using (public.is_coach());
