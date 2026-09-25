-- =============================================================================
-- 12 · Maintenance
-- One-off data cleanup that is safe to repeat on every deployment.
-- Requires: 04_tracking.sql, 08_group_invitations.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Legacy data cleanup
-- -----------------------------------------------------------------------------

-- Legacy data cleanup. This is intentionally part of the canonical setup so
-- deployments need only this file. It is safe to run repeatedly: current
-- triggers prevent new orphaned subject activity, and these predicates only
-- remove old rows that the app can no longer use.
with removed_entries as (
  delete from public.activity_entries e
  where coalesce(e.subject_id, '') <> ''
    and e.completed_tasks = 0
    and e.occurred_at < now() - interval '7 days'
    and not exists (
      select 1
      from public.user_subjects s
      where s.user_id = e.user_id and s.id = e.subject_id
    )
  returning e.id
), removed_invitations as (
  delete from public.group_invitations i
  where i.status in ('accepted', 'declined')
    and coalesce(i.responded_at, i.created_at)
      < now() - interval '30 days'
  returning i.id
)
select
  (select count(*) from removed_entries) as activity_entries_removed,
  (select count(*) from removed_invitations) as group_invitations_removed;
