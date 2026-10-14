-- New groups inherit the accent of the first personal activity linked by the
-- creator. Existing groups without a custom accent are backfilled likewise.
begin;

alter table public.groups
  add column if not exists color_value bigint;

update public.groups g
set color_value = first_link.color_value
from (
  select distinct on (l.group_id)
    l.group_id,
    case
      when linked_group.theme = 'dailyGoals' then goal.color_value
      else subject.color_value
    end as color_value
  from public.group_activity_links l
  join public.groups linked_group on linked_group.id = l.group_id
  left join public.daily_goals goal
    on linked_group.theme = 'dailyGoals'
   and goal.user_id = l.user_id
   and goal.id = l.source_id
  left join public.user_subjects subject
    on linked_group.theme <> 'dailyGoals'
   and subject.user_id = l.user_id
   and subject.id = l.source_id
  where l.ended_at is null
  order by l.group_id, l.started_at, l.id
) first_link
where g.id = first_link.group_id
  and g.color_value is null
  and first_link.color_value is not null;

drop function if exists public.create_group_with_members(
  text, text, uuid[], text, text[], date
);

create function public.create_group_with_members(
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

  insert into public.group_invitations (group_id, inviter_id, invitee_id)
  select new_group_id, current_user_id, invited_id
  from unnest(invited_friend_ids) invited_id
  on conflict (group_id, invitee_id) do nothing;

  perform public.set_group_activity_links(
    new_group_id,
    coalesce(source_ids, '{}'::text[]),
    coalesce(local_date, current_date)
  );

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

revoke all on function public.create_group_with_members(
  text, text, uuid[], text, text[], date
) from public;
grant execute on function public.create_group_with_members(
  text, text, uuid[], text, text[], date
) to authenticated;

notify pgrst, 'reload schema';

commit;
