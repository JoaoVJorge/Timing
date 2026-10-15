
-- backend/schema/00_common.sql
-- =============================================================================
-- 00 · Common
-- Extensions and helpers shared by every other section.
-- Apply this section first; the rest of the schema builds on it.
-- Requires: nothing
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Extensions
-- -----------------------------------------------------------------------------

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- Shared trigger helper
-- -----------------------------------------------------------------------------

-- Stamps updated_at from the server clock on every update, so it stays
-- reliable even for rows changed by RPCs and triggers that don't set it
-- themselves. Clients that resolve sync conflicts by comparing updated_at
-- can then trust it regardless of which code path touched the row.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- backend/schema/01_profiles.sql
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
  user_name text not null default '',
  nick_name text not null default '',
  email text,
  phone_number text,
  birth_date date,
  profile_photo_base64 text,
  accent_color_value bigint not null default 4279858898,
  avatar_icon_index integer not null default 0,
  is_online boolean not null default false,
  last_seen_at timestamptz,
  notifications_enabled boolean not null default true,
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

-- New profiles start on the app's default blue accent (0xFF1976D2).
alter table public.profiles
  alter column accent_color_value set default 4279858898;

-- The UI language is a device preference kept only in local storage.
alter table public.profiles
  drop column if exists language_code;

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
-- Retired indexes
-- -----------------------------------------------------------------------------

-- The trigram indexes existed only for the retired open profile search (02).
drop index if exists public.profiles_user_name_trgm_idx;
drop index if exists public.profiles_nick_name_trgm_idx;
drop index if exists public.profiles_friend_code_trgm_idx;

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

-- backend/schema/02_friends.sql
-- =============================================================================
-- 02 · Friends
-- Friendship requests, the access helper built on them, and the RPC used
-- to find the person behind a friend code.
-- Requires: 01_profiles.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'blocked')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

create index if not exists friendships_requester_idx
  on public.friendships(requester_id);
create index if not exists friendships_addressee_idx
  on public.friendships(addressee_id);

-- -----------------------------------------------------------------------------
-- Access helpers
-- -----------------------------------------------------------------------------

create or replace function public.are_friends(user_a uuid, user_b uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.friendships f
    where f.status = 'accepted'
      and (
        f.requester_id = user_a and f.addressee_id = user_b
        or f.requester_id = user_b and f.addressee_id = user_a
      )
  );
$$;

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

-- Relationship identity belongs to the row that was originally created. RLS
-- alone cannot compare OLD and NEW values, so without these triggers an
-- invitee could redirect a pending invitation to another group, or replace a
-- friendship requester while accepting the request.
create or replace function public.keep_friendship_identity_immutable()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.requester_id is distinct from old.requester_id
     or new.addressee_id is distinct from old.addressee_id then
    raise exception 'friendship participants cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_keep_friendship_identity_immutable
  on public.friendships;
create trigger trg_keep_friendship_identity_immutable
  before update on public.friendships
  for each row execute function public.keep_friendship_identity_immutable();

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

drop function if exists public.find_profile_by_friend_code(text);
create or replace function public.find_profile_by_friend_code(lookup_code text)
returns table (
  id uuid,
  user_name text,
  nick_name text,
  friend_code text,
  accent_color_value bigint,
  avatar_icon_index integer,
  profile_photo_base64 text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id,
    p.user_name,
    p.nick_name,
    p.friend_code,
    p.accent_color_value,
    p.avatar_icon_index,
    p.profile_photo_base64
  from public.profiles p
  where p.id <> auth.uid()
    and upper(p.friend_code) = upper(replace(trim(lookup_code), '@', ''))
    and not exists (
      select 1
      from public.friendships f
      where f.status in ('pending', 'accepted')
        and (
          f.requester_id = auth.uid() and f.addressee_id = p.id
          or f.requester_id = p.id and f.addressee_id = auth.uid()
        )
    )
  limit 1;
$$;

grant execute on function public.find_profile_by_friend_code(text)
to authenticated;

-- -----------------------------------------------------------------------------
-- Retired open profile search
-- -----------------------------------------------------------------------------

-- People are found by their friend code alone. The former search listed
-- every profile for any authenticated caller, so it goes with its indexes.
drop function if exists public.search_friend_candidates(text, integer);

-- backend/schema/03_groups.sql
-- =============================================================================
-- 03 · Groups (core)
-- Group tables, their integrity rules and the membership helpers reused by
-- every group feature. Behaviour lives in 05-08.
-- Requires: 01_profiles.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  -- A home category or 'dailyGoals'. It sets the ranking metric and which
  -- personal activities each member may link (05).
  theme text not null,
  description text not null default '',
  invite_code text not null unique,
  privacy text not null default 'inviteOnly',
  -- The group's own accent; null follows each viewer's accent.
  color_value bigint,
  -- Shared ranking counts from here on; null counts since the group began.
  score_reset_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.groups
  add column if not exists description text not null default '';
alter table public.groups
  add column if not exists color_value bigint;
alter table public.groups
  add column if not exists score_reset_at timestamptz;

create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member',
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

-- Retire the old secondary role on existing installations.
alter table public.group_members
  drop constraint if exists group_members_role_check;
update public.group_members set role = 'member' where role = 'vice';
alter table public.group_members add constraint group_members_role_check
  check (role in ('owner', 'member'));

create table if not exists public.group_invitations (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  inviter_id uuid not null references public.profiles(id) on delete cascade,
  invitee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'declined')),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  unique (group_id, invitee_id),
  check (inviter_id <> invitee_id)
);

-- Someone asking to join: from the group's link, or from an invitation sent
-- by a member who is not the leader. The leader answers each one. A person
-- has at most one request per group; asking again revives the same row.
create table if not exists public.group_join_requests (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  -- The member whose invitation led here, when it did not come from the link.
  invited_by uuid references public.profiles(id) on delete set null,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'declined')),
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  unique (group_id, user_id)
);

create index if not exists group_join_requests_pending_idx
  on public.group_join_requests(group_id)
  where status = 'pending';

create table if not exists public.group_image_messages (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  image_base64 text not null,
  created_at timestamptz not null default now()
);

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
    where conname = 'groups_name_not_blank_check'
      and conrelid = 'public.groups'::regclass
  ) then
    alter table public.groups add constraint
      groups_name_not_blank_check check (btrim(name) <> '') not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'group_image_message_size_check'
      and conrelid = 'public.group_image_messages'::regclass
  ) then
    alter table public.group_image_messages add constraint
      group_image_message_size_check check (
        octet_length(image_base64) between 1 and 4200000
      ) not valid;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

create index if not exists group_members_user_idx
  on public.group_members(user_id);
create index if not exists group_invitations_invitee_idx
  on public.group_invitations(invitee_id, status);
create index if not exists group_invitations_group_idx
  on public.group_invitations(group_id);

create index if not exists group_image_messages_group_cursor_idx
  on public.group_image_messages(group_id, created_at desc, id desc);
create index if not exists group_image_messages_sender_rate_idx
  on public.group_image_messages(sender_id, created_at desc);

-- -----------------------------------------------------------------------------
-- Access helpers
-- -----------------------------------------------------------------------------

create or replace function public.is_group_member(
  target_group_id uuid,
  target_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.group_members gm
    where gm.group_id = target_group_id
      and gm.user_id = target_user_id
  );
$$;

create or replace function public.share_group(user_a uuid, user_b uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.group_members a
    join public.group_members b on b.group_id = a.group_id
    where a.user_id = user_a
      and b.user_id = user_b
  );
$$;

create or replace function public.owns_group(
  target_group_id uuid,
  target_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.groups g
    where g.id = target_group_id
      and g.owner_id = target_user_id
  );
$$;

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

create or replace function public.keep_group_invitation_identity_immutable()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.group_id is distinct from old.group_id
     or new.inviter_id is distinct from old.inviter_id
     or new.invitee_id is distinct from old.invitee_id then
    raise exception 'group invitation identity cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_keep_group_invitation_identity_immutable
  on public.group_invitations;
create trigger trg_keep_group_invitation_identity_immutable
  before update on public.group_invitations
  for each row
  execute function public.keep_group_invitation_identity_immutable();

create or replace function public.enforce_group_image_rate_limit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null or new.sender_id <> auth.uid() then
    raise exception 'image sender must match the authenticated user'
      using errcode = '42501';
  end if;
  if (
    select count(*) from public.group_image_messages m
    where m.sender_id = new.sender_id
      and m.created_at >= now() - interval '1 minute'
  ) >= 12 or (
    select count(*) from public.group_image_messages m
    where m.sender_id = new.sender_id
      and m.created_at >= now() - interval '1 day'
  ) >= 200 then
    raise exception 'image message rate limit exceeded' using errcode = '54000';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_group_image_rate_limit
  on public.group_image_messages;
create trigger trg_group_image_rate_limit
  before insert on public.group_image_messages
  for each row execute function public.enforce_group_image_rate_limit();

-- backend/schema/04_tracking.sql
-- =============================================================================
-- 04 · Tracking
-- Everything a user records about their own time: activity log, subjects,
-- daily goals and the weekly schedule, plus the progress metrics view.
-- Requires: 01_profiles.sql, 03_groups.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

create table if not exists public.activity_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  category text not null,
  subject_id text,
  subject_name text,
  seconds integer not null default 0 check (seconds >= 0),
  pages integer not null default 0 check (pages >= 0),
  completed_tasks integer not null default 0 check (completed_tasks >= 0),
  occurred_at timestamptz not null default now()
);

-- One row per "remove time" request, so a request that is sent again after a
-- lost answer is not applied twice. Only remove_activity_seconds() touches it.
create table if not exists public.activity_time_removals (
  id uuid not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.user_subjects (
  id text not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  category text not null
    check (category in ('studying', 'exercises', 'reading', 'hobbies')),
  color_value bigint not null,
  total_seconds integer not null default 0 check (total_seconds >= 0),
  goal_seconds integer not null default 0 check (goal_seconds >= 0),
  current_pages integer not null default 0 check (current_pages >= 0),
  goal_pages integer not null default 0 check (goal_pages >= 0),
  notes text not null default '',
  icon_name text not null default '',
  rest_minutes integer not null default 5 check (rest_minutes >= 0),
  focus_session_count integer not null default 1
    check (focus_session_count > 0),
  wallpaper_index integer not null default 0 check (wallpaper_index >= 0),
  activity_type text not null default 'daily'
    check (activity_type in ('daily', 'permanent')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.daily_goals (
  id text not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  color_value bigint not null,
  target_days integer not null default 0 check (target_days >= 0),
  completed_dates text[] not null default '{}',
  sequence_type text not null default 'casual'
    check (sequence_type in ('intense', 'casual')),
  last_resolved_missed_date text,
  goal_type text not null default 'total'
    check (goal_type in ('daily', 'total')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.schedule_entries (
  id text not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  weekday integer not null check (weekday between 1 and 7),
  start_minutes integer check (
    start_minutes is null or start_minutes between 0 and 1439
  ),
  end_minutes integer check (
    end_minutes is null or end_minutes between 0 and 1440
  ),
  active_from date not null default current_date,
  active_until date,
  constraint schedule_entries_active_until_check check (
    active_until is null or active_until >= active_from
  ),
  color_value bigint not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

alter table public.schedule_entries
  add column if not exists active_from date not null default current_date;
alter table public.schedule_entries
  add column if not exists active_until date;
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'schedule_entries_active_until_check'
      and conrelid = 'public.schedule_entries'::regclass
  ) then
    alter table public.schedule_entries
      add constraint schedule_entries_active_until_check
      check (active_until is null or active_until >= active_from);
  end if;
end $$;

-- Former ownership columns. Nothing reads them: a personal activity is never
-- owned by a group, it is only linked to one (05). They stay, always null, so a
-- build that still uploads them keeps syncing its personal data.
alter table public.user_subjects
  add column if not exists group_id uuid
    references public.groups(id) on delete set null;
alter table public.user_subjects
  add column if not exists group_activity_id uuid;
alter table public.user_subjects
  add column if not exists activity_type text not null default 'daily'
    check (activity_type in ('daily', 'permanent'));
alter table public.daily_goals
  add column if not exists group_id uuid
    references public.groups(id) on delete set null;
alter table public.daily_goals
  add column if not exists group_activity_id uuid;
alter table public.daily_goals
  add column if not exists sequence_type text not null default 'casual'
    check (sequence_type in ('intense', 'casual'));
alter table public.daily_goals
  add column if not exists last_resolved_missed_date text;
-- Minute of the day (device local time) the goal's daily reminder is shown;
-- null when the goal has no reminder.
alter table public.daily_goals
  add column if not exists reminder_minutes integer
    check (reminder_minutes between 0 and 1439);

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
    where conname = 'activity_entries_nonnegative_check'
      and conrelid = 'public.activity_entries'::regclass
  ) then
    alter table public.activity_entries add constraint
      activity_entries_nonnegative_check check (
        seconds >= 0 and pages >= 0 and completed_tasks >= 0
      ) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'user_subjects_progress_check'
      and conrelid = 'public.user_subjects'::regclass
  ) then
    alter table public.user_subjects add constraint
      user_subjects_progress_check check (
        total_seconds >= 0
        and goal_seconds >= 0
        and current_pages >= 0
        and goal_pages >= 0
        and rest_minutes >= 0
        and focus_session_count > 0
        and wallpaper_index >= 0
      ) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'daily_goals_target_days_check'
      and conrelid = 'public.daily_goals'::regclass
  ) then
    alter table public.daily_goals add constraint
      daily_goals_target_days_check check (target_days >= 0) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'activity_entries_reasonable_values_check'
      and conrelid = 'public.activity_entries'::regclass
  ) then
    alter table public.activity_entries add constraint
      activity_entries_reasonable_values_check check (
        seconds between 0 and 86400
        and pages between 0 and 10000
        and completed_tasks between 0 and 1000
        and (seconds > 0 or pages > 0 or completed_tasks > 0)
      ) not valid;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

create index if not exists activity_entries_user_period_idx
  on public.activity_entries(user_id, occurred_at);
create index if not exists activity_entries_user_subject_period_idx
  on public.activity_entries(user_id, subject_id, occurred_at);
create index if not exists user_subjects_user_category_idx
  on public.user_subjects(user_id, category);
create index if not exists daily_goals_user_idx
  on public.daily_goals(user_id);
create index if not exists schedule_entries_user_weekday_idx
  on public.schedule_entries(user_id, weekday, active_from, start_minutes);

drop index if exists public.user_subjects_group_activity_user_idx;
drop index if exists public.user_subjects_group_idx;
drop index if exists public.daily_goals_group_idx;

-- -----------------------------------------------------------------------------
-- Retired views
-- -----------------------------------------------------------------------------

-- Nothing ever read these aggregates: the app derives its progress numbers
-- from the activity and goal rows it already syncs.
drop view if exists public.user_progress_metrics;

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

drop trigger if exists trg_user_subjects_set_updated_at on public.user_subjects;
create trigger trg_user_subjects_set_updated_at
  before update on public.user_subjects
  for each row execute function public.set_updated_at();

drop trigger if exists trg_daily_goals_set_updated_at on public.daily_goals;
create trigger trg_daily_goals_set_updated_at
  before update on public.daily_goals
  for each row execute function public.set_updated_at();

drop trigger if exists trg_schedule_entries_set_updated_at
  on public.schedule_entries;
create trigger trg_schedule_entries_set_updated_at
  before update on public.schedule_entries
  for each row execute function public.set_updated_at();

-- An activity's log rows (activity_entries) go away with the activity when the
-- user deletes it. activity_entries.subject_id is plain text rather than a
-- foreign key (a session can reach the backend before its activity does, and a
-- foreign key would reject that row), so nothing else ever removed the log of a
-- deleted activity and it stayed in the table for good.
-- Unlinking an activity from a group, or leaving the group, deletes nothing.
create or replace function public.delete_activity_entries_of_deleted_subject()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.activity_entries
   where user_id = old.user_id
     and subject_id = old.id;
  return old;
end;
$$;

drop trigger if exists trg_delete_activity_entries_of_deleted_subject
  on public.user_subjects;
create trigger trg_delete_activity_entries_of_deleted_subject
  after delete on public.user_subjects
  for each row
  execute function public.delete_activity_entries_of_deleted_subject();

-- Client timestamps are retained for offline sessions, but their range and
-- score are bounded. Entries are immutable and can only be created through
-- record_activity_entry(), preventing arbitrary table upserts from rewriting
-- leaderboard history.
create or replace function public.validate_activity_entry()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is not null and new.user_id <> auth.uid() then
    raise exception 'activity owner must match the authenticated user'
      using errcode = '42501';
  end if;
  if new.occurred_at < now() - interval '400 days'
     or new.occurred_at > now() + interval '5 minutes' then
    raise exception 'activity timestamp is outside the accepted range'
      using errcode = '22007';
  end if;
  if new.seconds > 86400 or new.pages > 10000
     or new.completed_tasks > 1000 then
    raise exception 'activity value exceeds the accepted limit'
      using errcode = '22003';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_validate_activity_entry
  on public.activity_entries;
create trigger trg_validate_activity_entry
  before insert or update on public.activity_entries
  for each row execute function public.validate_activity_entry();

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

drop function if exists public.record_activity_entry(
  uuid, text, text, text, integer, integer, integer, timestamptz
);
create or replace function public.record_activity_entry(
  entry_id uuid,
  entry_category text,
  entry_subject_id text,
  entry_subject_name text,
  entry_seconds integer,
  entry_pages integer,
  entry_completed_tasks integer,
  entry_occurred_at timestamptz
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'authentication required' using errcode = '28000';
  end if;
  if entry_category not in ('studying', 'exercises', 'reading', 'hobbies') then
    raise exception 'invalid activity category' using errcode = '23514';
  end if;

  insert into public.activity_entries (
    id, user_id, category, subject_id, subject_name,
    seconds, pages, completed_tasks, occurred_at
  ) values (
    entry_id, current_user_id, entry_category,
    nullif(entry_subject_id, ''), left(coalesce(entry_subject_name, ''), 200),
    entry_seconds, entry_pages, entry_completed_tasks, entry_occurred_at
  )
  on conflict (id) do nothing;
end;
$$;

-- Takes time back off an activity, newest sessions first: the correction for
-- a timer that was left running. Entries stay immutable to clients; this is
-- the only way one gets shorter, and it only ever shortens the caller's own.
-- Pages and completed tasks logged with a session are kept.
drop function if exists public.remove_activity_seconds(
  uuid, text, integer, timestamptz
);
create or replace function public.remove_activity_seconds(
  removal_id uuid,
  entry_subject_id text,
  seconds_to_remove integer,
  removed_at timestamptz
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  remaining integer := seconds_to_remove;
  entry record;
begin
  if current_user_id is null then
    raise exception 'authentication required' using errcode = '28000';
  end if;
  if removal_id is null or coalesce(entry_subject_id, '') = ''
     or coalesce(seconds_to_remove, 0) <= 0 then
    return;
  end if;

  insert into public.activity_time_removals (id, user_id)
  values (removal_id, current_user_id)
  on conflict (user_id, id) do nothing;
  if not found then
    return;
  end if;
  -- A request is only ever repeated within moments of being made.
  delete from public.activity_time_removals
  where user_id = current_user_id
    and created_at < now() - interval '30 days';

  for entry in
    select a.id, a.seconds, a.pages, a.completed_tasks
    from public.activity_entries a
    where a.user_id = current_user_id
      and a.subject_id = entry_subject_id
      and a.seconds > 0
      and a.occurred_at <= removed_at
      -- Older entries can no longer be rewritten (validate_activity_entry).
      and a.occurred_at > now() - interval '399 days'
    order by a.occurred_at desc, a.id desc
    for update
  loop
    exit when remaining <= 0;
    if entry.seconds > remaining then
      update public.activity_entries
      set seconds = seconds - remaining
      where id = entry.id;
      remaining := 0;
    elsif entry.pages > 0 or entry.completed_tasks > 0 then
      update public.activity_entries set seconds = 0 where id = entry.id;
      remaining := remaining - entry.seconds;
    else
      delete from public.activity_entries where id = entry.id;
      remaining := remaining - entry.seconds;
    end if;
  end loop;
end;
$$;

drop function if exists public.activity_entry_totals(timestamptz);
create or replace function public.activity_entry_totals(period_start timestamptz)
returns table (
  category text,
  subject_id text,
  subject_name text,
  occurred_at timestamptz,
  seconds bigint,
  pages bigint,
  completed_tasks bigint
)
language sql
stable
security invoker
set search_path = public
as $$
  select
    a.category,
    a.subject_id,
    a.subject_name,
    max(a.occurred_at),
    sum(a.seconds),
    sum(a.pages),
    sum(a.completed_tasks)
  from public.activity_entries a
  where a.user_id = (select auth.uid())
    and a.occurred_at >= period_start
  group by
    date_bin(
      interval '15 minutes',
      a.occurred_at,
      timestamptz '2000-01-01 00:00:00+00'
    ),
    a.category,
    a.subject_id,
    a.subject_name;
$$;

-- backend/schema/05_group_activity_links.sql
-- =============================================================================
-- 05 · Group activity links
-- A group owns no activity. Each member links personal activities that match
-- the group's theme, and only what they record while linked counts for it.
-- Link periods preserve past contributions without importing prior history.
-- Requires: 03_groups.sql, 04_tracking.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

-- A source may contribute during several disjoint periods. Closed periods stay
-- queryable, so unlinking/relinking neither erases scores nor imports the gap.
create table if not exists public.group_activity_links (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  source_id text not null,
  started_at timestamptz not null default clock_timestamp(),
  ended_at timestamptz,
  start_date date not null default current_date,
  excluded_dates text[] not null default '{}',
  check (ended_at is null or ended_at >= started_at)
);

-- Daily goals only store dates. Snapshot newly checked dates while linked,
-- rather than treating an already-completed day as a new contribution.
create table if not exists public.group_goal_contributions (
  link_id uuid not null references public.group_activity_links(id) on delete cascade,
  completed_date date not null,
  recorded_at timestamptz not null default clock_timestamp(),
  primary key (link_id, completed_date)
);

-- -----------------------------------------------------------------------------
-- Upgrade from shared group activities
-- -----------------------------------------------------------------------------

-- Groups used to hold a shared activity that members linked to, and before
-- that handed each member a copy of it. Both become plain links to the group:
-- periods, scores, the reset boundary and the group's color are kept, and the
-- shared activity itself is dropped. Skipped once that table is gone.
alter table public.group_activity_links
  add column if not exists group_id uuid
    references public.groups(id) on delete cascade;

do $$
begin
  if to_regclass('public.group_activities') is null then
    return;
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'group_activity_links'
      and column_name = 'activity_id'
  ) then
    -- A goal only counted in a daily-goals group and an activity only in the
    -- others, so a link of the wrong kind never scored; leave it behind.
    update public.group_activity_links l set group_id = ga.group_id
    from public.group_activities ga
    join public.groups g on g.id = ga.group_id
    where ga.id = l.activity_id
      and (ga.kind = 'goal') = (g.theme = 'dailyGoals');
    delete from public.group_activity_links where group_id is null;
    alter table public.group_activity_links drop column activity_id;
  end if;

  -- Copies handed out by the group become links to that same personal row.
  insert into public.group_activity_links(
    group_id, user_id, source_id, started_at, start_date
  )
  select ga.group_id, s.user_id, s.id, greatest(ga.created_at, gm.joined_at),
    (greatest(ga.created_at, gm.joined_at) at time zone 'utc')::date
  from public.user_subjects s
  join public.group_activities ga
    on ga.id = s.group_activity_id and ga.kind = 'subject'
  join public.groups g on g.id = ga.group_id and g.theme <> 'dailyGoals'
  join public.group_members gm
    on gm.group_id = ga.group_id and gm.user_id = s.user_id
  where not exists (
    select 1 from public.group_activity_links l
    where l.group_id = ga.group_id and l.user_id = s.user_id
      and l.source_id = s.id
  );
  with copied as (
    insert into public.group_activity_links(
      group_id, user_id, source_id, started_at, start_date
    )
    select ga.group_id, d.user_id, d.id, greatest(ga.created_at, gm.joined_at),
      (greatest(ga.created_at, gm.joined_at) at time zone 'utc')::date
    from public.daily_goals d
    join public.group_activities ga
      on ga.id = d.group_activity_id and ga.kind = 'goal'
    join public.groups g on g.id = ga.group_id and g.theme = 'dailyGoals'
    join public.group_members gm
      on gm.group_id = ga.group_id and gm.user_id = d.user_id
    where not exists (
      select 1 from public.group_activity_links l
      where l.group_id = ga.group_id and l.user_id = d.user_id
        and l.source_id = d.id
    )
    returning id, user_id, source_id, start_date
  )
  insert into public.group_goal_contributions(
    link_id, completed_date, recorded_at
  )
  select copied.id, value::date, value::date::timestamptz
  from copied
  join public.daily_goals d
    on d.user_id = copied.user_id and d.id = copied.source_id
  cross join lateral unnest(d.completed_dates) value
  where value::date >= copied.start_date
  on conflict do nothing;
  update public.user_subjects set group_id = null, group_activity_id = null
  where group_id is not null or group_activity_id is not null;
  update public.daily_goals set group_id = null, group_activity_id = null
  where group_id is not null or group_activity_id is not null;

  -- A source linked to several activities of one group is now linked once.
  with ranked as (
    select l.id,
      first_value(l.id) over same_source as kept_id,
      row_number() over same_source as position
    from public.group_activity_links l
    where l.ended_at is null
    window same_source as (
      partition by l.group_id, l.user_id, l.source_id
      order by l.started_at, l.id
    )
  ), moved as (
    insert into public.group_goal_contributions(
      link_id, completed_date, recorded_at
    )
    select ranked.kept_id, c.completed_date, c.recorded_at
    from ranked
    join public.group_goal_contributions c on c.link_id = ranked.id
    where ranked.position > 1
    on conflict do nothing
  )
  delete from public.group_activity_links l
  using ranked
  where l.id = ranked.id and ranked.position > 1;

  -- A daily-goals group now takes one goal per member: the earliest link
  -- keeps counting and the others end here, with what they already earned.
  update public.group_activity_links l set ended_at = clock_timestamp()
  from (
    select link.id,
      row_number() over (
        partition by link.group_id, link.user_id
        order by link.started_at, link.id
      ) as position
    from public.group_activity_links link
    join public.groups g on g.id = link.group_id and g.theme = 'dailyGoals'
    where link.ended_at is null
  ) ranked
  where l.id = ranked.id and ranked.position > 1;

  update public.groups g
  set color_value = coalesce(g.color_value, shared.color_value),
      score_reset_at = coalesce(g.score_reset_at, shared.score_reset_at)
  from (
    select ga.group_id,
      (array_agg((ga.payload->>'color_value')::bigint order by ga.created_at)
        filter (where ga.payload->>'color_value' ~ '^[0-9]+$'))[1]
        as color_value,
      max(ga.score_reset_at) as score_reset_at
    from public.group_activities ga
    group by ga.group_id
  ) shared
  where shared.group_id = g.id;

  drop table public.group_activities cascade;
end $$;

alter table public.group_activity_links alter column group_id set not null;

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

drop index if exists public.group_activity_links_active_idx;
create unique index if not exists group_activity_links_active_group_idx
  on public.group_activity_links(group_id, user_id, source_id)
  where ended_at is null;
create index if not exists group_activity_links_user_idx
  on public.group_activity_links(user_id, source_id, started_at);

-- -----------------------------------------------------------------------------
-- Retired group-owned activities
-- -----------------------------------------------------------------------------

drop trigger if exists trg_materialize_group_activities_on_join
  on public.group_members;
drop function if exists public.materialize_group_activities_on_join();
drop function if exists public.materialize_group_activities_for_user(uuid, uuid);
drop function if exists public.group_activity_progress(uuid, text);
drop function if exists public.set_group_activity_links(
  uuid, text[], boolean, date
);

-- A build that still uploads the former ownership columns must not bring them
-- back: whatever it sends, a personal row is never owned by a group.
create or replace function public.discard_group_ownership()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.group_id := null;
  new.group_activity_id := null;
  return new;
end;
$$;

drop trigger if exists trg_protect_group_subject on public.user_subjects;
drop trigger if exists trg_discard_group_ownership on public.user_subjects;
create trigger trg_discard_group_ownership
  before insert or update on public.user_subjects
  for each row execute function public.discard_group_ownership();

drop trigger if exists trg_protect_group_goal on public.daily_goals;
drop trigger if exists trg_discard_group_ownership on public.daily_goals;
create trigger trg_discard_group_ownership
  before insert or update on public.daily_goals
  for each row execute function public.discard_group_ownership();

drop function if exists public.protect_group_subject();
drop function if exists public.protect_group_goal();

-- -----------------------------------------------------------------------------
-- Goal completion dates
-- -----------------------------------------------------------------------------

create or replace function public.validate_daily_goal_dates()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  invalid_date text;
begin
  if cardinality(new.completed_dates) > 4000 then
    raise exception 'too many completion dates' using errcode = '54000';
  end if;
  select value into invalid_date
  from unnest(new.completed_dates) as value
  where value !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
     or value::date > current_date
  limit 1;
  if invalid_date is not null
     or cardinality(new.completed_dates) <> (
       select count(distinct value) from unnest(new.completed_dates) as value
     ) then
    raise exception 'invalid, future, or duplicate completion date'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_validate_daily_goal_dates on public.daily_goals;
create trigger trg_validate_daily_goal_dates
  before insert or update on public.daily_goals
  for each row execute function public.validate_daily_goal_dates();

-- Keeps a linked goal's contributions in step with its checked dates: a day
-- checked while linked counts, and unchecking it while linked takes it back.
create or replace function public.capture_group_goal_contributions()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  delete from public.group_goal_contributions c
  using public.group_activity_links l, public.groups g
  where c.link_id = l.id and g.id = l.group_id and g.theme = 'dailyGoals'
    and l.user_id = new.user_id and l.source_id = new.id and l.ended_at is null
    and not (c.completed_date::text = any(new.completed_dates));
  insert into public.group_goal_contributions(link_id, completed_date)
  select l.id, value::date
  from public.group_activity_links l
  join public.groups g on g.id = l.group_id and g.theme = 'dailyGoals'
  cross join lateral unnest(new.completed_dates) value
  where l.user_id = new.user_id and l.source_id = new.id and l.ended_at is null
    and value::date >= l.start_date
    and not (value = any(l.excluded_dates))
    and (tg_op = 'INSERT' or not (value = any(old.completed_dates)))
  on conflict do nothing;
  return new;
end; $$;
drop trigger if exists trg_capture_group_goal_contributions on public.daily_goals;
create trigger trg_capture_group_goal_contributions after insert or update of completed_dates
on public.daily_goals for each row execute function public.capture_group_goal_contributions();

-- -----------------------------------------------------------------------------
-- Membership changes
-- -----------------------------------------------------------------------------

-- Leaving closes the member's link periods and keeps every personal activity.
-- If the last member leaves, the group is deleted so all group-owned rows that
-- cascade from public.groups are removed. If the owner leaves while members
-- remain, ownership is handed to the earliest remaining member.
create or replace function public.handle_group_member_left()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  next_owner_id uuid;
  leaving_user_was_owner boolean;
begin
  if not exists (
    select 1
    from public.groups g
    where g.id = old.group_id
  ) then
    return old;
  end if;

  update public.group_activity_links set ended_at = clock_timestamp()
  where group_id = old.group_id and user_id = old.user_id
    and ended_at is null;

  select gm.user_id
  into next_owner_id
  from public.group_members gm
  where gm.group_id = old.group_id
  order by gm.joined_at asc, gm.user_id asc
  limit 1;

  if next_owner_id is null then
    delete from public.groups g
    where g.id = old.group_id;
    return old;
  end if;

  if pg_trigger_depth() > 1 then
    return old;
  end if;

  select exists (
    select 1
    from public.groups g
    where g.id = old.group_id
      and g.owner_id = old.user_id
  )
  into leaving_user_was_owner;

  if leaving_user_was_owner or old.role = 'owner' then
    update public.groups
    set owner_id = next_owner_id
    where id = old.group_id;

    update public.group_members
    set role = case
      when user_id = next_owner_id then 'owner'
      when role = 'owner' then 'member'
      else role
    end
    where group_id = old.group_id;
  end if;

  return old;
end;
$$;

drop trigger if exists trg_cleanup_group_activities_on_leave
  on public.group_members;
drop function if exists public.cleanup_group_activities_on_leave();
drop trigger if exists trg_handle_group_member_left on public.group_members;
create trigger trg_handle_group_member_left
  after delete on public.group_members
  for each row
  execute function public.handle_group_member_left();

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

-- Atomic replacement of the caller's selection, under the membership lock.
-- Unchanged selections retain their original start; retries do not start new
-- intervals or create new rows. A source must be the caller's own and match the
-- group's theme: a goal for a daily-goals group (one at most), otherwise an
-- activity of the theme's category.
create or replace function public.set_group_activity_links(
  target_group_id uuid,
  source_ids text[] default '{}',
  local_date date default current_date
) returns void language plpgsql security definer set search_path = public
as $$
declare
  group_theme text;
  selected_ids text[];
  source text;
  change_at timestamptz;
begin
  select g.theme into group_theme from public.groups g
  where g.id = target_group_id;
  perform 1 from public.group_members
  where group_id = target_group_id and user_id = auth.uid() for update;
  if not found then raise exception 'not a group member' using errcode = '42501'; end if;
  change_at := clock_timestamp();
  if local_date is null or abs(local_date - current_date) > 1 then
    raise exception 'invalid local date' using errcode = '23514';
  end if;
  if array_position(source_ids, null) is not null then
    raise exception 'invalid sources' using errcode = '23514';
  end if;
  selected_ids := array(
    select distinct chosen from unnest(coalesce(source_ids, '{}'::text[])) chosen
  );
  if cardinality(selected_ids) > 100 then
    raise exception 'invalid sources' using errcode = '23514';
  end if;
  if group_theme = 'dailyGoals' and cardinality(selected_ids) > 1 then
    raise exception 'a daily-goals group takes a single goal'
      using errcode = '23514';
  end if;
  foreach source in array selected_ids loop
    if group_theme = 'dailyGoals' then
      perform 1 from public.daily_goals d where d.user_id = auth.uid()
        and d.id = source for update;
    else
      perform 1 from public.user_subjects s where s.user_id = auth.uid()
        and s.id = source and s.category = group_theme;
    end if;
    if not found then
      raise exception 'source is missing or incompatible' using errcode = '23514';
    end if;
  end loop;
  update public.group_activity_links set ended_at = change_at
  where group_id = target_group_id and user_id = auth.uid()
    and ended_at is null and not (source_id = any(selected_ids));
  insert into public.group_activity_links(group_id, user_id, source_id,
    started_at, start_date, excluded_dates)
  select target_group_id, auth.uid(), chosen, change_at, local_date,
    case when group_theme = 'dailyGoals' then coalesce((select d.completed_dates
      from public.daily_goals d where d.user_id = auth.uid() and d.id = chosen), '{}')
      else '{}'::text[] end
  from unnest(selected_ids) chosen
  where not exists (select 1 from public.group_activity_links l
    where l.group_id = target_group_id and l.user_id = auth.uid()
      and l.source_id = chosen and l.ended_at is null);
end; $$;

-- The caller's own activities that fit the group's theme, and which of them
-- are linked now. A peer can see aggregate scores, never another member's list
-- of personal activities or notes.
create or replace function public.group_activity_link_options(target_group_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public
as $$
declare
  group_theme text;
begin
  if not public.is_group_member(target_group_id, auth.uid()) then
    raise exception 'not a group member' using errcode = '42501';
  end if;
  select g.theme into group_theme from public.groups g
  where g.id = target_group_id;
  return jsonb_build_object(
    'theme', group_theme,
    'selected_ids', coalesce((select jsonb_agg(l.source_id order by l.started_at)
      from public.group_activity_links l where l.group_id = target_group_id
        and l.user_id = auth.uid() and l.ended_at is null), '[]'::jsonb),
    'options', case when group_theme = 'dailyGoals' then coalesce((
      select jsonb_agg(jsonb_build_object('id', d.id, 'name', d.name) order by d.name)
      from public.daily_goals d where d.user_id = auth.uid()), '[]'::jsonb)
    else coalesce((
      select jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name) order by s.name)
      from public.user_subjects s where s.user_id = auth.uid()
        and s.category = group_theme), '[]'::jsonb) end
  );
end; $$;

-- backend/schema/06_group_ranking.sql
-- =============================================================================
-- 06 · Group ranking
-- Read side of a group: the leaderboard built from what members recorded on
-- the personal activities they linked to it.
-- Requires: 03_groups.sql, 04_tracking.sql, 05_group_activity_links.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

-- Aggregated leaderboard scores for each requested group. A member scores
-- only with entries of an activity linked to that group, recorded inside one
-- of its link periods and after the group's last reset. Daily-goal groups
-- count each completion date once.
-- Doing this server-side avoids downloading every activity entry, and the
-- function runs with definer rights because members cannot read each other's
-- entries: only these aggregates leave the server.
drop function if exists public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
);
create or replace function public.group_leaderboard_scores(
  target_group_ids uuid[],
  today_start timestamptz,
  week_start timestamptz,
  month_start timestamptz
)
returns table (
  group_id uuid,
  user_id uuid,
  category text,
  today_score bigint,
  week_score bigint,
  month_score bigint,
  total_score bigint
)
language sql
stable
security definer
set search_path = public
as $$
  with authorized_groups as (
    select requested.group_id, target.theme as category,
      target.created_at, target.score_reset_at
    from unnest(target_group_ids) as requested(group_id)
    join public.groups target on target.id = requested.group_id
    where public.is_group_member(requested.group_id, auth.uid())
  ), member_scope as (
    select target.group_id, target.category, target.created_at,
      target.score_reset_at, member.user_id
    from authorized_groups target
    join public.group_members member on member.group_id = target.group_id
  ), scored_entries as (
    select
      member.group_id,
      member.user_id,
      member.category,
      activity.occurred_at,
      case
        when member.category = 'reading' then activity.pages
        else activity.seconds
      end::bigint as score
    from member_scope member
    join public.activity_entries activity on activity.user_id = member.user_id
    where exists (
      select 1 from public.group_activity_links link
      where link.group_id = member.group_id
        and link.user_id = member.user_id and link.source_id = activity.subject_id
        and activity.category = member.category
        and activity.occurred_at >= greatest(
          link.started_at, coalesce(member.score_reset_at, member.created_at)
        )
        and (link.ended_at is null or activity.occurred_at < link.ended_at)
    )
      and member.category <> 'dailyGoals'
  ), activity_scores as (
    select
      scored.group_id,
      scored.user_id,
      scored.category,
      coalesce(sum(scored.score) filter (
        where scored.occurred_at >= today_start
      ), 0)::bigint as today_score,
      coalesce(sum(scored.score) filter (
        where scored.occurred_at >= week_start
      ), 0)::bigint as week_score,
      coalesce(sum(scored.score) filter (
        where scored.occurred_at >= month_start
      ), 0)::bigint as month_score,
      coalesce(sum(scored.score), 0)::bigint as total_score
    from scored_entries scored
    group by scored.group_id, scored.user_id, scored.category
  ), goal_dates as (
    select distinct
      member.group_id,
      member.user_id,
      completed.completed_date
    from member_scope member
    join public.group_activity_links link on link.group_id = member.group_id
      and link.user_id = member.user_id
    join public.group_goal_contributions completed on completed.link_id = link.id
    where member.category = 'dailyGoals'
      and (member.score_reset_at is null
        or completed.completed_date > (member.score_reset_at at time zone 'utc')::date)
      and completed.completed_date <= (today_start at time zone 'utc')::date
  ), goal_scores as (
    select
      goal_date.group_id,
      goal_date.user_id,
      'dailyGoals'::text as category,
      count(*) filter (
        where goal_date.completed_date >=
          (today_start at time zone 'utc')::date
      )::bigint as today_score,
      count(*) filter (
        where goal_date.completed_date >=
          (week_start at time zone 'utc')::date
      )::bigint as week_score,
      count(*) filter (
        where goal_date.completed_date >=
          (month_start at time zone 'utc')::date
      )::bigint as month_score,
      count(*)::bigint as total_score
    from goal_dates goal_date
    group by goal_date.group_id, goal_date.user_id
  )
  select * from activity_scores
  union all
  select * from goal_scores;
$$;

revoke execute on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) from public;
grant execute on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) to authenticated;

-- backend/schema/07_group_management.sql
-- =============================================================================
-- 07 · Group management
-- Create, join, edit, reset and hand over a group.
-- Requires: 03_groups.sql, 05_group_activity_links.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

drop function if exists public.create_group_with_members(text, text, uuid[]);
drop function if exists public.create_group_with_members(
  text, text, uuid[], text, text, jsonb
);
drop function if exists public.create_group_with_members(
  text, text, uuid[], text, text[], date
);

-- A group is its theme: the creator may already link personal activities of
-- that theme (source_ids), exactly as any member does later.
create or replace function public.create_group_with_members(
  group_name text,
  group_theme text,
  invited_friend_ids uuid[],
  group_description text default '',
  source_ids text[] default '{}',
  local_date date default current_date
)
returns table (
  id uuid,
  owner_id uuid,
  name text,
  theme text,
  description text,
  invite_code text,
  privacy text,
  created_at timestamptz,
  color_value bigint
)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  new_group_id uuid;
  new_invite_code text;
begin
  if current_user_id is null then
    raise exception 'User must be authenticated to create a group.'
      using errcode = '28000';
  end if;

  if group_theme is null or group_theme not in (
    'studying', 'dailyGoals', 'exercises', 'reading', 'hobbies'
  ) then
    raise exception 'Unknown group theme.' using errcode = '23514';
  end if;

  if coalesce(array_length(invited_friend_ids, 1), 0) < 1 then
    raise exception 'A group requires at least one invited friend.'
      using errcode = '23514';
  end if;

  if exists (
    select 1
    from unnest(invited_friend_ids) invited_id
    where not public.are_friends(current_user_id, invited_id)
  ) then
    raise exception 'Only accepted friends can be invited to a group.'
      using errcode = '42501';
  end if;

  loop
    new_invite_code :=
      'H' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 10));
    exit when not exists (
      select 1 from public.groups g where g.invite_code = new_invite_code
    );
  end loop;

  insert into public.groups (
    owner_id, name, theme, description, invite_code, privacy
  )
  values (
    current_user_id,
    trim(group_name),
    group_theme,
    coalesce(group_description, ''),
    new_invite_code,
    'inviteOnly'
  )
  returning groups.id into new_group_id;

  insert into public.group_members (group_id, user_id, role)
  values (new_group_id, current_user_id, 'owner');

  -- Invited friends are not added as members here: they receive a pending
  -- invitation and only join once they accept it.
  insert into public.group_invitations (group_id, inviter_id, invitee_id)
  select new_group_id, current_user_id, invited_id
  from unnest(invited_friend_ids) invited_id
  on conflict (group_id, invitee_id) do nothing;

  perform public.set_group_activity_links(
    new_group_id,
    coalesce(source_ids, '{}'::text[]),
    coalesce(local_date, current_date)
  );

  -- The first selected personal activity defines the group's accent. The
  -- source was validated by set_group_activity_links above, so its color is
  -- safe to copy without accepting an arbitrary client-provided value.
  if cardinality(coalesce(source_ids, '{}'::text[])) > 0 then
    if group_theme = 'dailyGoals' then
      update public.groups g
      set color_value = d.color_value
      from public.daily_goals d
      where g.id = new_group_id
        and d.user_id = current_user_id
        and d.id = source_ids[1];
    else
      update public.groups g
      set color_value = s.color_value
      from public.user_subjects s
      where g.id = new_group_id
        and s.user_id = current_user_id
        and s.id = source_ids[1];
    end if;
  end if;

  return query
  select
    g.id,
    g.owner_id,
    g.name,
    g.theme,
    g.description,
    g.invite_code,
    g.privacy,
    g.created_at,
    g.color_value
  from public.groups g
  where g.id = new_group_id;
end;
$$;

grant execute on function public.create_group_with_members(
  text, text, uuid[], text, text[], date
)
to authenticated;

drop function if exists public.join_group_by_invite_code(text);

-- The group's link and code do not put anyone in the group: they raise a
-- request for the leader to answer. [pending_approval] is false only when the
-- caller is already a member, so the client can just open the group.
create or replace function public.join_group_by_invite_code(lookup_code text)
returns table (
  id uuid,
  name text,
  theme text,
  description text,
  owner_id uuid,
  created_at timestamptz,
  invite_code text,
  privacy text,
  pending_approval boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  target_group_id uuid;
  already_member boolean;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select g.id
  into target_group_id
  from public.groups g
  where upper(g.invite_code) = upper(trim(lookup_code))
  limit 1;

  if target_group_id is null then
    raise exception 'group not found';
  end if;

  already_member := public.is_group_member(target_group_id, auth.uid());

  if not already_member then
    insert into public.group_join_requests (group_id, user_id)
    values (target_group_id, auth.uid())
    on conflict (group_id, user_id) do update
    set status = 'pending',
        invited_by = null,
        created_at = now(),
        decided_at = null;
  end if;

  return query
  select
    g.id, g.name, g.theme, g.description, g.owner_id,
    g.created_at, g.invite_code, g.privacy, not already_member
  from public.groups g
  where g.id = target_group_id;
end;
$$;

drop function if exists public.update_group_with_activity(uuid, text, text, jsonb);
drop function if exists public.update_group(uuid, text, text, bigint);

-- The leader's edits: name, description and the group's own color. A null
-- color leaves the current one untouched.
create or replace function public.update_group(
  target_group_id uuid,
  group_name text,
  group_description text default '',
  group_color_value bigint default null
)
returns table (
  id uuid,
  name text,
  theme text,
  description text,
  owner_id uuid,
  created_at timestamptz,
  invite_code text,
  privacy text,
  color_value bigint
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.owns_group(target_group_id, auth.uid()) then
    raise exception 'only the group owner can edit this group'
      using errcode = '42501';
  end if;

  update public.groups
  set
    name = nullif(btrim(group_name), ''),
    description = coalesce(group_description, ''),
    color_value = coalesce(group_color_value, groups.color_value)
  where groups.id = target_group_id;

  return query
  select
    g.id,
    g.name,
    g.theme,
    g.description,
    g.owner_id,
    g.created_at,
    g.invite_code,
    g.privacy,
    g.color_value
  from public.groups g
  where g.id = target_group_id;
end;
$$;

revoke all on function public.update_group(uuid, text, text, bigint)
from public;
grant execute on function public.update_group(uuid, text, text, bigint)
to authenticated;

-- Starts the shared ranking afresh without changing anyone's personal
-- activity data: history remains intact, it just stops counting for the group.
drop function if exists public.reset_group_progress(uuid);
create or replace function public.reset_group_progress(target_group_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.owns_group(target_group_id, auth.uid()) then
    raise exception 'only the group owner can reset this group'
      using errcode = '42501';
  end if;

  update public.groups
  set score_reset_at = clock_timestamp()
  where id = target_group_id;
end;
$$;

revoke all on function public.reset_group_progress(uuid) from public;
grant execute on function public.reset_group_progress(uuid) to authenticated;

-- Ownership changes need to update the group and membership roles together.
-- The ordinary owner update policy intentionally prevents changing owner_id,
-- so this narrowly scoped RPC performs the transfer after checking the caller.
drop function if exists public.transfer_group_ownership(uuid, uuid);
create or replace function public.transfer_group_ownership(
  target_group_id uuid,
  next_owner_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_owner_id uuid;
begin
  select owner_id
  into current_owner_id
  from public.groups
  where id = target_group_id;

  if current_owner_id is null then
    raise exception 'Group not found';
  end if;

  if current_owner_id <> auth.uid() then
    raise exception 'Only the current group owner can transfer leadership';
  end if;

  if next_owner_id = current_owner_id then
    return;
  end if;

  if not exists (
    select 1
    from public.group_members
    where group_id = target_group_id
      and user_id = next_owner_id
  ) then
    raise exception 'New group owner must already be a member';
  end if;

  update public.groups
  set owner_id = next_owner_id
  where id = target_group_id;

  update public.group_members
  set role = case
    when user_id = next_owner_id then 'owner'
    when user_id = current_owner_id then 'member'
    else role
  end
  where group_id = target_group_id;
end;
$$;

revoke all on function public.transfer_group_ownership(uuid, uuid) from public;
grant execute on function public.transfer_group_ownership(uuid, uuid)
  to authenticated;

-- Remove the discontinued role-assignment endpoint from existing installs.
drop function if exists public.set_group_member_role(uuid, uuid, text);

-- -----------------------------------------------------------------------------
-- Account deletion
-- -----------------------------------------------------------------------------

-- Erases the caller's account and every row that hangs off it. Leaving each
-- group first lets trg_handle_group_member_left hand ownership to the
-- earliest remaining member, or drop the group when nobody is left. Removing
-- the auth user then cascades through profiles to all remaining personal data.
drop function if exists public.delete_my_account();
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  delete from public.group_members where user_id = current_user_id;
  delete from auth.users where id = current_user_id;
end;
$$;

-- backend/schema/08_group_invitations.sql
-- =============================================================================
-- 08 · Group invitations and join requests
-- Inviting friends into a group, answering those invitations, and the
-- requests the leader approves (from the group's link, or from an invitation
-- sent by a member who is not the leader).
-- Requires: 02_friends.sql, 03_groups.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

-- Received (pending) group invitations for the current user, joined with the
-- group and the inviter's display name. Security definer so the invitee can
-- read the group and inviter profile before they are a member of the group.
drop function if exists public.pending_group_invitations();
create or replace function public.pending_group_invitations()
returns table (
  id uuid,
  group_id uuid,
  group_name text,
  group_theme text,
  inviter_id uuid,
  inviter_name text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    gi.id,
    gi.group_id,
    g.name,
    g.theme,
    gi.inviter_id,
    coalesce(
      nullif(p.nick_name, ''),
      nullif(p.user_name, ''),
      'Timing'
    ) as inviter_name,
    gi.created_at
  from public.group_invitations gi
  join public.groups g on g.id = gi.group_id
  left join public.profiles p on p.id = gi.inviter_id
  where gi.invitee_id = auth.uid()
    and gi.status = 'pending'
  order by gi.created_at desc;
$$;

grant execute on function public.pending_group_invitations() to authenticated;

-- Friends the caller can invite, plus their current state for this group.
-- Every member may invite, so this also marks those already waiting for the
-- leader's approval. Runs with definer rights so one member can see the
-- invitations sent by another.
drop function if exists public.group_invite_options(uuid);
create or replace function public.group_invite_options(target_group_id uuid)
returns table (
  friend_id uuid,
  friend_name text,
  accent_color_value bigint,
  status text,
  invitation_id uuid,
  join_request_id uuid
)
language sql
security definer
set search_path = public
as $$
  with current_friends as (
    select
      case
        when f.requester_id = auth.uid() then f.addressee_id
        else f.requester_id
      end as friend_id
    from public.friendships f
    where f.status = 'accepted'
      and (f.requester_id = auth.uid() or f.addressee_id = auth.uid())
  ),
  latest_invitations as (
    select distinct on (gi.invitee_id)
      gi.id,
      gi.invitee_id,
      gi.status
    from public.group_invitations gi
    where gi.group_id = target_group_id
    order by gi.invitee_id, gi.created_at desc
  ),
  pending_requests as (
    select jr.id, jr.user_id
    from public.group_join_requests jr
    where jr.group_id = target_group_id and jr.status = 'pending'
  ),
  candidates as (
    select cf.friend_id
    from current_friends cf
    union
    select pr.user_id
    from pending_requests pr
    where exists (
      select 1
      from public.groups g
      where g.id = target_group_id
        and g.owner_id = auth.uid()
    )
  )
  select
    candidate.friend_id,
    coalesce(nullif(trim(p.nick_name), ''), nullif(trim(p.user_name), ''), 'Timing User')
      as friend_name,
    p.accent_color_value,
    case
      when gm.user_id is not null then 'member'
      when pr.user_id is not null then 'requested'
      when li.status = 'pending' then 'invited'
      else 'available'
    end as status,
    case when li.status = 'pending' then li.id else null end as invitation_id,
    pr.id as join_request_id
  from candidates candidate
  join public.profiles p on p.id = candidate.friend_id
  left join public.group_members gm
    on gm.group_id = target_group_id and gm.user_id = candidate.friend_id
  left join latest_invitations li on li.invitee_id = candidate.friend_id
  left join pending_requests pr on pr.user_id = candidate.friend_id
  where public.is_group_member(target_group_id, auth.uid())
  order by friend_name asc;
$$;

create or replace function public.invite_friend_to_group(
  target_group_id uuid,
  target_friend_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'User must be authenticated to invite a friend.'
      using errcode = '28000';
  end if;

  if not public.is_group_member(target_group_id, auth.uid()) then
    raise exception 'Only group members can invite friends.'
      using errcode = '42501';
  end if;

  if not public.are_friends(auth.uid(), target_friend_id) then
    raise exception 'Only accepted friends can be invited to a group.'
      using errcode = '42501';
  end if;

  if exists (
    select 1
    from public.group_members gm
    where gm.group_id = target_group_id
      and gm.user_id = target_friend_id
  ) then
    raise exception 'User is already a group member.'
      using errcode = '23505';
  end if;

  insert into public.group_invitations (
    group_id, inviter_id, invitee_id, status, responded_at
  )
  values (target_group_id, auth.uid(), target_friend_id, 'pending', null)
  on conflict (group_id, invitee_id) do update
  set inviter_id = auth.uid(),
      status = 'pending',
      responded_at = null,
      created_at = now();
end;
$$;

create or replace function public.cancel_group_invitation(
  target_group_id uuid,
  target_friend_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'User must be authenticated to cancel an invitation.'
      using errcode = '28000';
  end if;

  if not public.is_group_member(target_group_id, auth.uid()) then
    raise exception 'Only group members can cancel invitations.'
      using errcode = '42501';
  end if;

  -- Whoever sent it may take it back, and so may the leader.
  delete from public.group_invitations gi
  where gi.group_id = target_group_id
    and gi.invitee_id = target_friend_id
    and gi.status = 'pending'
    and (
      gi.inviter_id = auth.uid()
      or public.owns_group(target_group_id, auth.uid())
    );
end;
$$;

grant execute on function public.group_invite_options(uuid) to authenticated;
grant execute on function public.invite_friend_to_group(uuid, uuid)
to authenticated;
grant execute on function public.cancel_group_invitation(uuid, uuid)
to authenticated;

-- Accepts a pending invitation. An invitation from the leader puts the user
-- in the group at once; one from an ordinary member becomes a request for the
-- leader to approve. [pending_approval] says which happened, and the group row
-- lets the client add it to the list without a second lookup when it joined.
drop function if exists public.accept_group_invitation(uuid);
create or replace function public.accept_group_invitation(invitation_id uuid)
returns table (
  id uuid,
  name text,
  theme text,
  description text,
  owner_id uuid,
  created_at timestamptz,
  invite_code text,
  privacy text,
  pending_approval boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  target_group_id uuid;
  inviter uuid;
  needs_approval boolean;
begin
  if current_user_id is null then
    raise exception 'User must be authenticated to accept an invitation.'
      using errcode = '28000';
  end if;

  select gi.group_id, gi.inviter_id
  into target_group_id, inviter
  from public.group_invitations gi
  where gi.id = invitation_id
    and gi.invitee_id = current_user_id
    and gi.status = 'pending'
  limit 1;

  if target_group_id is null then
    raise exception 'Invitation not found or already handled.'
      using errcode = 'P0002';
  end if;

  needs_approval :=
    not public.owns_group(target_group_id, inviter)
    and not public.is_group_member(target_group_id, current_user_id);

  update public.group_invitations gi
    set status = 'accepted', responded_at = now()
    where gi.id = invitation_id;

  if needs_approval then
    insert into public.group_join_requests (group_id, user_id, invited_by)
    values (target_group_id, current_user_id, inviter)
    on conflict (group_id, user_id) do update
    set status = 'pending',
        invited_by = excluded.invited_by,
        created_at = now(),
        decided_at = null;
  else
    insert into public.group_members (group_id, user_id, role)
    values (target_group_id, current_user_id, 'member')
    on conflict (group_id, user_id) do nothing;
  end if;

  return query
  select
    g.id, g.name, g.theme, g.description, g.owner_id,
    g.created_at, g.invite_code, g.privacy, needs_approval
  from public.groups g
  where g.id = target_group_id;
end;
$$;

grant execute on function public.accept_group_invitation(uuid) to authenticated;

-- Declines a pending invitation. Kept as a status change (not a delete) so the
-- inviter can tell the difference between "not answered yet" and "declined".
create or replace function public.decline_group_invitation(invitation_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.group_invitations
    set status = 'declined', responded_at = now()
    where id = invitation_id
      and invitee_id = auth.uid()
      and status = 'pending';
end;
$$;

-- -----------------------------------------------------------------------------
-- Join requests
-- -----------------------------------------------------------------------------

-- Requests the current user has already made and that still await the leader.
-- This is separate from invitations: opening a group link creates a request,
-- so the requester needs a visible receipt even though there is no invitation
-- left to show in the Friends area.
drop function if exists public.pending_group_join_requests();
create or replace function public.pending_group_join_requests()
returns table (
  id uuid,
  group_id uuid,
  group_name text,
  group_theme text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    jr.id,
    jr.group_id,
    g.name,
    g.theme,
    jr.created_at
  from public.group_join_requests jr
  join public.groups g on g.id = jr.group_id
  where jr.user_id = auth.uid()
    and jr.status = 'pending'
  order by jr.created_at desc;
$$;

grant execute on function public.pending_group_join_requests()
to authenticated;

-- Who is waiting to be let into the group. Only the leader answers them, so
-- only the leader reads the list. Definer rights so the leader can read the
-- profile of someone they do not know yet.
drop function if exists public.group_join_requests(uuid);
create or replace function public.group_join_requests(target_group_id uuid)
returns table (
  id uuid,
  user_id uuid,
  user_name text,
  accent_color_value bigint,
  profile_photo_base64 text,
  avatar_icon_index integer,
  invited_by uuid,
  invited_by_name text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    jr.id,
    jr.user_id,
    coalesce(
      nullif(trim(p.nick_name), ''),
      nullif(trim(p.user_name), ''),
      'Timing User'
    ) as user_name,
    p.accent_color_value,
    p.profile_photo_base64,
    p.avatar_icon_index,
    jr.invited_by,
    coalesce(nullif(trim(i.nick_name), ''), nullif(trim(i.user_name), ''))
      as invited_by_name,
    jr.created_at
  from public.group_join_requests jr
  join public.profiles p on p.id = jr.user_id
  left join public.profiles i on i.id = jr.invited_by
  where jr.group_id = target_group_id
    and jr.status = 'pending'
    and public.owns_group(target_group_id, auth.uid())
  order by jr.created_at asc;
$$;

-- Lets the person in. Repeating it on an answered request changes nothing.
create or replace function public.approve_group_join_request(request_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  target_group_id uuid;
  requester_id uuid;
begin
  select jr.group_id, jr.user_id
  into target_group_id, requester_id
  from public.group_join_requests jr
  where jr.id = request_id and jr.status = 'pending'
  for update;

  if target_group_id is null then
    raise exception 'Join request not found or already handled.'
      using errcode = 'P0002';
  end if;

  if not public.owns_group(target_group_id, auth.uid()) then
    raise exception 'Only the group leader can answer join requests.'
      using errcode = '42501';
  end if;

  insert into public.group_members (group_id, user_id, role)
  values (target_group_id, requester_id, 'member')
  on conflict (group_id, user_id) do nothing;

  update public.group_join_requests
  set status = 'approved', decided_at = now()
  where id = request_id;
end;
$$;

-- Turns the request down. The row is kept as 'declined' rather than deleted,
-- so asking again is a deliberate new request instead of a silent retry.
create or replace function public.decline_group_join_request(request_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  target_group_id uuid;
begin
  select jr.group_id
  into target_group_id
  from public.group_join_requests jr
  where jr.id = request_id and jr.status = 'pending'
  for update;

  if target_group_id is null then
    raise exception 'Join request not found or already handled.'
      using errcode = 'P0002';
  end if;

  if not public.owns_group(target_group_id, auth.uid()) then
    raise exception 'Only the group leader can answer join requests.'
      using errcode = '42501';
  end if;

  update public.group_join_requests
  set status = 'declined', decided_at = now()
  where id = request_id;
end;
$$;

-- backend/schema/09_policies.sql
-- =============================================================================
-- 09 · Row level security
-- Enables RLS on every table and defines who can see or change each row.
-- Requires: 02-04 (tables), the access helpers in 02-04
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Enable RLS
-- -----------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.profile_private_data enable row level security;
alter table public.friendships enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_invitations enable row level security;
alter table public.activity_entries enable row level security;
-- No policies: remove_activity_seconds() is its only reader and writer.
alter table public.activity_time_removals enable row level security;
alter table public.user_subjects enable row level security;
alter table public.daily_goals enable row level security;
alter table public.schedule_entries enable row level security;
alter table public.group_image_messages enable row level security;
alter table public.group_join_requests enable row level security;

-- -----------------------------------------------------------------------------
-- Drop previous policies
-- -----------------------------------------------------------------------------

drop policy if exists "profiles are visible to self, friends, and group peers"
on public.profiles;
drop policy if exists "users read own private profile"
on public.profile_private_data;
drop policy if exists "users insert own private profile"
on public.profile_private_data;
drop policy if exists "users update own private profile"
on public.profile_private_data;
drop policy if exists "users delete own private profile"
on public.profile_private_data;
drop policy if exists "users insert own profile" on public.profiles;
drop policy if exists "users update own profile" on public.profiles;
drop policy if exists "users see own friendships" on public.friendships;
drop policy if exists "users request friendships" on public.friendships;
drop policy if exists "users answer received friendships" on public.friendships;
drop policy if exists "users delete own friendships" on public.friendships;
drop policy if exists "members see their groups" on public.groups;
drop policy if exists "users create owned groups" on public.groups;
drop policy if exists "owners update groups" on public.groups;
drop policy if exists "owners delete groups" on public.groups;
drop policy if exists "members see group memberships" on public.group_members;
drop policy if exists "owners add group members" on public.group_members;
drop policy if exists "users join groups" on public.group_members;
drop policy if exists "invitees join invited groups" on public.group_members;
drop policy if exists "leader invitees join groups" on public.group_members;
drop policy if exists "requesters and leaders read join requests"
on public.group_join_requests;
drop policy if exists "owners remove group members" on public.group_members;
drop policy if exists "managers remove group members" on public.group_members;
drop policy if exists "users leave their groups" on public.group_members;
drop policy if exists "invited or inviter see invitations"
on public.group_invitations;
drop policy if exists "owners create invitations" on public.group_invitations;
drop policy if exists "managers create invitations" on public.group_invitations;
drop policy if exists "invitee answers invitations" on public.group_invitations;
drop policy if exists "inviter or invitee delete invitations"
on public.group_invitations;
drop policy if exists "users see activity from group peers"
on public.activity_entries;
drop policy if exists "users read own activity" on public.activity_entries;
drop policy if exists "users insert own activity" on public.activity_entries;
drop policy if exists "users manage own activity" on public.activity_entries;
drop policy if exists "users delete own activity" on public.activity_entries;
drop policy if exists "users manage own subjects" on public.user_subjects;
drop policy if exists "users manage own goals" on public.daily_goals;
drop policy if exists "users manage own schedule entries"
on public.schedule_entries;

drop policy if exists "users read own subjects" on public.user_subjects;
drop policy if exists "users insert own subjects" on public.user_subjects;
drop policy if exists "users update own subjects" on public.user_subjects;
drop policy if exists "users delete own subjects" on public.user_subjects;
drop policy if exists "users read own goals" on public.daily_goals;
drop policy if exists "users insert own goals" on public.daily_goals;
drop policy if exists "users update own goals" on public.daily_goals;
drop policy if exists "users delete own goals" on public.daily_goals;
drop policy if exists "users read own schedule entries"
on public.schedule_entries;
drop policy if exists "users insert own schedule entries"
on public.schedule_entries;
drop policy if exists "users update own schedule entries"
on public.schedule_entries;
drop policy if exists "users delete own schedule entries"
on public.schedule_entries;
drop policy if exists "members read group image messages"
on public.group_image_messages;
drop policy if exists "members insert own group image messages"
on public.group_image_messages;

-- -----------------------------------------------------------------------------
-- Policies
-- -----------------------------------------------------------------------------

create policy "profiles are visible to self, friends, and group peers"
on public.profiles for select
using (
  id = auth.uid()
  or public.are_friends(auth.uid(), profiles.id)
  or public.share_group(auth.uid(), profiles.id)
);

create policy "users read own private profile"
on public.profile_private_data for select
using (user_id = auth.uid());

create policy "users insert own private profile"
on public.profile_private_data for insert
with check (user_id = auth.uid());

create policy "users update own private profile"
on public.profile_private_data for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own private profile"
on public.profile_private_data for delete
using (user_id = auth.uid());

create policy "users insert own profile"
on public.profiles for insert
with check (id = auth.uid());

create policy "users update own profile"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "users see own friendships"
on public.friendships for select
using (requester_id = auth.uid() or addressee_id = auth.uid());

create policy "users request friendships"
on public.friendships for insert
with check (
  requester_id = auth.uid()
  and addressee_id <> auth.uid()
  and status = 'pending'
);

create policy "users answer received friendships"
on public.friendships for update
using (addressee_id = auth.uid())
with check (addressee_id = auth.uid());

create policy "users delete own friendships"
on public.friendships for delete
using (requester_id = auth.uid() or addressee_id = auth.uid());

create policy "members see their groups"
on public.groups for select
using (public.is_group_member(groups.id, auth.uid()));

create policy "users create owned groups"
on public.groups for insert
with check (owner_id = auth.uid());

create policy "owners update groups"
on public.groups for update
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "owners delete groups"
on public.groups for delete
using (owner_id = auth.uid());

create policy "members see group memberships"
on public.group_members for select
using (public.is_group_member(group_members.group_id, auth.uid()));

-- Only an invitation from the leader puts someone straight into the group.
-- Everyone else arrives through an approved join request, which is written by
-- approve_group_join_request.
create policy "leader invitees join groups"
on public.group_members for insert
with check (
  group_members.user_id = auth.uid()
  and group_members.role = 'member'
  and exists (
    select 1
    from public.group_invitations gi
    join public.groups g on g.id = gi.group_id
    where gi.group_id = group_members.group_id
      and gi.invitee_id = auth.uid()
      and gi.status = 'pending'
      and gi.inviter_id = g.owner_id
  )
);

-- Requests are raised and answered through their RPCs; reading one is for the
-- person waiting and for the leader who answers.
create policy "requesters and leaders read join requests"
on public.group_join_requests for select
using (
  group_join_requests.user_id = auth.uid()
  or public.owns_group(group_join_requests.group_id, auth.uid())
);

create policy "owners remove group members"
on public.group_members for delete
using (public.owns_group(group_members.group_id, auth.uid()));

create policy "users leave their groups"
on public.group_members for delete
using (user_id = auth.uid());

create policy "invited or inviter see invitations"
on public.group_invitations for select
using (invitee_id = auth.uid() or inviter_id = auth.uid());

create policy "owners create invitations"
on public.group_invitations for insert
with check (
  inviter_id = auth.uid()
  and public.owns_group(group_invitations.group_id, auth.uid())
  and public.are_friends(auth.uid(), group_invitations.invitee_id)
  and group_invitations.status = 'pending'
);

create policy "invitee answers invitations"
on public.group_invitations for update
using (invitee_id = auth.uid())
with check (invitee_id = auth.uid());

create policy "inviter or invitee delete invitations"
on public.group_invitations for delete
using (inviter_id = auth.uid() or invitee_id = auth.uid());

-- Nobody reads another person's entries: group peers only get the aggregates
-- of group_leaderboard_scores().
create policy "users read own activity"
on public.activity_entries for select
using (user_id = auth.uid());

create policy "users insert own activity"
on public.activity_entries for insert
with check (user_id = auth.uid());

create policy "users manage own activity"
on public.activity_entries for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own activity"
on public.activity_entries for delete
using (user_id = auth.uid());

create policy "users read own subjects"
on public.user_subjects for select
using (user_id = auth.uid());

create policy "users insert own subjects"
on public.user_subjects for insert
with check (user_id = auth.uid());

create policy "users update own subjects"
on public.user_subjects for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own subjects"
on public.user_subjects for delete
using (user_id = auth.uid());

create policy "users read own goals"
on public.daily_goals for select
using (user_id = auth.uid());

create policy "users insert own goals"
on public.daily_goals for insert
with check (user_id = auth.uid());

create policy "users update own goals"
on public.daily_goals for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own goals"
on public.daily_goals for delete
using (user_id = auth.uid());

create policy "users read own schedule entries"
on public.schedule_entries for select
using (user_id = auth.uid());

create policy "users insert own schedule entries"
on public.schedule_entries for insert
with check (user_id = auth.uid());

create policy "users update own schedule entries"
on public.schedule_entries for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own schedule entries"
on public.schedule_entries for delete
using (user_id = auth.uid());

create policy "members read group image messages"
on public.group_image_messages for select
using (public.is_group_member(group_image_messages.group_id, auth.uid()));

create policy "members insert own group image messages"
on public.group_image_messages for insert
with check (
  sender_id = auth.uid()
  and public.is_group_member(group_image_messages.group_id, auth.uid())
);

-- Link periods and goal snapshots are server-owned; only aggregate RPCs expose
-- peer progress. The member may inspect their own periods.
alter table public.group_activity_links enable row level security;
alter table public.group_goal_contributions enable row level security;
drop policy if exists group_activity_links_self on public.group_activity_links;
create policy group_activity_links_self on public.group_activity_links
for select to authenticated using (user_id = auth.uid());

-- All management checks now use owns_group.
drop function if exists public.manages_group(uuid, uuid);
-- Entries are owner-only now, so the peer check has no policy left to serve.
drop function if exists public.can_view_peer_activity(uuid, text);

-- backend/schema/10_storage.sql
-- =============================================================================
-- 10 · Storage
-- Image buckets and the policies on storage.objects.
-- Requires: 02_friends.sql, 03_groups.sql (access helpers used by the policies)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Buckets and policies
-- -----------------------------------------------------------------------------

-- Storage buckets for images, so profiles.profile_photo_base64 and
-- group_image_messages.image_base64 can move out of Postgres (base64 text
-- bloats rows and is shipped in full on every read). Store the bytes here and
-- keep only a path in the tables.
--
-- Path conventions the policies below assume:
--   profile-photos/<user_id>/<file>
--   group-images/<group_id>/<file>
--
-- The client rewrite (upload/read from these buckets, then drop the *_base64
-- columns once existing rows are migrated) is a separate step.
insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
)
values (
  'profile-photos', 'profile-photos', false, 2000000,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
)
values (
  'group-images', 'group-images', false, 4000000,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Profile photos: the owner writes their own folder; self, friends and group
-- peers can read it (mirrors the profiles select policy).
drop policy if exists "profile photo readable by self friends peers"
on storage.objects;
create policy "profile photo readable by self friends peers"
on storage.objects for select
using (
  bucket_id = 'profile-photos'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.are_friends(auth.uid(), ((storage.foldername(name))[1])::uuid)
    or public.share_group(auth.uid(), ((storage.foldername(name))[1])::uuid)
  )
);

drop policy if exists "profile photo writable by owner" on storage.objects;
create policy "profile photo writable by owner"
on storage.objects for all
using (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Group images: any group member can read; a member can upload into their
-- group's folder.
drop policy if exists "group image readable by members" on storage.objects;
create policy "group image readable by members"
on storage.objects for select
using (
  bucket_id = 'group-images'
  and public.is_group_member(
    ((storage.foldername(name))[1])::uuid, auth.uid()
  )
);

drop policy if exists "group image writable by members" on storage.objects;
create policy "group image writable by members"
on storage.objects for insert
with check (
  bucket_id = 'group-images'
  and public.is_group_member(
    ((storage.foldername(name))[1])::uuid, auth.uid()
  )
);

-- backend/schema/11_grants.sql
-- =============================================================================
-- 11 · Grants
-- Least-privilege lockdown. Must stay after every function and table is
-- defined, or the objects created later keep Supabase's default grants.
-- Requires: every section above
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Function privileges
-- -----------------------------------------------------------------------------

-- PostgreSQL grants EXECUTE on new functions to PUBLIC by default. Explicitly
-- close every definer/trigger helper, then expose only the RPC surface used by
-- authenticated clients.
revoke all on function public.handle_new_user() from public;
revoke all on function public.handle_group_member_left() from public;
revoke all on function public.delete_activity_entries_of_deleted_subject()
  from public;
revoke all on function public.keep_friendship_identity_immutable() from public;
revoke all on function public.keep_group_invitation_identity_immutable()
  from public;
revoke all on function public.set_updated_at() from public;
revoke all on function public.validate_activity_entry() from public;
revoke all on function public.discard_group_ownership() from public;
revoke all on function public.validate_daily_goal_dates() from public;
revoke all on function public.enforce_group_image_rate_limit() from public;

revoke all on function public.generate_friend_code() from public;
revoke all on function public.are_friends(uuid, uuid) from public;
revoke all on function public.is_group_member(uuid, uuid) from public;
revoke all on function public.share_group(uuid, uuid) from public;
revoke all on function public.owns_group(uuid, uuid) from public;
revoke all on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) from public;
revoke all on function public.find_profile_by_friend_code(text) from public;
revoke all on function public.create_group_with_members(
  text, text, uuid[], text, text[], date
) from public;
revoke all on function public.join_group_by_invite_code(text) from public;
revoke all on function public.update_group(uuid, text, text, bigint)
  from public;
revoke all on function public.reset_group_progress(uuid) from public;
revoke all on function public.pending_group_invitations() from public;
revoke all on function public.pending_group_join_requests() from public;
revoke all on function public.group_join_requests(uuid) from public;
revoke all on function public.approve_group_join_request(uuid) from public;
revoke all on function public.decline_group_join_request(uuid) from public;
revoke all on function public.group_invite_options(uuid) from public;
revoke all on function public.invite_friend_to_group(uuid, uuid) from public;
revoke all on function public.cancel_group_invitation(uuid, uuid) from public;
revoke all on function public.accept_group_invitation(uuid) from public;
revoke all on function public.decline_group_invitation(uuid) from public;
revoke all on function public.record_activity_entry(
  uuid, text, text, text, integer, integer, integer, timestamptz
) from public;
revoke all on function public.remove_activity_seconds(
  uuid, text, integer, timestamptz
) from public;
revoke all on function public.activity_entry_totals(timestamptz) from public;
revoke all on function public.delete_my_account() from public;

grant execute on function public.generate_friend_code() to authenticated;
grant execute on function public.are_friends(uuid, uuid) to authenticated;
grant execute on function public.is_group_member(uuid, uuid) to authenticated;
grant execute on function public.share_group(uuid, uuid) to authenticated;
grant execute on function public.owns_group(uuid, uuid) to authenticated;
grant execute on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) to authenticated;
grant execute on function public.find_profile_by_friend_code(text)
  to authenticated;
grant execute on function public.create_group_with_members(
  text, text, uuid[], text, text[], date
) to authenticated;
grant execute on function public.join_group_by_invite_code(text)
  to authenticated;
grant execute on function public.update_group(uuid, text, text, bigint)
  to authenticated;
grant execute on function public.reset_group_progress(uuid) to authenticated;
grant execute on function public.pending_group_invitations() to authenticated;
grant execute on function public.pending_group_join_requests()
  to authenticated;
grant execute on function public.group_join_requests(uuid) to authenticated;
grant execute on function public.approve_group_join_request(uuid)
  to authenticated;
grant execute on function public.decline_group_join_request(uuid)
  to authenticated;
grant execute on function public.group_invite_options(uuid) to authenticated;
grant execute on function public.invite_friend_to_group(uuid, uuid)
  to authenticated;
grant execute on function public.cancel_group_invitation(uuid, uuid)
  to authenticated;
grant execute on function public.accept_group_invitation(uuid)
  to authenticated;
grant execute on function public.decline_group_invitation(uuid)
  to authenticated;
grant execute on function public.record_activity_entry(
  uuid, text, text, text, integer, integer, integer, timestamptz
) to authenticated;
grant execute on function public.remove_activity_seconds(
  uuid, text, integer, timestamptz
) to authenticated;
grant execute on function public.activity_entry_totals(timestamptz)
  to authenticated;
grant execute on function public.delete_my_account() to authenticated;

-- -----------------------------------------------------------------------------
-- Table privileges
-- -----------------------------------------------------------------------------

-- The mobile app has no signed-out data surface. Remove the broad default
-- Data API grants and keep authenticated access explicit. RLS still decides
-- which rows each signed-in user may reach.
revoke all on all tables in schema public from anon;
revoke all on all sequences in schema public from anon;
revoke execute on all functions in schema public from anon;

-- Do not rely on Supabase's project-wide default grants. Keep the Data API
-- surface explicit; row policies below remain the per-record authorization
-- layer for every granted operation.
revoke all on table public.profiles from authenticated;
revoke all on table public.friendships from authenticated;
revoke all on table public.groups from authenticated;
revoke all on table public.group_members from authenticated;
revoke all on table public.group_join_requests from authenticated;
revoke all on table public.group_invitations from authenticated;
revoke all on table public.activity_entries from authenticated;
revoke all on table public.activity_time_removals from authenticated;
revoke all on table public.user_subjects from authenticated;
revoke all on table public.daily_goals from authenticated;
revoke all on table public.schedule_entries from authenticated;
revoke all on table public.group_image_messages from authenticated;

grant select, insert on table public.profiles to authenticated;
grant select, insert, update, delete
  on table public.friendships to authenticated;
grant select, insert, update, delete on table public.groups to authenticated;
grant select, insert, delete on table public.group_members to authenticated;
-- Raised and answered only through their RPCs.
grant select on table public.group_join_requests to authenticated;
grant select, insert, update, delete
  on table public.group_invitations to authenticated;
grant select, insert, update, delete
  on table public.user_subjects to authenticated;
grant select, insert, update, delete
  on table public.daily_goals to authenticated;
grant select, insert, update, delete
  on table public.schedule_entries to authenticated;
grant select, insert on table public.group_image_messages to authenticated;
grant select on table public.profile_presence_status to authenticated;

revoke all on table public.profile_private_data from authenticated;
grant select, insert, update, delete
  on table public.profile_private_data to authenticated;

-- Profile identity and audit columns are server-owned.
revoke update on table public.profiles from authenticated;
grant update (
  id,
  user_name,
  nick_name,
  profile_photo_base64,
  accent_color_value,
  avatar_icon_index,
  is_online,
  last_seen_at,
  notifications_enabled,
  focus_lock_studying_enabled,
  focus_lock_exercises_enabled,
  focus_lock_reading_enabled,
  focus_lock_hobbies_enabled
) on table public.profiles to authenticated;

-- Activity history is append-only through the validating RPC above. Users may
-- still remove their own history through the owner-scoped delete policy.
grant select, delete on table public.activity_entries to authenticated;

revoke all on public.group_activity_links, public.group_goal_contributions from public, anon, authenticated;
grant select on public.group_activity_links to authenticated;
revoke all on function public.capture_group_goal_contributions() from public, anon, authenticated;
revoke all on function public.set_group_activity_links(uuid, text[], date) from public, anon;
revoke all on function public.group_activity_link_options(uuid) from public, anon;
grant execute on function public.set_group_activity_links(uuid, text[], date) to authenticated;
grant execute on function public.group_activity_link_options(uuid) to authenticated;

-- backend/schema/12_google_calendar.sql
-- Google Calendar credentials and OAuth state are accessible only to the Edge
-- Function's service role. Never grant these tables to authenticated clients.
create table if not exists public.google_calendar_connections (
  user_id uuid primary key references auth.users(id) on delete cascade,
  refresh_token_encrypted text not null,
  calendar_id text not null,
  time_zone text not null,
  generation uuid not null default gen_random_uuid(),
  events jsonb not null default '{}',
  lease_until timestamptz,
  lease_id uuid,
  updated_at timestamptz not null default now()
);
create table if not exists public.google_calendar_oauth_states (
  state text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  expires_at timestamptz not null default now() + interval '10 minutes'
);
alter table public.google_calendar_connections enable row level security;
alter table public.google_calendar_oauth_states enable row level security;
revoke all on public.google_calendar_connections from public, anon, authenticated;
revoke all on public.google_calendar_oauth_states from public, anon, authenticated;
grant all on public.google_calendar_connections to service_role;
grant all on public.google_calendar_oauth_states to service_role;

-- Serialize reconciliation across devices/functions. A crashed worker's lease
-- expires; lease_id prevents it from releasing a newer worker's lease.
create or replace function public.claim_google_calendar_sync(owner uuid, worker uuid)
returns boolean language sql security definer set search_path = '' as $$
  with claimed as (
    update public.google_calendar_connections
      set lease_until = now() + interval '180 seconds', lease_id = worker
      where user_id = owner and (lease_until is null or lease_until < now())
      returning user_id
  ) select exists(select 1 from claimed);
$$;
revoke all on function public.claim_google_calendar_sync(uuid, uuid) from public, anon, authenticated;
grant execute on function public.claim_google_calendar_sync(uuid, uuid) to service_role;

-- backend/schema/12_maintenance.sql
-- =============================================================================
-- 12 · Maintenance
-- One-off data cleanup that is safe to repeat on every deployment.
-- Requires: 04_tracking.sql, 08_group_invitations.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Legacy data cleanup
-- -----------------------------------------------------------------------------

-- Legacy data cleanup. This is intentionally part of the canonical setup so
-- deployments need only this file. It is safe to run repeatedly: current
-- triggers prevent new orphaned subject activity, and these predicates only
-- remove old rows that the app can no longer use.
with removed_entries as (
  delete from public.activity_entries e
  where coalesce(e.subject_id, '') <> ''
    and e.completed_tasks = 0
    and e.occurred_at < now() - interval '7 days'
    and not exists (
      select 1
      from public.user_subjects s
      where s.user_id = e.user_id and s.id = e.subject_id
    )
  returning e.id
), removed_invitations as (
  delete from public.group_invitations i
  where i.status in ('accepted', 'declined')
    and coalesce(i.responded_at, i.created_at)
      < now() - interval '30 days'
  returning i.id
)
select
  (select count(*) from removed_entries) as activity_entries_removed,
  (select count(*) from removed_invitations) as group_invitations_removed;
