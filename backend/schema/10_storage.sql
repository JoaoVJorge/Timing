-- =============================================================================
-- 10 · Storage
-- Image buckets and the policies on storage.objects.
-- Requires: 02_friends.sql, 03_groups.sql (access helpers used by the policies)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Buckets and policies
-- -----------------------------------------------------------------------------

-- Storage buckets for images, so profiles.profile_photo_base64 and
-- group_image_messages.image_base64 can move out of Postgres (base64 text
-- bloats rows and is shipped in full on every read). Store the bytes here and
-- keep only a path in the tables.
--
-- Path conventions the policies below assume:
--   profile-photos/<user_id>/<file>
--   group-images/<group_id>/<file>
--
-- The client rewrite (upload/read from these buckets, then drop the *_base64
-- columns once existing rows are migrated) is a separate step.
insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
)
values (
  'profile-photos', 'profile-photos', false, 2000000,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
)
values (
  'group-images', 'group-images', false, 4000000,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Profile photos: the owner writes their own folder; self, friends and group
-- peers can read it (mirrors the profiles select policy).
drop policy if exists "profile photo readable by self friends peers"
on storage.objects;
create policy "profile photo readable by self friends peers"
on storage.objects for select
using (
  bucket_id = 'profile-photos'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.are_friends(auth.uid(), ((storage.foldername(name))[1])::uuid)
    or public.share_group(auth.uid(), ((storage.foldername(name))[1])::uuid)
  )
);

drop policy if exists "profile photo writable by owner" on storage.objects;
create policy "profile photo writable by owner"
on storage.objects for all
using (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Group images: any group member can read; a member can upload into their
-- group's folder.
drop policy if exists "group image readable by members" on storage.objects;
create policy "group image readable by members"
on storage.objects for select
using (
  bucket_id = 'group-images'
  and public.is_group_member(
    ((storage.foldername(name))[1])::uuid, auth.uid()
  )
);

drop policy if exists "group image writable by members" on storage.objects;
create policy "group image writable by members"
on storage.objects for insert
with check (
  bucket_id = 'group-images'
  and public.is_group_member(
    ((storage.foldername(name))[1])::uuid, auth.uid()
  )
);
