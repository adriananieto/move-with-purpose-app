-- Melissa Hernandez's training plan.
-- Per Adriana: same exercise split as Gixallys/Gretchen (not the PDF's own training
-- section), mapped to her Tue/Wed/Thu presencial schedule + Mon/Fri cardio:
--   Día 1 (Lun) = Cardio
--   Día 2 (Mar) = Gixallys Día 1 (Lower - Quads & Glutes)
--   Día 3 (Mié) = Gixallys Día 2 (Upper - Push)
--   Día 4 (Jue) = Full Body — same 8-exercise Lower+Pull mix used for Gretchen's
--                 Friday (4 lower + 4 upper + core)
--   Día 5 (Vie) = Cardio
--
-- Run create_client_melissa.sql FIRST. Safe to re-run.

drop table if exists _melissa;
create temporary table _melissa as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'hernandez.casanova39@gmail.com';

do $$
begin
  if (select count(*) from _melissa) = 0 then
    raise exception 'No profile matched that email. Run create_client_melissa.sql first, or check the address.';
  end if;
end $$;

-- Should already exist from Gixallys/Gretchen/Myrna — insert-if-missing kept for safety.
insert into public.exercises (name, video_url)
select v.name, null
from (values
  ('Deadlift'), ('Goblet Squats'), ('Bulgarian Split Squats'), ('Hip Thrust'),
  ('Leg Extension'), ('Walking Lunges'), ('Calf Raises (Barbell)'), ('Hip Abduction (Band)'),
  ('Planks'), ('Crunches'), ('Chest Press'), ('Incline Chest Press'), ('Lat Pulldown'),
  ('Push Ups'), ('Front Raises'), ('Lateral Raises'), ('Tricep Pushdown'), ('Tricep Kickback'),
  ('Dumbbell RDLs'), ('Step Up'), ('Jump Squats'), ('Bicep Curl (Barbell)'), ('Russian Twist'),
  ('Escalera')
) as v(name)
where not exists (
  select 1 from public.exercises e where lower(trim(e.name)) = lower(trim(v.name))
);

insert into public.workouts (client_id, name)
select client_id, v.name
from _melissa, (values
  ('Día 1 (Lunes) - Cardio'),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)'),
  ('Día 3 (Miércoles) - Upper Body (Push)'),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)'),
  ('Día 5 (Viernes) - Cardio')
) as v(name)
where not exists (
  select 1 from public.workouts w where w.client_id = _melissa.client_id and w.name = v.name
);

insert into public.workout_exercises (workout_id, exercise_id, sets, target_reps, order_index)
select w.id, e.id, x.sets, x.target_reps, x.order_index
from (values
  ('Día 1 (Lunes) - Cardio', 'Escalera', 1, '[Cardio] 20-25 min, paso moderado', 1),

  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Deadlift', 4, '[Workout] 8', 1),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Goblet Squats', 4, '[Workout] 10', 2),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Bulgarian Split Squats', 3, '[Workout] 10 c/lado', 3),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Hip Thrust', 4, '[Workout] 12', 4),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Leg Extension', 3, '[Workout] 12', 5),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Walking Lunges', 3, '[Workout] 10 c/lado', 6),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Calf Raises (Barbell)', 4, '[Workout] 12', 7),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Hip Abduction (Band)', 3, '[Workout] 15', 8),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Planks', 3, '[Core] 45s', 9),
  ('Día 2 (Martes) - Lower Body (Quads & Glutes)', 'Crunches', 3, '[Core] 15', 10),

  ('Día 3 (Miércoles) - Upper Body (Push)', 'Chest Press', 4, '[Workout] 8', 1),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Incline Chest Press', 4, '[Workout] 10', 2),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Lat Pulldown', 4, '[Workout] 10', 3),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Push Ups', 3, '[Workout] 15', 4),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Front Raises', 3, '[Workout] 12', 5),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Lateral Raises', 3, '[Workout] 15', 6),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Tricep Pushdown', 4, '[Workout] 10', 7),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Tricep Kickback', 3, '[Workout] 15 c/lado', 8),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Planks', 3, '[Core] 45s', 9),
  ('Día 3 (Miércoles) - Upper Body (Push)', 'Crunches', 3, '[Core] 15', 10),

  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Dumbbell RDLs', 4, '[Workout] 10', 1),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Hip Thrust', 4, '[Workout] 12', 2),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Step Up', 3, '[Workout] 10 c/lado', 3),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Jump Squats', 3, '[Workout] 15', 4),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Lat Pulldown', 4, '[Workout] 10', 5),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Bicep Curl (Barbell)', 4, '[Workout] 8', 6),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Push Ups', 3, '[Workout] 12', 7),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Tricep Pushdown', 3, '[Workout] 12', 8),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Russian Twist', 3, '[Core] 20 c/lado', 9),
  ('Día 4 (Jueves) - Full Body (Lower + Pull)', 'Planks', 3, '[Core] 45s', 10),

  ('Día 5 (Viernes) - Cardio', 'Escalera', 1, '[Cardio] 20-25 min, paso moderado', 1)
) as x(day_name, exercise_name, sets, target_reps, order_index)
join public.workouts w on w.client_id = (select client_id from _melissa) and w.name = x.day_name
join public.exercises e on lower(trim(e.name)) = lower(trim(x.exercise_name))
where not exists (
  select 1 from public.workout_exercises we2
  where we2.workout_id = w.id and we2.order_index = x.order_index
);

update public.nutrition_targets
set calories = 1700, protein_g = 130, carbs_g = 190, fat_g = 45
where user_id = (select client_id from _melissa);

select w.name as day, e.name as exercise, we.sets, we.target_reps, we.order_index
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
where w.client_id = (select client_id from _melissa)
order by w.name, we.order_index;
