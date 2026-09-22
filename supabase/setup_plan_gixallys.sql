-- Gixallys García's 4-day training plan + nutrition targets.
-- Run create_client_gixallys.sql FIRST (creates her login + profile).
-- Safe to re-run (re-running just updates sets/reps/targets, no duplicates).

drop table if exists _gixallys;
create temporary table _gixallys as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'Gixallysg@gmail.com';

do $$
begin
  if (select count(*) from _gixallys) = 0 then
    raise exception 'No profile matched that email. Run create_client_gixallys.sql first, or check the address.';
  end if;
end $$;

-- Reuses any exercise that already exists (matched case-insensitively, e.g. from
-- Rosaida's catalog); only creates a catalog row (no video yet) for ones that aren't
-- there. Safe against duplicates.
insert into public.exercises (name, video_url)
select v.name, null
from (values
  ('Deadlift'), ('Goblet Squats'), ('Bulgarian Split Squats'), ('Hip Thrust'),
  ('Leg Extension'), ('Walking Lunges'), ('Calf Raises (Barbell)'), ('Hip Abduction (Band)'),
  ('Planks'), ('Crunches'), ('Chest Press'), ('Incline Chest Press'), ('Lat Pulldown'),
  ('Push Ups'), ('Front Raises'), ('Lateral Raises'), ('Tricep Pushdown'), ('Tricep Kickback'),
  ('Dumbbell RDLs'), ('Cable Kickback'), ('Laying Hamstring Curl'), ('Step Up'), ('Jump Squats'),
  ('Cable Leg Lateral Raises'), ('Calf Raises (Dumbbells)'), ('Russian Twist'), ('Face Pull'),
  ('Reverse Pec Deck'), ('Bicep Curl (Barbell)'), ('Bicep Curl (Dumbbells)'), ('Hammer Curl'),
  ('Escalera')
) as v(name)
where not exists (
  select 1 from public.exercises e where lower(trim(e.name)) = lower(trim(v.name))
);

insert into public.workouts (client_id, name)
select client_id, v.name
from _gixallys, (values
  ('Day 1 - Lower Body (Quads & Glutes)'),
  ('Day 2 - Upper Body (Push)'),
  ('Day 3 - Lower Body (Hamstrings & Glutes)'),
  ('Day 4 - Upper Body (Pull)'),
  ('Day 5 - Cardio (2x/week, flexible days)')
) as v(name)
where not exists (
  select 1 from public.workouts w where w.client_id = _gixallys.client_id and w.name = v.name
);

insert into public.workout_exercises (workout_id, exercise_id, sets, target_reps, order_index)
select w.id, e.id, x.sets, x.target_reps, x.order_index
from (values
  ('Day 1 - Lower Body (Quads & Glutes)', 'Deadlift', 4, '[Workout] 8', 1),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Goblet Squats', 4, '[Workout] 10', 2),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Bulgarian Split Squats', 3, '[Workout] 10 c/lado', 3),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Hip Thrust', 4, '[Workout] 12', 4),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Leg Extension', 3, '[Workout] 12', 5),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Walking Lunges', 3, '[Workout] 10 c/lado', 6),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Calf Raises (Barbell)', 4, '[Workout] 12', 7),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Hip Abduction (Band)', 3, '[Workout] 15', 8),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Planks', 3, '[Core] 45s', 9),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Crunches', 3, '[Core] 15', 10),
  ('Day 1 - Lower Body (Quads & Glutes)', 'Escalera', 1, '[Cardio] 15 min incline/caminadora, opcional', 11),

  ('Day 2 - Upper Body (Push)', 'Chest Press', 4, '[Workout] 8', 1),
  ('Day 2 - Upper Body (Push)', 'Incline Chest Press', 4, '[Workout] 10', 2),
  ('Day 2 - Upper Body (Push)', 'Lat Pulldown', 4, '[Workout] 10', 3),
  ('Day 2 - Upper Body (Push)', 'Push Ups', 3, '[Workout] 15', 4),
  ('Day 2 - Upper Body (Push)', 'Front Raises', 3, '[Workout] 12', 5),
  ('Day 2 - Upper Body (Push)', 'Lateral Raises', 3, '[Workout] 15', 6),
  ('Day 2 - Upper Body (Push)', 'Tricep Pushdown', 4, '[Workout] 10', 7),
  ('Day 2 - Upper Body (Push)', 'Tricep Kickback', 3, '[Workout] 15 c/lado', 8),
  ('Day 2 - Upper Body (Push)', 'Planks', 3, '[Core] 45s', 9),
  ('Day 2 - Upper Body (Push)', 'Crunches', 3, '[Core] 15', 10),
  ('Day 2 - Upper Body (Push)', 'Escalera', 1, '[Cardio] 15 min incline/caminadora, opcional', 11),

  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Dumbbell RDLs', 4, '[Workout] 10', 1),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Hip Thrust', 4, '[Workout] 12', 2),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Cable Kickback', 3, '[Workout] 12 c/lado', 3),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Laying Hamstring Curl', 3, '[Workout] 12', 4),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Step Up', 3, '[Workout] 10 c/lado', 5),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Jump Squats', 3, '[Workout] 15', 6),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Cable Leg Lateral Raises', 3, '[Workout] 15 c/lado', 7),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Calf Raises (Dumbbells)', 4, '[Workout] 15', 8),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Russian Twist', 3, '[Core] 20 c/lado', 9),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Planks', 3, '[Core] 45s', 10),
  ('Day 3 - Lower Body (Hamstrings & Glutes)', 'Escalera', 1, '[Cardio] 15 min incline/caminadora, opcional', 11),

  ('Day 4 - Upper Body (Pull)', 'Lat Pulldown', 4, '[Workout] 10', 1),
  ('Day 4 - Upper Body (Pull)', 'Face Pull', 4, '[Workout] 15', 2),
  ('Day 4 - Upper Body (Pull)', 'Reverse Pec Deck', 3, '[Workout] 12', 3),
  ('Day 4 - Upper Body (Pull)', 'Bicep Curl (Barbell)', 4, '[Workout] 8', 4),
  ('Day 4 - Upper Body (Pull)', 'Bicep Curl (Dumbbells)', 3, '[Workout] 12', 5),
  ('Day 4 - Upper Body (Pull)', 'Hammer Curl', 3, '[Workout] 12', 6),
  ('Day 4 - Upper Body (Pull)', 'Push Ups', 3, '[Workout] 12', 7),
  ('Day 4 - Upper Body (Pull)', 'Tricep Pushdown', 3, '[Workout] 12', 8),
  ('Day 4 - Upper Body (Pull)', 'Russian Twist', 3, '[Core] 20 c/lado', 9),
  ('Day 4 - Upper Body (Pull)', 'Planks', 3, '[Core] 45s', 10),
  ('Day 4 - Upper Body (Pull)', 'Escalera', 1, '[Cardio] 15 min incline/caminadora, opcional', 11),

  ('Day 5 - Cardio (2x/week, flexible days)', 'Escalera', 1, '[Cardio] 25-30 min, paso moderado — 2x por semana en días sin pesas', 1)
) as x(day_name, exercise_name, sets, target_reps, order_index)
join public.workouts w on w.client_id = (select client_id from _gixallys) and w.name = x.day_name
join public.exercises e on lower(trim(e.name)) = lower(trim(x.exercise_name))
where not exists (
  select 1 from public.workout_exercises we2
  where we2.workout_id = w.id and we2.order_index = x.order_index
);

-- Nutrition targets (lactose intolerant — handled in her meal plan, not here)
update public.nutrition_targets
set calories = 1950, protein_g = 140, carbs_g = 200, fat_g = 65
where user_id = (select client_id from _gixallys);

-- Confirm: full plan with sets/reps and whether each exercise has video linked.
select w.name as day, e.name as exercise, we.sets, we.target_reps, we.order_index,
       (e.video_url is not null) as has_video
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
where w.client_id = (select client_id from _gixallys)
order by w.name, we.order_index;

select calories, protein_g, carbs_g, fat_g from public.nutrition_targets
where user_id = (select client_id from _gixallys);
