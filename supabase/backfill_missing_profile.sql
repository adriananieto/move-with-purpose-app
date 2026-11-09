-- Fixes accounts that exist in auth.users but have no matching profiles row
-- (e.g. created before the handle_new_user trigger existed). Safe to re-run.
-- Edit v_email below, then run in the SQL editor.

drop table if exists _backfill_target;
create temporary table _backfill_target as
select u.id, u.email, coalesce(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1)) as full_name
from auth.users u
where u.email ilike 'anietopr@gmail.com';  -- <-- EDIT if needed

insert into public.profiles (id, full_name)
select id, full_name from _backfill_target
on conflict (id) do nothing;

insert into public.nutrition_targets (user_id)
select id from _backfill_target
on conflict (user_id) do nothing;

-- Confirm:
select p.id, p.full_name, p.plan_tier, p.member_since
from public.profiles p
join _backfill_target b on b.id = p.id;
