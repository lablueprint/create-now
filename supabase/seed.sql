-- All accounts use the password: password123
--
--   artist1@example.com  -> artist, beginner
--   artist2@example.com  -> artist, advanced
--   admin@example.com    -> admin

-- Auth users
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select
  '00000000-0000-0000-0000-000000000000', u.id, 'authenticated', 'authenticated', u.email,
  extensions.crypt('password123', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}', '{}', now(), now(),
  '', '', '', ''
from (values
  ('11111111-1111-1111-1111-111111111111'::uuid, 'artist1@example.com'),
  ('22222222-2222-2222-2222-222222222222'::uuid, 'artist2@example.com'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'admin@example.com')
) as u(id, email);

insert into auth.identities (
  id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at
)
select
  gen_random_uuid(), u.id, u.id::text, 'email',
  jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
  now(), now(), now()
from auth.users u
where u.email like '%@example.com';

-- Profiles
insert into public.profiles (id, username, birth_date, state, track, role) values
  ('11111111-1111-1111-1111-111111111111', 'sunny_sketches', '2012-04-15', 'CA', 'beginner', 'artist'),
  ('22222222-2222-2222-2222-222222222222', 'inkwell_ivy',    '2009-09-02', 'NY', 'advanced', 'artist'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'createnow_staff','1995-01-20', 'CA', 'advanced', 'admin');
