-- Natalia Nieto's training plan — exact same plan as Karen J Rodriguez Navarro,
-- per Adriana's instruction.
--
-- Run create_client_natalia.sql FIRST. Safe to re-run.

drop table if exists _natalia;
create temporary table _natalia as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'natalia.nieto5@gmail.com';

do $$
begin
  if (select count(*) from _natalia) = 0 then
    raise exception 'No profile matched that email. Run create_client_natalia.sql first, or check the address.';
  end if;
end $$;

insert into public.exercises (name, video_url)
select v.name, null
from (values
  ('Squats'), ('Deadlift'), ('Hip Thrust'), ('Cable Kickback'), ('Cable Leg Lateral Raises'),
  ('Walking Lunges'), ('Leg Curl'), ('Calf Raises'), ('Crunches'),
  ('Russian Twist'), ('Escalera'), ('Plank Shoulder Taps'), ('Lat Pulldown'),
  ('Seated Row (Machine)'), ('Reverse Pec Deck'), ('Face Pull'), ('Bicep Curl'), ('Hammer Curl'),
  ('Push Ups'), ('Planks'), ('Goblet Squats'), ('Glute Bridge (Band)'), ('Leg Extension'),
  ('Jump Squats'), ('Shoulder Press'), ('Lateral Raises'), ('Front Raises'),
  ('Overhead Tricep Extension'), ('Tricep Kickback')
) as v(name)
where not exists (
  select 1 from public.exercises e where lower(trim(e.name)) = lower(trim(v.name))
);

insert into public.workouts (client_id, name)
select client_id, v.name
from _natalia, (values
  ('Día 1 - Lower Body'),
  ('Día 2 - Upper Body'),
  ('Día 3 - Lower Body'),
  ('Día 4 - Upper Body'),
  ('Día 5 - Lower Body')
) as v(name)
where not exists (
  select 1 from public.workouts w where w.client_id = _natalia.client_id and w.name = v.name
);

insert into public.workout_exercises (workout_id, exercise_id, sets, target_reps, order_index)
select w.id, e.id, x.sets, x.target_reps, x.order_index
from (values
  ('Día 1 - Lower Body', 'Escalera', 1, '[Warm Up] 10 min, caminata inclinada, ritmo constante', 1),
  ('Día 1 - Lower Body', 'Squats', 3, '[Warm Up] 10, sin peso', 2),
  ('Día 1 - Lower Body', 'Squats', 4, '[Workout] 8', 3),
  ('Día 1 - Lower Body', 'Hip Thrust', 4, '[Workout] 10', 4),
  ('Día 1 - Lower Body', 'Cable Kickback', 3, '[Workout] 10 c/lado', 5),
  ('Día 1 - Lower Body', 'Cable Leg Lateral Raises', 3, '[Workout] 10 c/lado', 6),
  ('Día 1 - Lower Body', 'Deadlift', 3, '[Workout] 10', 7),
  ('Día 1 - Lower Body', 'Walking Lunges', 3, '[Workout] 10 c/lado', 8),
  ('Día 1 - Lower Body', 'Leg Curl', 3, '[Workout] 12', 9),
  ('Día 1 - Lower Body', 'Calf Raises', 3, '[Workout] 15', 10),
  ('Día 1 - Lower Body', 'Crunches', 3, '[Core] 15', 11),
  ('Día 1 - Lower Body', 'Russian Twist', 3, '[Core] 10 c/lado', 12),

  ('Día 2 - Upper Body', 'Escalera', 1, '[Warm Up] 10 min, caminata inclinada, ritmo constante', 1),
  ('Día 2 - Upper Body', 'Plank Shoulder Taps', 3, '[Warm Up] 10 c/u', 2),
  ('Día 2 - Upper Body', 'Lat Pulldown', 4, '[Workout] 12', 3),
  ('Día 2 - Upper Body', 'Seated Row (Machine)', 3, '[Workout] 15', 4),
  ('Día 2 - Upper Body', 'Reverse Pec Deck', 3, '[Workout] 15', 5),
  ('Día 2 - Upper Body', 'Face Pull', 3, '[Workout] 15', 6),
  ('Día 2 - Upper Body', 'Bicep Curl', 3, '[Workout] 15', 7),
  ('Día 2 - Upper Body', 'Hammer Curl', 3, '[Workout] 12', 8),
  ('Día 2 - Upper Body', 'Push Ups', 3, '[Workout] 10', 9),
  ('Día 2 - Upper Body', 'Planks', 3, '[Core] 1 min', 10),
  ('Día 2 - Upper Body', 'Russian Twist', 3, '[Core] 10 c/u', 11),
  ('Día 2 - Upper Body', 'Escalera', 1, '[Cardio] 30 min, caminata inclinada, ritmo constante', 12),

  ('Día 3 - Lower Body', 'Escalera', 1, '[Warm Up] 10 min, caminata inclinada, ritmo constante', 1),
  ('Día 3 - Lower Body', 'Squats', 3, '[Warm Up] 10, sin peso', 2),
  ('Día 3 - Lower Body', 'Goblet Squats', 4, '[Workout] 8', 3),
  ('Día 3 - Lower Body', 'Hip Thrust', 4, '[Workout] 10', 4),
  ('Día 3 - Lower Body', 'Cable Kickback', 3, '[Workout] 10 c/lado', 5),
  ('Día 3 - Lower Body', 'Cable Leg Lateral Raises', 3, '[Workout] 10 c/lado', 6),
  ('Día 3 - Lower Body', 'Glute Bridge (Band)', 3, '[Workout] 10', 7),
  ('Día 3 - Lower Body', 'Walking Lunges', 3, '[Workout] 10 c/lado', 8),
  ('Día 3 - Lower Body', 'Leg Extension', 3, '[Workout] 12', 9),
  ('Día 3 - Lower Body', 'Calf Raises', 3, '[Workout] 15', 10),
  ('Día 3 - Lower Body', 'Crunches', 3, '[Core] 15', 11),
  ('Día 3 - Lower Body', 'Russian Twist', 3, '[Core] 10 c/lado', 12),

  ('Día 4 - Upper Body', 'Escalera', 1, '[Warm Up] 10 min, caminata inclinada, ritmo constante', 1),
  ('Día 4 - Upper Body', 'Plank Shoulder Taps', 3, '[Warm Up] 10 c/u', 2),
  ('Día 4 - Upper Body', 'Shoulder Press', 4, '[Workout] 12', 3),
  ('Día 4 - Upper Body', 'Lateral Raises', 3, '[Workout] 15', 4),
  ('Día 4 - Upper Body', 'Front Raises', 3, '[Workout] 10', 5),
  ('Día 4 - Upper Body', 'Face Pull', 3, '[Workout] 15', 6),
  ('Día 4 - Upper Body', 'Overhead Tricep Extension', 3, '[Workout] 15', 7),
  ('Día 4 - Upper Body', 'Tricep Kickback', 3, '[Workout] 10 c/lado', 8),
  ('Día 4 - Upper Body', 'Push Ups', 3, '[Workout] 10', 9),
  ('Día 4 - Upper Body', 'Planks', 3, '[Core] 1 min', 10),
  ('Día 4 - Upper Body', 'Russian Twist', 3, '[Core] 10 c/u', 11),
  ('Día 4 - Upper Body', 'Escalera', 1, '[Cardio] 30 min, caminata inclinada, ritmo constante', 12),

  ('Día 5 - Lower Body', 'Escalera', 1, '[Warm Up] 10 min, caminata inclinada, ritmo constante', 1),
  ('Día 5 - Lower Body', 'Squats', 3, '[Warm Up] 10, sin peso', 2),
  ('Día 5 - Lower Body', 'Squats', 4, '[Workout] 8', 3),
  ('Día 5 - Lower Body', 'Hip Thrust', 4, '[Workout] 10', 4),
  ('Día 5 - Lower Body', 'Cable Kickback', 3, '[Workout] 10 c/lado', 5),
  ('Día 5 - Lower Body', 'Cable Leg Lateral Raises', 3, '[Workout] 10 c/lado', 6),
  ('Día 5 - Lower Body', 'Leg Curl', 3, '[Workout] 10 c/lado', 7),
  ('Día 5 - Lower Body', 'Leg Extension', 3, '[Workout] 12', 8),
  ('Día 5 - Lower Body', 'Jump Squats', 3, '[Workout] 10', 9),
  ('Día 5 - Lower Body', 'Calf Raises', 3, '[Workout] 15', 10),
  ('Día 5 - Lower Body', 'Crunches', 3, '[Core] 15', 11),
  ('Día 5 - Lower Body', 'Russian Twist', 3, '[Core] 10 c/lado', 12)
) as x(day_name, exercise_name, sets, target_reps, order_index)
join public.workouts w on w.client_id = (select client_id from _natalia) and w.name = x.day_name
join public.exercises e on lower(trim(e.name)) = lower(trim(x.exercise_name))
where not exists (
  select 1 from public.workout_exercises we2
  where we2.workout_id = w.id and we2.order_index = x.order_index
);

update public.nutrition_targets
set calories = 1830, protein_g = 140, carbs_g = 205, fat_g = 50
where user_id = (select client_id from _natalia);

select w.name as day, e.name as exercise, we.sets, we.target_reps, we.order_index,
       (e.video_url is not null) as has_video
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
where w.client_id = (select client_id from _natalia)
order by w.name, we.order_index;
