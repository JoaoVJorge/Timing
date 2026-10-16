-- A group created without an activity gets its accent when the first member
-- links one later. Existing unstyled groups are backfilled from their earliest
-- active personal link.
begin;

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

create or replace function public.set_group_activity_links(
  target_group_id uuid,
  source_ids text[] default '{}',
  local_date date default current_date
) returns void language plpgsql security definer set search_path = public
as $$
declare
  group_theme text;
  selected_ids text[];
  first_source text;
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
  first_source := (coalesce(source_ids, '{}'::text[]))[1];
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

  if first_source is not null then
    if group_theme = 'dailyGoals' then
      update public.groups g
      set color_value = d.color_value
      from public.daily_goals d
      where g.id = target_group_id
        and g.color_value is null
        and d.user_id = auth.uid()
        and d.id = first_source;
    else
      update public.groups g
      set color_value = s.color_value
      from public.user_subjects s
      where g.id = target_group_id
        and g.color_value is null
        and s.user_id = auth.uid()
        and s.id = first_source;
    end if;
  end if;
end; $$;

revoke all on function public.set_group_activity_links(uuid, text[], date)
from public, anon;
grant execute on function public.set_group_activity_links(uuid, text[], date)
to authenticated;

notify pgrst, 'reload schema';

commit;
