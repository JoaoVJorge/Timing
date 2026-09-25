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
  theme text not null,
  description text not null default '',
  invite_code text not null unique,
  privacy text not null default 'inviteOnly',
  created_at timestamptz not null default now()
);

alter table public.groups
  add column if not exists description text not null default '';

create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member',
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

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

create table if not exists public.group_image_messages (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  image_base64 text not null,
  created_at timestamptz not null default now()
);

-- The activity template chosen when a group is created. Each row is fanned out
-- into a per-member copy in user_subjects / daily_goals (see
-- materialize_group_activities_for_user), so every member tracks their own.
create table if not exists public.group_activities (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  kind text not null check (kind in ('subject', 'goal')),
  payload jsonb not null default '{}'::jsonb,
  score_reset_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.group_activities
  add column if not exists score_reset_at timestamptz;

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
create index if not exists group_activities_group_idx
  on public.group_activities(group_id);

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
