-- Miriam Navarro Rodriguez's nutrition plan: recommended foods and meal options,
-- taken from "MOVA - PROGRAMA ENTRENAMIENTO & NUTRICION - MIRIAM NAVARRO.pdf".
-- Run create_client_miriam.sql FIRST (creates her login + profile).
--
-- NOTE: the PDF only gives a daily macro target (already set in setup_plan_miriam.sql),
-- not a per-meal breakdown, so meal_targets is intentionally left empty for her —
-- her Nutrition Plan screen will just show daily targets + foods + meal options.
--
-- "Pre-workout" maps to snack_am and "Desayuno (post-workout)" maps to breakfast,
-- so on her Nutrition Plan screen breakfast lists before the pre-workout snack —
-- harmless, just a display-order quirk since the app has no explicit time field.
--
-- Safe to re-run: recommended_foods and meal_options are replaced fresh each run.

drop table if exists _miriam;
create temporary table _miriam as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'mimanavarro@gmail.com';

do $$
begin
  if (select count(*) from _miriam) = 0 then
    raise exception 'No profile matched that email. Run create_client_miriam.sql first, or check the address.';
  end if;
end $$;

delete from public.recommended_foods where user_id = (select client_id from _miriam);
insert into public.recommended_foods (user_id, category, name, order_index)
select client_id, v.category, v.name, v.order_index
from _miriam, (values
  ('⚠️ Importante', 'Evitar toronja/grapefruit — interactúa con el Lipitor', 1),
  ('⚠️ Importante', 'Priorizar grasas insaturadas (oliva, aguacate, pescado); limitar frituras y grasas saturadas', 2),

  ('Proteínas', 'Pechuga de pollo', 1),
  ('Proteínas', 'Pavo molido', 2),
  ('Proteínas', 'Carne molida magra (baja en grasa)', 3),
  ('Proteínas', 'Salmón', 4),
  ('Proteínas', 'Atún', 5),
  ('Proteínas', 'Huevo entero (con moderación)', 6),
  ('Proteínas', 'Claras de huevo', 7),
  ('Proteínas', 'Yogurt griego bajo en grasa', 8),
  ('Proteínas', 'Proteína en polvo', 9),

  ('Carbohidratos', 'Arroz (blanco o integral)', 1),
  ('Carbohidratos', 'Habichuelas / legumbres', 2),
  ('Carbohidratos', 'Avena', 3),
  ('Carbohidratos', 'Batata / papa', 4),
  ('Carbohidratos', 'Pan y tortillas integrales', 5),
  ('Carbohidratos', 'Quinoa', 6),
  ('Carbohidratos', 'Banana', 7),
  ('Carbohidratos', 'Berries', 8),
  ('Carbohidratos', 'Manzana', 9),
  ('Carbohidratos', 'Mango', 10),

  ('Grasas Saludables', 'Aguacate', 1),
  ('Grasas Saludables', 'Aceite de oliva', 2),
  ('Grasas Saludables', 'Nueces / almendras', 3),
  ('Grasas Saludables', 'Semillas (chia, flax)', 4),
  ('Grasas Saludables', 'Mantequilla de maní / almendra (con moderación)', 5),

  ('Vegetales', 'Brócoli', 1),
  ('Vegetales', 'Espinaca', 2),
  ('Vegetales', 'Zucchini', 3),
  ('Vegetales', 'Pimientos', 4),
  ('Vegetales', 'Espárragos', 5),
  ('Vegetales', 'Ensaladas mixtas', 6)
) as v(category, name, order_index);

delete from public.meal_options where user_id = (select client_id from _miriam);
insert into public.meal_options (user_id, meal_type, option_label, description, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.order_index
from _miriam, (values
  -- Desayuno (post-workout)
  ('breakfast', 'Opción 1', '½ taza avena + 1 scoop proteína + ½ banana + 5 almendras', 1),
  ('breakfast', 'Opción 2', '1 huevo + 2 claras + 1 rebanada pan integral + ¼ aguacate', 2),
  ('breakfast', 'Opción 3', '¾ taza yogurt griego + 100g berries + 15g almendras + 1 tsp miel', 3),
  ('breakfast', 'Opción 4 (batida)', 'Batida: 1 scoop proteína + ½ banana + espinaca + leche de almendra. Empieza por esta opción si el desayuno todavía no es un hábito — vamos progresando poco a poco.', 4),

  -- Pre-workout (light)
  ('snack_am', 'Opción 1', '½ banana pequeña + 6 almendras + ¼ scoop proteína', 1),
  ('snack_am', 'Opción 2', '1 rice cake + 1 tsp mantequilla de almendra', 2),
  ('snack_am', 'Opción 3', '½ taza yogurt griego + 1 tsp miel', 3),

  -- Almuerzo
  ('lunch', 'Opción 1', '4oz pechuga de pollo + ¾ taza arroz + vegetales + 1 tbsp aceite de oliva', 1),
  ('lunch', 'Opción 2', '4oz pollo o pavo + ½ taza habichuelas + ensalada + 1 tbsp aceite de oliva', 2),
  ('lunch', 'Opción 3', '4oz salmón + ¾ taza quinoa + vegetales', 3),

  -- Snack
  ('snack_pm', 'Opción 1', '¾ taza yogurt griego + 80g fruta + 10g almendras', 1),
  ('snack_pm', 'Opción 2', '1 scoop proteína + 1 rice cake + 1 tsp mantequilla de almendra', 2),
  ('snack_pm', 'Opción 3', '¾ taza cottage cheese + 80g fruta', 3),

  -- Cena
  ('dinner', 'Opción 1', '4oz pollo o pescado + ensalada grande + ¼ aguacate + 1 tbsp aceite de oliva', 1),
  ('dinner', 'Opción 2', '4oz salmón + vegetales al vapor + ½ batata', 2),
  ('dinner', 'Opción 3', '4oz pavo molido + zucchini salteado + ensalada', 3)
) as x(meal_type, option_label, description, order_index);

-- Confirm
select category, count(*) from public.recommended_foods
where user_id = (select client_id from _miriam) group by category;

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _miriam)
order by meal_type, order_index;
