-- Updates the signup trigger to also accept plan_tier from signup metadata.
-- Safe to run on its own — does NOT touch existing data (unlike schema.sql,
-- which drops and recreates everything). Run this once in the SQL editor.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, plan_tier)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'New Member'),
    coalesce(new.raw_user_meta_data->>'plan_tier', 'Premium')
  );

  insert into public.nutrition_targets (user_id) values (new.id);

  return new;
end;
$$;
