-- Run in the Supabase SQL editor for existing installations.
-- Safe to repeat; existing goals keep reminders disabled (null).
begin;

alter table public.daily_goals
  add column if not exists reminder_minutes integer
    check (reminder_minutes between 0 and 1439);

notify pgrst, 'reload schema';

commit;
