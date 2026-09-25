-- =============================================================================
-- 04 · Tracking
-- Everything a user records about their own time: activity log, subjects,
-- daily goals and the weekly schedule, plus the progress metrics view.
-- Requires: 01_profiles.sql, 03_groups.sql (subjects and goals link to groups)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

create table if not exists public.activity_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  category text not null,
  subject_id text,
  subject_name text,
  seconds integer not null default 0 check (seconds >= 0),
  pages integer not null default 0 check (pages >= 0),
  completed_tasks integer not null default 0 check (completed_tasks >= 0),
  occurred_at timestamptz not null default now()
);

create table if not exists public.user_subjects (
  id text not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  category text not null
    check (category in ('studying', 'exercises', 'reading', 'hobbies')),
  color_value bigint not null,
  total_seconds integer not null default 0 check (total_seconds >= 0),
  goal_seconds integer not null default 0 check (goal_seconds >= 0),
  current_pages integer not null default 0 check (current_pages >= 0),
  goal_pages integer not null default 0 check (goal_pages >= 0),
  notes text not null default '',
  icon_name text not null default '',
  rest_minutes integer not null default 5 check (rest_minutes >= 0),
  focus_session_count integer not null default 1
    check (focus_session_count > 0),
  wallpaper_index integer not null default 0 check (wallpaper_index >= 0),
  activity_type text not null default 'daily'
    check (activity_type in ('daily', 'permanent')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.daily_goals (
  id text not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  color_value bigint not null,
  target_days integer not null default 0 check (target_days >= 0),
  completed_dates text[] not null default '{}',
  sequence_type text not null default 'casual'
    check (sequence_type in ('intense', 'casual')),
  last_resolved_missed_date text,
  goal_type text not null default 'total'
    check (goal_type in ('daily', 'total')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.schedule_entries (
  id text not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  weekday integer not null check (weekday between 1 and 7),
  start_minutes integer check (
    start_minutes is null or start_minutes between 0 and 1439
  ),
  end_minutes integer check (
    end_minutes is null or end_minutes between 0 and 1440
  ),
  active_from date not null default current_date,
  active_until date,
  constraint schedule_entries_active_until_check check (
    active_until is null or active_until >= active_from
  ),
  color_value bigint not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

alter table public.schedule_entries
  add column if not exists active_from date not null default current_date;
alter table public.schedule_entries
  add column if not exists active_until date;
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'schedule_entries_active_until_check'
      and conrelid = 'public.schedule_entries'::regclass
  ) then
    alter table public.schedule_entries
      add constraint schedule_entries_active_until_check
      check (active_until is null or active_until >= active_from);
  end if;
end $$;

-- Group-owned copies: a non-null group_id marks a subject/goal handed out by a
-- group. They cannot be deleted manually while the user is still a member (see
-- the delete policies) and are removed automatically when the membership ends
-- (see cleanup_group_activities_on_leave).
alter table public.user_subjects
  add column if not exists group_id uuid
    references public.groups(id) on delete set null;
alter table public.user_subjects
  add column if not exists group_activity_id uuid
    references public.group_activities(id) on delete set null;
alter table public.user_subjects
  add column if not exists activity_type text not null default 'daily'
    check (activity_type in ('daily', 'permanent'));
alter table public.daily_goals
  add column if not exists group_id uuid
    references public.groups(id) on delete set null;
alter table public.daily_goals
  add column if not exists group_activity_id uuid
    references public.group_activities(id) on delete set null;
alter table public.daily_goals
  add column if not exists sequence_type text not null default 'casual'
    check (sequence_type in ('intense', 'casual'));
alter table public.daily_goals
  add column if not exists last_resolved_missed_date text;

-- -----------------------------------------------------------------------------
-- Constraints
-- -----------------------------------------------------------------------------

-- Existing installations do not receive CHECK clauses from CREATE TABLE IF
-- NOT EXISTS. Add equivalent constraints as NOT VALID: new writes are guarded
-- immediately, while legacy rows can be cleaned and validated separately.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'activity_entries_nonnegative_check'
      and conrelid = 'public.activity_entries'::regclass
  ) then
    alter table public.activity_entries add constraint
      activity_entries_nonnegative_check check (
        seconds >= 0 and pages >= 0 and completed_tasks >= 0
      ) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'user_subjects_progress_check'
      and conrelid = 'public.user_subjects'::regclass
  ) then
    alter table public.user_subjects add constraint
      user_subjects_progress_check check (
        total_seconds >= 0
        and goal_seconds >= 0
        and current_pages >= 0
        and goal_pages >= 0
        and rest_minutes >= 0
        and focus_session_count > 0
        and wallpaper_index >= 0
      ) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'daily_goals_target_days_check'
      and conrelid = 'public.daily_goals'::regclass
  ) then
    alter table public.daily_goals add constraint
      daily_goals_target_days_check check (target_days >= 0) not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'activity_entries_reasonable_values_check'
      and conrelid = 'public.activity_entries'::regclass
  ) then
    alter table public.activity_entries add constraint
      activity_entries_reasonable_values_check check (
        seconds between 0 and 86400
        and pages between 0 and 10000
        and completed_tasks between 0 and 1000
        and (seconds > 0 or pages > 0 or completed_tasks > 0)
      ) not valid;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

create index if not exists activity_entries_user_period_idx
  on public.activity_entries(user_id, occurred_at);
create index if not exists activity_entries_user_subject_period_idx
  on public.activity_entries(user_id, subject_id, occurred_at);
create index if not exists user_subjects_user_category_idx
  on public.user_subjects(user_id, category);
create index if not exists user_subjects_group_activity_user_idx
  on public.user_subjects(group_activity_id, user_id);
create index if not exists daily_goals_user_idx
  on public.daily_goals(user_id);
create index if not exists schedule_entries_user_weekday_idx
  on public.schedule_entries(user_id, weekday, active_from, start_minutes);

create index if not exists user_subjects_group_idx
  on public.user_subjects(group_id);
create index if not exists daily_goals_group_idx
  on public.daily_goals(group_id);

-- -----------------------------------------------------------------------------
-- Views
-- -----------------------------------------------------------------------------

create or replace view public.user_progress_metrics
with (security_invoker = true) as
select
  p.id as user_id,
  subject_metrics.total_focus_seconds::integer,
  subject_metrics.studying_seconds::integer,
  subject_metrics.exercises_seconds::integer,
  subject_metrics.reading_seconds::integer,
  subject_metrics.hobbies_seconds::integer,
  subject_metrics.pages_read::integer,
  subject_metrics.focus_goal_seconds::integer,
  subject_metrics.reading_goal_pages::integer,
  goal_metrics.completed_goal_days::integer,
  goal_metrics.goals_count::integer,
  subject_metrics.subjects_count::integer,
  coalesce(month_activity.focus_seconds, 0)::integer as month_focus_seconds,
  coalesce(month_activity.sessions, 0)::integer as month_sessions,
  coalesce(month_activity.pages, 0)::integer as month_pages,
  coalesce(month_activity.completed_tasks, 0)::integer
    as month_completed_tasks
from public.profiles p
left join lateral (
  select
    coalesce(sum(s.total_seconds), 0) as total_focus_seconds,
    coalesce(
      sum(s.total_seconds) filter (where s.category = 'studying'),
      0
    ) as studying_seconds,
    coalesce(
      sum(s.total_seconds) filter (where s.category = 'exercises'),
      0
    ) as exercises_seconds,
    coalesce(
      sum(s.total_seconds) filter (where s.category = 'reading'),
      0
    ) as reading_seconds,
    coalesce(
      sum(s.total_seconds) filter (where s.category = 'hobbies'),
      0
    ) as hobbies_seconds,
    coalesce(sum(s.current_pages), 0) as pages_read,
    coalesce(sum(s.goal_seconds), 0) as focus_goal_seconds,
    coalesce(sum(s.goal_pages), 0) as reading_goal_pages,
    count(*) as subjects_count
  from public.user_subjects s
  where s.user_id = p.id
) subject_metrics on true
left join lateral (
  select
    coalesce(sum(cardinality(g.completed_dates)), 0) as completed_goal_days,
    count(*) as goals_count
  from public.daily_goals g
  where g.user_id = p.id
) goal_metrics on true
left join lateral (
  select
    coalesce(sum(a.seconds), 0) as focus_seconds,
    count(*) filter (where a.seconds > 0) as sessions,
    coalesce(sum(a.pages), 0) as pages,
    coalesce(sum(a.completed_tasks), 0) as completed_tasks
  from public.activity_entries a
  where a.user_id = p.id
    and a.occurred_at >= date_trunc('month', now())
) month_activity on true
where p.id = auth.uid();

-- -----------------------------------------------------------------------------
-- Access helpers
-- -----------------------------------------------------------------------------

-- Narrower than share_group: true only when the caller shares a group with
-- target_user_id through the specific subject that produced this activity
-- entry, so a group peer sees the entries feeding the leaderboard and nothing
-- else the target user tracks outside that group.
create or replace function public.can_view_peer_activity(
  target_user_id uuid,
  target_subject_id text
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_subjects s
    where s.user_id = target_user_id
      and s.id = target_subject_id
      and s.group_id is not null
      and public.is_group_member(s.group_id, auth.uid())
  );
$$;

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

drop trigger if exists trg_user_subjects_set_updated_at on public.user_subjects;
create trigger trg_user_subjects_set_updated_at
  before update on public.user_subjects
  for each row execute function public.set_updated_at();

drop trigger if exists trg_daily_goals_set_updated_at on public.daily_goals;
create trigger trg_daily_goals_set_updated_at
  before update on public.daily_goals
  for each row execute function public.set_updated_at();

drop trigger if exists trg_schedule_entries_set_updated_at
  on public.schedule_entries;
create trigger trg_schedule_entries_set_updated_at
  before update on public.schedule_entries
  for each row execute function public.set_updated_at();

-- An activity's log rows (activity_entries) go away with the activity: deleted
-- by the user, or removed because they left (or were removed from) the group
-- that handed it out. activity_entries.subject_id is plain text rather than a
-- foreign key (a session can reach the backend before its activity does, and a
-- foreign key would reject that row), so nothing else ever removed the log of a
-- deleted activity and it stayed in the table for good.
-- An activity that is only unlinked (group_id set to null when its group is
-- deleted) is updated, not deleted, so it keeps its log.
create or replace function public.delete_activity_entries_of_deleted_subject()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.activity_entries
   where user_id = old.user_id
     and subject_id = old.id;
  return old;
end;
$$;

drop trigger if exists trg_delete_activity_entries_of_deleted_subject
  on public.user_subjects;
create trigger trg_delete_activity_entries_of_deleted_subject
  after delete on public.user_subjects
  for each row
  execute function public.delete_activity_entries_of_deleted_subject();

-- Client timestamps are retained for offline sessions, but their range and
-- score are bounded. Entries are immutable and can only be created through
-- record_activity_entry(), preventing arbitrary table upserts from rewriting
-- leaderboard history.
create or replace function public.validate_activity_entry()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is not null and new.user_id <> auth.uid() then
    raise exception 'activity owner must match the authenticated user'
      using errcode = '42501';
  end if;
  if new.occurred_at < now() - interval '400 days'
     or new.occurred_at > now() + interval '5 minutes' then
    raise exception 'activity timestamp is outside the accepted range'
      using errcode = '22007';
  end if;
  if new.seconds > 86400 or new.pages > 10000
     or new.completed_tasks > 1000 then
    raise exception 'activity value exceeds the accepted limit'
      using errcode = '22003';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_validate_activity_entry
  on public.activity_entries;
create trigger trg_validate_activity_entry
  before insert or update on public.activity_entries
  for each row execute function public.validate_activity_entry();

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

drop function if exists public.record_activity_entry(
  uuid, text, text, text, integer, integer, integer, timestamptz
);
create or replace function public.record_activity_entry(
  entry_id uuid,
  entry_category text,
  entry_subject_id text,
  entry_subject_name text,
  entry_seconds integer,
  entry_pages integer,
  entry_completed_tasks integer,
  entry_occurred_at timestamptz
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'authentication required' using errcode = '28000';
  end if;
  if entry_category not in ('studying', 'exercises', 'reading', 'hobbies') then
    raise exception 'invalid activity category' using errcode = '23514';
  end if;

  insert into public.activity_entries (
    id, user_id, category, subject_id, subject_name,
    seconds, pages, completed_tasks, occurred_at
  ) values (
    entry_id, current_user_id, entry_category,
    nullif(entry_subject_id, ''), left(coalesce(entry_subject_name, ''), 200),
    entry_seconds, entry_pages, entry_completed_tasks, entry_occurred_at
  )
  on conflict (id) do nothing;
end;
$$;
