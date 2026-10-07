-- =============================================================================
-- 06 · Group ranking
-- Read side of group activities: the leaderboard and per-member progress.
-- Requires: 03_groups.sql, 04_tracking.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

-- Aggregated leaderboard scores for each requested group. Every score is
-- isolated to the subject/goal linked to that group and starts when the group
-- activity was created. Daily-goal groups count each completion date once.
-- Doing this server-side avoids downloading every activity entry and,
-- because the function runs with definer rights, avoids evaluating the
-- activity_entries peer RLS policy once per activity row. The explicit peer
-- check below keeps the same access boundary as that policy.
drop function if exists public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
);
create or replace function public.group_leaderboard_scores(
  target_group_ids uuid[],
  today_start timestamptz,
  week_start timestamptz,
  month_start timestamptz
)
returns table (
  group_id uuid,
  user_id uuid,
  category text,
  today_score bigint,
  week_score bigint,
  month_score bigint,
  total_score bigint
)
language sql
stable
security definer
set search_path = public
as $$
  with authorized_groups as (
    select requested.group_id, target.theme as category
    from unnest(target_group_ids) as requested(group_id)
    join public.groups target on target.id = requested.group_id
    where public.is_group_member(requested.group_id, auth.uid())
  ), member_scope as (
    select target.group_id, target.category, member.user_id
    from authorized_groups target
    join public.group_members member on member.group_id = target.group_id
  ), scored_entries as (
    select
      member.group_id,
      member.user_id,
      member.category,
      activity.occurred_at,
      case
        when member.category = 'reading' then activity.pages
        else activity.seconds
      end::bigint as score
    from member_scope member
    join public.activity_entries activity on activity.user_id = member.user_id
    where exists (
      select 1 from public.group_activity_links link
      join public.group_activities ga on ga.id = link.activity_id
      where ga.group_id = member.group_id and ga.kind = 'subject'
        and link.user_id = member.user_id and link.source_id = activity.subject_id
        and activity.category = member.category
        and activity.occurred_at >= greatest(link.started_at, coalesce(ga.score_reset_at, ga.created_at))
        and (link.ended_at is null or activity.occurred_at < link.ended_at)
    )
      and member.category <> 'dailyGoals'
  ), activity_scores as (
    select
      scored.group_id,
      scored.user_id,
      scored.category,
      coalesce(sum(scored.score) filter (
        where scored.occurred_at >= today_start
      ), 0)::bigint as today_score,
      coalesce(sum(scored.score) filter (
        where scored.occurred_at >= week_start
      ), 0)::bigint as week_score,
      coalesce(sum(scored.score) filter (
        where scored.occurred_at >= month_start
      ), 0)::bigint as month_score,
      coalesce(sum(scored.score), 0)::bigint as total_score
    from scored_entries scored
    group by scored.group_id, scored.user_id, scored.category
  ), goal_dates as (
    select distinct
      member.group_id,
      member.user_id,
      completed.completed_date
    from member_scope member
    join public.group_activities activity
      on activity.group_id = member.group_id
     and activity.kind = 'goal'
    join public.group_activity_links link on link.activity_id = activity.id
      and link.user_id = member.user_id
    join public.group_goal_contributions completed on completed.link_id = link.id
    where member.category = 'dailyGoals'
      and (activity.score_reset_at is null
        or completed.completed_date > (activity.score_reset_at at time zone 'utc')::date)
      and completed.completed_date <= (today_start at time zone 'utc')::date
  ), goal_scores as (
    select
      goal_date.group_id,
      goal_date.user_id,
      'dailyGoals'::text as category,
      count(*) filter (
        where goal_date.completed_date >=
          (today_start at time zone 'utc')::date
      )::bigint as today_score,
      count(*) filter (
        where goal_date.completed_date >=
          (week_start at time zone 'utc')::date
      )::bigint as week_score,
      count(*) filter (
        where goal_date.completed_date >=
          (month_start at time zone 'utc')::date
      )::bigint as month_score,
      count(*)::bigint as total_score
    from goal_dates goal_date
    group by goal_date.group_id, goal_date.user_id
  )
  select * from activity_scores
  union all
  select * from goal_scores;
$$;

revoke execute on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) from public;
grant execute on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) to authenticated;

-- Per-member completion of a group's activities. Runs with definer rights so a
-- member can see whether their peers completed it today, which RLS on
-- user_subjects / daily_goals would otherwise hide. [local_date] is the
-- caller's local YYYY-MM-DD, used so the "daily" meta check matches the day the
-- client recorded, not the server's UTC day. Once an activity is reset, its
-- shared progress is derived from entries/completion dates after score_reset_at;
-- the member's cumulative personal fields remain untouched.
-- Dropped first: an older deployment may have a different OUT-parameter row
-- type, which `create or replace` cannot change (error 42P13).
drop function if exists public.group_activity_progress(uuid, text);
create or replace function public.group_activity_progress(
  target_group_id uuid,
  local_date text default null
)
returns table (
  activity_id uuid,
  kind text,
  name text,
  member_id uuid,
  progress integer,
  target integer,
  reached boolean,
  focus_seconds integer,
  rest_minutes integer,
  focus_session_count integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  today_key text := coalesce(
    nullif(local_date, ''),
    to_char((now() at time zone 'utc'), 'YYYY-MM-DD')
  );
begin
  if not public.is_group_member(target_group_id, auth.uid()) then
    raise exception 'not a group member' using errcode = '42501';
  end if;

  return query
  select
    ga.id,
    ga.kind,
    coalesce(nullif(ga.payload->>'name', ''), 'Atividade'),
    gm.user_id,
    coalesce(reset_subject.progress, 0),
    case
      when coalesce((ga.payload->>'goal_pages')::integer, 0) > 0
        then (ga.payload->>'goal_pages')::integer
      else coalesce((ga.payload->>'goal_seconds')::integer, 0)
    end,
    case
      when coalesce((ga.payload->>'goal_pages')::integer, 0) > 0 then
        coalesce(reset_subject.progress, 0) >=
          (ga.payload->>'goal_pages')::integer
      else
        coalesce((ga.payload->>'goal_seconds')::integer, 0) > 0
        and coalesce(reset_subject.progress, 0) >=
          (ga.payload->>'goal_seconds')::integer
    end,
    coalesce((ga.payload->>'goal_seconds')::integer, 0),
    coalesce((ga.payload->>'rest_minutes')::integer, 5),
    coalesce((ga.payload->>'focus_session_count')::integer, 1)
  from public.group_activities ga
  join public.group_members gm on gm.group_id = ga.group_id
  left join lateral (
    select coalesce(sum(
      case
        when coalesce((ga.payload->>'goal_pages')::integer, 0) > 0
          then entry.pages
        else entry.seconds
      end
    ), 0)::integer as progress
    from public.activity_entries entry
    where entry.user_id = gm.user_id
      and entry.category = ga.payload->>'category'
      and entry.occurred_at >= coalesce(ga.score_reset_at, ga.created_at)
      and exists (
        select 1 from public.group_activity_links link
        where link.activity_id = ga.id and link.user_id = gm.user_id
          and link.source_id = entry.subject_id
          and entry.occurred_at >= link.started_at
          and (link.ended_at is null or entry.occurred_at < link.ended_at)
      )
  ) reset_subject on true
  where ga.group_id = target_group_id and ga.kind = 'subject'

  union all

  select
    ga.id,
    ga.kind,
    coalesce(nullif(ga.payload->>'name', ''), 'Meta'),
    gm.user_id,
    case
      when coalesce(ga.payload->>'goal_type', 'total') = 'daily'
        then case when goal_progress.completed_today then 1 else 0 end
      else goal_progress.completed_count
    end,
    coalesce(
      case
        when coalesce(ga.payload->>'goal_type', 'total') = 'daily'
          then 1
        else coalesce(
          (ga.payload->>'target_days')::integer,
          0
        )
      end,
      0
    ),
    goal_progress.completed_today,
    0,
    5,
    1
  from public.group_activities ga
  join public.group_members gm on gm.group_id = ga.group_id
  left join lateral (
    select count(distinct completed.completed_date)::integer as completed_count,
      coalesce(bool_or(completed.completed_date::text = today_key), false) as completed_today
    from public.group_activity_links link
    join public.group_goal_contributions completed on completed.link_id = link.id
    where link.activity_id = ga.id and link.user_id = gm.user_id
      and completed.completed_date <= today_key::date
      and (ga.score_reset_at is null or completed.completed_date >
        (ga.score_reset_at at time zone 'utc')::date)
  ) goal_progress on true
  where ga.group_id = target_group_id and ga.kind = 'goal';
end;
$$;

grant execute on function public.group_activity_progress(uuid, text)
to authenticated;
