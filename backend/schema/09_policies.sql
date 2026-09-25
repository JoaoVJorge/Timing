-- =============================================================================
-- 09 · Row level security
-- Enables RLS on every table and defines who can see or change each row.
-- Requires: 02-04 (tables), the access helpers in 02-04
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Enable RLS
-- -----------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.profile_private_data enable row level security;
alter table public.friendships enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_invitations enable row level security;
alter table public.group_activities enable row level security;
alter table public.activity_entries enable row level security;
alter table public.user_subjects enable row level security;
alter table public.daily_goals enable row level security;
alter table public.schedule_entries enable row level security;
alter table public.group_image_messages enable row level security;

-- -----------------------------------------------------------------------------
-- Drop previous policies
-- -----------------------------------------------------------------------------

drop policy if exists "profiles are visible to self, friends, and group peers"
on public.profiles;
drop policy if exists "users read own private profile"
on public.profile_private_data;
drop policy if exists "users insert own private profile"
on public.profile_private_data;
drop policy if exists "users update own private profile"
on public.profile_private_data;
drop policy if exists "users delete own private profile"
on public.profile_private_data;
drop policy if exists "users insert own profile" on public.profiles;
drop policy if exists "users update own profile" on public.profiles;
drop policy if exists "users see own friendships" on public.friendships;
drop policy if exists "users request friendships" on public.friendships;
drop policy if exists "users answer received friendships" on public.friendships;
drop policy if exists "users delete own friendships" on public.friendships;
drop policy if exists "members see their groups" on public.groups;
drop policy if exists "users create owned groups" on public.groups;
drop policy if exists "owners update groups" on public.groups;
drop policy if exists "owners delete groups" on public.groups;
drop policy if exists "members see group memberships" on public.group_members;
drop policy if exists "owners add group members" on public.group_members;
drop policy if exists "users join groups" on public.group_members;
drop policy if exists "invitees join invited groups" on public.group_members;
drop policy if exists "owners remove group members" on public.group_members;
drop policy if exists "users leave their groups" on public.group_members;
drop policy if exists "invited or inviter see invitations"
on public.group_invitations;
drop policy if exists "owners create invitations" on public.group_invitations;
drop policy if exists "invitee answers invitations" on public.group_invitations;
drop policy if exists "inviter or invitee delete invitations"
on public.group_invitations;
drop policy if exists "members read group activities" on public.group_activities;
drop policy if exists "owners manage group activities" on public.group_activities;
drop policy if exists "users see activity from group peers"
on public.activity_entries;
drop policy if exists "users insert own activity" on public.activity_entries;
drop policy if exists "users manage own activity" on public.activity_entries;
drop policy if exists "users delete own activity" on public.activity_entries;
drop policy if exists "users manage own subjects" on public.user_subjects;
drop policy if exists "users manage own goals" on public.daily_goals;
drop policy if exists "users manage own schedule entries"
on public.schedule_entries;

drop policy if exists "users read own subjects" on public.user_subjects;
drop policy if exists "users insert own subjects" on public.user_subjects;
drop policy if exists "users update own subjects" on public.user_subjects;
drop policy if exists "users delete own subjects" on public.user_subjects;
drop policy if exists "users read own goals" on public.daily_goals;
drop policy if exists "users insert own goals" on public.daily_goals;
drop policy if exists "users update own goals" on public.daily_goals;
drop policy if exists "users delete own goals" on public.daily_goals;
drop policy if exists "users read own schedule entries"
on public.schedule_entries;
drop policy if exists "users insert own schedule entries"
on public.schedule_entries;
drop policy if exists "users update own schedule entries"
on public.schedule_entries;
drop policy if exists "users delete own schedule entries"
on public.schedule_entries;
drop policy if exists "members read group image messages"
on public.group_image_messages;
drop policy if exists "members insert own group image messages"
on public.group_image_messages;

-- -----------------------------------------------------------------------------
-- Policies
-- -----------------------------------------------------------------------------

create policy "profiles are visible to self, friends, and group peers"
on public.profiles for select
using (
  id = auth.uid()
  or public.are_friends(auth.uid(), profiles.id)
  or public.share_group(auth.uid(), profiles.id)
);

create policy "users read own private profile"
on public.profile_private_data for select
using (user_id = auth.uid());

create policy "users insert own private profile"
on public.profile_private_data for insert
with check (user_id = auth.uid());

create policy "users update own private profile"
on public.profile_private_data for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own private profile"
on public.profile_private_data for delete
using (user_id = auth.uid());

create policy "users insert own profile"
on public.profiles for insert
with check (id = auth.uid());

create policy "users update own profile"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "users see own friendships"
on public.friendships for select
using (requester_id = auth.uid() or addressee_id = auth.uid());

create policy "users request friendships"
on public.friendships for insert
with check (
  requester_id = auth.uid()
  and addressee_id <> auth.uid()
  and status = 'pending'
);

create policy "users answer received friendships"
on public.friendships for update
using (addressee_id = auth.uid())
with check (addressee_id = auth.uid());

create policy "users delete own friendships"
on public.friendships for delete
using (requester_id = auth.uid() or addressee_id = auth.uid());

create policy "members see their groups"
on public.groups for select
using (public.is_group_member(groups.id, auth.uid()));

create policy "users create owned groups"
on public.groups for insert
with check (owner_id = auth.uid());

create policy "owners update groups"
on public.groups for update
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "owners delete groups"
on public.groups for delete
using (owner_id = auth.uid());

create policy "members see group memberships"
on public.group_members for select
using (public.is_group_member(group_members.group_id, auth.uid()));

create policy "invitees join invited groups"
on public.group_members for insert
with check (
  group_members.user_id = auth.uid()
  and group_members.role = 'member'
  and exists (
    select 1
    from public.group_invitations gi
    where gi.group_id = group_members.group_id
      and gi.invitee_id = auth.uid()
      and gi.status = 'pending'
  )
);

create policy "owners remove group members"
on public.group_members for delete
using (public.owns_group(group_members.group_id, auth.uid()));

create policy "users leave their groups"
on public.group_members for delete
using (user_id = auth.uid());

create policy "invited or inviter see invitations"
on public.group_invitations for select
using (invitee_id = auth.uid() or inviter_id = auth.uid());

create policy "owners create invitations"
on public.group_invitations for insert
with check (
  inviter_id = auth.uid()
  and public.owns_group(group_invitations.group_id, auth.uid())
  and public.are_friends(auth.uid(), group_invitations.invitee_id)
  and group_invitations.status = 'pending'
);

create policy "invitee answers invitations"
on public.group_invitations for update
using (invitee_id = auth.uid())
with check (invitee_id = auth.uid());

create policy "inviter or invitee delete invitations"
on public.group_invitations for delete
using (inviter_id = auth.uid() or invitee_id = auth.uid());

create policy "members read group activities"
on public.group_activities for select
using (public.is_group_member(group_activities.group_id, auth.uid()));

create policy "owners manage group activities"
on public.group_activities for all
using (public.owns_group(group_activities.group_id, auth.uid()))
with check (public.owns_group(group_activities.group_id, auth.uid()));

create policy "users see activity from group peers"
on public.activity_entries for select
using (
  user_id = auth.uid()
  or public.can_view_peer_activity(
    activity_entries.user_id, activity_entries.subject_id
  )
);

create policy "users insert own activity"
on public.activity_entries for insert
with check (user_id = auth.uid());

create policy "users manage own activity"
on public.activity_entries for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own activity"
on public.activity_entries for delete
using (user_id = auth.uid());

create policy "users read own subjects"
on public.user_subjects for select
using (user_id = auth.uid());

create policy "users insert own subjects"
on public.user_subjects for insert
with check (user_id = auth.uid());

create policy "users update own subjects"
on public.user_subjects for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own subjects"
on public.user_subjects for delete
using (
  user_id = auth.uid()
  and (
    group_id is null
    or not public.is_group_member(group_id, auth.uid())
  )
);

create policy "users read own goals"
on public.daily_goals for select
using (user_id = auth.uid());

create policy "users insert own goals"
on public.daily_goals for insert
with check (user_id = auth.uid());

create policy "users update own goals"
on public.daily_goals for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own goals"
on public.daily_goals for delete
using (
  user_id = auth.uid()
  and (
    group_id is null
    or not public.is_group_member(group_id, auth.uid())
  )
);

create policy "users read own schedule entries"
on public.schedule_entries for select
using (user_id = auth.uid());

create policy "users insert own schedule entries"
on public.schedule_entries for insert
with check (user_id = auth.uid());

create policy "users update own schedule entries"
on public.schedule_entries for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "users delete own schedule entries"
on public.schedule_entries for delete
using (user_id = auth.uid());

create policy "members read group image messages"
on public.group_image_messages for select
using (public.is_group_member(group_image_messages.group_id, auth.uid()));

create policy "members insert own group image messages"
on public.group_image_messages for insert
with check (
  sender_id = auth.uid()
  and public.is_group_member(group_image_messages.group_id, auth.uid())
);
