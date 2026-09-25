-- Mariela Nieto's nutrition plan — exact same plan as Karen J Rodriguez Navarro,
-- per Adriana's instruction.
-- Run create_client_mariela.sql FIRST.
--
-- NOTE: this PDF has no "recommended foods" list section (only daily target +
-- meal options), so recommended_foods is intentionally left empty for her.
-- No per-meal macro breakdown either, so meal_targets stays empty too.
-- "Pre-workout" maps to snack_am, "Snack" maps to snack_pm.
--
-- Safe to re-run: meal_options is replaced fresh each run.

drop table if exists _mariela;
create temporary table _mariela as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'nietomarielapr@gmail.com';

do $$
begin
  if (select count(*) from _mariela) = 0 then
    raise exception 'No profile matched that email. Run create_client_mariela.sql first, or check the address.';
  end if;
end $$;

delete from public.meal_options where user_id = (select client_id from _mariela);
insert into public.meal_options (user_id, meal_type, option_label, description, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.order_index
from _mariela, (values
  ('snack_am', 'Opción 1', '1 banana + 1 scoop proteína', 1),
  ('snack_am', 'Opción 2', '2 rice cakes + 3oz pavo', 2),
  ('snack_am', 'Opción 3', '1 taza yogurt griego + ½ taza berries', 3),

  ('breakfast', 'Opción 1', '2 huevos + 4 claras + ½ taza avena + canela + ½ taza berries', 1),
  ('breakfast', 'Opción 2', '1 scoop proteína + 2 rebanadas pan integral + 1 cda mantequilla de maní', 2),
  ('breakfast', 'Opción 3', 'Omelette (3 huevos + 4 claras) + vegetales + 2 tostadas integrales', 3),
  ('breakfast', 'Opción 4', '1 taza yogurt griego sin grasa + ½ taza granola baja en azúcar + fresas + 1 cda semillas de chía', 4),
  ('breakfast', 'Opción 5', 'Smoothie: 1 scoop proteína + ½ taza avena + 1 banana + leche de almendra sin azúcar', 5),

  ('snack_pm', 'Opción 1', '1 taza yogurt griego + 15 almendras', 1),
  ('snack_pm', 'Opción 2', '1 manzana o pera + 2 cdas peanut butter', 2),
  ('snack_pm', 'Opción 3', '1 scoop proteína + 1 banana', 3),
  ('snack_pm', 'Opción 4', '1 taza cottage cheese + fruta (mango/duraznos)', 4),
  ('snack_pm', 'Opción 5', '2 rice cakes + 3oz pechuga de pavo', 5),

  ('lunch', 'Opción 1', '6oz pollo + 1 taza arroz + brócoli + ¼ aguacate', 1),
  ('lunch', 'Opción 2', '6oz salmón + 1 taza batata + espárragos', 2),
  ('lunch', 'Opción 3', '6oz carne magra + 1 taza papa + ensalada', 3),
  ('lunch', 'Opción 4', '6oz pavo molido + 1 taza quinoa + vegetales salteados', 4),
  ('lunch', 'Opción 5 (Burrito Bowl)', '6oz pollo + 1 taza arroz + lechuga + pico de gallo + ¼ aguacate', 5),

  ('dinner', 'Opción 1', '5-6oz pollo + ¾-1 taza arroz + vegetales', 1),
  ('dinner', 'Opción 2', '5-6oz salmón + ¾ taza batata + espárragos', 2),
  ('dinner', 'Opción 3', '5-6oz camarones + ¾ taza quinoa + vegetales', 3),
  ('dinner', 'Opción 4', '5-6oz carne magra + ¾ taza papa + ensalada', 4),
  ('dinner', 'Opción 5 (Fajitas)', '5-6oz pollo + 2 tortillas integrales + pimientos y cebolla', 5)
) as x(meal_type, option_label, description, order_index);

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _mariela)
order by meal_type, order_index;
