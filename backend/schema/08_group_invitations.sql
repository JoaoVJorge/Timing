-- =============================================================================
-- 08 · Group invitations and join requests
-- Inviting friends into a group, answering those invitations, and the
-- requests the leader approves (from the group's link, or from an invitation
-- sent by a member who is not the leader).
-- Requires: 02_friends.sql, 03_groups.sql, 05_group_activities.sql
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
  invitation_id uuid
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
    select jr.user_id
    from public.group_join_requests jr
    where jr.group_id = target_group_id and jr.status = 'pending'
  )
  select
    cf.friend_id,
    coalesce(nullif(trim(p.nick_name), ''), nullif(trim(p.user_name), ''), 'Timing User')
      as friend_name,
    p.accent_color_value,
    case
      when gm.user_id is not null then 'member'
      when pr.user_id is not null then 'requested'
      when li.status = 'pending' then 'invited'
      else 'available'
    end as status,
    case when li.status = 'pending' then li.id else null end as invitation_id
  from current_friends cf
  join public.profiles p on p.id = cf.friend_id
  left join public.group_members gm
    on gm.group_id = target_group_id and gm.user_id = cf.friend_id
  left join latest_invitations li on li.invitee_id = cf.friend_id
  left join pending_requests pr on pr.user_id = cf.friend_id
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

    perform public.materialize_group_activities_for_user(
      target_group_id, current_user_id
    );
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

  perform public.materialize_group_activities_for_user(
    target_group_id, requester_id
  );
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
