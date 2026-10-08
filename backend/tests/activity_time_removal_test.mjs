// remove_activity_seconds() against the real schema in PGlite. Only the auth
// identity is supplied by this harness.
import { PGlite } from '@electric-sql/pglite';
import { pg_trgm } from '@electric-sql/pglite/contrib/pg_trgm';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const schema = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../schema');
const db = new PGlite({extensions: {pg_trgm}});
const owner = '00000000-0000-0000-0000-000000000001';
const other = '00000000-0000-0000-0000-000000000002';
const scalar = async sql => Object.values((await db.query(sql)).rows[0])[0];
async function user(id) {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub','${id}',false); set role authenticated;`);
}
async function admin() { await db.exec("reset role; select set_config('request.jwt.claim.sub','',false);"); }
async function loadSchema() {
  for (const file of fs.readdirSync(schema).sort()) {
    if (!file.endsWith('.sql') || file.startsWith('10_')) continue; // Storage is unrelated.
    const sql = fs.readFileSync(path.join(schema, file), 'utf8')
      .replace('create extension if not exists pgcrypto;', ''); // gen_random_uuid is built in.
    try { await db.exec(sql); } catch (error) { throw new Error(`${file}: ${error.message}`, {cause:error}); }
  }
}
async function record(subject, seconds, {pages = 0, when = 'now()', category = 'studying'} = {}) {
  await db.exec(`select public.record_activity_entry(gen_random_uuid(), '${category}', '${subject}', '${subject}', ${seconds}, ${pages}, 0, ${when});`);
}
let removalCount = 0;
const removalId = () => `10000000-0000-0000-0000-${String(++removalCount).padStart(12, '0')}`;
async function remove(subject, seconds, {id = removalId(), at = "now() + interval '1 second'"} = {}) {
  await db.exec(`select public.remove_activity_seconds('${id}', '${subject}', ${seconds}, ${at});`);
  return id;
}
// The table has no grants for signed-in users, so sums are read as the owner.
async function seconds(subject, userId = owner) {
  await admin();
  const total = Number(await scalar(`select coalesce(sum(seconds),0) from public.activity_entries where user_id='${userId}' and subject_id='${subject}'`));
  await user(owner);
  return total;
}
async function rows(subject) {
  await admin();
  const result = await db.query(`select seconds, pages from public.activity_entries where user_id='${owner}' and subject_id='${subject}' order by occurred_at, id`);
  await user(owner);
  return result.rows.map(row => `${row.seconds}s/${row.pages}p`);
}
try {
  await db.exec(`create role authenticated; create role anon; create role service_role bypassrls; create schema auth;
    grant usage on schema auth to authenticated, anon;
    create table auth.users(id uuid primary key, raw_user_meta_data jsonb default '{}', email text, phone text);
    create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;`);
  await loadSchema();
  await db.exec(`insert into auth.users(id) values ('${owner}'),('${other}');`);

  await user(owner);
  await record('math', 600, {when: "now() - interval '2 days'"});
  await record('math', 300, {when: "now() - interval '1 day'"});
  await record('math', 120, {when: "now() - interval '1 hour'"});
  await record('physics', 500);

  // Newest first: the 120s session goes, then 80s comes off yesterday's.
  await remove('math', 200);
  assert.deepEqual(await rows('math'), ['600s/0p', '220s/0p'], 'trims the newest sessions first');
  assert.equal(await seconds('physics'), 500, 'leaves other activities alone');

  // A request sent twice (its answer was lost) is applied once.
  const repeated = await remove('math', 100);
  await remove('math', 100, {id: repeated});
  assert.equal(await seconds('math'), 720, 'a repeated request is applied once');

  // Sessions logged after the moment of the request are not touched.
  await record('math', 50);
  await remove('math', 60, {at: "now() - interval '30 minutes'"});
  assert.deepEqual(await rows('math'), ['600s/0p', '60s/0p', '50s/0p'], 'only sessions up to the request');

  // Asking for more than there is empties the activity and stops there.
  await remove('math', 100000);
  assert.equal(await seconds('math'), 0, 'never goes below zero');
  assert.deepEqual(await rows('math'), [], 'emptied sessions are deleted');

  // A session that also logged pages keeps them.
  await record('book', 400, {pages: 12, category: 'reading'});
  await remove('book', 400);
  assert.deepEqual(await rows('book'), ['0s/12p'], 'pages survive losing the time');

  // It only ever reaches the caller's own sessions.
  await user(other);
  await record('math', 900);
  await user(owner);
  await remove('math', 900);
  assert.equal(await seconds('math', other), 900, "another user's time is untouched");
  await user(other);
  await assert.rejects(
    db.exec(`update public.activity_entries set seconds = 1 where subject_id = 'math';`),
    /permission denied/,
    'clients still cannot rewrite entries directly',
  );
  await assert.rejects(
    db.exec('select count(*) from public.activity_time_removals;'),
    /permission denied/,
    'the request log is not readable by clients',
  );

  // Nothing to do is not an error, and signed-out callers are refused.
  await user(owner);
  await remove('math', 0);
  await remove('', 60);
  await db.exec("reset role; select set_config('request.jwt.claim.sub','',false); set role authenticated;");
  await assert.rejects(remove('math', 60), /authentication required/, 'requires a signed-in user');

  // Deploying again keeps working.
  await admin();
  await loadSchema();
  await user(owner);
  await record('math', 90);
  await remove('math', 30);
  assert.equal(await seconds('math'), 60, 'works after redeployment');
  console.log('PASS: newest-first trimming, idempotent requests, request cutoff, floor at zero, pages kept, own sessions only, redeployment');
} finally { await db.close(); }
