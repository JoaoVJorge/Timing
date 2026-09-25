-- =============================================================================
-- 01 · Profiles
-- Public profiles, the owner-only private data split off them, presence,
-- and the trigger that creates a profile as soon as an auth user exists.
-- Requires: 00_common.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Friend code generator
-- -----------------------------------------------------------------------------

-- Generates a unique friend code, retrying until it finds one not already in
-- use. A single random draw could (rarely) collide with the unique constraint
-- and fail the insert; the loop makes generation reliable.
create or replace function public.generate_friend_code()
returns text
language plpgsql
as $$
declare
  candidate text;
begin
  loop
    candidate := upper(
      substr(md5(random()::text || clock_timestamp()::text), 1, 10)
    );
    exit when not exists (
      select 1 from public.profiles where friend_code = candidate
    );
  end loop;
  return candidate;
end;
$$;

-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  friend_code text not null default public.generate_friend_code() unique,
  is_dark_mode boolean not null default false,
  user_name text not null default '',
  nick_name text not null default '',
  email text,
  phone_number text,
  birth_date date,
  profile_photo_base64 text,
  accent_color_value bigint not null default 4294940679,
  avatar_icon_index integer not null default 0,
  is_online boolean not null default false,
  last_seen_at timestamptz,
  notifications_enabled boolean not null default true,
  language_code text,
  focus_lock_studying_enabled boolean not null default false,
  focus_lock_exercises_enabled boolean not null default false,
  focus_lock_reading_enabled boolean not null default false,
  focus_lock_hobbies_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists focus_lock_studying_enabled boolean not null default false,
  add column if not exists focus_lock_exercises_enabled boolean not null default false,
  add column if not exists focus_lock_reading_enabled boolean not null default false,
  add column if not exists focus_lock_hobbies_enabled boolean not null default false,
  add column if not exists is_online boolean not null default false,
  add column if not exists last_seen_at timestamptz;

-- Personally identifiable fields are kept in an owner-only table. Keeping
-- them on profiles would expose them whenever the public profile row is made
-- visible to a friend or group peer by RLS.
create table if not exists public.profile_private_data (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  email text,
  phone_number text,
  birth_date date,
  updated_at timestamptz not null default now()
);

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'email'
  ) then
    execute $migration$
      insert into public.profile_private_data (
        user_id, email, phone_number, birth_date
      )
      select id, email, phone_number, birth_date
      from public.profiles
      on conflict (user_id) do update
      set
        email = coalesce(profile_private_data.email, excluded.email),
        phone_number = coalesce(
          profile_private_data.phone_number, excluded.phone_number
        ),
        birth_date = coalesce(
          profile_private_data.birth_date, excluded.birth_date
        )
    $migration$;
  end if;
end $$;

alter table public.profiles
  drop column if exists email,
  drop column if exists phone_number,
  drop column if exists birth_date;

-- -----------------------------------------------------------------------------
-- Constraints
-- -----------------------------------------------------------------------------

-- Existing installations do not receive CHECK clauses from CREATE TABLE IF
-- NOT EXISTS. Add equivalent constraints as NOT VALID: new writes are guarded
-- immediately, while legacy rows can be cleaned and validated separately.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_photo_size_check'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles add constraint profiles_photo_size_check
      check (
        profile_photo_base64 is null
        or octet_length(profile_photo_base64) <= 2000000
      ) not valid;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

-- GIN trigram indexes so search_friend_candidates()'s `ilike '%...%'` filter
-- can use an index instead of scanning every profile (a leading wildcard rules
-- out a plain b-tree index).
create index if not exists profiles_user_name_trgm_idx
  on public.profiles using gin (user_name gin_trgm_ops);
create index if not exists profiles_nick_name_trgm_idx
  on public.profiles using gin (nick_name gin_trgm_ops);
create index if not exists profiles_friend_code_trgm_idx
  on public.profiles using gin (friend_code gin_trgm_ops);

-- -----------------------------------------------------------------------------
-- Views
-- -----------------------------------------------------------------------------

create or replace view public.profile_presence_status
with (security_invoker = true) as
select
  id,
  coalesce(
    is_online and last_seen_at > now() - interval '2 minutes',
    false
  ) as is_online,
  last_seen_at
from public.profiles;

grant select on public.profile_presence_status to authenticated;

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

-- Creates the profile row as soon as the auth user exists, instead of relying
-- on the app's first profile sync. Anything that references public.profiles
-- before that first sync (friendships, group membership) would otherwise fail.
-- The app's later upsert fills in the remaining fields.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  insert into public.profile_private_data (user_id, email, phone_number)
  values (new.id, new.email, new.phone)
  on conflict (user_id) do update
  set email = excluded.email, phone_number = excluded.phone_number;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

drop trigger if exists trg_profiles_set_updated_at on public.profiles;
create trigger trg_profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists trg_profile_private_data_set_updated_at
  on public.profile_private_data;
create trigger trg_profile_private_data_set_updated_at
  before update on public.profile_private_data
  for each row execute function public.set_updated_at();
