-- pgTAP tests for public.profiles

begin;
create extension if not exists pgtap with schema extensions;

select plan(23);

-- Create test users
insert into auth.users (id, email) values
  ('a0000000-0000-0000-0000-000000000001', 'test_artist_a@test.local'),
  ('b0000000-0000-0000-0000-000000000001', 'test_artist_b@test.local'),
  ('ad000000-0000-0000-0000-000000000001', 'test_admin@test.local'),
  ('c0000000-0000-0000-0000-000000000001', 'test_new_user@test.local');

insert into public.profiles (id, username, birth_date, state, track, role) values
  ('a0000000-0000-0000-0000-000000000001', 'test_artist_a', '2012-01-01', 'CA', 'beginner', 'artist'),
  ('b0000000-0000-0000-0000-000000000001', 'test_artist_b', '2011-06-15', 'NY', 'advanced', 'artist'),
  ('ad000000-0000-0000-0000-000000000001', 'test_admin',    '1990-03-03', 'CA', 'advanced', 'admin');

-- Schema
select has_table('public', 'profiles', 'profiles table exists');
select col_is_pk('public', 'profiles', 'id', 'id is the primary key');
select col_not_null('public', 'profiles', 'username',   'username is required');
select col_not_null('public', 'profiles', 'birth_date', 'birth_date is required');
select col_not_null('public', 'profiles', 'state',      'state is required');
select col_not_null('public', 'profiles', 'role',       'role is required');
select is(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  true,
  'RLS is enabled on profiles'
);
select policies_are('public', 'profiles', array[
  'Users can read their own profile',
  'Admins can read all profiles',
  'Users can create their own profile',
  'Users can update their own profile'
], 'profiles has exactly the expected policies');

-- Constraints and defaults
select throws_ok(
  $$ insert into public.profiles (id, username, birth_date, state)
     values ('c0000000-0000-0000-0000-000000000001', 'some_user', '2010-01-01', 'ZZ') $$,
  '23514', null, 'state must be a valid US state code'
);
select throws_ok(
  $$ insert into public.profiles (id, username, birth_date, state)
     values ('c0000000-0000-0000-0000-000000000001', 'some_user', current_date + 1, 'CA') $$,
  '23514', null, 'birth_date cannot be in the future'
);
select throws_ok(
  $$ insert into public.profiles (id, username, birth_date, state)
     values ('c0000000-0000-0000-0000-000000000001', 'test_artist_a', '2010-01-01', 'CA') $$,
  '23505', null, 'username must be unique'
);
select col_default_is('public', 'profiles', 'role', 'artist'::public.user_role, 'role defaults to artist');
select col_default_is('public', 'profiles', 'track', 'beginner'::public.art_track, 'track defaults to beginner');

-- RLS as artist A
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a0000000-0000-0000-0000-000000000001","role":"authenticated"}', true);

select results_eq(
  $$ select username from public.profiles where username like 'test\_%' $$,
  $$ values ('test_artist_a') $$,
  'artist can only see their own profile'
);
select is_empty(
  $$ update public.profiles set track = 'beginner'
     where id = 'b0000000-0000-0000-0000-000000000001' returning id $$,
  'artist cannot update another user''s profile'
);
select lives_ok(
  $$ update public.profiles set track = 'advanced', state = 'TX'
     where id = 'a0000000-0000-0000-0000-000000000001' $$,
  'artist can update their own track and state'
);
select throws_ok(
  $$ update public.profiles set role = 'admin'
     where id = 'a0000000-0000-0000-0000-000000000001' $$,
  '42501', null, 'artist cannot change their own role'
);
select throws_ok(
  $$ update public.profiles set birth_date = '2000-01-01'
     where id = 'a0000000-0000-0000-0000-000000000001' $$,
  '42501', null, 'artist cannot change their own birth_date'
);
select throws_ok(
  $$ insert into public.profiles (id, username, birth_date, state)
     values ('c0000000-0000-0000-0000-000000000001', 'impostor', '2010-01-01', 'CA') $$,
  '42501', null, 'artist cannot create a profile for someone else'
);

-- RLS as a new user
select set_config('request.jwt.claims', '{"sub":"c0000000-0000-0000-0000-000000000001","role":"authenticated"}', true);

select lives_ok(
  $$ insert into public.profiles (id, username, birth_date, state, track)
     values ('c0000000-0000-0000-0000-000000000001', 'test_new_user', '2013-02-02', 'WA', 'beginner') $$,
  'new user can create their own profile'
);

-- RLS as admin
select set_config('request.jwt.claims', '{"sub":"ad000000-0000-0000-0000-000000000001","role":"authenticated"}', true);

select results_eq(
  $$ select count(*)::int from public.profiles where username like 'test\_%' $$,
  $$ values (4) $$,
  'admin can see all profiles'
);

-- RLS as logged-out
reset role;
set local role anon;

select throws_ok(
  $$ select * from public.profiles $$,
  '42501', null, 'logged-out visitors cannot read profiles'
);

-- Cascade: deleting the auth user deletes the profile
reset role;
delete from auth.users where id = 'b0000000-0000-0000-0000-000000000001';

select is_empty(
  $$ select 1 from public.profiles where id = 'b0000000-0000-0000-0000-000000000001' $$,
  'deleting an auth user deletes their profile'
);

select * from finish();
rollback;
