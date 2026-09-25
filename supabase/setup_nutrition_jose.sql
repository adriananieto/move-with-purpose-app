-- José Llama's nutrition plan: per-meal targets, recommended foods, and meal
-- options (dairy included, no allergies/conditions noted).
-- "Post-workout" maps to snack_am (training-day only, optional). "Snack" maps
-- to snack_pm. Dinner options are bistec, sushi, and pasta con proteína.
-- Run create_client_jose.sql FIRST. Safe to re-run.

drop table if exists _jose;
create temporary table _jose as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'josellama2014@gmail.com';

do $$
begin
  if (select count(*) from _jose) = 0 then
    raise exception 'No profile matched that email. Run create_client_jose.sql first, or check the address.';
  end if;
end $$;

-- 1. Per-meal macro targets
insert into public.meal_targets (user_id, meal_type, calories, protein_g, carbs_g, fat_g)
select client_id, v.meal_type, v.calories, v.protein_g, v.carbs_g, v.fat_g
from _jose, (values
  ('breakfast', 300, 25, 30, 10),
  ('snack_am', 300, 30, 35, 5),
  ('lunch', 800, 65, 70, 25),
  ('snack_pm', 300, 20, 30, 10),
  ('dinner', 800, 65, 70, 25)
) as v(meal_type, calories, protein_g, carbs_g, fat_g)
on conflict (user_id, meal_type) do update set
  calories = excluded.calories, protein_g = excluded.protein_g,
  carbs_g = excluded.carbs_g, fat_g = excluded.fat_g;

-- 2. Recommended foods
delete from public.recommended_foods where user_id = (select client_id from _jose);
insert into public.recommended_foods (user_id, category, name, order_index)
select client_id, v.category, v.name, v.order_index
from _jose, (values
  ('Proteína', 'Pechuga de pollo', 1),
  ('Proteína', 'Molida de pavo', 2),
  ('Proteína', 'Molida de res (90/10)', 3),
  ('Proteína', 'Salmón', 4),
  ('Proteína', 'Camarones', 5),
  ('Proteína', 'Huevo entero', 6),
  ('Proteína', 'Claras', 7),
  ('Proteína', 'Yogurt griego', 8),
  ('Proteína', 'Proteína en polvo', 9),
  ('Proteína', 'Bistec/carne roja magra', 10),
  ('Proteína', 'Atún', 11),

  ('Carbohidratos', 'Arroz', 1),
  ('Carbohidratos', 'Sweet potato', 2),
  ('Carbohidratos', 'Pasta integral/de proteína', 3),
  ('Carbohidratos', 'Avena', 4),
  ('Carbohidratos', 'Rice cakes', 5),
  ('Carbohidratos', 'Banana', 6),
  ('Carbohidratos', 'Berries', 7),
  ('Carbohidratos', 'Granola', 8),
  ('Carbohidratos', 'Sushi/rolls', 9),

  ('Grasas', 'Mantequilla de maní', 1),
  ('Grasas', 'Aguacate', 2),
  ('Grasas', 'Almendras', 3),

  ('Vegetales', 'Brócoli', 1),
  ('Vegetales', 'Espinaca', 2),
  ('Vegetales', 'Pimientos', 3),
  ('Vegetales', 'Ensalada mixta', 4),
  ('Vegetales', 'Calabacín', 5),
  ('Vegetales', 'Edamame', 6)
) as v(category, name, order_index);

-- 3. Meal options (breakfast optional, post-workout optional/training days)
delete from public.meal_options where user_id = (select client_id from _jose);
insert into public.meal_options (user_id, meal_type, option_label, description, calories, protein_g, carbs_g, fat_g, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.calories, x.protein_g, x.carbs_g, x.fat_g, x.order_index
from _jose, (values
  ('breakfast', 'Opción 1', '4 claras + 1 huevo entero revueltos + 1/2 taza avena seca', 300, 25, 30, 10, 1),
  ('breakfast', 'Opción 2', '1 scoop proteína + 1/2 taza avena seca + 1/2 banana', 300, 25, 30, 10, 2),
  ('breakfast', 'Opción 3', '3 huevos enteros + 2 tortillas de maíz + 1/4 aguacate', 300, 25, 30, 10, 3),

  ('lunch', 'Opción 1', '7oz pechuga de pollo (peso cocido) + 1 taza arroz cocido + 2 tazas vegetales', 800, 65, 70, 25, 1),
  ('lunch', 'Opción 2', '7oz molida de pavo (peso cocido) + 1 sweet potato grande (200g) + 1.5 tazas vegetales', 800, 65, 70, 25, 2),
  ('lunch', 'Opción 3', '6oz salmón (peso cocido) + 1 taza pasta integral o de proteína cocida + 1 taza vegetales', 800, 65, 70, 25, 3),

  ('snack_pm', 'Opción 1', '1 scoop proteína + 1 banana + 1 cda mantequilla de maní', 300, 20, 30, 10, 1),
  ('snack_pm', 'Opción 2', '1 taza yogurt griego + 1/2 taza granola + 1/2 taza berries', 300, 20, 30, 10, 2),
  ('snack_pm', 'Opción 3', '2 rice cakes + 2 cda mantequilla de maní', 300, 20, 30, 10, 3),

  ('dinner', 'Opción 1', '7oz bistec/carne roja magra (sirloin) + 1 sweet potato o 1 taza arroz + vegetales', 800, 65, 70, 25, 1),
  ('dinner', 'Opción 2', 'Sushi — 10-12 piezas de rolls con proteína (salmón, atún, camarón) + edamame como extra de proteína', 800, 65, 70, 25, 2),
  ('dinner', 'Opción 3', '2 tazas pasta integral o de proteína cocida + 6oz proteína magra (pollo o molida) + salsa de tomate ligera', 800, 65, 70, 25, 3),

  ('snack_am', 'Opción 1 (post-workout, días de entreno)', '1.5 scoop proteína + 1 banana + agua', 300, 30, 35, 5, 1),
  ('snack_am', 'Opción 2 (post-workout, días de entreno)', '1 taza yogurt griego + 1 taza berries + 1 cdta miel', 300, 30, 35, 5, 2),
  ('snack_am', 'Opción 3 (post-workout, días de entreno)', '2 claras cocidas + 1 rice cake + 1 fruta pequeña', 300, 30, 35, 5, 3)
) as x(meal_type, option_label, description, calories, protein_g, carbs_g, fat_g, order_index);

-- Confirm
select meal_type, calories, protein_g, carbs_g, fat_g
from public.meal_targets where user_id = (select client_id from _jose)
order by array_position(array['breakfast','snack_am','lunch','snack_pm','dinner'], meal_type);

select category, count(*) from public.recommended_foods
where user_id = (select client_id from _jose) group by category;

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _jose)
order by meal_type, order_index;
