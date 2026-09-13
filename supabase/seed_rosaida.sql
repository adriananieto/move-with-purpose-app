-- Rosaida — 5-day training program
-- Run this in Supabase: Dashboard → SQL Editor → New query → paste → Run.
--
-- Assumes:
--   workouts(id, client_id, name, scheduled_date)
--   workout_exercises(id, workout_id, exercise_id, sets, target_reps, order_index)
--   exercises(id, name, video_url)
-- Safe to re-run for a DIFFERENT client after changing the name pattern below —
-- but re-running as-is for Rosaida will duplicate her 5 workouts (no existing-workout check).

-- ============================================================
-- 0. Resolve Rosaida's client_id from profiles.full_name.
--    Fails loudly instead of guessing if 0 or 2+ profiles match.
--    Edit the pattern below if you know her exact full_name.
-- ============================================================
drop table if exists _rosaida_client;
create temporary table _rosaida_client as
select id as client_id, full_name
from public.profiles
where full_name ilike '%Rosaida%';

do $$
declare
  v_count int;
begin
  select count(*) into v_count from _rosaida_client;
  if v_count = 0 then
    raise exception 'No profile matched name ILIKE %%Rosaida%%. Confirm Rosaida has signed up (profiles rows are only created on signup) or edit the pattern above.';
  elsif v_count > 1 then
    raise exception 'Multiple profiles matched %%Rosaida%%: %. Narrow the ilike pattern above and re-run.',
      (select string_agg(full_name, ', ') from _rosaida_client);
  end if;
end $$;

-- ============================================================
-- 1. Ensure every exercise this program needs exists in the catalog.
--    Reuses any existing row whose name matches (case/whitespace-insensitive).
--    Creates the rest with video_url = null (fill in later).
-- ============================================================
insert into public.exercises (name, video_url)
select v.name, null
from (values
  ('Escalera'), ('Hip Thrust'), ('Walking Lunges'), ('Sumo Squats'), ('Cable Kickback'),
  ('Dumbbell RDLs'), ('Laying Hamstring Curl'), ('Jump Squats'), ('Calf Raises'), ('Crunches'),
  ('Bicycle Crunches'), ('Pull Ups'), ('Tricep Dips'), ('Overhead Tricep Extension'), ('Push Press'),
  ('Lateral Raises'), ('Plank Shoulder Taps'), ('Plank to Push Ups'), ('Burpees'), ('Mountain Climbers'),
  ('Russian Twists'), ('Bulgarian Split Squats'), ('Goblet Squats'), ('Cable Leg Lateral Raises'), ('Leg Press'),
  ('Leg Extension'), ('Reverse Crunches'), ('Bicep Curls'), ('Hammer Curls'), ('Tricep Kickbacks'),
  ('Arnold Press'), ('Bicep Concentrated Curls'), ('Skull Crushers'), ('Squats'), ('Deadlift'),
  ('Lat Pulldown'), ('Planks')
) as v(name)
where not exists (
  select 1 from public.exercises e where lower(trim(e.name)) = lower(trim(v.name))
);

-- ============================================================
-- 2. One `workouts` row per training day, assigned to Rosaida.
--    scheduled_date left null — its exact type wasn't confirmed; set later if needed.
-- ============================================================
insert into public.workouts (client_id, name)
select client_id, v.name
from _rosaida_client, (values
  ('Day 1 - Lower Body'),
  ('Day 2 - Upper Body'),
  ('Day 3 - Lower Body'),
  ('Day 4 - Upper Body'),
  ('Day 5 - Full Body (Pump Day)')
) as v(name);

-- ============================================================
-- 3. workout_exercises rows.
--    No section/notes column exists yet, so each target_reps is tagged with its
--    section ([Warm Up]/[Workout]/[Core]/[Cardio]) and carries any qualifier
--    (c/lado, cruzado, con peso, stance, pace) as free text after the number.
--    order_index preserves the exact sequence within each day.
-- ============================================================
insert into public.workout_exercises (workout_id, exercise_id, sets, target_reps, order_index)
select w.id, e.id, x.sets, x.target_reps, x.order_index
from (values
  -- Day 1 — Lower Body
  ('Day 1 - Lower Body', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Day 1 - Lower Body', 'Hip Thrust', 4, '[Workout] 12', 2),
  ('Day 1 - Lower Body', 'Walking Lunges', 3, '[Workout] 10 c/lado', 3),
  ('Day 1 - Lower Body', 'Sumo Squats', 3, '[Workout] 12', 4),
  ('Day 1 - Lower Body', 'Cable Kickback', 3, '[Workout] 12 c/lado, cruzado', 5),
  ('Day 1 - Lower Body', 'Dumbbell RDLs', 3, '[Workout] 15', 6),
  ('Day 1 - Lower Body', 'Laying Hamstring Curl', 3, '[Workout] 12', 7),
  ('Day 1 - Lower Body', 'Jump Squats', 3, '[Workout] 10', 8),
  ('Day 1 - Lower Body', 'Calf Raises', 3, '[Workout] 15', 9),
  ('Day 1 - Lower Body', 'Crunches', 3, '[Core] 15, con peso', 10),
  ('Day 1 - Lower Body', 'Bicycle Crunches', 3, '[Core] 10 c/lado, cruzado', 11),
  ('Day 1 - Lower Body', 'Escalera', 1, '[Cardio] 30 min, pace moderado', 12),

  -- Day 2 — Upper Body
  ('Day 2 - Upper Body', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Day 2 - Upper Body', 'Pull Ups', 3, '[Workout] 10', 2),
  ('Day 2 - Upper Body', 'Tricep Dips', 3, '[Workout] 12', 3),
  ('Day 2 - Upper Body', 'Overhead Tricep Extension', 3, '[Workout] 15', 4),
  ('Day 2 - Upper Body', 'Push Press', 3, '[Workout] 10 c/lado', 5),
  ('Day 2 - Upper Body', 'Lateral Raises', 3, '[Workout] 15', 6),
  ('Day 2 - Upper Body', 'Plank Shoulder Taps', 3, '[Workout] 20', 7),
  ('Day 2 - Upper Body', 'Plank to Push Ups', 3, '[Workout] 10', 8),
  ('Day 2 - Upper Body', 'Burpees', 3, '[Workout] 10', 9),
  ('Day 2 - Upper Body', 'Mountain Climbers', 3, '[Core] 20, cruzado', 10),
  ('Day 2 - Upper Body', 'Russian Twists', 3, '[Core] 10 c/lado, con peso', 11),
  ('Day 2 - Upper Body', 'Escalera', 1, '[Cardio] 30 min, pace moderado', 12),

  -- Day 3 — Lower Body
  ('Day 3 - Lower Body', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Day 3 - Lower Body', 'Hip Thrust', 4, '[Workout] 12', 2),
  ('Day 3 - Lower Body', 'Bulgarian Split Squats', 3, '[Workout] 10 c/lado', 3),
  ('Day 3 - Lower Body', 'Goblet Squats', 3, '[Workout] 15', 4),
  ('Day 3 - Lower Body', 'Cable Leg Lateral Raises', 3, '[Workout] 10 c/lado', 5),
  ('Day 3 - Lower Body', 'Leg Press', 3, '[Workout] 12, abajo + cerrado', 6),
  ('Day 3 - Lower Body', 'Leg Extension', 3, '[Workout] 12', 7),
  ('Day 3 - Lower Body', 'Walking Lunges', 3, '[Workout] 10 c/lado', 8),
  ('Day 3 - Lower Body', 'Calf Raises', 3, '[Workout] 15', 9),
  ('Day 3 - Lower Body', 'Reverse Crunches', 3, '[Core] 15', 10),
  ('Day 3 - Lower Body', 'Bicycle Crunches', 3, '[Core] 20, cruzado', 11),
  ('Day 3 - Lower Body', 'Escalera', 1, '[Cardio] 30 min, pace moderado', 12),

  -- Day 4 — Upper Body
  ('Day 4 - Upper Body', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Day 4 - Upper Body', 'Bicep Curls', 3, '[Workout] 15', 2),
  ('Day 4 - Upper Body', 'Hammer Curls', 3, '[Workout] 12', 3),
  ('Day 4 - Upper Body', 'Tricep Kickbacks', 3, '[Workout] 15 c/lado', 4),
  ('Day 4 - Upper Body', 'Arnold Press', 3, '[Workout] 10', 5),
  ('Day 4 - Upper Body', 'Bicep Concentrated Curls', 3, '[Workout] 7-7-7', 6),
  ('Day 4 - Upper Body', 'Skull Crushers', 3, '[Workout] 12', 7),
  ('Day 4 - Upper Body', 'Plank to Push Ups', 3, '[Workout] 10', 8),
  ('Day 4 - Upper Body', 'Burpees', 3, '[Workout] 10', 9),
  ('Day 4 - Upper Body', 'Reverse Crunches', 3, '[Core] 15', 10),
  ('Day 4 - Upper Body', 'Russian Twists', 3, '[Core] 10 c/lado, con peso', 11),
  ('Day 4 - Upper Body', 'Escalera', 1, '[Cardio] 30 min, pace moderado', 12),

  -- Day 5 — Full Body (Pump Day) — no warm up or cardio listed
  ('Day 5 - Full Body (Pump Day)', 'Squats', 3, '[Workout] 15', 1),
  ('Day 5 - Full Body (Pump Day)', 'Deadlift', 3, '[Workout] 12', 2),
  ('Day 5 - Full Body (Pump Day)', 'Lat Pulldown', 3, '[Workout] 12', 3),
  ('Day 5 - Full Body (Pump Day)', 'Push Press', 3, '[Workout] 10', 4),
  ('Day 5 - Full Body (Pump Day)', 'Walking Lunges', 3, '[Workout] 10 c/lado', 5),
  ('Day 5 - Full Body (Pump Day)', 'Bicep Curls', 3, '[Workout] 12', 6),
  ('Day 5 - Full Body (Pump Day)', 'Tricep Dips', 3, '[Workout] 15', 7),
  ('Day 5 - Full Body (Pump Day)', 'Burpees', 3, '[Workout] 10', 8),
  ('Day 5 - Full Body (Pump Day)', 'Planks', 3, '[Core] 1 min', 9),
  ('Day 5 - Full Body (Pump Day)', 'Mountain Climbers', 3, '[Core] 20', 10)
) as x(workout_name, exercise_name, sets, target_reps, order_index)
join public.workouts w
  on w.name = x.workout_name and w.client_id = (select client_id from _rosaida_client)
join public.exercises e
  on lower(trim(e.name)) = lower(trim(x.exercise_name));

-- ============================================================
-- 4. Verify: row counts, and which exercises still need a video.
-- ============================================================
select w.name as workout, count(we.id) as exercise_count
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
where w.client_id = (select client_id from _rosaida_client)
group by w.name
order by w.name;

select e.name, e.video_url
from public.exercises e
where e.video_url is null
order by e.name;
