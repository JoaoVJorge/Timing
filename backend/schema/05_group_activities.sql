-- =============================================================================
-- 05 · Group activities
-- Links each member's personal sources to shared activity targets.
-- Link periods preserve past contributions without importing prior history.
-- Requires: 03_groups.sql, 04_tracking.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Fan-out
-- -----------------------------------------------------------------------------

-- New memberships wait for the member's explicit selection. Kept as an
-- internal no-op for older join RPCs; opening progress must never create copies.
create or replace function public.materialize_group_activities_for_user(
  target_group_id uuid, target_user_id uuid
) returns void language plpgsql security definer set search_path = public
as $$ begin return; end; $$;

-- Compatibility hook: selection happens after joining, never automatically.
create or replace function public.materialize_group_activities_on_join()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.materialize_group_activities_for_user(
    new.group_id, new.user_id
  );
  return new;
end;
$$;

drop trigger if exists trg_materialize_group_activities_on_join
  on public.group_members;
create trigger trg_materialize_group_activities_on_join
  after insert on public.group_members
  for each row
  execute function public.materialize_group_activities_on_join();

-- A source may contribute during several disjoint periods. Closed periods stay
-- queryable, so unlinking/relinking neither erases scores nor imports the gap.
create table if not exists public.group_activity_links (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.group_activities(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  source_id text not null,
  started_at timestamptz not null default clock_timestamp(),
  ended_at timestamptz,
  start_date date not null default current_date,
  excluded_dates text[] not null default '{}',
  check (ended_at is null or ended_at >= started_at)
);
create unique index if not exists group_activity_links_active_idx
  on public.group_activity_links(activity_id, user_id, source_id)
  where ended_at is null;
create index if not exists group_activity_links_user_idx
  on public.group_activity_links(user_id, source_id, started_at);

-- Daily goals only store dates. Snapshot newly checked dates while linked,
-- rather than treating an already-completed day as a new contribution.
create table if not exists public.group_goal_contributions (
  link_id uuid not null references public.group_activity_links(id) on delete cascade,
  completed_date date not null,
  recorded_at timestamptz not null default clock_timestamp(),
  primary key (link_id, completed_date)
);

-- -----------------------------------------------------------------------------
-- Membership changes
-- -----------------------------------------------------------------------------

-- Leaving closes contribution periods and preserves all personal sources.
-- Any remaining legacy group-owned rows are detached without losing history.
-- If the last member leaves, the group is deleted so all group-owned rows that
-- cascade from public.groups are removed. If the owner leaves while members
-- remain, ownership is handed to the earliest remaining member.
create or replace function public.cleanup_group_activities_on_leave()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  next_owner_id uuid;
  leaving_user_was_owner boolean;
begin
  update public.group_activity_links l set ended_at = clock_timestamp()
  from public.group_activities ga
  where l.activity_id = ga.id and ga.group_id = old.group_id
    and l.user_id = old.user_id and l.ended_at is null;
  if not exists (
    select 1
    from public.groups g
    where g.id = old.group_id
  ) then
    update public.user_subjects
       set group_id = null,
           group_activity_id = null
     where user_id = old.user_id and group_id = old.group_id;
    update public.daily_goals
       set group_id = null,
           group_activity_id = null
     where user_id = old.user_id and group_id = old.group_id;
    return old;
  end if;

  select gm.user_id
  into next_owner_id
  from public.group_members gm
  where gm.group_id = old.group_id
  order by gm.joined_at asc, gm.user_id asc
  limit 1;

  if next_owner_id is null then
    update public.user_subjects
       set group_id = null,
           group_activity_id = null
     where user_id = old.user_id and group_id = old.group_id;
    update public.daily_goals
       set group_id = null,
           group_activity_id = null
     where user_id = old.user_id and group_id = old.group_id;
    delete from public.groups g
    where g.id = old.group_id;
    return old;
  end if;

  update public.user_subjects set group_id = null, group_activity_id = null
   where user_id = old.user_id and group_id = old.group_id;
  update public.daily_goals set group_id = null, group_activity_id = null
   where user_id = old.user_id and group_id = old.group_id;

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
create trigger trg_cleanup_group_activities_on_leave
  after delete on public.group_members
  for each row
  execute function public.cleanup_group_activities_on_leave();

-- -----------------------------------------------------------------------------
-- Protecting group-owned rows
-- -----------------------------------------------------------------------------

-- Group-provided metadata is owned by the group. Members may advance their
-- own progress, but cannot relink a row or change the target/category used by
-- shared progress and rankings through the generic Data API.
create or replace function public.protect_group_subject()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  -- Older cached clients may still upload the former ownership columns.
  -- Normalize known migrated sources, and require the dedicated RPC for new
  -- links. Generic personal writes must never reintroduce group ownership.
  if current_user in ('authenticated', 'anon')
     and (new.group_id is not null or new.group_activity_id is not null) then
    if exists (select 1 from public.group_activity_links l
      where l.activity_id = new.group_activity_id and l.user_id = new.user_id
        and l.source_id = new.id) then
      new.group_id := null;
      new.group_activity_id := null;
    else
      raise exception 'use group activity links' using errcode = '42501';
    end if;
  end if;
  if new.group_id is not null or new.group_activity_id is not null then
    if new.group_id is null or new.group_activity_id is null
       or new.id <> 'grp_' || new.group_activity_id::text
       or not public.is_group_member(new.group_id, new.user_id)
       or not exists (
         select 1 from public.group_activities ga
         where ga.id = new.group_activity_id
           and ga.group_id = new.group_id
           and ga.kind = 'subject'
       ) then
      raise exception 'invalid group subject link' using errcode = '42501';
    end if;
  end if;

  if tg_op = 'UPDATE'
     and current_user in ('authenticated', 'anon')
     and old.group_activity_id is not null and (
    new.id is distinct from old.id
    or new.user_id is distinct from old.user_id
    or new.name is distinct from old.name
    or new.category is distinct from old.category
    or new.color_value is distinct from old.color_value
    or new.goal_seconds is distinct from old.goal_seconds
    or new.goal_pages is distinct from old.goal_pages
    or new.icon_name is distinct from old.icon_name
    or new.rest_minutes is distinct from old.rest_minutes
    or new.focus_session_count is distinct from old.focus_session_count
    or new.wallpaper_index is distinct from old.wallpaper_index
    or new.activity_type is distinct from old.activity_type
    or new.group_id is distinct from old.group_id
    or new.group_activity_id is distinct from old.group_activity_id
  ) then
    raise exception 'group subject metadata is immutable for members'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_protect_group_subject on public.user_subjects;
create trigger trg_protect_group_subject
  before insert or update on public.user_subjects
  for each row execute function public.protect_group_subject();

create or replace function public.protect_group_goal()
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

  -- Older cached clients may still upload the former ownership columns.
  -- Normalize known migrated sources, and require the dedicated RPC for new
  -- links. Generic personal writes must never reintroduce group ownership.
  if current_user in ('authenticated', 'anon')
     and (new.group_id is not null or new.group_activity_id is not null) then
    if exists (select 1 from public.group_activity_links l
      where l.activity_id = new.group_activity_id and l.user_id = new.user_id
        and l.source_id = new.id) then
      new.group_id := null;
      new.group_activity_id := null;
    else
      raise exception 'use group activity links' using errcode = '42501';
    end if;
  end if;
  if new.group_id is not null or new.group_activity_id is not null then
    if new.group_id is null or new.group_activity_id is null
       or new.id <> 'grp_' || new.group_activity_id::text
       or not public.is_group_member(new.group_id, new.user_id)
       or not exists (
         select 1 from public.group_activities ga
         where ga.id = new.group_activity_id
           and ga.group_id = new.group_id
           and ga.kind = 'goal'
       ) then
      raise exception 'invalid group goal link' using errcode = '42501';
    end if;
  end if;

  if tg_op = 'UPDATE'
     and current_user in ('authenticated', 'anon')
     and old.group_activity_id is not null and (
    new.id is distinct from old.id
    or new.user_id is distinct from old.user_id
    or new.name is distinct from old.name
    or new.color_value is distinct from old.color_value
    or new.target_days is distinct from old.target_days
    or new.sequence_type is distinct from old.sequence_type
    or new.goal_type is distinct from old.goal_type
    or new.group_id is distinct from old.group_id
    or new.group_activity_id is distinct from old.group_activity_id
  ) then
    raise exception 'group goal metadata is immutable for members'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_protect_group_goal on public.daily_goals;
create trigger trg_protect_group_goal
  before insert or update on public.daily_goals
  for each row execute function public.protect_group_goal();

-- Upgrade existing copies in place: retain ids/history and initial scoring
-- boundary, then release personal metadata from group ownership. Repeat-safe.
insert into public.group_activity_links(activity_id, user_id, source_id, started_at, start_date)
select ga.id, s.user_id, s.id, greatest(ga.created_at, gm.joined_at),
  (greatest(ga.created_at, gm.joined_at) at time zone 'utc')::date
from public.user_subjects s
join public.group_activities ga on ga.id = s.group_activity_id
join public.group_members gm on gm.group_id = ga.group_id and gm.user_id = s.user_id
where not exists (select 1 from public.group_activity_links l
  where l.activity_id = ga.id and l.user_id = s.user_id and l.source_id = s.id);
insert into public.group_activity_links(activity_id, user_id, source_id, started_at, start_date)
select ga.id, d.user_id, d.id, greatest(ga.created_at, gm.joined_at),
  (greatest(ga.created_at, gm.joined_at) at time zone 'utc')::date
from public.daily_goals d
join public.group_activities ga on ga.id = d.group_activity_id
join public.group_members gm on gm.group_id = ga.group_id and gm.user_id = d.user_id
where not exists (select 1 from public.group_activity_links l
  where l.activity_id = ga.id and l.user_id = d.user_id and l.source_id = d.id);
insert into public.group_goal_contributions(link_id, completed_date, recorded_at)
select l.id, value::date, value::date::timestamptz
from public.daily_goals d
join public.group_activity_links l on l.activity_id = d.group_activity_id
  and l.user_id = d.user_id and l.source_id = d.id
cross join lateral unnest(d.completed_dates) value
where value::date >= l.start_date
on conflict do nothing;
update public.user_subjects set group_id = null, group_activity_id = null
where group_id is not null or group_activity_id is not null;
update public.daily_goals set group_id = null, group_activity_id = null
where group_id is not null or group_activity_id is not null;

create or replace function public.capture_group_goal_contributions()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  delete from public.group_goal_contributions c
  using public.group_activity_links l, public.group_activities ga
  where c.link_id = l.id and l.activity_id = ga.id and ga.kind = 'goal'
    and l.user_id = new.user_id and l.source_id = new.id and l.ended_at is null
    and not (c.completed_date::text = any(new.completed_dates));
  insert into public.group_goal_contributions(link_id, completed_date)
  select l.id, value::date
  from public.group_activity_links l
  join public.group_activities ga on ga.id = l.activity_id and ga.kind = 'goal'
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

-- Atomic replacement under the membership lock. Unchanged selections retain
-- their original start; retries do not start new intervals or create new rows.
create or replace function public.set_group_activity_links(
  target_activity_id uuid,
  source_ids text[] default '{}',
  create_new boolean default false,
  local_date date default current_date
) returns void language plpgsql security definer set search_path = public
as $$
declare
  ga public.group_activities;
  selected_ids text[] := coalesce(source_ids, '{}'::text[]);
  source text;
  change_at timestamptz;
begin
  select * into ga from public.group_activities where id = target_activity_id;
  perform 1 from public.group_members
  where group_id = ga.group_id and user_id = auth.uid() for update;
  if not found then raise exception 'not a group member' using errcode = '42501'; end if;
  change_at := clock_timestamp();
  if abs(local_date - current_date) > 1 or local_date is null then
    raise exception 'invalid local date' using errcode = '23514';
  end if;
  if cardinality(selected_ids) > 100 or array_position(selected_ids, null) is not null then
    raise exception 'invalid sources' using errcode = '23514';
  end if;
  if create_new then
    if cardinality(selected_ids) <> 0 then
      raise exception 'choose existing sources or create one' using errcode = '23514';
    end if;
    source := 'grp_' || ga.id::text;
    if ga.kind = 'subject' then
      insert into public.user_subjects(id, user_id, name, category, color_value,
        goal_seconds, goal_pages, icon_name, rest_minutes, focus_session_count,
        wallpaper_index, activity_type)
      values (source, auth.uid(), coalesce(ga.payload->>'name', 'Atividade'),
        ga.payload->>'category', coalesce((ga.payload->>'color_value')::bigint, 4280391411),
        coalesce((ga.payload->>'goal_seconds')::integer, 0),
        coalesce((ga.payload->>'goal_pages')::integer, 0),
        coalesce(ga.payload->>'icon_name', ''),
        coalesce((ga.payload->>'rest_minutes')::integer, 5),
        coalesce((ga.payload->>'focus_session_count')::integer, 1),
        coalesce((ga.payload->>'wallpaper_index')::integer, 0),
        coalesce(ga.payload->>'activity_type', 'daily'))
      on conflict (user_id, id) do nothing;
    else
      insert into public.daily_goals(id, user_id, name, color_value, target_days,
        sequence_type, goal_type)
      values (source, auth.uid(), coalesce(ga.payload->>'name', 'Meta'),
        coalesce((ga.payload->>'color_value')::bigint, 4280391411),
        coalesce((ga.payload->>'target_days')::integer, 0),
        coalesce(ga.payload->>'sequence_type', 'casual'),
        coalesce(ga.payload->>'goal_type', 'total'))
      on conflict (user_id, id) do nothing;
    end if;
    selected_ids := array[source];
  end if;
  foreach source in array selected_ids loop
    if ga.kind = 'subject' then
      perform 1 from public.user_subjects s where s.user_id = auth.uid()
        and s.id = source and s.category = ga.payload->>'category'
        and s.group_id is null;
    else
      perform 1 from public.daily_goals d where d.user_id = auth.uid()
        and d.id = source and d.group_id is null for update;
    end if;
    if not found then
      raise exception 'source is missing or incompatible' using errcode = '23514';
    end if;
  end loop;
  update public.group_activity_links set ended_at = change_at
  where activity_id = ga.id and user_id = auth.uid() and ended_at is null
    and not (source_id = any(selected_ids));
  insert into public.group_activity_links(activity_id, user_id, source_id,
    started_at, start_date, excluded_dates)
  select ga.id, auth.uid(), chosen, change_at, local_date,
    case when ga.kind = 'goal' then coalesce((select d.completed_dates
      from public.daily_goals d where d.user_id = auth.uid() and d.id = chosen), '{}')
      else '{}'::text[] end
  from (select distinct unnest(selected_ids) chosen) selected
  where not exists (select 1 from public.group_activity_links l
    where l.activity_id = ga.id and l.user_id = auth.uid()
      and l.source_id = chosen and l.ended_at is null);
end; $$;

-- Only the caller's sources are returned. A peer can see aggregate scores,
-- never another member's list of personal activities or notes.
create or replace function public.group_activity_link_options(target_group_id uuid)
returns jsonb language plpgsql stable security definer set search_path = public
as $$
begin
  if not public.is_group_member(target_group_id, auth.uid()) then
    raise exception 'not a group member' using errcode = '42501';
  end if;
  return coalesce((select jsonb_agg(jsonb_build_object(
    'id', ga.id, 'kind', ga.kind, 'payload', ga.payload,
    'selected_ids', coalesce((select jsonb_agg(l.source_id)
      from public.group_activity_links l where l.activity_id = ga.id
        and l.user_id = auth.uid() and l.ended_at is null), '[]'::jsonb),
    'options', case when ga.kind = 'subject' then coalesce((
      select jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name) order by s.name)
      from public.user_subjects s where s.user_id = auth.uid() and s.group_id is null
        and s.category = ga.payload->>'category'), '[]'::jsonb)
    else coalesce((select jsonb_agg(jsonb_build_object('id', d.id, 'name', d.name) order by d.name)
      from public.daily_goals d where d.user_id = auth.uid() and d.group_id is null), '[]'::jsonb) end
  ) order by ga.created_at) from public.group_activities ga where ga.group_id = target_group_id), '[]'::jsonb);
end; $$;
