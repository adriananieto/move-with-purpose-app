-- TEMPORARY password so we can preview Gixallys's real client-facing screens
-- before she logs in herself. She can still overwrite this any time using
-- "Forgot password?" with her own email — this doesn't block that.
-- Safe to re-run.

create extension if not exists pgcrypto;

update auth.users
set encrypted_password = crypt('PreviewOnly2024!', gen_salt('bf'))
where email = 'Gixallysg@gmail.com';
