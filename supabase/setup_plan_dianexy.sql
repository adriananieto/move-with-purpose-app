-- Dianexy Falcon Nieves's training plan ("Ruptura de Plateau" phase), from
-- "MOVE_WITH_PURPOSE_DIANEXY_FINAL.pdf" — 5 días (Lower/Upper/Lower/Upper/Lower),
-- fuerza en rangos bajos (6-8) para romper el plateau.
-- Run create_client_dianexy.sql FIRST. Safe to re-run (deletes and rebuilds her
-- plan each time, so edits always take effect).

drop table if exists _dianexy;
create temporary table _dianexy as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'dianexy.nieves@gmail.com';

do $$
begin
  if (select count(*) from _dianexy) = 0 then
    raise exception 'No profile matched that email. Run create_client_dianexy.sql first, or check the address.';
  end if;
end $$;

insert into public.exercises (name, video_url)
select v.name, null
from (values
  ('Escalera'), ('Hip Thrust'), ('Squats'), ('Bulgarian Split Squats'), ('Leg Curl'),
  ('Cable Kickback'), ('Calf Raises'), ('Planks'), ('Side Plank'),
  ('Arnold Press'), ('Lateral Raises'), ('Front Raises'), ('Face Pull'), ('Reverse Pec Deck'),
  ('Bicep Curl'), ('Hammer Curl'), ('Crunches'), ('Russian Twist'), ('Deadlift'),
  ('Walking Lunges'), ('Jump Squats'), ('Lat Pulldown'), ('Chest Press'),
  ('Tricep Pushdown'), ('Overhead Tricep Extension'),
  ('Push Ups'), ('Hip Abduction (Band)'), ('Sumo Squats')
) as v(name)
where not exists (
  select 1 from public.exercises e where lower(trim(e.name)) = lower(trim(v.name))
);

-- Clear her existing workouts/exercises so re-running always reflects edits.
delete from public.workout_exercises where workout_id in (
  select id from public.workouts where client_id = (select client_id from _dianexy)
);
delete from public.workouts where client_id = (select client_id from _dianexy);

insert into public.workouts (client_id, name)
select client_id, v.name
from _dianexy, (values
  ('Día 1 - Lower Body (Fuerza)'),
  ('Día 2 - Upper Body'),
  ('Día 3 - Lower Body (Fuerza)'),
  ('Día 4 - Upper Body'),
  ('Día 5 - Lower Body')
) as v(name);

insert into public.workout_exercises (workout_id, exercise_id, sets, target_reps, order_index)
select w.id, e.id, x.sets, x.target_reps, x.order_index
from (values
  ('Día 1 - Lower Body (Fuerza)', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Día 1 - Lower Body (Fuerza)', 'Hip Thrust', 4, '[Workout] 6-8, subir carga', 2),
  ('Día 1 - Lower Body (Fuerza)', 'Squats', 4, '[Workout] 6-8, subir carga', 3),
  ('Día 1 - Lower Body (Fuerza)', 'Bulgarian Split Squats', 3, '[Workout] 10 c/lado', 4),
  ('Día 1 - Lower Body (Fuerza)', 'Leg Curl', 3, '[Workout] 15, acostada', 5),
  ('Día 1 - Lower Body (Fuerza)', 'Cable Kickback', 3, '[Workout] 10 c/lado', 6),
  ('Día 1 - Lower Body (Fuerza)', 'Jump Squats', 3, '[Workout] 10', 7),
  ('Día 1 - Lower Body (Fuerza)', 'Calf Raises', 3, '[Workout] 15', 8),
  ('Día 1 - Lower Body (Fuerza)', 'Planks', 3, '[Core] 1 min', 9),
  ('Día 1 - Lower Body (Fuerza)', 'Side Plank', 3, '[Core] 30s', 10),
  ('Día 1 - Lower Body (Fuerza)', 'Escalera', 1, '[Cardio] 12 min intervalos (1 min alto / 1 min moderado), caminadora inclinada', 11),

  ('Día 2 - Upper Body', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Día 2 - Upper Body', 'Arnold Press', 3, '[Workout] 12', 2),
  ('Día 2 - Upper Body', 'Lateral Raises', 3, '[Workout] 10', 3),
  ('Día 2 - Upper Body', 'Front Raises', 3, '[Workout] 10', 4),
  ('Día 2 - Upper Body', 'Face Pull', 3, '[Workout] 15', 5),
  ('Día 2 - Upper Body', 'Reverse Pec Deck', 3, '[Workout] 12', 6),
  ('Día 2 - Upper Body', 'Bicep Curl', 3, '[Workout] 12', 7),
  ('Día 2 - Upper Body', 'Hammer Curl', 3, '[Workout] 10', 8),
  ('Día 2 - Upper Body', 'Crunches', 3, '[Core] 15, con peso', 9),
  ('Día 2 - Upper Body', 'Russian Twist', 3, '[Core] 10 c/lado, con peso', 10),
  ('Día 2 - Upper Body', 'Escalera', 1, '[Cardio] 25 min, caminadora inclinada, pace moderado', 11),

  ('Día 3 - Lower Body (Fuerza)', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Día 3 - Lower Body (Fuerza)', 'Squats', 4, '[Workout] 6-8, subir carga', 2),
  ('Día 3 - Lower Body (Fuerza)', 'Hip Thrust', 4, '[Workout] 6-8, subir carga', 3),
  ('Día 3 - Lower Body (Fuerza)', 'Cable Kickback', 3, '[Workout] 10 c/lado', 4),
  ('Día 3 - Lower Body (Fuerza)', 'Deadlift', 3, '[Workout] 10, con dumbbells, subir carga', 5),
  ('Día 3 - Lower Body (Fuerza)', 'Walking Lunges', 3, '[Workout] 10 c/pierna', 6),
  ('Día 3 - Lower Body (Fuerza)', 'Jump Squats', 3, '[Workout] 10', 7),
  ('Día 3 - Lower Body (Fuerza)', 'Calf Raises', 3, '[Workout] 15', 8),
  ('Día 3 - Lower Body (Fuerza)', 'Planks', 3, '[Core] 1 min', 9),
  ('Día 3 - Lower Body (Fuerza)', 'Side Plank', 3, '[Core] 30s', 10),
  ('Día 3 - Lower Body (Fuerza)', 'Escalera', 1, '[Cardio] 12 min intervalos (1 min alto / 1 min moderado), caminadora inclinada', 11),

  ('Día 4 - Upper Body', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Día 4 - Upper Body', 'Lat Pulldown', 3, '[Workout] 12', 2),
  ('Día 4 - Upper Body', 'Face Pull', 3, '[Workout] 12', 3),
  ('Día 4 - Upper Body', 'Chest Press', 3, '[Workout] 15', 4),
  ('Día 4 - Upper Body', 'Tricep Pushdown', 3, '[Workout] 15, cuerda', 5),
  ('Día 4 - Upper Body', 'Overhead Tricep Extension', 3, '[Workout] 12, dumbbell', 6),
  ('Día 4 - Upper Body', 'Push Ups', 3, '[Workout] 12', 7),
  ('Día 4 - Upper Body', 'Calf Raises', 3, '[Workout] 15', 8),
  ('Día 4 - Upper Body', 'Crunches', 3, '[Core] 15, con peso', 9),
  ('Día 4 - Upper Body', 'Russian Twist', 3, '[Core] 10 c/lado, con peso', 10),
  ('Día 4 - Upper Body', 'Escalera', 1, '[Cardio] 25 min, caminadora inclinada, pace moderado', 11),

  ('Día 5 - Lower Body', 'Escalera', 1, '[Warm Up] 10 min, pace moderado', 1),
  ('Día 5 - Lower Body', 'Hip Thrust', 4, '[Workout] 10', 2),
  ('Día 5 - Lower Body', 'Squats', 4, '[Workout] 10', 3),
  ('Día 5 - Lower Body', 'Cable Kickback', 3, '[Workout] 10 c/lado', 4),
  ('Día 5 - Lower Body', 'Jump Squats', 3, '[Workout] 15', 5),
  ('Día 5 - Lower Body', 'Hip Abduction (Band)', 3, '[Workout] 15', 6),
  ('Día 5 - Lower Body', 'Sumo Squats', 3, '[Workout] 10', 7),
  ('Día 5 - Lower Body', 'Calf Raises', 3, '[Workout] 15', 8),
  ('Día 5 - Lower Body', 'Planks', 3, '[Core] 1 min', 9),
  ('Día 5 - Lower Body', 'Side Plank', 3, '[Core] 30s', 10),
  ('Día 5 - Lower Body', 'Escalera', 1, '[Cardio] 15 min, caminadora inclinada, pace moderado', 11)
) as x(day_name, exercise_name, sets, target_reps, order_index)
join public.workouts w on w.client_id = (select client_id from _dianexy) and w.name = x.day_name
join public.exercises e on lower(trim(e.name)) = lower(trim(x.exercise_name));

select w.name as day, e.name as exercise, we.sets, we.target_reps, we.order_index,
       (e.video_url is not null) as has_video
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
where w.client_id = (select client_id from _dianexy)
order by w.name, we.order_index;
