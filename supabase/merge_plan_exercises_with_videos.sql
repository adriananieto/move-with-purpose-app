-- Repoints Rosaida's plan exercises to your existing video-linked catalog entries
-- where names differed slightly (singular/plural, equipment variant), then removes
-- the now-unused auto-created (no-video) duplicates. Safe to re-run.

do $$
declare
  mapping record;
begin
  for mapping in
    select * from (values
      ('Hammer Curls', 'Hammer Curl'),
      ('Russian Twists', 'Russian Twist'),
      ('Tricep Kickbacks', 'Tricep Kickback'),
      ('Bicep Curls', 'Bicep Curl (Barbell)'),
      ('Calf Raises', 'Calf Raises (Barbell)')
    ) as m(plan_name, real_name)
  loop
    update public.workout_exercises we
    set exercise_id = real_e.id
    from public.exercises dup_e, public.exercises real_e
    where dup_e.id = we.exercise_id
      and lower(trim(dup_e.name)) = lower(trim(mapping.plan_name))
      and lower(trim(real_e.name)) = lower(trim(mapping.real_name))
      and dup_e.id <> real_e.id;

    delete from public.exercises
    where lower(trim(name)) = lower(trim(mapping.plan_name))
      and id not in (select exercise_id from public.workout_exercises);
  end loop;
end $$;

-- Confirm: shows every exercise in Rosaida's plan and whether it now has a video.
select distinct e.name, e.video_url
from public.workouts w
join public.workout_exercises we on we.workout_id = w.id
join public.exercises e on e.id = we.exercise_id
join public.profiles p on p.id = w.client_id
join auth.users u on u.id = p.id
where u.email = 'anietopr@gmail.com'
order by e.video_url nulls last, e.name;
