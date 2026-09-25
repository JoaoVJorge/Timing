-- =============================================================================
-- 05 · Group activities
-- Fans a group's activity template out to each member and keeps those
-- group-owned copies consistent when members join, leave or edit them.
-- Requires: 03_groups.sql, 04_tracking.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Fan-out
-- -----------------------------------------------------------------------------

-- Creates a per-user copy of every activity template attached to a group.
-- Reused by group creation (once per member) and by joining via invite code
-- (once for the joining user), so every member ends up with their own
-- group-linked subject/goal. Idempotent via the (user_id, id) conflict key.
create or replace function public.materialize_group_activities_for_user(
  target_group_id uuid,
  target_user_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  ga record;
begin
  for ga in
    select * from public.group_activities where group_id = target_group_id
  loop
    if ga.kind = 'subject' then
      insert into public.user_subjects (
        id, user_id, name, category, color_value,
        goal_seconds, goal_pages, notes, icon_name,
        rest_minutes, focus_session_count, wallpaper_index, activity_type,
        group_id, group_activity_id
      ) values (
        'grp_' || ga.id::text,
        target_user_id,
        coalesce(nullif(ga.payload->>'name', ''), 'Atividade'),
        coalesce(nullif(ga.payload->>'category', ''), 'studying'),
        coalesce((ga.payload->>'color_value')::bigint, 4280391411),
        coalesce((ga.payload->>'goal_seconds')::integer, 0),
        coalesce((ga.payload->>'goal_pages')::integer, 0),
        coalesce(ga.payload->>'notes', ''),
        coalesce(ga.payload->>'icon_name', ''),
        coalesce((ga.payload->>'rest_minutes')::integer, 5),
        coalesce((ga.payload->>'focus_session_count')::integer, 1),
        coalesce((ga.payload->>'wallpaper_index')::integer, 0),
        coalesce(nullif(ga.payload->>'activity_type', ''), 'daily'),
        target_group_id,
        ga.id
      )
      on conflict (user_id, id) do nothing;
    elsif ga.kind = 'goal' then
      insert into public.daily_goals (
        id, user_id, name, color_value, target_days,
        sequence_type, goal_type,
        group_id, group_activity_id
      ) values (
        'grp_' || ga.id::text,
        target_user_id,
        coalesce(nullif(ga.payload->>'name', ''), 'Meta'),
        coalesce((ga.payload->>'color_value')::bigint, 4280391411),
        coalesce((ga.payload->>'target_days')::integer, 0),
        coalesce(nullif(ga.payload->>'sequence_type', ''), 'casual'),
        coalesce(nullif(ga.payload->>'goal_type', ''), 'total'),
        target_group_id,
        ga.id
      )
      on conflict (user_id, id) do update
      set
        name = excluded.name,
        color_value = excluded.color_value,
        target_days = excluded.target_days,
        sequence_type = excluded.sequence_type,
        goal_type = excluded.goal_type,
        group_id = excluded.group_id,
        group_activity_id = excluded.group_activity_id
      where
        daily_goals.name is distinct from excluded.name
        or daily_goals.color_value is distinct from excluded.color_value
        or daily_goals.target_days is distinct from excluded.target_days
        or daily_goals.sequence_type is distinct from excluded.sequence_type
        or daily_goals.goal_type is distinct from excluded.goal_type
        or daily_goals.group_id is distinct from excluded.group_id
        or daily_goals.group_activity_id
          is distinct from excluded.group_activity_id;

      -- Older clients could reuse a local goal with a different id and stamp
      -- the same group_activity_id on it. Preserve any dates recorded on that
      -- legacy copy by folding them into the canonical grp_<activity-id> row.
      update public.daily_goals canonical_goal
      set completed_dates = coalesce((
        select array_agg(distinct completed.value order by completed.value)
        from public.daily_goals source_goal
        cross join lateral unnest(source_goal.completed_dates)
          as completed(value)
        where source_goal.user_id = target_user_id
          and (
            source_goal.id = 'grp_' || ga.id::text
            or source_goal.group_activity_id = ga.id
          )
      ), '{}'::text[])
      where canonical_goal.user_id = target_user_id
        and canonical_goal.id = 'grp_' || ga.id::text;
    end if;
  end loop;
end;
$$;

-- Fans the group's activities out to a member the moment their membership row
-- is created, no matter which path created it: the accept/join RPCs, or the
-- client-side fallback (_acceptInvitationDirectly) that inserts the membership
-- directly and cannot call materialize itself. Idempotent — the materialize
-- inserts use `on conflict do nothing`, so the explicit calls in the RPCs stay
-- harmless. (Group creation still needs its own explicit call: the owner's
-- membership is inserted before the group_activities row exists.)
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

-- -----------------------------------------------------------------------------
-- Membership changes
-- -----------------------------------------------------------------------------

-- When a membership row goes away because the user leaves (or is removed),
-- their group-linked copies are removed. When the group itself is deleted,
-- the copies are kept and unlinked so they become ordinary activities/goals
-- that the user can edit or delete.
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

  delete from public.user_subjects
   where user_id = old.user_id and group_id = old.group_id;
  delete from public.daily_goals
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
