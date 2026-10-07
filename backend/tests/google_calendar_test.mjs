import { PGlite } from '@electric-sql/pglite';
import assert from 'node:assert/strict';
import fs from 'node:fs';
const db = new PGlite();
const user = '00000000-0000-0000-0000-000000000001';
const worker = '00000000-0000-0000-0000-000000000002';
const otherWorker = '00000000-0000-0000-0000-000000000003';
const scalar = async sql => Object.values((await db.query(sql)).rows[0])[0];
try {
  await db.exec(`create role anon; create role authenticated; create role service_role bypassrls; create schema auth; create table auth.users(id uuid primary key);`);
  const schema = fs.readFileSync(new URL('../schema/12_google_calendar.sql', import.meta.url), 'utf8');
  await db.exec(schema);
  await db.exec(schema); // Re-applying migrations remains safe.
  await db.exec(`insert into auth.users values ('${user}');
    insert into public.google_calendar_connections(user_id,refresh_token_encrypted,calendar_id,time_zone)
    values ('${user}','encrypted','primary','America/Fortaleza');`);
  await db.exec('set role authenticated');
  await assert.rejects(db.query('select * from public.google_calendar_connections'), /permission denied/);
  await assert.rejects(db.query('select * from public.google_calendar_oauth_states'), /permission denied/);
  await assert.rejects(db.query(`select public.claim_google_calendar_sync('${user}','${worker}')`), /permission denied/);
  await db.exec('reset role; set role service_role');
  assert.equal(await scalar(`select public.claim_google_calendar_sync('${user}','${worker}')`), true);
  assert.equal(await scalar(`select public.claim_google_calendar_sync('${user}','${otherWorker}')`), false);
  await db.exec(`update public.google_calendar_connections set lease_until=now()-interval '1 second';`);
  assert.equal(await scalar(`select public.claim_google_calendar_sync('${user}','${otherWorker}')`), true);
  await db.exec(`update public.google_calendar_connections set lease_id=null,lease_until=null where lease_id='${worker}';`);
  assert.equal(await scalar(`select lease_id::text from public.google_calendar_connections`), otherWorker);
  await db.exec(`reset role; delete from auth.users where id='${user}';`);
  assert.equal(await scalar('select count(*)::int from public.google_calendar_connections'), 0);
  console.log('Google Calendar SQL: permissions, exclusive lease, expiry, stale-worker guard and account deletion passed.');
} finally { await db.close(); }
