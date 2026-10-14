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
