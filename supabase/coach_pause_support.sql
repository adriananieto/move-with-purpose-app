-- Lets the coach pause / resume a client's program from coach-clients.html.
-- RLS on profiles only lets each user update their OWN row, and a broad
-- "coach can update any profile" policy would expose every column. Instead,
-- these two security-definer functions touch ONLY paused_since / paused_days,
-- and only when the caller is a coach (is_coach() from coach_view_support.sql).
-- p_today is the coach's LOCAL date, so day counts match what the app shows.
-- Safe to re-run.

alter table public.profiles add column if not exists paused_since date;
alter table public.profiles add column if not exists paused_days int not null default 0;

create or replace function public.coach_pause_client(p_client_id uuid, p_today date)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'Only coaches can pause a client';
  end if;
  update public.profiles
     set paused_since = p_today
   where id = p_client_id
     and paused_since is null;
end;
$$;

create or replace function public.coach_resume_client(p_client_id uuid, p_today date)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_coach() then
    raise exception 'Only coaches can resume a client';
  end if;
  update public.profiles
     set paused_days = coalesce(paused_days, 0) + greatest(0, p_today - paused_since),
         paused_since = null
   where id = p_client_id
     and paused_since is not null;
end;
$$;

revoke all on function public.coach_pause_client(uuid, date) from public, anon;
revoke all on function public.coach_resume_client(uuid, date) from public, anon;
grant execute on function public.coach_pause_client(uuid, date) to authenticated;
grant execute on function public.coach_resume_client(uuid, date) to authenticated;
