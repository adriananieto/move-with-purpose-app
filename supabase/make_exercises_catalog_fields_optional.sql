-- The live `exercises` table still has legacy columns (order_index, target_sets,
-- target_reps, section_id) from the old single-program design, some marked NOT NULL.
-- Now that sets/reps/order live on workout_exercises instead, a catalog-only exercise
-- (just name + video_url) has no value to put there. Loosen those constraints.
-- Safe to re-run; only removes a constraint, never touches data.

alter table public.exercises alter column order_index drop not null;
alter table public.exercises alter column target_sets drop not null;
alter table public.exercises alter column target_reps drop not null;
alter table public.exercises alter column section_id drop not null;
