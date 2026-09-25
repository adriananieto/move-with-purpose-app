-- José Llama's Fase 1 training plan: 3 días de fuerza + 2 cardio (Upper → Cardio →
-- Lower → Cardio → Upper). All exercises reused from the existing video-linked
-- catalog — no duplicates created. Meta: bajar de 195 a 185 lb manteniendo músculo.
-- Run create_client_jose.sql FIRST. Safe to re-run.

drop table if exists _jose;
create temporary table _jose as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'josellama2014@gmail.com';

do $$
begin
  if (select count(*) from _jose) = 0 then
    raise exception 'No profile matched that email. Run create_client_jose.sql first, or check the address.';
  end if;
end $$;

-- Reuses existing video-linked exercises; only creates a catalog row (no video)
-- for anything that isn't already there.
insert into public.exercises (name, video_url)
select v.name, null
from (values
  ('Chest Press'), ('Incline Chest Press'), ('Push Ups'), ('Lateral Raises'),
  ('Tricep Pushdown'), ('Reverse Pec Deck'), ('Planks'), ('Russian Twist'),
  ('Goblet Squats'), ('Deadlift'), ('Bulgarian Split Squats'), ('Leg Press'),
  ('Laying Hamstring Curl'), ('Calf Raises (Barbell)'), ('Crunches'), ('Lat Pulldown'),
  ('Face Pull'), ('Bicep Curl (Barbell)'), ('Bicep Curl (Dumbbells)'), ('Hammer Curl'),
  ('Cardio')
) as v(name)
where not exists (
  select 1 from public.exercises e where lower(trim(e.name)) = lower(trim(v.name))
);

insert into public.workouts (client_id, name)
select client_id, v.name
from _jose, (values
  ('Día 1 - Upper Body (Push)'),
  ('Día 2 - Cardio'),
  ('Día 3 - Lower Body (Full)'),
  ('Día 4 - Cardio'),
  ('Día 5 - Upper Body (Pull)')
) as v(name)
where not exists (
  select 1 from public.workouts w where w.client_id = _jose.client_id and w.name = v.name
);

-- Clear his existing plan first so edits (like this one) always take effect on
-- re-run, instead of being silently skipped because a row already sits at that
-- order_index.
delete from public.workout_exercises where workout_id in (
  select id from public.workouts where client_id = (select client_id from _jose)
);

insert into public.workout_exercises (workout_id, exercise_id, sets, target_reps, order_index)
select w.id, e.id, x.sets, x.target_reps, x.order_index
from (values
  ('Día 1 - Upper Body (Push)', 'Chest Press', 4, '[Workout] 10', 1),
  ('Día 1 - Upper Body (Push)', 'Incline Chest Press', 3, '[Workout] 10', 2),
  ('Día 1 - Upper Body (Push)', 'Push Ups', 3, '[Workout] 15', 3),
  ('Día 1 - Upper Body (Push)', 'Lateral Raises', 3, '[Workout] 15', 4),
  ('Día 1 - Upper Body (Push)', 'Tricep Pushdown', 4, '[Workout] 12', 5),
  ('Día 1 - Upper Body (Push)', 'Reverse Pec Deck', 3, '[Workout] 12', 6),
  ('Día 1 - Upper Body (Push)', 'Planks', 3, '[Core] 45s', 7),
  ('Día 1 - Upper Body (Push)', 'Russian Twist', 3, '[Core] 20 c/lado', 8),

  ('Día 2 - Cardio', 'Cardio', 1, '[Cardio] 25-30 min, paso moderado', 1),

  ('Día 3 - Lower Body (Full)', 'Goblet Squats', 4, '[Workout] 10', 1),
  ('Día 3 - Lower Body (Full)', 'Deadlift', 4, '[Workout] 8', 2),
  ('Día 3 - Lower Body (Full)', 'Bulgarian Split Squats', 3, '[Workout] 10 c/lado', 3),
  ('Día 3 - Lower Body (Full)', 'Leg Press', 4, '[Workout] 12', 4),
  ('Día 3 - Lower Body (Full)', 'Laying Hamstring Curl', 3, '[Workout] 12', 5),
  ('Día 3 - Lower Body (Full)', 'Calf Raises (Barbell)', 4, '[Workout] 12', 6),
  ('Día 3 - Lower Body (Full)', 'Planks', 3, '[Core] 45s', 7),
  ('Día 3 - Lower Body (Full)', 'Crunches', 3, '[Core] 15', 8),

  ('Día 4 - Cardio', 'Cardio', 1, '[Cardio] 25-30 min, paso moderado', 1),

  ('Día 5 - Upper Body (Pull)', 'Lat Pulldown', 4, '[Workout] 10', 1),
  ('Día 5 - Upper Body (Pull)', 'Face Pull', 4, '[Workout] 15', 2),
  ('Día 5 - Upper Body (Pull)', 'Bicep Curl (Barbell)', 4, '[Workout] 10', 3),
  ('Día 5 - Upper Body (Pull)', 'Bicep Curl (Dumbbells)', 3, '[Workout] 12', 4),
  ('Día 5 - Upper Body (Pull)', 'Hammer Curl', 3, '[Workout] 12', 5),
  ('Día 5 - Upper Body (Pull)', 'Tricep Pushdown', 3, '[Workout] 12', 6),
  ('Día 5 - Upper Body (Pull)', 'Russian Twist', 3, '[Core] 20 c/lado', 7),
  ('Día 5 - Upper Body (Pull)', 'Planks', 3, '[Core] 45s', 8)
) as x(day_name, exercise_name, sets, target_reps, order_index)
join public.workouts w on w.client_id = (select client_id from _jose) and w.name = x.day_name
join public.exercises e on lower(trim(e.name)) = lower(trim(x.exercise_name));

update public.nutrition_targets
set calories = 2250, protein_g = 190, carbs_g = 210, fat_g = 65
where user_id = (select client_id from _jose);

-- Confirm: full plan with sets/reps and whether each exercise has video linked.
select w.name as day, e.name as exercise, we.sets, we.target_reps, we.order_index,
       (e.video_url is not null) as has_video
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
where w.client_id = (select client_id from _jose)
order by w.name, we.order_index;

select calories, protein_g, carbs_g, fat_g from public.nutrition_targets
where user_id = (select client_id from _jose);
