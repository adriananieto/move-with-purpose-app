-- Move With Purpose — database schema
-- Run this in Supabase: Dashboard → SQL Editor → New query → paste → Run
-- Safe to re-run: it drops any existing objects first, then recreates everything.
-- NOTE: re-running this wipes all workout/nutrition/checkin data (fresh start).

-- ============================================================
-- RESET (drop everything from a previous run, if any)
-- ============================================================
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();

drop policy if exists "photos: read all" on storage.objects;
drop policy if exists "photos: owner insert" on storage.objects;
drop policy if exists "photos: owner update" on storage.objects;
drop policy if exists "photos: owner delete" on storage.objects;

drop table if exists public.meal_log_items cascade;
drop table if exists public.meal_logs cascade;
drop table if exists public.checkins cascade;
drop table if exists public.exercise_logs cascade;
drop table if exists public.exercises cascade;
drop table if exists public.workout_sections cascade;
drop table if exists public.workout_days cascade;
drop table if exists public.programs cascade;
drop table if exists public.meal_plan_items cascade;
drop table if exists public.nutrition_targets cascade;
drop table if exists public.progress_photos cascade;
drop table if exists public.body_weight_logs cascade;
drop table if exists public.profiles cascade;

-- ============================================================
-- PROFILES (one row per user, mirrors auth.users)
-- ============================================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  plan_tier text not null default 'Premium',
  member_since date not null default current_date,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles: read own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles: update own" on public.profiles
  for update using (auth.uid() = id);

-- ============================================================
-- BODY WEIGHT + COMPOSITION LOGS
-- ============================================================
create table public.body_weight_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  weight_lb numeric not null,
  body_fat_pct numeric,
  muscle_mass_pct numeric,
  logged_at date not null default current_date,
  created_at timestamptz not null default now()
);

alter table public.body_weight_logs enable row level security;

create policy "body_weight_logs: owner all" on public.body_weight_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================
-- PROGRESS PHOTOS (metadata; files live in Storage bucket 'photos')
-- ============================================================
create table public.progress_photos (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  storage_path text not null,
  taken_at date not null default current_date,
  created_at timestamptz not null default now()
);

alter table public.progress_photos enable row level security;

create policy "progress_photos: owner all" on public.progress_photos
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================
-- WORKOUT SPLIT: days -> sections -> exercises (shared catalog)
-- ============================================================
create table public.workout_days (
  id bigint generated always as identity primary key,
  day_number int not null,
  name text not null
);

create table public.workout_sections (
  id bigint generated always as identity primary key,
  workout_day_id bigint not null references public.workout_days(id) on delete cascade,
  name text not null,
  order_index int not null
);

create table public.exercises (
  id bigint generated always as identity primary key,
  section_id bigint not null references public.workout_sections(id) on delete cascade,
  name text not null,
  order_index int not null,
  target_sets int not null,
  target_reps int not null,
  video_url text
);

alter table public.workout_days enable row level security;
alter table public.workout_sections enable row level security;
alter table public.exercises enable row level security;

create policy "workout_days: read all authenticated" on public.workout_days
  for select using (auth.role() = 'authenticated');
create policy "workout_sections: read all authenticated" on public.workout_sections
  for select using (auth.role() = 'authenticated');
create policy "exercises: read all authenticated" on public.exercises
  for select using (auth.role() = 'authenticated');

-- ============================================================
-- EXERCISE LOGS (per-set results logged by the client)
-- ============================================================
create table public.exercise_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  exercise_id bigint not null references public.exercises(id) on delete cascade,
  set_number int not null,
  weight_lb numeric,
  reps int,
  notes text,
  logged_at timestamptz not null default now()
);

alter table public.exercise_logs enable row level security;

create policy "exercise_logs: owner all" on public.exercise_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================
-- NUTRITION TARGETS (daily macro goals per user)
-- ============================================================
create table public.nutrition_targets (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  calories int not null default 1800,
  protein_g int not null default 130,
  carbs_g int not null default 180,
  fat_g int not null default 60
);

alter table public.nutrition_targets enable row level security;

create policy "nutrition_targets: owner all" on public.nutrition_targets
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ============================================================
-- MEAL LOGS + ITEMS (actual food logged by the client)
-- ============================================================
create table public.meal_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  meal_type text not null check (meal_type in ('breakfast','snack_am','lunch','snack_pm','dinner')),
  logged_at date not null default current_date,
  photo_path text,
  total_calories int not null default 0,
  protein_g numeric not null default 0,
  carbs_g numeric not null default 0,
  fat_g numeric not null default 0,
  created_at timestamptz not null default now()
);

create table public.meal_log_items (
  id bigint generated always as identity primary key,
  meal_log_id bigint not null references public.meal_logs(id) on delete cascade,
  food_name text not null,
  amount numeric,
  unit text,
  calories int not null default 0,
  protein_g numeric not null default 0,
  carbs_g numeric not null default 0,
  fat_g numeric not null default 0
);

alter table public.meal_logs enable row level security;
alter table public.meal_log_items enable row level security;

create policy "meal_logs: owner all" on public.meal_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "meal_log_items: owner all" on public.meal_log_items
  for all using (
    exists (select 1 from public.meal_logs m where m.id = meal_log_id and m.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.meal_logs m where m.id = meal_log_id and m.user_id = auth.uid())
  );

-- ============================================================
-- WEEKLY CHECK-INS
-- ============================================================
create table public.checkins (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  week_number int not null,
  fasting_weight_lb numeric,
  body_fat_pct numeric,
  muscle_mass_pct numeric,
  hunger_level int check (hunger_level between 1 and 5),
  energy_level int check (energy_level between 1 and 5),
  adherence_level int check (adherence_level between 1 and 5),
  stress_level int check (stress_level between 1 and 5),
  feedback_text text,
  coach_reply text,
  submitted_at timestamptz not null default now()
);

alter table public.checkins enable row level security;

create policy "checkins: owner select/insert" on public.checkins
  for select using (auth.uid() = user_id);
create policy "checkins: owner insert" on public.checkins
  for insert with check (auth.uid() = user_id);

-- ============================================================
-- NEW USER SETUP (auto-create profile + defaults on signup)
-- ============================================================
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', 'New Member'));

  insert into public.nutrition_targets (user_id) values (new.id);

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- SEED: sample 3-day split (replace with the real program later)
-- ============================================================
insert into public.workout_days (day_number, name) values
  (1, 'Lower Body'),
  (2, 'Upper Body'),
  (3, 'Conditioning');

-- Day 1: Lower Body
insert into public.workout_sections (workout_day_id, name, order_index)
select d.id, s.name, s.order_index
from public.workout_days d, (values
  ('Warm Up', 1),
  ('Workout', 2),
  ('Core', 3)
) as s(name, order_index)
where d.name = 'Lower Body';

insert into public.exercises (section_id, name, order_index, target_sets, target_reps)
select sec.id, e.name, e.order_index, e.target_sets, e.target_reps
from public.workout_sections sec
join public.workout_days d on d.id = sec.workout_day_id and d.name = 'Lower Body'
join (values
  ('Warm Up', 'Bodyweight Squat', 1, 2, 15),
  ('Warm Up', 'Leg Swings', 2, 2, 12),
  ('Workout', 'Barbell Back Squat', 1, 4, 10),
  ('Workout', 'Romanian Deadlift', 2, 4, 10),
  ('Workout', 'Bulgarian Split Squat', 3, 4, 12),
  ('Workout', 'Leg Press', 4, 3, 15),
  ('Core', 'Hanging Leg Raise', 1, 3, 12),
  ('Core', 'Plank', 2, 3, 1)
) as e(section_name, name, order_index, target_sets, target_reps)
  on e.section_name = sec.name;

-- Day 2: Upper Body
insert into public.workout_sections (workout_day_id, name, order_index)
select d.id, s.name, s.order_index
from public.workout_days d, (values
  ('Warm Up', 1),
  ('Workout', 2),
  ('Core', 3)
) as s(name, order_index)
where d.name = 'Upper Body';

insert into public.exercises (section_id, name, order_index, target_sets, target_reps)
select sec.id, e.name, e.order_index, e.target_sets, e.target_reps
from public.workout_sections sec
join public.workout_days d on d.id = sec.workout_day_id and d.name = 'Upper Body'
join (values
  ('Warm Up', 'Band Pull-Apart', 1, 2, 15),
  ('Warm Up', 'Arm Circles', 2, 2, 12),
  ('Workout', 'Barbell Bench Press', 1, 4, 10),
  ('Workout', 'Bent-Over Row', 2, 4, 10),
  ('Workout', 'Overhead Press', 3, 4, 10),
  ('Workout', 'Lat Pulldown', 4, 3, 12),
  ('Core', 'Cable Crunch', 1, 3, 15),
  ('Core', 'Side Plank', 2, 3, 1)
) as e(section_name, name, order_index, target_sets, target_reps)
  on e.section_name = sec.name;

-- Day 3: Conditioning
insert into public.workout_sections (workout_day_id, name, order_index)
select d.id, s.name, s.order_index
from public.workout_days d, (values
  ('Warm Up', 1),
  ('Cardio', 2)
) as s(name, order_index)
where d.name = 'Conditioning';

insert into public.exercises (section_id, name, order_index, target_sets, target_reps)
select sec.id, e.name, e.order_index, e.target_sets, e.target_reps
from public.workout_sections sec
join public.workout_days d on d.id = sec.workout_day_id and d.name = 'Conditioning'
join (values
  ('Warm Up', 'Jumping Jacks', 1, 2, 20),
  ('Cardio', 'Kettlebell Swing', 1, 4, 15),
  ('Cardio', 'Rowing Machine (calories)', 2, 3, 20),
  ('Cardio', 'Battle Ropes', 3, 3, 1)
) as e(section_name, name, order_index, target_sets, target_reps)
  on e.section_name = sec.name;

-- ============================================================
-- STORAGE: bucket for progress + meal photos
-- ============================================================
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do nothing;

create policy "photos: read all" on storage.objects
  for select using (bucket_id = 'photos');
create policy "photos: owner insert" on storage.objects
  for insert with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos: owner update" on storage.objects
  for update using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos: owner delete" on storage.objects
  for delete using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
