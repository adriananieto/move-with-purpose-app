-- Melissa Hernandez's nutrition plan, from
-- "MOVE_WITH_PURPOSE_MELISSA_HERNANDEZ.pdf".
-- Run create_client_melissa.sql FIRST.
--
-- NOTE: no per-meal macro breakdown given, so meal_targets stays empty — daily
-- target only (set in setup_plan_melissa.sql). "Pre Workout" maps to snack_am,
-- "Snack" maps to snack_pm.
--
-- Safe to re-run: recommended_foods and meal_options are replaced fresh each run.

drop table if exists _melissa;
create temporary table _melissa as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'hernandez.casanova39@gmail.com';

do $$
begin
  if (select count(*) from _melissa) = 0 then
    raise exception 'No profile matched that email. Run create_client_melissa.sql first, or check the address.';
  end if;
end $$;

delete from public.recommended_foods where user_id = (select client_id from _melissa);
insert into public.recommended_foods (user_id, category, name, order_index)
select client_id, v.category, v.name, v.order_index
from _melissa, (values
  ('Proteínas (5 oz cocidas por porción)', 'Pechuga de pollo', 1),
  ('Proteínas (5 oz cocidas por porción)', 'Pavo molido 93/7', 2),
  ('Proteínas (5 oz cocidas por porción)', 'Carne molida 90-93% magra', 3),
  ('Proteínas (5 oz cocidas por porción)', 'Bistec magro', 4),
  ('Proteínas (5 oz cocidas por porción)', 'Filete de res', 5),
  ('Proteínas (5 oz cocidas por porción)', 'Salmón', 6),
  ('Proteínas (5 oz cocidas por porción)', 'Atún fresco', 7),
  ('Proteínas (5 oz cocidas por porción)', 'Mero', 8),
  ('Proteínas (5 oz cocidas por porción)', 'Chillo', 9),
  ('Proteínas (5 oz cocidas por porción)', 'Tilapia', 10),
  ('Proteínas (5 oz cocidas por porción)', 'Camarones', 11),
  ('Proteínas (5 oz cocidas por porción)', 'Claras de huevo', 12),
  ('Proteínas (5 oz cocidas por porción)', 'Huevos enteros', 13),
  ('Proteínas (5 oz cocidas por porción)', 'Yogurt griego sin grasa', 14),
  ('Proteínas (5 oz cocidas por porción)', 'Cottage cheese bajo en grasa', 15),
  ('Proteínas (5 oz cocidas por porción)', 'Whey Protein', 16),

  ('Carbohidratos', 'Avena', 1),
  ('Carbohidratos', 'Pan integral', 2),
  ('Carbohidratos', 'English Muffin integral', 3),
  ('Carbohidratos', 'Tortillas integrales', 4),
  ('Carbohidratos', 'Cereal alto en fibra', 5),
  ('Carbohidratos', 'Guineo', 6),
  ('Carbohidratos', 'Berries', 7),
  ('Carbohidratos', 'Manzana', 8),
  ('Carbohidratos', 'China', 9),
  ('Carbohidratos', 'Arroz blanco o integral', 10),
  ('Carbohidratos', 'Batata', 11),
  ('Carbohidratos', 'Papa', 12),
  ('Carbohidratos', 'Quinoa', 13),
  ('Carbohidratos', 'Pasta integral', 14),
  ('Carbohidratos', 'Yuca', 15),
  ('Carbohidratos', 'Ñame', 16),

  ('Grasas Saludables (1 porción por comida)', 'Aguacate (¼)', 1),
  ('Grasas Saludables (1 porción por comida)', 'Almendras (15)', 2),
  ('Grasas Saludables (1 porción por comida)', 'Nueces (15)', 3),
  ('Grasas Saludables (1 porción por comida)', 'Mantequilla de almendra (1 cda)', 4),
  ('Grasas Saludables (1 porción por comida)', 'Mantequilla de maní natural (1 cda)', 5),
  ('Grasas Saludables (1 porción por comida)', 'Aceite de oliva (1 cda)', 6),
  ('Grasas Saludables (1 porción por comida)', 'Semillas de chía (1 cda)', 7),
  ('Grasas Saludables (1 porción por comida)', 'Semillas de linaza (1 cda)', 8),

  ('Vegetales (libres)', 'Brócoli', 1),
  ('Vegetales (libres)', 'Espárragos', 2),
  ('Vegetales (libres)', 'Lechuga', 3),
  ('Vegetales (libres)', 'Espinaca', 4),
  ('Vegetales (libres)', 'Pepino', 5),
  ('Vegetales (libres)', 'Zucchini', 6),
  ('Vegetales (libres)', 'Coliflor', 7),
  ('Vegetales (libres)', 'Repollo', 8),
  ('Vegetales (libres)', 'Pimientos', 9),
  ('Vegetales (libres)', 'Habichuelas tiernas', 10),
  ('Vegetales (libres)', 'Tomates', 11),
  ('Vegetales (libres)', 'Hongos', 12),

  ('Hidratación y Hábitos', 'Hidratación: 2.5-3 litros de agua al día, más en días de entrenamiento', 1),
  ('Hidratación y Hábitos', 'Regla 80/20: prioriza alimentos nutritivos y disfruta con moderación los fines de semana', 2),
  ('Hidratación y Hábitos', 'Modera el café en la tarde; duerme 7-8 horas para recuperación', 3)
) as v(category, name, order_index);

delete from public.meal_options where user_id = (select client_id from _melissa);
insert into public.meal_options (user_id, meal_type, option_label, description, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.order_index
from _melissa, (values
  ('snack_am', 'Opción 1', '1 banana + 1 scoop proteína', 1),
  ('snack_am', 'Opción 2', '2 rice cakes + 3oz pavo', 2),
  ('snack_am', 'Opción 3', 'Yogurt griego + ½ taza berries', 3),

  ('breakfast', 'Opción 1', '2 huevos + 4 claras + ½ taza avena + canela + ½ taza berries', 1),
  ('breakfast', 'Opción 2', '1 scoop de proteína + 2 rebanadas pan integral + 1 cda mantequilla de maní natural', 2),
  ('breakfast', 'Opción 3', 'Omelette (2 huevos + 4 claras) + vegetales + 2 tostadas integrales', 3),
  ('breakfast', 'Opción 4', 'Yogurt griego sin grasa + ½ taza granola baja en azúcar + fresas + 1 cda semillas de chía', 4),
  ('breakfast', 'Opción 5', 'Smoothie: 1 scoop proteína + ½ taza avena + 1 banana + leche de almendra sin azúcar', 5),

  ('snack_pm', 'Opción 1', 'Yogurt griego + 15 almendras', 1),
  ('snack_pm', 'Opción 2', 'Manzana + 2 cdas peanut butter natural', 2),
  ('snack_pm', 'Opción 3', '1 scoop proteína + 1 banana', 3),
  ('snack_pm', 'Opción 4', 'Cottage cheese + piña', 4),
  ('snack_pm', 'Opción 5', '2 rice cakes + 3oz pechuga de pavo', 5),

  ('lunch', 'Opción 1', '5oz pollo + 1 taza arroz + brócoli', 1),
  ('lunch', 'Opción 2', '5oz salmón + 1 taza batata + espárragos', 2),
  ('lunch', 'Opción 3', '5oz carne magra + 1 taza papa + ensalada', 3),
  ('lunch', 'Opción 4', '5oz pavo molido + 1 taza quinoa + vegetales salteados', 4),
  ('lunch', 'Opción 5 (Burrito Bowl)', '5oz pollo + 1 taza arroz + lechuga + pico de gallo + ¼ aguacate', 5),

  ('dinner', 'Opción 1', '5oz pollo + ¾ taza arroz + vegetales', 1),
  ('dinner', 'Opción 2', '5oz salmón + ¾ taza batata + espárragos', 2),
  ('dinner', 'Opción 3', '5oz camarones + ¾ taza quinoa + vegetales mixtos', 3),
  ('dinner', 'Opción 4', '5oz carne magra + ¾ taza papa + ensalada', 4),
  ('dinner', 'Opción 5 (Fajitas)', '5oz pollo + 2 tortillas integrales pequeñas + pimientos y cebolla', 5)
) as x(meal_type, option_label, description, order_index);

select category, count(*) from public.recommended_foods
where user_id = (select client_id from _melissa) group by category;

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _melissa)
order by meal_type, order_index;
