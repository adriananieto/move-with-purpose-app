-- Miriam Navarro Rodriguez's training plan — REPLACES her original PDF-derived
-- plan (which used exercises without video, e.g. Trotadora, Peloton, Glute
-- Bridge) with the same exercise split as Gixallys/Gretchen, all of which already
-- have video. Only the cardio days have no video (expected, per Adriana).
--
-- Same weekly shape as Gretchen: 3x presencial (Lun/Mié/Vie) + cardio Mar/Jue,
-- but 30 min cardio instead of 20-25:
--   Día 1 (Lun) = Lower (Quads & Glutes) — Gixallys Día 1
--   Día 2 (Mar) = Cardio, 30 min
--   Día 3 (Mié) = Upper (Push) — Gixallys Día 2
--   Día 4 (Jue) = Cardio, 30 min
--   Día 5 (Vie) = Full Body — same 4 lower + 4 upper + core mix used for Gretchen
--
-- Run create_client_miriam.sql FIRST if you haven't already. Safe to re-run.

drop table if exists _miriam;
create temporary table _miriam as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'mimanavarro@gmail.com';

do $$
begin
  if (select count(*) from _miriam) = 0 then
    raise exception 'No profile matched that email. Run create_client_miriam.sql first, or check the address.';
  end if;
end $$;

-- Remove her old plan entirely (different exercises, several without video).
delete from public.workout_exercises where workout_id in (
  select id from public.workouts where client_id = (select client_id from _miriam)
);
delete from public.workouts where client_id = (select client_id from _miriam);

-- Should already exist from Gixallys/Gretchen/Melissa — insert-if-missing kept for safety.
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
from _miriam, (values
  ('Día 1 (Lunes) - Lower Body (Quads & Glutes)'),
  ('Día 2 (Martes) - Cardio'),
  ('Día 3 (Miércoles) - Upper Body (Push)'),
  ('Día 4 (Jueves) - Cardio'),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)')
) as v(name);

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

  ('Día 2 (Martes) - Cardio', 'Escalera', 1, '[Cardio] 30 min, paso moderado', 1),

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

  ('Día 4 (Jueves) - Cardio', 'Escalera', 1, '[Cardio] 30 min, paso moderado', 1),

  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Dumbbell RDLs', 4, '[Workout] 10', 1),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Hip Thrust', 4, '[Workout] 12', 2),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Step Up', 3, '[Workout] 10 c/lado', 3),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Jump Squats', 3, '[Workout] 15', 4),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Lat Pulldown', 4, '[Workout] 10', 5),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Bicep Curl (Barbell)', 4, '[Workout] 8', 6),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Push Ups', 3, '[Workout] 12', 7),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Tricep Pushdown', 3, '[Workout] 12', 8),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Russian Twist', 3, '[Core] 20 c/lado', 9),
  ('Día 5 (Viernes) - Full Body (Lower + Pull)', 'Planks', 3, '[Core] 45s', 10)
) as x(day_name, exercise_name, sets, target_reps, order_index)
join public.workouts w on w.client_id = (select client_id from _miriam) and w.name = x.day_name
join public.exercises e on lower(trim(e.name)) = lower(trim(x.exercise_name));

update public.nutrition_targets
set calories = 1650, protein_g = 115, carbs_g = 175, fat_g = 55
where user_id = (select client_id from _miriam);

-- Confirm: every non-cardio exercise should show has_video = true.
select w.name as day, e.name as exercise, we.sets, we.target_reps, we.order_index,
       (e.video_url is not null) as has_video
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
where w.client_id = (select client_id from _miriam)
order by w.name, we.order_index;
