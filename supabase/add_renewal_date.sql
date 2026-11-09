-- Adds a renewal_date to each client's profile, so the app can remind her to
-- pay via ATH Móvil (payment itself stays outside the app). You update this
-- date by hand each time someone renews — move it forward one cycle and the
-- reminder clears itself. Safe to re-run.

alter table public.profiles
  add column if not exists renewal_date date;

-- Example: set (or update) a client's next renewal date.
-- update public.profiles p
-- set renewal_date = '2026-10-15'
-- from auth.users u
-- where u.id = p.id and u.email = 'EDIT_ME@example.com';
