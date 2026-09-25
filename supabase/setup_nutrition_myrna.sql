-- Myrna Camacho's nutrition plan, from
-- "MOVE WITH PURPOSE - MYRNA CAMACHO (31agosto).pdf".
-- Run create_client_myrna.sql FIRST.
--
-- NOTE: no per-meal macro breakdown given, so meal_targets stays empty — daily
-- target only (set in setup_plan_myrna.sql). "Snack" (single, unspecified AM/PM)
-- maps to snack_pm only, same convention as Gretchen's plan.
--
-- Safe to re-run: recommended_foods and meal_options are replaced fresh each run.

drop table if exists _myrna;
create temporary table _myrna as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'myrnidmd@gmail.com';

do $$
begin
  if (select count(*) from _myrna) = 0 then
    raise exception 'No profile matched that email. Run create_client_myrna.sql first, or check the address.';
  end if;
end $$;

delete from public.recommended_foods where user_id = (select client_id from _myrna);
insert into public.recommended_foods (user_id, category, name, order_index)
select client_id, v.category, v.name, v.order_index
from _myrna, (values
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

  ('Suplementos', 'Creatina monohidratada — 5g diarios, todos los días incluyendo descanso', 1),
  ('Suplementos', 'Whey Protein — 1 scoop, para alcanzar el consumo diario de proteína', 2),

  ('Hidratación y Hábitos', 'Meta diaria: 2.5-3 litros de agua', 1),
  ('Hidratación y Hábitos', '8,000-10,000 pasos diarios como referencia', 2),
  ('Hidratación y Hábitos', 'Fin de semana: mantener estructura, no saltarse comidas, alcohol máx. 2 tragos 1x/semana', 3)
) as v(category, name, order_index);

delete from public.meal_options where user_id = (select client_id from _myrna);
insert into public.meal_options (user_id, meal_type, option_label, description, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.order_index
from _myrna, (values
  ('breakfast', 'Opción 1', '2 huevos enteros + 4 claras + ½ taza de avena + ½ taza de berries', 1),
  ('breakfast', 'Opción 2', '1 Greek yogurt alto en proteína + ½ taza de avena + 1 banana pequeña + 1 cda de chia', 2),
  ('breakfast', 'Opción 3', '2 tostadas integrales + 3 huevos enteros + ¼ aguacate + 1 fruta', 3),
  ('breakfast', 'Opción 4 (rápida)', '1 scoop whey protein + ½ taza avena + 1 banana + 1 cda peanut butter + agua o leche de almendra sin azúcar', 4),

  ('lunch', 'Opción 1', '5oz pechuga de pollo + 1 taza arroz + 1 taza vegetales + 1 cdita aceite de oliva', 1),
  ('lunch', 'Opción 2', '5oz carne magra + 1 taza papa + ensalada + ¼ aguacate', 2),
  ('lunch', 'Opción 3', '5oz salmón + 1 taza batata + espárragos', 3),
  ('lunch', 'Opción 4', '5oz pavo molido + 1 taza quinoa + 1 taza vegetales', 4),
  ('lunch', 'Opción 5 (Bowl)', '5oz pollo + 1 taza arroz + lechuga + pico de gallo + ¼ aguacate', 5),

  ('dinner', 'Opción 1', '5oz pollo + ¾-1 taza arroz + 1-2 tazas vegetales', 1),
  ('dinner', 'Opción 2', '5oz pescado blanco + 1 taza papa + ensalada', 2),
  ('dinner', 'Opción 3', '5oz salmón + ¾ taza batata + espárragos', 3),
  ('dinner', 'Opción 4', '5oz carne magra + ¾ taza arroz + vegetales', 4),
  ('dinner', 'Opción 5 (Fajitas)', '5oz pollo + 2 tortillas integrales pequeñas + pimientos y cebolla + ¼ aguacate', 5),

  ('snack_pm', 'Opción 1', '1 Greek yogurt + 1 fruta + 10 almendras', 1),
  ('snack_pm', 'Opción 2', '1 manzana + 1 cda peanut butter + 1 string cheese', 2),
  ('snack_pm', 'Opción 3', '3oz turkey slices + 2 rice cakes + 1 fruta', 3),
  ('snack_pm', 'Opción 4', '¾ taza cottage cheese + ½ taza pineapple', 4)
) as x(meal_type, option_label, description, order_index);

select category, count(*) from public.recommended_foods
where user_id = (select client_id from _myrna) group by category;

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _myrna)
order by meal_type, order_index;
