-- =============================================================================
-- 02 · Friends
-- Friendship requests, the access helper built on them, and the RPCs used
-- to find people to add.
-- Requires: 01_profiles.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tables
-- -----------------------------------------------------------------------------

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'blocked')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

create index if not exists friendships_requester_idx
  on public.friendships(requester_id);
create index if not exists friendships_addressee_idx
  on public.friendships(addressee_id);

-- -----------------------------------------------------------------------------
-- Access helpers
-- -----------------------------------------------------------------------------

create or replace function public.are_friends(user_a uuid, user_b uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.friendships f
    where f.status = 'accepted'
      and (
        f.requester_id = user_a and f.addressee_id = user_b
        or f.requester_id = user_b and f.addressee_id = user_a
      )
  );
$$;

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

-- Relationship identity belongs to the row that was originally created. RLS
-- alone cannot compare OLD and NEW values, so without these triggers an
-- invitee could redirect a pending invitation to another group, or replace a
-- friendship requester while accepting the request.
create or replace function public.keep_friendship_identity_immutable()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.requester_id is distinct from old.requester_id
     or new.addressee_id is distinct from old.addressee_id then
    raise exception 'friendship participants cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_keep_friendship_identity_immutable
  on public.friendships;
create trigger trg_keep_friendship_identity_immutable
  before update on public.friendships
  for each row execute function public.keep_friendship_identity_immutable();

-- -----------------------------------------------------------------------------
-- RPCs
-- -----------------------------------------------------------------------------

drop function if exists public.search_friend_candidates(text, integer);
create or replace function public.search_friend_candidates(
  search_text text default '',
  result_limit integer default 12
)
returns table (
  id uuid,
  user_name text,
  nick_name text,
  friend_code text,
  accent_color_value bigint,
  avatar_icon_index integer,
  profile_photo_base64 text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id,
    p.user_name,
    p.nick_name,
    p.friend_code,
    p.accent_color_value,
    p.avatar_icon_index,
    p.profile_photo_base64
  from public.profiles p
  where p.id <> auth.uid()
    and not exists (
      select 1
      from public.friendships f
      where f.status in ('pending', 'accepted')
        and (
          f.requester_id = auth.uid() and f.addressee_id = p.id
          or f.requester_id = p.id and f.addressee_id = auth.uid()
        )
    )
    and (
      coalesce(nullif(trim(search_text), ''), '') = ''
      or p.user_name ilike '%' || replace(trim(search_text), '@', '') || '%'
      or p.nick_name ilike '%' || replace(trim(search_text), '@', '') || '%'
      or p.friend_code ilike '%' || replace(trim(search_text), '@', '') || '%'
    )
  order by p.created_at desc
  limit greatest(1, least(coalesce(result_limit, 12), 30));
$$;

grant execute on function public.search_friend_candidates(text, integer)
to authenticated;

drop function if exists public.find_profile_by_friend_code(text);
create or replace function public.find_profile_by_friend_code(lookup_code text)
returns table (
  id uuid,
  user_name text,
  nick_name text,
  friend_code text,
  accent_color_value bigint,
  avatar_icon_index integer,
  profile_photo_base64 text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id,
    p.user_name,
    p.nick_name,
    p.friend_code,
    p.accent_color_value,
    p.avatar_icon_index,
    p.profile_photo_base64
  from public.profiles p
  where p.id <> auth.uid()
    and upper(p.friend_code) = upper(replace(trim(lookup_code), '@', ''))
    and not exists (
      select 1
      from public.friendships f
      where f.status in ('pending', 'accepted')
        and (
          f.requester_id = auth.uid() and f.addressee_id = p.id
          or f.requester_id = p.id and f.addressee_id = auth.uid()
        )
    )
  limit 1;
$$;

grant execute on function public.find_profile_by_friend_code(text)
to authenticated;
