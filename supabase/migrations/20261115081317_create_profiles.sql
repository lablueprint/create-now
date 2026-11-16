SET local check_function_bodies = off;

CREATE TABLE "public"."profiles" (
  "id"         uuid         NOT NULL,
  "username"   text         NOT NULL,
  "birth_date" date         NOT NULL,
  "state"      character(2) NOT NULL,
  CONSTRAINT "profiles_birth_date_check" CHECK (((birth_date > '1900-01-01'::date) AND (birth_date <= CURRENT_DATE))),
  CONSTRAINT "profiles_pkey" PRIMARY KEY (id),
  CONSTRAINT "profiles_state_check"
    CHECK
    ((state = ANY (ARRAY['AL'::bpchar, 'AK'::bpchar, 'AZ'::bpchar, 'AR'::bpchar, 'CA'::bpchar, 'CO'::bpchar, 'CT'::bpchar, 'DE'::bpchar, 'DC'::bpchar, 'FL'::bpchar, 'GA'::bpchar,
    'HI'::bpchar,
    'ID'::bpchar,
    'IL'::bpchar,
    'IN'::bpchar,
    'IA'::bpchar,
    'KS'::bpchar,
    'KY'::bpchar,
    'LA'::bpchar,
    'ME'::bpchar,
    'MD'::bpchar,
    'MA'::bpchar,
    'MI'::bpchar,
    'MN'::bpchar,
    'MS'::bpchar,
    'MO'::bpchar,
    'MT'::bpchar,
    'NE'::bpchar,
    'NV'::bpchar,
    'NH'::bpchar,
    'NJ'::bpchar,
    'NM'::bpchar,
    'NY'::bpchar,
    'NC'::bpchar,
    'ND'::bpchar,
    'OH'::bpchar,
    'OK'::bpchar,
    'OR'::bpchar,
    'PA'::bpchar,
    'RI'::bpchar, 'SC'::bpchar, 'SD'::bpchar, 'TN'::bpchar, 'TX'::bpchar, 'UT'::bpchar, 'VT'::bpchar, 'VA'::bpchar, 'WA'::bpchar, 'WV'::bpchar, 'WI'::bpchar, 'WY'::bpchar]))),
  CONSTRAINT "profiles_username_key" UNIQUE (username)
);

ALTER TABLE "public"."profiles"
  ENABLE ROW LEVEL SECURITY;

CREATE TYPE "public"."art_track" AS ENUM (
  'beginner',
  'advanced'
);

ALTER TABLE "public"."profiles"
  ADD COLUMN "track" public.art_track NOT NULL DEFAULT 'beginner'::public.art_track;

CREATE TYPE "public"."user_role" AS ENUM (
  'artist',
  'admin'
);

ALTER TABLE "public"."profiles"
  ADD COLUMN "role" public.user_role NOT NULL DEFAULT 'artist'::public.user_role;

ALTER TABLE "public"."profiles"
  ADD COLUMN "created_at" timestamp WITH time zone NOT NULL DEFAULT now();

CREATE OR REPLACE FUNCTION public.is_admin()
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$function$;

REVOKE ALL ON FUNCTION "public"."is_admin"() FROM PUBLIC, "anon", "service_role";

ALTER TABLE "public"."profiles"
  ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE POLICY "Admins can read all profiles" ON "public"."profiles"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT public.is_admin() AS is_admin));

CREATE POLICY "Users can create their own profile" ON "public"."profiles"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Users can read their own profile" ON "public"."profiles"
  FOR SELECT
  TO "authenticated"
  USING ((id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Users can update their own profile" ON "public"."profiles"
  FOR UPDATE
  TO "authenticated"
  USING ((id = ( SELECT auth.uid() AS uid)))
  WITH CHECK ((id = ( SELECT auth.uid() AS uid)));

GRANT EXECUTE ON FUNCTION "public"."is_admin"() TO "authenticated";

REVOKE ALL ON FUNCTION "public"."is_admin"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."is_admin"() TO "postgres";

REVOKE ALL ON TABLE "public"."profiles" FROM "anon";

GRANT MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."profiles" TO "anon";

REVOKE ALL ON TABLE "public"."profiles" FROM "authenticated";

REVOKE ALL ("birth_date") ON TABLE "public"."profiles" FROM "authenticated";

GRANT INSERT ("birth_date") ON TABLE "public"."profiles" TO "authenticated";

REVOKE ALL ("id") ON TABLE "public"."profiles" FROM "authenticated";

GRANT INSERT ("id") ON TABLE "public"."profiles" TO "authenticated";

REVOKE ALL ("state") ON TABLE "public"."profiles" FROM "authenticated";

GRANT INSERT ("state"), UPDATE ("state") ON TABLE "public"."profiles" TO "authenticated";

REVOKE ALL ("track") ON TABLE "public"."profiles" FROM "authenticated";

GRANT INSERT ("track"), UPDATE ("track") ON TABLE "public"."profiles" TO "authenticated";

REVOKE ALL ("username") ON TABLE "public"."profiles" FROM "authenticated";

GRANT INSERT ("username"), UPDATE ("username") ON TABLE "public"."profiles" TO "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."profiles" TO "authenticated";

REVOKE ALL ON TABLE "public"."profiles" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."profiles" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."profiles" TO "service_role";
