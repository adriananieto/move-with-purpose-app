-- Links the second batch of uploaded videos to their exercises rows.
-- Safe to re-run.

update public.exercises e
set video_url = 'https://yaqiwakfoeaknmdgyzrl.supabase.co/storage/v1/object/public/exercise-videos/' || replace(v.filename, ' ', '%20')
from (values
  ('Cable Kickback', 'CABLE KICKBACK.mov'),
  ('Dumbbell RDLs', 'ROMANIAN DEADLIFT CON DUMBBELLS.mov'),
  ('Laying Hamstring Curl', 'LEG CURL ACOSTADO.mov'),
  ('Crunches', 'CRUNCHES.mov'),
  ('Overhead Tricep Extension', 'OVERHEAD TRICEP EXTENSION.mov'),
  ('Bulgarian Split Squats', 'BULGARIAN SPLIT SQUATS.mov'),
  ('Goblet Squats', 'GOBLET SQUAT.mov'),
  ('Cable Leg Lateral Raises', 'LEG LATERAL RAISE.mov'),
  ('Leg Extension', 'LEG EXTENSION.mov'),
  ('Lat Pulldown', 'LAT PULLDOWN.mov'),
  ('Hip Thrust', 'HIP THRUST.mov'),
  ('Deadlift', 'ROMANIAN DEADLIFT CON DUMBBELLS.mov')
) as v(exercise_name, filename)
where lower(trim(e.name)) = lower(trim(v.exercise_name));

-- Confirm:
select name, video_url
from public.exercises
where name in (
  'Cable Kickback','Dumbbell RDLs','Laying Hamstring Curl','Crunches',
  'Overhead Tricep Extension','Bulgarian Split Squats','Goblet Squats',
  'Cable Leg Lateral Raises','Leg Extension','Lat Pulldown','Hip Thrust','Deadlift'
)
order by name;
