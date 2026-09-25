-- Myrna Camacho's training plan.
-- Same structure as Gretchen (3x presencial Lun/Mié/Vie + cardio Mar/Jue), but her
-- 3rd presencial day is a SECOND lower day instead of full body:
--   Día 1 (Lun) = Lower (Quads & Glutes) — same as Gixallys/Gretchen Día 1
--   Día 2 (Mar) = Cardio
--   Día 3 (Mié) = Upper (Push) — same as Gixallys/Gretchen Día 3
--   Día 4 (Jue) = Cardio
--   Día 5 (Vie) = Lower (Hamstrings & Glutes) — same as Gixallys Día 3, full 8+2
--
-- Run create_client_myrna.sql FIRST. Safe to re-run.

drop table if exists _myrna;
create temporary table _myrna as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'myrnidmd@gmail.com';

do $$
begin
  if (select count(*) from _myrna) = 0 then
    raise exception 'No profile matched that email. Run create_client_myrna.sql first, or check the address.';
  end if;
end $$;

-- Should already exist from Gixallys/Gretchen — insert-if-missing kept for safety.
insert into public.exercises (name, video_url)
select v.name, null
from (values
  ('Deadlift'), ('Goblet Squats'), ('Bulgarian Split Squats'), ('Hip Thrust'),
  ('Leg Extension'), ('Walking Lunges'), ('Calf Raises (Barbell)'), ('Hip Abduction (Band)'),
  ('Planks'), ('Crunches'), ('Chest Press'), ('Incline Chest Press'), ('Lat Pulldown'),
  ('Push Ups'), ('Front Raises'), ('Lateral Raises'), ('Tricep Pushdown'), ('Tricep Kickback'),
  ('Dumbbell RDLs'), ('Cable Kickback'), ('Laying Hamstring Curl'), ('Step Up'), ('Jump Squats'),
  ('Cable Leg Lateral Raises'), ('Calf Raises (Dumbbells)'), ('Russian Twist'), ('Escalera')
) as v(name)
where not exists (
  select 1 from public.exercises e where lower(trim(e.name)) = lower(trim(v.name))
);

insert into public.workouts (client_id, name)
select client_id, v.name
from _myrna, (values
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)'),
  ('Día 2 (Martes) - Cardio'),
  ('Día 3 (Miércoles) - Upper Body (Push)'),
  ('Día 4 (Jueves) - Cardio'),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)')
) as v(name)
where not exists (
  select 1 from public.workouts w where w.client_id = _myrna.client_id and w.name = v.name
);

insert into public.workout_exercises (workout_id, exercise_id, sets, target_reps, order_index)
select w.id, e.id, x.sets, x.target_reps, x.order_index
from (values
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Deadlift', 4, '[Workout] 8', 1),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Goblet Squats', 4, '[Workout] 10', 2),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Bulgarian Split Squats', 3, '[Workout] 10 c/lado', 3),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Hip Thrust', 4, '[Workout] 12', 4),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Leg Extension', 3, '[Workout] 12', 5),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Walking Lunges', 3, '[Workout] 10 c/lado', 6),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Calf Raises (Barbell)', 4, '[Workout] 12', 7),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Hip Abduction (Band)', 3, '[Workout] 15', 8),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Planks', 3, '[Core] 45s', 9),
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)', 'Crunches', 3, '[Core] 15', 10),

  ('Día 2 (Martes) - Cardio', 'Escalera', 1, '[Cardio] 20-25 min, paso moderado', 1),

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

  ('Día 4 (Jueves) - Cardio', 'Escalera', 1, '[Cardio] 20-25 min, paso moderado', 1),

  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Dumbbell RDLs', 4, '[Workout] 10', 1),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Hip Thrust', 4, '[Workout] 12', 2),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Cable Kickback', 3, '[Workout] 12 c/lado', 3),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Laying Hamstring Curl', 3, '[Workout] 12', 4),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Step Up', 3, '[Workout] 10 c/lado', 5),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Jump Squats', 3, '[Workout] 15', 6),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Cable Leg Lateral Raises', 3, '[Workout] 15 c/lado', 7),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Calf Raises (Dumbbells)', 4, '[Workout] 15', 8),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Russian Twist', 3, '[Core] 20 c/lado', 9),
  ('Día 5 (Viernes) - Lower Body (Hamstrings & Glutes)', 'Planks', 3, '[Core] 45s', 10)
) as x(day_name, exercise_name, sets, target_reps, order_index)
join public.workouts w on w.client_id = (select client_id from _myrna) and w.name = x.day_name
join public.exercises e on lower(trim(e.name)) = lower(trim(x.exercise_name))
where not exists (
  select 1 from public.workout_exercises we2
  where we2.workout_id = w.id and we2.order_index = x.order_index
);

update public.nutrition_targets
set calories = 1850, protein_g = 145, carbs_g = 170, fat_g = 55
where user_id = (select client_id from _myrna);

select w.name as day, e.name as exercise, we.sets, we.target_reps, we.order_index
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
where w.client_id = (select client_id from _myrna)
order by w.name, we.order_index;
