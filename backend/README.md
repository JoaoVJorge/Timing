# Backend

The Supabase schema, RPCs, row level security and grants live in
`schema/`, split into numbered sections. Apply them in numeric order; each
one only depends on the sections before it.

| Section | Holds |
| --- | --- |
| `00_common.sql` | Extensions and `set_updated_at()`, shared by everything else |
| `01_profiles.sql` | `profiles`, owner-only `profile_private_data`, presence view, sign-up trigger |
| `02_friends.sql` | `friendships`, `are_friends()`, friend search RPCs |
| `03_groups.sql` | Group tables, membership helpers (`is_group_member`, `owns_group`, ...), integrity triggers |
| `04_tracking.sql` | `activity_entries`, `user_subjects`, `daily_goals`, `schedule_entries`, progress metrics, `record_activity_entry` |
| `05_group_activities.sql` | Fan-out of a group's activity to each member, and protection of those group-owned copies |
| `06_group_ranking.sql` | `group_leaderboard_scores`, `group_activity_progress` |
| `07_group_management.sql` | Create, join, edit, reset and transfer a group |
| `08_group_invitations.sql` | Invite, cancel, accept and decline |
| `09_policies.sql` | Row level security for every table |
| `10_storage.sql` | Image buckets and their `storage.objects` policies |
| `11_grants.sql` | Least-privilege function and table grants |
| `12_maintenance.sql` | Safe-to-repeat legacy data cleanup |

Sections `00`-`08` are organised by feature and each one keeps a table
together with its constraints, indexes, triggers and functions. `09`-`12` cut
across features on purpose, so all access rules stay in one place to audit.

## Applying

Nothing deploys on its own. `supabase-setup.sql` is the generated, consolidated
deployment file for the Supabase SQL editor. Its source of truth remains the
numbered files in `schema/`.

After changing a section, regenerate the deployment file with:

```sh
awk 'FNR == 1 { print "\n-- " FILENAME } { print }' backend/schema/*.sql > backend/supabase-setup.sql
```

Then paste `backend/supabase-setup.sql` into the Supabase SQL editor. You can
still run individual numbered sections when deploying a focused change.

Every statement is idempotent (`create or replace`, `if not exists`,
`drop ... if exists`), so re-running everything is safe.

## Adding to it

- A new table goes in the section of the feature it belongs to, next to its
  constraints and indexes. Add its RLS enable and policies to `09_policies.sql`
  and its grants to `11_grants.sql`.
- A new RPC goes in its feature section. Give it `revoke all ... from public`
  and `grant execute ... to authenticated`, and add it to the function
  privileges list in `11_grants.sql`.
- SQL-language functions are validated when they are created, so every table
  and function they reference must already exist in an earlier section. If a
  new section is needed, pick a number that keeps that order.
- `11_grants.sql` must stay after every function and table is defined:
  it revokes the broad default grants only from objects that already exist.
