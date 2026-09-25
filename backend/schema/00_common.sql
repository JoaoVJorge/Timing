-- =============================================================================
-- 00 · Common
-- Extensions and helpers shared by every other section.
-- Apply this section first; the rest of the schema builds on it.
-- Requires: nothing
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Extensions
-- -----------------------------------------------------------------------------

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

-- -----------------------------------------------------------------------------
-- Shared trigger helper
-- -----------------------------------------------------------------------------

-- Stamps updated_at from the server clock on every update, so it stays
-- reliable even for rows changed by RPCs (materialize_group_activities_for_user,
-- update_group_with_activity, cleanup_group_activities_on_leave) that don't set
-- it themselves. Clients that resolve sync conflicts by comparing updated_at
-- can then trust it regardless of which code path touched the row.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
