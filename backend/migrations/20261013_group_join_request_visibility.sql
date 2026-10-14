-- Makes pending link requests visible to their requester and actionable from
-- the group's invitation screen. Safe to apply repeatedly.

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
    coalesce(
      nullif(trim(p.nick_name), ''),
      nullif(trim(p.user_name), ''),
      'Timing User'
    ) as friend_name,
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

revoke all on function public.group_invite_options(uuid) from public, anon;
revoke all on function public.pending_group_join_requests() from public, anon;
grant execute on function public.group_invite_options(uuid) to authenticated;
grant execute on function public.pending_group_join_requests()
to authenticated;

notify pgrst, 'reload schema';
