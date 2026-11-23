ALTER TYPE "public"."art_track" RENAME TO "track";

CREATE TYPE "public"."activity_kind" AS ENUM (
  'upload',
  'daily_prompt'
);

CREATE TYPE "public"."guardian_consent" AS ENUM (
  'not_required',
  'pending',
  'approved',
  'denied'
);

CREATE TYPE "public"."moderation_status" AS ENUM (
  'pending',
  'flagged',
  'approved',
  'removed'
);

CREATE TYPE "public"."prompt_status" AS ENUM (
  'draft',
  'published',
  'archived'
);

CREATE TYPE "public"."submission_visibility" AS ENUM (
  'private',
  'community'
);
