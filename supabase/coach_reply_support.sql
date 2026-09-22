-- Lets a coach account write coach_reply on any client's check-in.
-- Builds on is_coach() from coach_view_support.sql (run that first if you haven't).
-- Safe to re-run.

drop policy if exists "checkins: coach update reply" on public.checkins;
create policy "checkins: coach update reply" on public.checkins
  for update using (public.is_coach())
  with check (public.is_coach());
