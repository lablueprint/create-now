-- Date/time helpers

-- app_today(): today's date in Pacific time (handles PST/PDT automatically).
-- Use this instead of current_date, which is UTC on Supabase.

create function public.app_today()
returns date
language sql
stable
set search_path = ''
as $$
  select (now() at time zone 'America/Los_Angeles')::date;
$$;

grant execute on function public.app_today() to authenticated, service_role;
