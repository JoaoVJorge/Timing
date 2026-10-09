// Leader-only management, role retirement, and leadership transfer.
import { PGlite } from '@electric-sql/pglite';
import { pg_trgm } from '@electric-sql/pglite/contrib/pg_trgm';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const schema = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../schema');
const db = new PGlite({extensions: {pg_trgm}});
const id = n => `00000000-0000-0000-0000-00000000000${n}`;
const [leader, memberA, memberB, member, friend, stranger] = [1, 2, 3, 4, 5, 6].map(id);
const scalar = async sql => Object.values((await db.query(sql)).rows[0])[0];
async function user(userId) {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub','${userId}',false); set role authenticated;`);
}
async function admin() { await db.exec("reset role; select set_config('request.jwt.claim.sub','',false);"); }
const roleOf = userId => scalar(`select role from public.group_members where group_id='${group}' and user_id='${userId}'`);
const isMember = async userId => (await scalar(`select count(*)::int from public.group_members where group_id='${group}' and user_id='${userId}'`)) === 1;
/// A delete the row policy hides matches nothing instead of failing.
const remove = userId => db.exec(`delete from public.group_members where group_id='${group}' and user_id='${userId}';`);
let group;
try {
  await db.exec(`create role authenticated; create role anon; create role service_role bypassrls; create schema auth;
    grant usage on schema auth to authenticated, anon;
    create table auth.users(id uuid primary key, raw_user_meta_data jsonb default '{}', email text, phone text);
    create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;`);
  // Twice, as it is re-run in full on an existing project.
  for (let pass = 0; pass < 2; pass++) {
    for (const file of fs.readdirSync(schema).sort()) {
      if (!file.endsWith('.sql') || file.startsWith('10_')) continue; // Storage is unrelated.
      const sql = fs.readFileSync(path.join(schema, file), 'utf8')
        .replace('create extension if not exists pgcrypto;', ''); // gen_random_uuid is built in.
      try { await db.exec(sql); } catch (error) { throw new Error(`${file}: ${error.message}`, {cause:error}); }
    }
  }
  await db.exec(`insert into auth.users(id) values ${[leader, memberA, memberB, member, friend, stranger].map(u => `('${u}')`).join(',')};
    insert into public.friendships(requester_id,addressee_id,status) values
      ('${leader}','${memberA}','accepted'),('${leader}','${memberB}','accepted'),
      ('${leader}','${member}','accepted'),('${memberA}','${friend}','accepted');`);
  await user(leader);
  group = (await db.query(`select * from public.create_group_with_members('Group','exercises',array['${memberA}','${memberB}','${member}']::uuid[],'','subject','{"name":"Gym","category":"exercises","goal_seconds":1800}'::jsonb)`)).rows[0].id;
  for (const invitee of [memberA, memberB, member]) {
    await user(invitee);
    await db.exec(`select public.accept_group_invitation('${await scalar(`select id from public.group_invitations where group_id='${group}' and invitee_id='${invitee}'`)}');`);
  }

  await user(member);
  await assert.rejects(db.exec(`select public.reset_group_progress('${group}');`), /only the group owner/);
  await assert.rejects(db.exec(`select * from public.update_group_with_activity('${group}','Renamed','','{}'::jsonb);`), /only the group owner/);
  // Inviting is not a leader's privilege: every member may, and what follows
  // from it is covered by group_join_requests_test.
  await user(memberA);
  await db.exec(`select public.invite_friend_to_group('${group}','${friend}');`);
  await user(member);
  await remove(leader);
  await remove(memberA);
  assert.equal(await isMember(leader), true);
  assert.equal(await isMember(memberA), true);
  await assert.rejects(db.exec(`select public.set_group_member_role('${group}','${memberA}','vice');`), /does not exist/);

  await user(leader);
  await db.exec(`select public.reset_group_progress('${group}');`);
  await remove(member);
  assert.equal(await isMember(member), false);

  // The full schema also retires a role and endpoint left by an older install.
  await admin();
  await db.exec(`alter table public.group_members drop constraint group_members_role_check;
    update public.group_members set role='vice' where group_id='${group}' and user_id='${memberA}';
    create function public.set_group_member_role(uuid, uuid, text) returns void language sql as $$ select $$;
    create function public.manages_group(uuid, uuid) returns boolean language sql as $$ select true $$;
    create policy "managers manage group activities" on public.group_activities for all
      using (public.manages_group(group_id, auth.uid()));`);
  for (const file of fs.readdirSync(schema).sort()) {
    if (!file.endsWith('.sql') || file.startsWith('10_')) continue;
    await db.exec(fs.readFileSync(path.join(schema, file), 'utf8').replace('create extension if not exists pgcrypto;', ''));
  }
  assert.equal(await roleOf(memberA), 'member');
  assert.equal(await scalar("select to_regprocedure('public.set_group_member_role(uuid,uuid,text)') is null"), true);
  assert.equal(await scalar("select to_regprocedure('public.manages_group(uuid,uuid)') is null"), true);
  await assert.rejects(db.exec(`update public.group_members set role='vice' where group_id='${group}' and user_id='${memberA}';`), /group_members_role_check/);

  await user(memberA);
  await assert.rejects(db.exec(`select public.reset_group_progress('${group}');`), /only the group owner/);
  await user(leader);
  await db.exec(`select public.transfer_group_ownership('${group}','${memberA}');`);
  assert.equal(await roleOf(memberA), 'owner');
  assert.equal(await roleOf(leader), 'member');
  console.log('group leadership tests passed');
} finally {
  await db.close();
}
