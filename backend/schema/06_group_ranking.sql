-- =============================================================================
-- 06 · Group ranking
-- Read side of a group: the leaderboard built from what members recorded on
-- the personal activities they linked to it.
-- Requires: 03_groups.sql, 04_tracking.sql, 05_group_activity_links.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

-- Aggregated leaderboard scores for each requested group. A member scores
-- only with entries of an activity linked to that group, recorded inside one
-- of its link periods and after the group's last reset. Daily-goal groups
-- count each completion date once.
-- Doing this server-side avoids downloading every activity entry, and the
-- function runs with definer rights because members cannot read each other's
-- entries: only these aggregates leave the server.
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
    select requested.group_id, target.theme as category,
      target.created_at, target.score_reset_at
    from unnest(target_group_ids) as requested(group_id)
    join public.groups target on target.id = requested.group_id
    where public.is_group_member(requested.group_id, auth.uid())
  ), member_scope as (
    select target.group_id, target.category, target.created_at,
      target.score_reset_at, member.user_id
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
      where link.group_id = member.group_id
        and link.user_id = member.user_id and link.source_id = activity.subject_id
        and activity.category = member.category
        and activity.occurred_at >= greatest(
          link.started_at, coalesce(member.score_reset_at, member.created_at)
        )
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
    join public.group_activity_links link on link.group_id = member.group_id
      and link.user_id = member.user_id
    join public.group_goal_contributions completed on completed.link_id = link.id
    where member.category = 'dailyGoals'
      and (member.score_reset_at is null
        or completed.completed_date > (member.score_reset_at at time zone 'utc')::date)
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
