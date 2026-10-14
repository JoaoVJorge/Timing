-- Adds the optional group accent introduced by the group appearance editor.
-- Safe to apply repeatedly to installations created before this column.
begin;

alter table public.groups
  add column if not exists color_value bigint;

notify pgrst, 'reload schema';

commit;
