// PostgreSQL integration tests without a Supabase project. PGlite runs the
// actual schema/functions; only auth identity is supplied by this harness.
import { PGlite } from '@electric-sql/pglite';
import { pg_trgm } from '@electric-sql/pglite/contrib/pg_trgm';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const schema = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../schema');
const db = new PGlite({extensions: {pg_trgm}});
const owner = '00000000-0000-0000-0000-000000000001';
const member = '00000000-0000-0000-0000-000000000002';
const stranger = '00000000-0000-0000-0000-000000000003';
const scalar = async sql => Object.values((await db.query(sql)).rows[0])[0];
async function user(id) {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub','${id}',false); set role authenticated;`);
}
async function admin() { await db.exec("reset role; select set_config('request.jwt.claim.sub','',false);"); }
const legacyUser = '00000000-0000-0000-0000-000000000010';
const legacyGroup = '00000000-0000-0000-0000-000000000011';
const legacyActivity = '00000000-0000-0000-0000-000000000012';
const legacyGoal = '00000000-0000-0000-0000-000000000013';
async function loadSchema(seedLegacy = false) {
  for (const file of fs.readdirSync(schema).sort()) {
    if (!file.endsWith('.sql') || file.startsWith('10_')) continue; // Storage is unrelated.
    if (seedLegacy && file.startsWith('05_')) {
      await db.exec(`insert into auth.users(id) values ('${legacyUser}');
        insert into public.groups(id,owner_id,name,theme,invite_code) values ('${legacyGroup}','${legacyUser}','Legacy','exercises','LEGACY');
        insert into public.group_members(group_id,user_id,role,joined_at) values ('${legacyGroup}','${legacyUser}','owner',now()-interval '2 days');
        insert into public.group_activities(id,group_id,kind,payload,created_at) values
          ('${legacyActivity}','${legacyGroup}','subject','{"name":"Legacy","category":"exercises","goal_seconds":1800}',now()-interval '2 days'),
          ('${legacyGoal}','${legacyGroup}','goal','{"name":"Legacy goal","target_days":30}',now()-interval '2 days');
        insert into public.user_subjects(id,user_id,name,category,color_value,total_seconds,goal_seconds,group_id,group_activity_id)
          values ('grp_${legacyActivity}','${legacyUser}','Legacy','exercises',1,120,1800,'${legacyGroup}','${legacyActivity}');
        insert into public.activity_entries(user_id,subject_id,category,seconds,occurred_at)
          values ('${legacyUser}','grp_${legacyActivity}','exercises',120,now()-interval '1 day');
        insert into public.daily_goals(id,user_id,name,color_value,target_days,completed_dates,group_id,group_activity_id)
          values ('grp_${legacyGoal}','${legacyUser}','Legacy goal',1,30,array[current_date::text],'${legacyGroup}','${legacyGoal}');`);
    }
    const sql = fs.readFileSync(path.join(schema, file), 'utf8')
      .replace('create extension if not exists pgcrypto;', ''); // gen_random_uuid is built in.
    try { await db.exec(sql); } catch (error) { throw new Error(`${file}: ${error.message}`, {cause:error}); }
  }
}
async function record(source, seconds = 60, category = 'exercises', pages = 0, when = 'clock_timestamp()') {
  await db.exec(`select public.record_activity_entry(gen_random_uuid(), '${category}', '${source}', '${source}', ${seconds}, ${pages}, 0, ${when});`);
}
async function score(group, id = owner) {
  return Number(await scalar(`select coalesce((select total_score from public.group_leaderboard_scores(array['${group}']::uuid[], current_date, current_date - 7, current_date - 30) where user_id = '${id}'),0)`));
}
async function create(theme, kind, payload) {
  const rows = await db.query(`select * from public.create_group_with_members('Group','${theme}',array['${member}']::uuid[],'','${kind}',$1::jsonb)`, [JSON.stringify(payload)]);
  return rows.rows[0];
}
try {
  await db.exec(`create role authenticated; create role anon; create role service_role bypassrls; create schema auth;
    grant usage on schema auth to authenticated, anon;
    create table auth.users(id uuid primary key, raw_user_meta_data jsonb default '{}', email text, phone text);
    create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;`);
  await loadSchema(true);
  await user(legacyUser);
  assert.equal(await score(legacyGroup,legacyUser),120,'legacy history migrated');
  assert.equal(await scalar("select count(*)::int from public.user_subjects where group_id is null"),1);
  assert.equal(await scalar("select count(*)::int from public.daily_goals where group_id is null"),1);
  assert.equal(await scalar(`select progress from public.group_activity_progress('${legacyGroup}') where activity_id='${legacyGoal}'`),1);
  await db.exec(`update public.user_subjects set group_id='${legacyGroup}',group_activity_id='${legacyActivity}' where id='grp_${legacyActivity}';`);
  assert.equal(await scalar("select group_id from public.user_subjects limit 1"),null,'stale clients cannot restore group ownership');
  await admin();
  await db.exec(`insert into auth.users(id) values ('${owner}'),('${member}'),('${stranger}');
    insert into public.friendships(requester_id,addressee_id,status) values ('${owner}','${member}','accepted');
    insert into public.user_subjects(id,user_id,name,category,color_value,goal_seconds,notes)
    values ('upper','${owner}','Upper','exercises',1,1200,'private'),
      ('lower','${owner}','Lower','exercises',2,1800,'private'),
      ('book','${owner}','Book','reading',3,0,'private'),
      ('gym','${member}','Gym','exercises',4,1200,'private');`);
  await user(owner);
  await record('upper', 900, 'exercises', 0, "now() - interval '1 day'");
  const group = await create('exercises','subject',{name:'Gym',category:'exercises',goal_seconds:1800,source_ids:['upper','lower']});
  const activity = group.activity_id;
  assert.equal(await scalar(`select count(*)::int from public.user_subjects`),3,'creation must not duplicate sources');
  assert.equal(await scalar("select goal_seconds from public.user_subjects where id='upper'"),1200,'personal goal preserved');
  assert.equal(await score(group.id),0,'history before linking excluded');
  await record('upper',2400);
  await record('lower',1800);
  assert.equal(await score(group.id),4200,'two sources summed');
  assert.equal(await scalar(`select progress from public.group_activity_progress('${group.id}') where member_id='${owner}'`),4200);
  const firstStart = await scalar(`select started_at::text from public.group_activity_links where activity_id='${activity}' and source_id='upper'`);
  await db.exec(`select public.set_group_activity_links('${activity}',array['upper','lower','upper']);`);
  assert.equal(await scalar(`select started_at::text from public.group_activity_links where activity_id='${activity}' and source_id='upper'`),firstStart,'unchanged link start retained');
  assert.equal(await score(group.id),4200,'duplicate source selection not double counted');
  await assert.rejects(db.exec(`select public.set_group_activity_links('${activity}',array['book']);`),/incompatible/);
  assert.equal(await scalar(`select count(*)::int from public.group_activity_links where ended_at is null`),2,'failed changes atomic');
  await db.exec(`select public.set_group_activity_links('${activity}',array['lower']);`);
  await record('upper',600);
  assert.equal(await score(group.id),4200,'unlinked gap excluded, old contributions retained');
  await db.exec(`select public.set_group_activity_links('${activity}',array['upper','lower']);`);
  await record('upper',300);
  assert.equal(await score(group.id),4500,'relink counts only new interval');
  // A second template in the same group must not duplicate leaderboard entries.
  await admin();
  const second = await scalar(`insert into public.group_activities(group_id,kind,payload,created_at) values ('${group.id}','subject','{"name":"Extra","category":"exercises"}',now()-interval '2 days') returning id`);
  await db.exec(`insert into public.group_activity_links(activity_id,user_id,source_id,started_at) values ('${second}','${owner}','upper',now()-interval '1 hour');`);
  await user(owner);
  assert.equal(await score(group.id),5100,'each entry counted once across templates');
  await admin();
  await db.exec(`delete from public.group_activities where id='${second}';`);
  await user(member);
  const invitation = await scalar(`select id from public.group_invitations where group_id='${group.id}'`);
  await db.exec(`select public.accept_group_invitation('${invitation}');`);
  assert.equal(await scalar('select count(*)::int from public.user_subjects'),1,'joining creates no unwanted copy');
  await db.exec(`select public.set_group_activity_links('${activity}',array['gym']);`);
  await record('gym',120);
  assert.equal(await score(group.id,member),120,'member uses own selection');
  const options = await scalar(`select public.group_activity_link_options('${group.id}')`);
  assert.deepEqual(options[0].options.map(x=>x.id),['gym'],'options contain only own sources');
  await assert.rejects(db.exec(`select public.set_group_activity_links('${activity}',array['upper']);`),/incompatible/);
  await assert.rejects(db.exec(`insert into public.group_activity_links(activity_id,user_id,source_id) values ('${activity}','${member}','gym')`),/permission denied/);
  await user(stranger);
  await assert.rejects(db.exec(`select public.group_activity_link_options('${group.id}')`),/not a group member/);
  await assert.rejects(db.exec(`select public.set_group_activity_links('${activity}',array[]::text[]);`),/not a group member/);
  await user(owner);
  await db.exec(`select public.update_group_with_activity('${group.id}','Renamed','','{"goal_seconds":3600,"name":"Shared"}');`);
  assert.equal(await scalar("select name from public.user_subjects where id='upper'"),'Upper','group edits preserve personal metadata');
  await db.exec(`select public.reset_group_progress('${group.id}');`);
  assert.equal(await score(group.id),0,'group reset excludes earlier contributions');
  await record('lower',60);
  assert.equal(await score(group.id),60);
  assert.equal(await scalar("select count(*)::int from public.activity_entries where subject_id='upper'"),4,'personal history remains');
  // Goal dates are deduplicated, baseline completions excluded, and snapshots
  // survive unlinking and subsequent personal edits.
  await db.exec(`insert into public.daily_goals(id,user_id,name,color_value,completed_dates)
    values ('water','${owner}','Water',1,array[current_date::text]),('walk','${owner}','Walk',1,'{}');`);
  const goals = await create('dailyGoals','goal',{name:'Healthy day',target_days:30,source_ids:['water','walk']});
  assert.equal(await score(goals.id),0,'already checked day excluded');
  await db.exec(`update public.daily_goals set completed_dates=array[current_date::text] where id='walk';`);
  assert.equal(await score(goals.id),1);
  await db.exec(`update public.daily_goals set completed_dates='{}' where id='walk';`);
  assert.equal(await score(goals.id),0,'undo while linked removes check');
  await db.exec(`update public.daily_goals set completed_dates=array[current_date::text] where id='walk';
    select public.set_group_activity_links('${goals.activity_id}',array[]::text[]);
    update public.daily_goals set completed_dates='{}' where id='walk';`);
  assert.equal(await score(goals.id),1,'unlink retains prior day');
  await db.exec(`select public.set_group_activity_links('${goals.activity_id}',array['walk']);
    update public.daily_goals set completed_dates=array[current_date::text] where id='walk';`);
  assert.equal(await score(goals.id),1,'same date across link periods counted once');
  assert.equal(await scalar(`select progress from public.group_activity_progress('${goals.id}') where member_id='${owner}'`),1);
  // New activity creation is retry-safe and returns an ordinary personal item.
  const fresh = await create('reading','subject',{name:'Reading',category:'reading',goal_pages:10});
  await db.exec(`select public.set_group_activity_links('${fresh.activity_id}','{}',true);
    select public.set_group_activity_links('${fresh.activity_id}','{}',true);`);
  assert.equal(await scalar(`select count(*)::int from public.user_subjects where id='grp_${fresh.activity_id}' and group_id is null`),1);
  await record(`grp_${fresh.activity_id}`,0,'reading',12);
  assert.equal(await score(fresh.id),12,'reading counts pages');
  // Leaving closes periods without deleting sources. Rejoin does not restart
  // links automatically or import activity recorded while away.
  await user(member);
  await db.exec(`delete from public.group_members where group_id='${group.id}' and user_id=auth.uid();`);
  assert.equal(await scalar("select count(*)::int from public.user_subjects where id='gym'"),1,'leave preserves activity');
  assert.equal(await scalar('select count(*)::int from public.group_activity_links where ended_at is null'),0);
  await record('gym',300);
  await db.exec(`select public.join_group_by_invite_code('${group.invite_code}');`);
  assert.equal(await scalar('select count(*)::int from public.group_activity_links where ended_at is null'),0,'rejoin waits for selection');
  // Deploy twice to catch accidental rematerialization or duplicate backfills.
  await admin();
  await loadSchema();
  await user(owner);
  assert.equal(await score(goals.id),1,'redeployment preserves intervals');
  console.log('PASS: multi-source creation/join, periods, deduplication, privacy, reset, pages, goals, leave, idempotent deployment');
} finally { await db.close(); }
