-- =============================================================================
-- 11 · Grants
-- Least-privilege lockdown. Must stay after every function and table is
-- defined, or the objects created later keep Supabase's default grants.
-- Requires: every section above
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Function privileges
-- -----------------------------------------------------------------------------

-- PostgreSQL grants EXECUTE on new functions to PUBLIC by default. Explicitly
-- close every definer/trigger helper, then expose only the RPC surface used by
-- authenticated clients. In particular, materialize_group_activities_for_user
-- must remain internal because it bypasses RLS and accepts a target user id.
revoke all on function public.handle_new_user() from public;
revoke all on function public.materialize_group_activities_for_user(uuid, uuid)
  from public;
revoke all on function public.cleanup_group_activities_on_leave() from public;
revoke all on function public.delete_activity_entries_of_deleted_subject()
  from public;
revoke all on function public.materialize_group_activities_on_join() from public;
revoke all on function public.keep_friendship_identity_immutable() from public;
revoke all on function public.keep_group_invitation_identity_immutable()
  from public;
revoke all on function public.set_updated_at() from public;
revoke all on function public.validate_activity_entry() from public;
revoke all on function public.protect_group_subject() from public;
revoke all on function public.protect_group_goal() from public;
revoke all on function public.enforce_group_image_rate_limit() from public;

revoke all on function public.generate_friend_code() from public;
revoke all on function public.are_friends(uuid, uuid) from public;
revoke all on function public.is_group_member(uuid, uuid) from public;
revoke all on function public.share_group(uuid, uuid) from public;
revoke all on function public.owns_group(uuid, uuid) from public;
revoke all on function public.can_view_peer_activity(uuid, text) from public;
revoke all on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) from public;
revoke all on function public.group_activity_progress(uuid, text) from public;
revoke all on function public.search_friend_candidates(text, integer)
  from public;
revoke all on function public.find_profile_by_friend_code(text) from public;
revoke all on function public.create_group_with_members(
  text, text, uuid[], text, text, jsonb
) from public;
revoke all on function public.join_group_by_invite_code(text) from public;
revoke all on function public.update_group_with_activity(
  uuid, text, text, jsonb
) from public;
revoke all on function public.reset_group_progress(uuid) from public;
revoke all on function public.pending_group_invitations() from public;
revoke all on function public.group_invite_options(uuid) from public;
revoke all on function public.invite_friend_to_group(uuid, uuid) from public;
revoke all on function public.cancel_group_invitation(uuid, uuid) from public;
revoke all on function public.accept_group_invitation(uuid) from public;
revoke all on function public.decline_group_invitation(uuid) from public;
revoke all on function public.record_activity_entry(
  uuid, text, text, text, integer, integer, integer, timestamptz
) from public;

grant execute on function public.generate_friend_code() to authenticated;
grant execute on function public.are_friends(uuid, uuid) to authenticated;
grant execute on function public.is_group_member(uuid, uuid) to authenticated;
grant execute on function public.share_group(uuid, uuid) to authenticated;
grant execute on function public.owns_group(uuid, uuid) to authenticated;
grant execute on function public.can_view_peer_activity(uuid, text)
  to authenticated;
grant execute on function public.group_leaderboard_scores(
  uuid[], timestamptz, timestamptz, timestamptz
) to authenticated;
grant execute on function public.group_activity_progress(uuid, text)
  to authenticated;
grant execute on function public.search_friend_candidates(text, integer)
  to authenticated;
grant execute on function public.find_profile_by_friend_code(text)
  to authenticated;
grant execute on function public.create_group_with_members(
  text, text, uuid[], text, text, jsonb
) to authenticated;
grant execute on function public.join_group_by_invite_code(text)
  to authenticated;
grant execute on function public.update_group_with_activity(
  uuid, text, text, jsonb
) to authenticated;
grant execute on function public.reset_group_progress(uuid) to authenticated;
grant execute on function public.pending_group_invitations() to authenticated;
grant execute on function public.group_invite_options(uuid) to authenticated;
grant execute on function public.invite_friend_to_group(uuid, uuid)
  to authenticated;
grant execute on function public.cancel_group_invitation(uuid, uuid)
  to authenticated;
grant execute on function public.accept_group_invitation(uuid)
  to authenticated;
grant execute on function public.decline_group_invitation(uuid)
  to authenticated;
grant execute on function public.record_activity_entry(
  uuid, text, text, text, integer, integer, integer, timestamptz
) to authenticated;

-- -----------------------------------------------------------------------------
-- Table privileges
-- -----------------------------------------------------------------------------

-- The mobile app has no signed-out data surface. Remove the broad default
-- Data API grants and keep authenticated access explicit. RLS still decides
-- which rows each signed-in user may reach.
revoke all on all tables in schema public from anon;
revoke all on all sequences in schema public from anon;
revoke execute on all functions in schema public from anon;

-- Do not rely on Supabase's project-wide default grants. Keep the Data API
-- surface explicit; row policies below remain the per-record authorization
-- layer for every granted operation.
revoke all on table public.profiles from authenticated;
revoke all on table public.friendships from authenticated;
revoke all on table public.groups from authenticated;
revoke all on table public.group_members from authenticated;
revoke all on table public.group_invitations from authenticated;
revoke all on table public.group_activities from authenticated;
revoke all on table public.activity_entries from authenticated;
revoke all on table public.user_subjects from authenticated;
revoke all on table public.daily_goals from authenticated;
revoke all on table public.schedule_entries from authenticated;
revoke all on table public.group_image_messages from authenticated;

grant select, insert on table public.profiles to authenticated;
grant select, insert, update, delete
  on table public.friendships to authenticated;
grant select, insert, update, delete on table public.groups to authenticated;
grant select, insert, delete on table public.group_members to authenticated;
grant select, insert, update, delete
  on table public.group_invitations to authenticated;
grant select, insert, update, delete
  on table public.group_activities to authenticated;
grant select, insert, update, delete
  on table public.user_subjects to authenticated;
grant select, insert, update, delete
  on table public.daily_goals to authenticated;
grant select, insert, update, delete
  on table public.schedule_entries to authenticated;
grant select, insert on table public.group_image_messages to authenticated;
grant select on table public.profile_presence_status to authenticated;
grant select on table public.user_progress_metrics to authenticated;

revoke all on table public.profile_private_data from authenticated;
grant select, insert, update, delete
  on table public.profile_private_data to authenticated;

-- Profile identity and audit columns are server-owned.
revoke update on table public.profiles from authenticated;
grant update (
  id,
  is_dark_mode,
  user_name,
  nick_name,
  profile_photo_base64,
  accent_color_value,
  avatar_icon_index,
  is_online,
  last_seen_at,
  notifications_enabled,
  language_code,
  focus_lock_studying_enabled,
  focus_lock_exercises_enabled,
  focus_lock_reading_enabled,
  focus_lock_hobbies_enabled
) on table public.profiles to authenticated;

-- Activity history is append-only through the validating RPC above. Users may
-- still remove their own history through the owner-scoped delete policy.
grant select, delete on table public.activity_entries to authenticated;
