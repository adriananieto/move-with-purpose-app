-- Adds a coach-defined nutrition plan per client, beyond the single daily total
-- already in nutrition_targets:
--   1. meal_targets      — macro goal for each specific meal of the day
--   2. recommended_foods — a grouped food list (protein/carbs/fats/etc) with portions
--   3. meal_options      — ready-made meal choices per meal type, with portions + macros
-- All owner-read-only from the client side; you fill these in per client via SQL,
-- same as workouts. Uses ADD COLUMN IF NOT EXISTS throughout so it's safe even if a
-- table with this name already existed from an earlier experiment — it patches the
-- shape instead of assuming CREATE TABLE defined it. Safe to re-run.

create table if not exists public.meal_targets (id bigint generated always as identity primary key);
alter table public.meal_targets add column if not exists user_id uuid references public.profiles(id) on delete cascade;
alter table public.meal_targets add column if not exists meal_type text;
alter table public.meal_targets add column if not exists calories int default 0;
alter table public.meal_targets add column if not exists protein_g int default 0;
alter table public.meal_targets add column if not exists carbs_g int default 0;
alter table public.meal_targets add column if not exists fat_g int default 0;
create unique index if not exists meal_targets_user_meal_unique on public.meal_targets (user_id, meal_type);

alter table public.meal_targets enable row level security;

drop policy if exists "meal_targets: owner select" on public.meal_targets;
create policy "meal_targets: owner select" on public.meal_targets
  for select using (auth.uid() = user_id);

drop policy if exists "meal_targets: coach select all" on public.meal_targets;
create policy "meal_targets: coach select all" on public.meal_targets
  for select using (public.is_coach());

create table if not exists public.recommended_foods (id bigint generated always as identity primary key);
alter table public.recommended_foods drop constraint if exists recommended_foods_category_check;
alter table public.recommended_foods add column if not exists user_id uuid references public.profiles(id) on delete cascade;
alter table public.recommended_foods add column if not exists category text;
alter table public.recommended_foods add column if not exists name text;
alter table public.recommended_foods add column if not exists portion text;
alter table public.recommended_foods add column if not exists order_index int default 0;

alter table public.recommended_foods enable row level security;

drop policy if exists "recommended_foods: owner select" on public.recommended_foods;
create policy "recommended_foods: owner select" on public.recommended_foods
  for select using (auth.uid() = user_id);

drop policy if exists "recommended_foods: coach select all" on public.recommended_foods;
create policy "recommended_foods: coach select all" on public.recommended_foods
  for select using (public.is_coach());

create table if not exists public.meal_options (id bigint generated always as identity primary key);
alter table public.meal_options add column if not exists user_id uuid references public.profiles(id) on delete cascade;
alter table public.meal_options add column if not exists meal_type text;
alter table public.meal_options add column if not exists option_label text;
alter table public.meal_options add column if not exists description text;
alter table public.meal_options add column if not exists calories int;
alter table public.meal_options add column if not exists protein_g int;
alter table public.meal_options add column if not exists carbs_g int;
alter table public.meal_options add column if not exists fat_g int;
alter table public.meal_options add column if not exists order_index int default 0;

alter table public.meal_options enable row level security;

drop policy if exists "meal_options: owner select" on public.meal_options;
create policy "meal_options: owner select" on public.meal_options
  for select using (auth.uid() = user_id);

drop policy if exists "meal_options: coach select all" on public.meal_options;
create policy "meal_options: coach select all" on public.meal_options
  for select using (public.is_coach());

-- Confirm the shape each table ended up with:
select table_name, column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name in ('meal_targets', 'recommended_foods', 'meal_options')
order by table_name, ordinal_position;
