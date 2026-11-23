create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  username    text not null unique,
  birth_date  date not null
              check (birth_date > '1900-01-01' and birth_date <= public.app_today()),
  state       char(2) not null
              check (state in (
                'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN',
                'IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH',
                'NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT',
                'VT','VA','WA','WV','WI','WY'
              )),
  track       public.track not null default 'beginner',
  role        public.user_role not null default 'artist',
  created_at  timestamptz not null default now()
);

-- Grants
grant select on public.profiles to authenticated;
grant insert (id, username, birth_date, state, track) on public.profiles to authenticated;
grant update (username, state, track) on public.profiles to authenticated;
grant all on public.profiles to service_role;

-- Row Level Security
alter table public.profiles enable row level security;

create policy "Users can read their own profile"
  on public.profiles for select
  to authenticated
  using (id = (select auth.uid()));

create policy "Admins can read all profiles"
  on public.profiles for select
  to authenticated
  using ((select public.is_admin()));

create policy "Users can create their own profile"
  on public.profiles for insert
  to authenticated
  with check (id = (select auth.uid()));

create policy "Users can update their own profile"
  on public.profiles for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));