-- Gixallys García's nutrition plan: per-meal macro targets, recommended foods list,
-- and 3 meal options per meal (all dairy-free per her lactose intolerance).
-- Run create_client_gixallys.sql FIRST (creates her login + profile).
-- Safe to re-run: meal_targets upserts by (user, meal), recommended_foods and
-- meal_options are replaced fresh each run.

drop table if exists _gixallys;
create temporary table _gixallys as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'Gixallysg@gmail.com';

do $$
begin
  if (select count(*) from _gixallys) = 0 then
    raise exception 'No profile matched that email. Run create_client_gixallys.sql first, or check the address.';
  end if;
end $$;

-- 1. Per-meal macro targets
insert into public.meal_targets (user_id, meal_type, calories, protein_g, carbs_g, fat_g)
select client_id, v.meal_type, v.calories, v.protein_g, v.carbs_g, v.fat_g
from _gixallys, (values
  ('breakfast', 400, 30, 40, 12),
  ('snack_am', 200, 15, 20, 6),
  ('lunch', 500, 40, 50, 15),
  ('snack_pm', 250, 10, 20, 15),
  ('dinner', 500, 40, 45, 17)
) as v(meal_type, calories, protein_g, carbs_g, fat_g)
on conflict (user_id, meal_type) do update set
  calories = excluded.calories, protein_g = excluded.protein_g,
  carbs_g = excluded.carbs_g, fat_g = excluded.fat_g;

-- 2. Recommended foods (grouped, no fixed portion — general guidance)
delete from public.recommended_foods where user_id = (select client_id from _gixallys);
insert into public.recommended_foods (user_id, category, name, order_index)
select client_id, v.category, v.name, v.order_index
from _gixallys, (values
  ('Proteína', 'Pechuga de pollo', 1),
  ('Proteína', 'Molida de pavo', 2),
  ('Proteína', 'Molida de res (90/10)', 3),
  ('Proteína', 'Salmón', 4),
  ('Proteína', 'Tilapia', 5),
  ('Proteína', 'Claras de huevo', 6),
  ('Proteína', 'Huevo entero', 7),
  ('Proteína', 'Camarones', 8),

  ('Carbohidratos', 'Sweet potato', 1),
  ('Carbohidratos', 'Arroz blanco/integral', 2),
  ('Carbohidratos', 'Quinoa', 3),
  ('Carbohidratos', 'Avena', 4),
  ('Carbohidratos', 'Tortillas de maíz', 5),
  ('Carbohidratos', 'Banana', 6),
  ('Carbohidratos', 'Berries', 7),
  ('Carbohidratos', 'Manzana', 8),

  ('Grasas', 'Aguacate', 1),
  ('Grasas', 'Almendras/nueces', 2),
  ('Grasas', 'Aceite de oliva', 3),
  ('Grasas', 'Mantequilla de maní', 4),
  ('Grasas', 'Semillas de chía', 5),

  ('Vegetales', 'Brócoli', 1),
  ('Vegetales', 'Espinaca', 2),
  ('Vegetales', 'Zanahoria', 3),
  ('Vegetales', 'Pimientos', 4),
  ('Vegetales', 'Ensalada mixta', 5),
  ('Vegetales', 'Pepino', 6),
  ('Vegetales', 'Calabacín', 7)
) as v(category, name, order_index);

-- 3. Meal options (3 per meal, each roughly hitting that meal's macro target)
delete from public.meal_options where user_id = (select client_id from _gixallys);
insert into public.meal_options (user_id, meal_type, option_label, description, calories, protein_g, carbs_g, fat_g, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.calories, x.protein_g, x.carbs_g, x.fat_g, x.order_index
from _gixallys, (values
  ('breakfast', 'Opción 1', '3 claras + 1 huevo entero revueltos con 1 taza vegetales + 1/2 taza avena seca con 1 taza leche de almendra', 400, 30, 40, 12, 1),
  ('breakfast', 'Opción 2', '1/2 taza avena seca + 1 scoop proteína en polvo + 1 banana mediana + 1 cda mantequilla de maní', 400, 30, 40, 12, 2),
  ('breakfast', 'Opción 3', '2 tortillas de maíz + 2 huevos revueltos + 1/4 aguacate + 2 cda salsa', 400, 30, 40, 12, 3),

  ('snack_am', 'Opción 1', '3/4 taza yogurt sin lactosa + 1/2 taza berries', 200, 15, 20, 6, 1),
  ('snack_am', 'Opción 2', '2 rice cakes + 1 cda mantequilla de maní', 200, 15, 20, 6, 2),
  ('snack_am', 'Opción 3', '1 manzana mediana + 15 almendras', 200, 15, 20, 6, 3),

  ('lunch', 'Opción 1', '5oz molida de pavo (peso cocido) + 1 sweet potato mediano (150g) + 1 taza vegetales', 500, 40, 50, 15, 1),
  ('lunch', 'Opción 2', '5oz pechuga de pollo (peso cocido) + 3/4 taza arroz cocido + 2 tazas ensalada mixta + 1 cda aceite de oliva', 500, 40, 50, 15, 2),
  ('lunch', 'Opción 3', '5oz camarones + 3/4 taza quinoa cocida + 1 taza vegetales salteados', 500, 40, 50, 15, 3),

  ('snack_pm', 'Opción 1', '3/4 taza yogurt sin lactosa + 1 cda semillas de chía + 1/2 banana', 250, 10, 20, 15, 1),
  ('snack_pm', 'Opción 2', '2 rice cakes + 1/4 aguacate', 250, 10, 20, 15, 2),
  ('snack_pm', 'Opción 3', '1/3 taza hummus + 1 taza vegetales cortados', 250, 10, 20, 15, 3),

  ('dinner', 'Opción 1', '5oz molida de res 90/10 (peso cocido) + 1 sweet potato mediano (150g) + 2 tazas ensalada', 500, 40, 45, 17, 1),
  ('dinner', 'Opción 2', '5oz salmón o tilapia (peso cocido) + 3/4 taza quinoa cocida + 1 taza vegetales asados + 1 cdta aceite de oliva', 500, 40, 45, 17, 2),
  ('dinner', 'Opción 3', '5oz pechuga de pollo (peso cocido) + 3/4 taza arroz integral cocido + 1 taza brócoli', 500, 40, 45, 17, 3)
) as x(meal_type, option_label, description, calories, protein_g, carbs_g, fat_g, order_index);

-- Confirm
select meal_type, calories, protein_g, carbs_g, fat_g
from public.meal_targets where user_id = (select client_id from _gixallys)
order by array_position(array['breakfast','snack_am','lunch','snack_pm','dinner'], meal_type);

select category, count(*) from public.recommended_foods
where user_id = (select client_id from _gixallys) group by category;

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _gixallys)
order by meal_type, order_index;
