SET local check_function_bodies = off;

ALTER TABLE "public"."profiles"
  DROP CONSTRAINT "profiles_birth_date_check";

CREATE OR REPLACE FUNCTION public.app_today()
  RETURNS date
  LANGUAGE sql
  STABLE
  SET search_path TO ''
  AS $function$
  select (now() at time zone 'America/Los_Angeles')::date;
$function$;

REVOKE ALL ON FUNCTION "public"."app_today"() FROM "anon";

GRANT EXECUTE ON FUNCTION "public"."app_today"() TO PUBLIC, "authenticated";

REVOKE ALL ON FUNCTION "public"."app_today"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."app_today"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."app_today"() TO "service_role";

ALTER TABLE "public"."profiles"
  ADD CONSTRAINT "profiles_birth_date_check" CHECK (((birth_date > '1900-01-01'::date) AND (birth_date <= public.app_today())));
