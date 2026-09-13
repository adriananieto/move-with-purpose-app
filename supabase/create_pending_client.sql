-- Pre-provision a client's login before she signs up herself.
-- Edit the 3 values below, then run this whole script in the Supabase SQL editor.
--
-- What it does: creates her real auth.users row (pre-confirmed, no password set yet).
-- Your existing signup trigger fires automatically from that insert and creates her
-- `profiles` (+ `nutrition_targets`) row exactly like a normal signup — so her real
-- program can be built against a real profiles.id right away.
--
-- She logs in for the first time later via "Forgot password?" on the login screen,
-- using this same email, to set her own password.
--
-- Run supabase/update_handle_new_user.sql FIRST if you haven't already (adds plan_tier
-- support to the trigger) — otherwise plan_tier below is silently ignored and she gets
-- the default 'Premium'.
--
-- If any column below errors, your live auth.users differs slightly from the standard
-- shape assumed here — check the actual columns in the Supabase dashboard and adjust.

drop table if exists _new_client_params;
create temporary table _new_client_params (
  email text,
  full_name text,
  plan_tier text
);
insert into _new_client_params values (
  'rosaida@example.com',   -- <-- EDIT: her real email
  'Rosaida ___',            -- <-- EDIT: her real full name (as you want it stored)
  'Premium'                 -- <-- EDIT if she's on a different tier
);

do $$
declare
  v_email     text;
  v_full_name text;
  v_plan_tier text;
  v_user_id   uuid := gen_random_uuid();
begin
  select email, full_name, plan_tier
  into v_email, v_full_name, v_plan_tier
  from _new_client_params;

  if exists (select 1 from auth.users where email = v_email) then
    raise exception 'A user with email % already exists — she may already be set up. Check profiles/auth.users before re-running.', v_email;
  end if;

  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, recovery_token, email_change, email_change_token_new
  ) values (
    '00000000-0000-0000-0000-000000000000',
    v_user_id, 'authenticated', 'authenticated', v_email, '',
    now(),
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    jsonb_build_object('full_name', v_full_name, 'plan_tier', v_plan_tier),
    now(), now(),
    '', '', '', ''
  );

  -- Some Supabase auth versions also expect a matching identity row for email/password
  -- sign-in to recognize the account. Harmless best-effort — remove this block if it errors
  -- and her project's auth.identities shape turns out to differ.
  insert into auth.identities (
    id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
  ) values (
    gen_random_uuid(), v_user_id, v_user_id::text,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
    'email', now(), now(), now()
  );
end $$;

-- Confirm the trigger created her profile:
select p.id as client_id, p.full_name, p.plan_tier, p.member_since
from public.profiles p
join auth.users u on u.id = p.id
join _new_client_params c on c.email = u.email;
