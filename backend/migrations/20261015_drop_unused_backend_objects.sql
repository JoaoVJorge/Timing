-- Removes backend objects nothing ever used: the open profile search RPC with
-- its trigram indexes, the user_progress_metrics view, and the
-- profiles.is_dark_mode column. Safe to repeat.
--
-- People are found by their friend code
-- (`find_profile_by_friend_code`); the former search returned every profile to
-- any authenticated caller. Progress numbers come from the activity and goal
-- rows the app already syncs, never from the view. The theme is a device
-- setting, kept in local storage.
--
-- Builds up to 0.1.6 still select is_dark_mode and stop loading the profile
-- once it is gone, so run this only after they are retired.
begin;

drop function if exists public.search_friend_candidates(text, integer);
drop index if exists public.profiles_user_name_trgm_idx;
drop index if exists public.profiles_nick_name_trgm_idx;
drop index if exists public.profiles_friend_code_trgm_idx;

drop view if exists public.user_progress_metrics;

alter table public.profiles
  drop column if exists is_dark_mode;

notify pgrst, 'reload schema';

commit;

-- pg_trgm was installed for those indexes alone. Outside the transaction so a
-- dependency elsewhere in the project only fails this last statement.
drop extension if exists pg_trgm;
