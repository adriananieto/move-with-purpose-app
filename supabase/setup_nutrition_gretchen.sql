-- Gretchen Hernández Rivera's nutrition plan, from
-- "MOVE WITH PURPOSE - Gretchen Hernández.pdf.pdf".
-- Run create_client_gretchen.sql FIRST.
--
-- NOTE: the PDF gives no per-meal macro breakdown, so meal_targets stays empty —
-- daily target only (already set in setup_plan_gretchen.sql).
-- Her plan is "3 comidas + 1 snack", so only snack_pm is used below (snack_am
-- intentionally left empty rather than duplicating the same options into both).
--
-- Safe to re-run: recommended_foods and meal_options are replaced fresh each run.

drop table if exists _gretchen;
create temporary table _gretchen as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'Gretchenh61@gmail.com';

do $$
begin
  if (select count(*) from _gretchen) = 0 then
    raise exception 'No profile matched that email. Run create_client_gretchen.sql first, or check the address.';
  end if;
end $$;

delete from public.recommended_foods where user_id = (select client_id from _gretchen);
insert into public.recommended_foods (user_id, category, name, order_index)
select client_id, v.category, v.name, v.order_index
from _gretchen, (values
  ('Proteínas', 'Pechuga de pollo', 1),
  ('Proteínas', 'Carne molida magra', 2),
  ('Proteínas', 'Bistec de res', 3),
  ('Proteínas', 'Pescado (tilapia, salmón, dorado)', 4),
  ('Proteínas', 'Huevos', 5),

  ('Carbohidratos', 'Arroz blanco o integral', 1),
  ('Carbohidratos', 'Batata', 2),
  ('Carbohidratos', 'Yuca', 3),
  ('Carbohidratos', 'Papa', 4),
  ('Carbohidratos', 'Plátano', 5),
  ('Carbohidratos', 'Avena', 6),

  ('Grasas Saludables', 'Aceite de oliva', 1),
  ('Grasas Saludables', 'Aguacate', 2),
  ('Grasas Saludables', 'Almendras o nueces', 3),

  ('Verduras', 'Zanahoria', 1),
  ('Verduras', 'Calabaza', 2),
  ('Verduras', 'Brócoli', 3),
  ('Verduras', 'Coliflor', 4),
  ('Verduras', 'Pimientos salteados', 5),

  ('Suplementos', 'Creatina — fuerza, rendimiento y recuperación', 1),
  ('Suplementos', 'Proteína en polvo — cubrir proteína diaria', 2),
  ('Suplementos', 'Omega 3 — antiinflamatorio y salud cardiovascular', 3)
) as v(category, name, order_index);

delete from public.meal_options where user_id = (select client_id from _gretchen);
insert into public.meal_options (user_id, meal_type, option_label, description, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.order_index
from _gretchen, (values
  ('breakfast', 'Opción 1', '2 huevos + 2 claras + ½ taza avena', 1),
  ('breakfast', 'Opción 2', '2 huevos + 1 tostada integral + ¼ aguacate', 2),
  ('breakfast', 'Opción 3', '2 huevos + ½ taza batata hervida', 3),
  ('breakfast', 'Opción 4', 'Avena (½ taza) + 2 claras + canela', 4),

  ('lunch', 'Opción 1', '150g pollo + 1 taza arroz + zanahoria cocida', 1),
  ('lunch', 'Opción 2', '150g carne magra + ½–1 taza batata + calabaza', 2),
  ('lunch', 'Opción 3', '150g pescado + 1 taza yuca + brócoli', 3),
  ('lunch', 'Opción 4', '150g pollo + 1 taza plátano hervido + vegetales', 4),

  ('dinner', 'Opción 1', '120g pollo + ½ taza arroz + vegetales', 1),
  ('dinner', 'Opción 2', '120g pescado + ½ taza batata + vegetales', 2),
  ('dinner', 'Opción 3', '2 huevos + 2 claras + ½ taza vianda', 3),
  ('dinner', 'Opción 4', '120g carne + ½ taza yuca + vegetales', 4),

  ('snack_pm', 'Opción 1', '1 fruta + 10 almendras', 1),
  ('snack_pm', 'Opción 2', '1 huevo hervido + ½ guineo', 2),
  ('snack_pm', 'Opción 3', '1 tostada integral + 1 cucharadita mantequilla de maní', 3),
  ('snack_pm', 'Opción 4', 'Café + 1 fruta', 4)
) as x(meal_type, option_label, description, order_index);

select category, count(*) from public.recommended_foods
where user_id = (select client_id from _gretchen) group by category;

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _gretchen)
order by meal_type, order_index;
