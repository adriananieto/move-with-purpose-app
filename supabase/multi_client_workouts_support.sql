-- Supporting changes for the app to actually read workouts/workout_exercises.
-- Safe to run on its own, non-destructive. Run this once in the SQL editor.

-- ============================================================
-- Disambiguate which day's assignment of a (possibly repeated) exercise
-- a logged set belongs to. Nullable so existing rows are unaffected.
-- ============================================================
alter table public.exercise_logs
  add column if not exists workout_exercise_id uuid references public.workout_exercises(id);

-- ============================================================
-- Row-level security: a client should only ever see her own workouts.
-- If these tables already had RLS/policies set up, these are additive/
-- idempotent (drop-if-exists before create) and won't conflict.
-- ============================================================
alter table public.workouts enable row level security;

drop policy if exists "workouts: owner select" on public.workouts;
create policy "workouts: owner select" on public.workouts
  for select using (auth.uid() = client_id);

alter table public.workout_exercises enable row level security;

drop policy if exists "workout_exercises: owner select" on public.workout_exercises;
create policy "workout_exercises: owner select" on public.workout_exercises
  for select using (
    exists (
      select 1 from public.workouts w
      where w.id = workout_exercises.workout_id and w.client_id = auth.uid()
    )
  );

-- Exercise catalog stays readable by any signed-in user (same as before).
alter table public.exercises enable row level security;

drop policy if exists "exercises: read all authenticated" on public.exercises;
create policy "exercises: read all authenticated" on public.exercises
  for select using (auth.role() = 'authenticated');
