-- Run in the Supabase SQL editor for existing installations, only once no
-- build up to 0.1.6 is in use: those still send reminder_minutes and their
-- goal sync fails with PGRST204 after this. Safe to repeat.
begin;

alter table public.daily_goals
  drop column if exists reminder_minutes;

notify pgrst, 'reload schema';

commit;
