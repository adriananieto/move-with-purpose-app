-- Dianexy Falcon Nieves's nutrition plan — Fase 3 (Déficit Moderado), replaces
-- Fase 2 entirely. Training plan is untouched (see setup_plan_dianexy.sql).
-- Daily targets use the midpoint of each given range:
--   Calorías 1500-1600 -> 1550, Proteína 130-140 -> 135,
--   Grasa 40-50 -> 45, Carbohidratos 140-160 -> 150.
-- Run create_client_dianexy.sql FIRST. Safe to re-run.

drop table if exists _dianexy;
create temporary table _dianexy as
select p.id as client_id
from public.profiles p
join auth.users u on u.id = p.id
where u.email = 'dianexy.nieves@gmail.com';

do $$
begin
  if (select count(*) from _dianexy) = 0 then
    raise exception 'No profile matched that email. Run create_client_dianexy.sql first, or check the address.';
  end if;
end $$;

update public.nutrition_targets
set calories = 1550, protein_g = 135, carbs_g = 150, fat_g = 45
where user_id = (select client_id from _dianexy);

delete from public.meal_options where user_id = (select client_id from _dianexy);
insert into public.meal_options (user_id, meal_type, option_label, description, order_index)
select client_id, x.meal_type, x.option_label, x.description, x.order_index
from _dianexy, (values
  ('breakfast', 'Opción 1', '2 huevos completos + 3 claras + ¼ aguacate + 1 slice pan integral', 1),
  ('breakfast', 'Opción 2', '¾ taza claras de huevo + 1 huevo completo + ½ taza avena cocida + canela + ¼ taza berries', 2),
  ('breakfast', 'Opción 3', 'Yogurt griego alto en proteína (200-220g) + ½ taza berries + 15g nueces + canela', 3),
  ('breakfast', 'Opción 4', '2 huevos completos + 2 claras + ½ taza cottage cheese + 1 slice tostada integral + ¼ aguacate', 4),

  ('snack_pm', 'Opción 1', 'Yogurt griego alto en proteína (170-200g) + ½ taza berries', 1),
  ('snack_pm', 'Opción 2', '1 scoop proteína whey + agua o leche de almendra sin azúcar', 2),
  ('snack_pm', 'Opción 3', 'Rice cake + 1 cucharada mantequilla de maní', 3),
  ('snack_pm', 'Opción 4', '1 fruta pequeña + 10 almendras', 4),

  ('lunch', 'Opción 1', '5-6oz pechuga de pollo + ¾ taza arroz cocido + 1 taza vegetales', 1),
  ('lunch', 'Opción 2', '5-6oz pescado blanco o salmón + ¾ taza papa/batata + ensalada grande', 2),
  ('lunch', 'Opción 3', '5-6oz pavo molido + ¾ taza quinoa + 1 taza vegetales', 3),
  ('lunch', 'Opción 4', '1 tortilla integral mediana + 5-6oz pollo/pavo + lechuga, espinaca, vegetales + 1 cucharada yogurt griego como salsa', 4),

  ('dinner', 'Opción 1', '5-6oz pollo + ½ taza arroz + 2 tazas vegetales', 1),
  ('dinner', 'Opción 2', '5-6oz pescado + ½ taza batata + ensalada grande', 2),
  ('dinner', 'Opción 3', '5-6oz carne magra + ½ taza pasta integral + 2 tazas vegetales', 3),
  ('dinner', 'Opción 4 (cuando no tengas apetito)', '1 scoop proteína whey + 1 taza agua o leche de almendra sin azúcar + 1 banana + ½ taza berries + 1 cucharada mantequilla de maní', 4)
) as x(meal_type, option_label, description, order_index);

select meal_type, option_label, description from public.meal_options
where user_id = (select client_id from _dianexy)
order by meal_type, order_index;

select calories, protein_g, carbs_g, fat_g from public.nutrition_targets
where user_id = (select client_id from _dianexy);
