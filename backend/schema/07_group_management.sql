-- =============================================================================
-- 07 · Group management
-- Create, join, edit, reset and hand over a group.
-- Requires: 03_groups.sql, 05_group_activities.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

drop function if exists public.create_group_with_members(text, text, uuid[]);
drop function if exists public.create_group_with_members(
  text, text, uuid[], text, text, jsonb
);

create or replace function public.create_group_with_members(
  group_name text,
  group_theme text,
  invited_friend_ids uuid[],
  group_description text default '',
  activity_kind text default null,
  activity_payload jsonb default null
)
returns table (
  id uuid,
  owner_id uuid,
  name text,
  theme text,
  description text,
  invite_code text,
  privacy text,
  activity_id uuid,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  new_group_id uuid;
  new_invite_code text;
  new_activity_id uuid;
  member_row record;
begin
  if current_user_id is null then
    raise exception 'User must be authenticated to create a group.'
      using errcode = '28000';
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

  if activity_kind is not null then
    insert into public.group_activities (group_id, kind, payload)
    values (
      new_group_id, activity_kind, coalesce(activity_payload, '{}'::jsonb)
    )
    returning group_activities.id into new_activity_id;

    for member_row in
      select gm.user_id
      from public.group_members gm
      where gm.group_id = new_group_id
    loop
      perform public.materialize_group_activities_for_user(
        new_group_id, member_row.user_id
      );
    end loop;
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
    new_activity_id,
    g.created_at
  from public.groups g
  where g.id = new_group_id;
end;
$$;

grant execute on function public.create_group_with_members(
  text, text, uuid[], text, text, jsonb
)
to authenticated;

drop function if exists public.join_group_by_invite_code(text);

create or replace function public.join_group_by_invite_code(lookup_code text)
returns table (
  id uuid,
  name text,
  theme text,
  description text,
  owner_id uuid,
  created_at timestamptz,
  invite_code text,
  privacy text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  target_group_id uuid;
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

  insert into public.group_members (group_id, user_id, role)
  values (target_group_id, auth.uid(), 'member')
  on conflict (group_id, user_id) do nothing;

  perform public.materialize_group_activities_for_user(
    target_group_id, auth.uid()
  );

  return query
  select
    g.id, g.name, g.theme, g.description, g.owner_id,
    g.created_at, g.invite_code, g.privacy
  from public.groups g
  where g.id = target_group_id;
end;
$$;

drop function if exists public.update_group_with_activity(uuid, text, text, jsonb);

create or replace function public.update_group_with_activity(
  target_group_id uuid,
  group_name text,
  group_description text default '',
  activity_payload jsonb default '{}'::jsonb
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
  activity_id uuid
)
language plpgsql
security definer
set search_path = public
as $$
declare
  target_activity_id uuid;
  target_activity_kind text;
  merged_payload jsonb;
begin
  if not public.owns_group(target_group_id, auth.uid()) then
    raise exception 'only the group owner can edit this group'
      using errcode = '42501';
  end if;

  update public.groups
  set
    name = nullif(btrim(group_name), ''),
    description = coalesce(group_description, '')
  where groups.id = target_group_id;

  select ga.id, ga.kind, ga.payload || coalesce(activity_payload, '{}'::jsonb)
  into target_activity_id, target_activity_kind, merged_payload
  from public.group_activities ga
  where ga.group_id = target_group_id
  order by ga.created_at
  limit 1;

  if target_activity_id is not null then
    update public.group_activities
    set payload = merged_payload
    where group_activities.id = target_activity_id;

    if target_activity_kind = 'subject' then
      update public.user_subjects
      set
        name = coalesce(nullif(merged_payload->>'name', ''), user_subjects.name),
        category = coalesce(
          nullif(merged_payload->>'category', ''),
          user_subjects.category
        ),
        color_value = coalesce(
          (merged_payload->>'color_value')::bigint,
          user_subjects.color_value
        ),
        goal_seconds = coalesce(
          (merged_payload->>'goal_seconds')::integer,
          user_subjects.goal_seconds
        ),
        goal_pages = coalesce(
          (merged_payload->>'goal_pages')::integer,
          user_subjects.goal_pages
        ),
        icon_name = coalesce(
          nullif(merged_payload->>'icon_name', ''),
          user_subjects.icon_name
        ),
        rest_minutes = coalesce(
          (merged_payload->>'rest_minutes')::integer,
          user_subjects.rest_minutes
        ),
        focus_session_count = coalesce(
          (merged_payload->>'focus_session_count')::integer,
          user_subjects.focus_session_count
        ),
        wallpaper_index = coalesce(
          (merged_payload->>'wallpaper_index')::integer,
          user_subjects.wallpaper_index
        ),
        activity_type = coalesce(
          nullif(merged_payload->>'activity_type', ''),
          user_subjects.activity_type
        )
      where user_subjects.group_activity_id = target_activity_id;
    elsif target_activity_kind = 'goal' then
      update public.daily_goals
      set
        name = coalesce(nullif(merged_payload->>'name', ''), daily_goals.name),
        color_value = coalesce(
          (merged_payload->>'color_value')::bigint,
          daily_goals.color_value
        ),
        target_days = coalesce(
          (merged_payload->>'target_days')::integer,
          daily_goals.target_days
        ),
        sequence_type = coalesce(
          nullif(merged_payload->>'sequence_type', ''),
          daily_goals.sequence_type
        ),
        goal_type = coalesce(
          nullif(merged_payload->>'goal_type', ''),
          daily_goals.goal_type
        )
      where daily_goals.group_activity_id = target_activity_id;
    end if;
  end if;

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
    target_activity_id
  from public.groups g
  where g.id = target_group_id;
end;
$$;

revoke all on function public.update_group_with_activity(uuid, text, text, jsonb)
from public;
grant execute on function public.update_group_with_activity(uuid, text, text, jsonb)
to authenticated;

-- Starts fresh shared ranking and activity progress without changing anyone's
-- cumulative personal activity data. History remains intact.
drop function if exists public.reset_group_progress(uuid);
create or replace function public.reset_group_progress(target_group_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  reset_at timestamptz := clock_timestamp();
begin
  if not public.owns_group(target_group_id, auth.uid()) then
    raise exception 'only the group owner can reset this group'
      using errcode = '42501';
  end if;

  update public.group_activities
  set score_reset_at = reset_at
  where group_id = target_group_id;

  if not found then
    raise exception 'group has no activities to reset'
      using errcode = 'P0002';
  end if;
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
