-- Karen's custom meal names/order: "Post Workout Meal" (stored as snack_am,
-- so her logs keep meal_type = 'snack_am') shows first, then Breakfast,
-- Lunch, Snack PM, Dinner.
-- Only touches label and sort_order: any macros already on her meal_targets
-- rows are kept; new rows get the 0 defaults, which the app hides.
-- Safe to re-run.

insert into public.meal_targets (user_id, meal_type, label, sort_order)
select p.id, x.meal_type, x.label, x.sort_order
from public.profiles p
join auth.users u on u.id = p.id,
(values
  ('snack_am',  'Post Workout Meal', 0),
  ('breakfast', null,                1),
  ('lunch',     null,                2),
  ('snack_pm',  null,                3),
  ('dinner',    null,                4)
) as x(meal_type, label, sort_order)
where u.email = 'karen_rodriguez_13@hotmail.com'
on conflict (user_id, meal_type) do update
  set label = excluded.label,
      sort_order = excluded.sort_order;

-- Check: should list Post Workout Meal first.
select t.meal_type, t.label, t.sort_order
from public.meal_targets t
join auth.users u on u.id = t.user_id
where u.email = 'karen_rodriguez_13@hotmail.com'
order by t.sort_order nulls last;
