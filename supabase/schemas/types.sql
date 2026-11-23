-- enums

create type public.user_role as enum ('artist', 'admin');
create type public.track as enum ('beginner', 'advanced');
create type public.guardian_consent as enum ('not_required', 'pending', 'approved', 'denied');
create type public.activity_kind as enum ('upload', 'daily_prompt');
create type public.prompt_status as enum ('draft', 'published', 'archived');
create type public.submission_visibility as enum ('private', 'community');
create type public.moderation_status as enum ('pending', 'flagged', 'approved', 'removed');
