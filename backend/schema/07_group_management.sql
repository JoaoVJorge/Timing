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
