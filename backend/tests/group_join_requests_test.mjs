// Everyone invites; the leader approves. The link and an ordinary member's
// invitation both become requests. Runs the real schema on PGlite.
import { PGlite } from '@electric-sql/pglite';
import { pg_trgm } from '@electric-sql/pglite/contrib/pg_trgm';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const schema = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../schema');
const db = new PGlite({extensions: {pg_trgm}});
const id = n => `00000000-0000-0000-0000-00000000000${n}`;
const [leader, member, friendOfMember, friendOfLeader, outsider, invitee] = [1, 2, 3, 4, 5, 6].map(id);
const scalar = async sql => Object.values((await db.query(sql)).rows[0])[0];
const rows = async sql => (await db.query(sql)).rows;
async function user(userId) {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub','${userId}',false); set role authenticated;`);
}
async function admin() { await db.exec("reset role; select set_config('request.jwt.claim.sub','',false);"); }
let group, code;
const isMember = async userId => (await scalar(`select count(*)::int from public.group_members where group_id='${group}' and user_id='${userId}'`)) === 1;
const pendingRequests = () => rows(`select * from public.group_join_requests('${group}')`);
/// The pending invitation's id, or undefined when there is none left.
const invitationFor = async userId => (await rows(
  `select id from public.group_invitations where group_id='${group}' and invitee_id='${userId}' and status='pending'`))[0]?.id;
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
  await db.exec(`insert into auth.users(id) values ${[leader, member, friendOfMember, friendOfLeader, outsider, invitee].map(u => `('${u}')`).join(',')};
    insert into public.friendships(requester_id,addressee_id,status) values
      ('${leader}','${member}','accepted'),('${leader}','${friendOfLeader}','accepted'),
      ('${member}','${friendOfMember}','accepted'),('${member}','${invitee}','accepted');`);
  await user(leader);
  const created = (await db.query(`select * from public.create_group_with_members('Group','exercises',array['${member}']::uuid[],'','subject','{"name":"Gym","category":"exercises","goal_seconds":1800}'::jsonb)`)).rows[0];
  group = created.id;
  code = created.invite_code;
  await user(member);
  await db.exec(`select * from public.accept_group_invitation('${await invitationFor(member)}');`);
  assert.equal(await isMember(member), true, 'the leader invited: straight in');
  assert.equal((await pendingRequests()).length, 0, 'and no request to answer');

  // An ordinary member may invite, and that acceptance waits for the leader.
  await user(member);
  const options = await rows(`select * from public.group_invite_options('${group}')`);
  assert.equal(options.find(o => o.friend_id === friendOfMember).status, 'available',
    'a member sees their own friends to invite');
  assert.equal(options.find(o => o.friend_id === leader).status, 'member');
  await db.exec(`select public.invite_friend_to_group('${group}','${friendOfMember}');`);
  await user(friendOfMember);
  const accepted = (await db.query(`select * from public.accept_group_invitation('${await invitationFor(friendOfMember)}')`)).rows[0];
  assert.equal(accepted.pending_approval, true, 'a member invitation needs approval');
  assert.equal(await isMember(friendOfMember), false, 'and does not join yet');
  await user(leader);
  let waiting = await pendingRequests();
  assert.equal(waiting.length, 1);
  assert.equal(waiting[0].user_id, friendOfMember);
  assert.equal(waiting[0].invited_by, member, 'the request says who invited them');

  // Only the leader answers.
  await user(member);
  assert.deepEqual(await pendingRequests(), [], 'a member sees no request list');
  await assert.rejects(db.exec(`select public.approve_group_join_request('${waiting[0].id}');`), /only the group leader/i);
  await user(leader);
  await db.exec(`select public.approve_group_join_request('${waiting[0].id}');`);
  assert.equal(await isMember(friendOfMember), true, 'approved: now a member');
  assert.equal((await pendingRequests()).length, 0, 'and off the list');

  // The link raises a request too, and never joins on its own.
  await user(outsider);
  const viaLink = (await db.query(`select * from public.join_group_by_invite_code('${code}')`)).rows[0];
  assert.equal(viaLink.pending_approval, true);
  assert.equal(viaLink.name, 'Group', 'the group is named back, to show who was asked');
  assert.equal(await isMember(outsider), false, 'the link alone does not let anyone in');
  await db.exec(`select * from public.join_group_by_invite_code('${code.toLowerCase()}');`);
  assert.equal(
    await scalar(`select count(*)::int from public.group_join_requests where group_id='${group}' and user_id='${outsider}'`),
    1, 'asking twice keeps one request');
  await assert.rejects(
    db.exec(`insert into public.group_members(group_id,user_id,role) values ('${group}','${outsider}','member');`),
    /row-level security/, 'nor can it be forced through the table');

  // The leader can turn a request down, and the person can ask again after.
  await user(leader);
  const [linkRequest] = await pendingRequests();
  assert.equal(linkRequest.user_id, outsider);
  assert.equal(linkRequest.invited_by, null, 'nobody invited them: it was the link');
  await db.exec(`select public.decline_group_join_request('${linkRequest.id}');`);
  assert.equal(await isMember(outsider), false);
  assert.equal((await pendingRequests()).length, 0);
  await assert.rejects(db.exec(`select public.decline_group_join_request('${linkRequest.id}');`), /already handled/);
  await user(outsider);
  await db.exec(`select * from public.join_group_by_invite_code('${code}');`);
  await user(leader);
  assert.equal((await pendingRequests()).length, 1, 'a declined person may ask again');

  // The person waiting sees their own request; an unrelated member does not.
  await user(outsider);
  assert.equal(await scalar(`select count(*)::int from public.group_join_requests`), 1, 'own request is visible');
  await user(friendOfLeader);
  assert.equal(await scalar(`select count(*)::int from public.group_join_requests`), 0, 'other people see none');

  // A member's invitation can be taken back by its sender or by the leader.
  await user(member);
  await db.exec(`select public.invite_friend_to_group('${group}','${invitee}');`);
  await db.exec(`select public.cancel_group_invitation('${group}','${invitee}');`);
  assert.equal(await invitationFor(invitee), undefined, 'the sender takes it back');
  await db.exec(`select public.invite_friend_to_group('${group}','${invitee}');`);
  await user(leader);
  await db.exec(`select public.cancel_group_invitation('${group}','${invitee}');`);
  assert.equal(await invitationFor(invitee), undefined, 'so does the leader');

  // Someone outside the group neither invites nor lists.
  await user(outsider);
  await assert.rejects(db.exec(`select public.invite_friend_to_group('${group}','${friendOfLeader}');`), /only group members/i);
  await admin();
  console.log('group join request tests passed');
} finally {
  await db.close();
}
