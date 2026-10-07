-- Google Calendar credentials and OAuth state are accessible only to the Edge
-- Function's service role. Never grant these tables to authenticated clients.
create table if not exists public.google_calendar_connections (
  user_id uuid primary key references auth.users(id) on delete cascade,
  refresh_token_encrypted text not null,
  calendar_id text not null,
  time_zone text not null,
  generation uuid not null default gen_random_uuid(),
  events jsonb not null default '{}',
  lease_until timestamptz,
  lease_id uuid,
  updated_at timestamptz not null default now()
);
create table if not exists public.google_calendar_oauth_states (
  state text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  expires_at timestamptz not null default now() + interval '10 minutes'
);
alter table public.google_calendar_connections enable row level security;
alter table public.google_calendar_oauth_states enable row level security;
revoke all on public.google_calendar_connections from public, anon, authenticated;
revoke all on public.google_calendar_oauth_states from public, anon, authenticated;
grant all on public.google_calendar_connections to service_role;
grant all on public.google_calendar_oauth_states to service_role;

-- Serialize reconciliation across devices/functions. A crashed worker's lease
-- expires; lease_id prevents it from releasing a newer worker's lease.
create or replace function public.claim_google_calendar_sync(owner uuid, worker uuid)
returns boolean language sql security definer set search_path = '' as $$
  with claimed as (
    update public.google_calendar_connections
      set lease_until = now() + interval '180 seconds', lease_id = worker
      where user_id = owner and (lease_until is null or lease_until < now())
      returning user_id
  ) select exists(select 1 from claimed);
$$;
revoke all on function public.claim_google_calendar_sync(uuid, uuid) from public, anon, authenticated;
grant execute on function public.claim_google_calendar_sync(uuid, uuid) to service_role;
