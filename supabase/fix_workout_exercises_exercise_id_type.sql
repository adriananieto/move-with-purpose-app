-- workout_exercises.exercise_id was created as uuid, but exercises.id is actually
-- bigint (the original catalog table, which already has 20 real rows with videos).
-- workout_exercises is still empty, so it's far safer to fix the type there than to
-- migrate exercises.id (which other legacy tables/data depend on).
-- Safe to re-run.

-- Drop whatever FK constraint currently exists on exercise_id, whatever it's named.
do $$
declare
  con record;
begin
  for con in
    select conname
    from pg_constraint
    where conrelid = 'public.workout_exercises'::regclass
      and contype = 'f'
      and conkey = (
        select array_agg(attnum) from pg_attribute
        where attrelid = 'public.workout_exercises'::regclass and attname = 'exercise_id'
      )
  loop
    execute format('alter table public.workout_exercises drop constraint %I', con.conname);
  end loop;
end $$;

alter table public.workout_exercises
  alter column exercise_id type bigint using exercise_id::text::bigint;

alter table public.workout_exercises
  add constraint workout_exercises_exercise_id_fkey
  foreign key (exercise_id) references public.exercises(id) on delete cascade;

-- target_reps also turned out to be integer, not text — but the plan needs strings
-- like "10 min, pace moderado" or "7-7-7", so widen it. Empty table, safe to re-run.
alter table public.workout_exercises
  alter column target_reps type text using target_reps::text;
