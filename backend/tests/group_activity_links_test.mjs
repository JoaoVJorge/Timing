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
// An installation from before groups stopped owning activities: one group
// still hands out copies, another already links personal sources to its
// shared activities.
const legacyUser = '00000000-0000-0000-0000-000000000010';
const copiesGroup = '00000000-0000-0000-0000-000000000011';
const copiedActivity = '00000000-0000-0000-0000-000000000012';
const goalsGroup = '00000000-0000-0000-0000-000000000013';
const copiedGoal = '00000000-0000-0000-0000-000000000014';
const linkedGroup = '00000000-0000-0000-0000-000000000015';
const linkedActivity = '00000000-0000-0000-0000-000000000016';
const extraActivity = '00000000-0000-0000-0000-000000000017';
const manyGoalsGroup = '00000000-0000-0000-0000-000000000018';
const manyGoalsActivity = '00000000-0000-0000-0000-000000000019';
const strayGoalActivity = '00000000-0000-0000-0000-00000000001a';
async function seedFormerInstallation() {
  await db.exec(`insert into auth.users(id) values ('${legacyUser}');
    create table public.group_activities (
      id uuid primary key default gen_random_uuid(),
      group_id uuid not null references public.groups(id) on delete cascade,
      kind text not null check (kind in ('subject', 'goal')),
      payload jsonb not null default '{}'::jsonb,
      score_reset_at timestamptz,
      created_at timestamptz not null default now()
    );
    alter table public.user_subjects add constraint user_subjects_group_activity_id_fkey
      foreign key (group_activity_id) references public.group_activities(id) on delete set null;
    alter table public.daily_goals add constraint daily_goals_group_activity_id_fkey
      foreign key (group_activity_id) references public.group_activities(id) on delete set null;
    create table public.group_activity_links (
      id uuid primary key default gen_random_uuid(),
      activity_id uuid not null references public.group_activities(id) on delete cascade,
      user_id uuid not null references public.profiles(id) on delete cascade,
      source_id text not null,
      started_at timestamptz not null default clock_timestamp(),
      ended_at timestamptz,
      start_date date not null default current_date,
      excluded_dates text[] not null default '{}',
      check (ended_at is null or ended_at >= started_at)
    );
    create unique index group_activity_links_active_idx
      on public.group_activity_links(activity_id, user_id, source_id) where ended_at is null;
    insert into public.groups(id,owner_id,name,theme,invite_code,created_at) values
      ('${copiesGroup}','${legacyUser}','Copies','exercises','COPIES',now()-interval '2 days'),
      ('${goalsGroup}','${legacyUser}','Goal copies','dailyGoals','GOALS',now()-interval '2 days'),
      ('${linkedGroup}','${legacyUser}','Linked','exercises','LINKED',now()-interval '2 days'),
      ('${manyGoalsGroup}','${legacyUser}','Many goals','dailyGoals','MANY',now()-interval '2 days');
    insert into public.group_members(group_id,user_id,role,joined_at)
      select id,'${legacyUser}','owner',now()-interval '2 days' from public.groups;
    insert into public.group_activities(id,group_id,kind,payload,score_reset_at,created_at) values
      ('${copiedActivity}','${copiesGroup}','subject','{"name":"Copy","category":"exercises","goal_seconds":1800,"color_value":4278190335}',null,now()-interval '2 days'),
      ('${copiedGoal}','${goalsGroup}','goal','{"name":"Goal copy","target_days":30}',null,now()-interval '2 days'),
      ('${linkedActivity}','${linkedGroup}','subject','{"name":"Shared","category":"exercises"}',now()-interval '90 minutes',now()-interval '2 days'),
      ('${extraActivity}','${linkedGroup}','subject','{"name":"Extra","category":"exercises"}',null,now()-interval '2 days'),
      ('${manyGoalsActivity}','${manyGoalsGroup}','goal','{"name":"Habits"}',null,now()-interval '2 days'),
      ('${strayGoalActivity}','${linkedGroup}','goal','{"name":"Stray"}',null,now()-interval '2 days');
    insert into public.user_subjects(id,user_id,name,category,color_value,total_seconds,goal_seconds,group_id,group_activity_id) values
      ('grp_${copiedActivity}','${legacyUser}','Copy','exercises',1,120,1800,'${copiesGroup}','${copiedActivity}'),
      ('run','${legacyUser}','Run','exercises',1,0,0,null,null);
    insert into public.activity_entries(user_id,subject_id,category,seconds,occurred_at) values
      ('${legacyUser}','grp_${copiedActivity}','exercises',120,now()-interval '1 day'),
      ('${legacyUser}','run','exercises',500,now()-interval '2 hours'),
      ('${legacyUser}','run','exercises',70,now()-interval '30 minutes');
    insert into public.daily_goals(id,user_id,name,color_value,target_days,completed_dates,group_id,group_activity_id) values
      ('grp_${copiedGoal}','${legacyUser}','Goal copy',1,30,array[current_date::text],'${goalsGroup}','${copiedGoal}'),
      ('sleep','${legacyUser}','Sleep',1,30,'{}',null,null),
      ('stretch','${legacyUser}','Stretch',1,30,'{}',null,null);
    insert into public.group_activity_links(activity_id,user_id,source_id,started_at) values
      ('${linkedActivity}','${legacyUser}','run',now()-interval '1 day'),
      ('${extraActivity}','${legacyUser}','run',now()-interval '1 hour'),
      ('${strayGoalActivity}','${legacyUser}','sleep',now()-interval '1 hour'),
      ('${manyGoalsActivity}','${legacyUser}','sleep',now()-interval '2 hours'),
      ('${manyGoalsActivity}','${legacyUser}','stretch',now()-interval '1 hour');`);
}
async function loadSchema(seedFormer = false) {
  for (const file of fs.readdirSync(schema).sort()) {
    if (!file.endsWith('.sql') || file.startsWith('10_')) continue; // Storage is unrelated.
    if (seedFormer && file.startsWith('05_')) await seedFormerInstallation();
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
const list = ids => `array[${ids.map(id => `'${id}'`).join(',')}]::text[]`;
async function link(group, ids) {
  await db.exec(`select public.set_group_activity_links('${group}',${list(ids)});`);
}
async function create(theme, sources = []) {
  const rows = await db.query(`select * from public.create_group_with_members('Group','${theme}',array['${member}']::uuid[],'',${list(sources)})`);
  return rows.rows[0];
}
const activeLinks = where => scalar(`select count(*)::int from public.group_activity_links where ended_at is null and ${where}`);
try {
  await db.exec(`create role authenticated; create role anon; create role service_role bypassrls; create schema auth;
    grant usage on schema auth to authenticated, anon;
    create table auth.users(id uuid primary key, raw_user_meta_data jsonb default '{}', email text, phone text);
    create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;`);
  await loadSchema(true);
  // Upgrade: copies and links to shared activities become links to the group.
  assert.equal(await scalar("select to_regclass('public.group_activities')::text"),null,'shared activities are gone');
  assert.equal(await scalar("select count(*)::int from information_schema.columns where table_name='group_activity_links' and column_name='activity_id'"),0);
  assert.equal(await scalar("select count(*)::int from public.user_subjects where group_id is not null or group_activity_id is not null"),0);
  assert.equal(await scalar("select count(*)::int from public.daily_goals where group_id is not null or group_activity_id is not null"),0);
  assert.equal(await scalar(`select color_value from public.groups where id='${copiesGroup}'`),4278190335,'group keeps its color');
  assert.equal(await activeLinks(`group_id='${linkedGroup}'`),1,'a source of two shared activities is linked once; the goal in an exercise group is dropped');
  assert.equal(await activeLinks(`group_id='${manyGoalsGroup}'`),1,'a daily-goals group keeps one goal per member');
  assert.equal(await scalar(`select source_id from public.group_activity_links where group_id='${manyGoalsGroup}' and ended_at is null`),'sleep','the earliest goal link stays');
  await user(legacyUser);
  assert.equal(await score(copiesGroup,legacyUser),120,'copy history still counts');
  assert.equal(await score(goalsGroup,legacyUser),1,'copied goal dates still count');
  assert.equal(await score(linkedGroup,legacyUser),70,'the reset boundary moves to the group');
  await db.exec(`update public.user_subjects set group_id='${copiesGroup}',group_activity_id='${copiedActivity}' where id='grp_${copiedActivity}';`);
  assert.equal(await scalar(`select group_id from public.user_subjects where id='grp_${copiedActivity}'`),null,'stale clients cannot restore group ownership');
  await db.exec(`delete from public.user_subjects where id='grp_${copiedActivity}';`);
  assert.equal(await scalar(`select count(*)::int from public.user_subjects where id='grp_${copiedActivity}'`),0,'a former copy is an ordinary personal activity');
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
  await assert.rejects(create('cooking'),/Unknown group theme/);
  const group = await create('exercises',['upper','lower']);
  assert.equal(group.color_value,1,'group uses the first linked activity color');
  assert.equal(await scalar(`select color_value from public.groups where id='${group.id}'`),1,'group persists the first linked activity color');
  assert.equal(await scalar(`select count(*)::int from public.user_subjects`),3,'creation must not duplicate sources');
  assert.equal(await scalar("select goal_seconds from public.user_subjects where id='upper'"),1200,'personal goal preserved');
  assert.equal(await score(group.id),0,'history before linking excluded');
  await record('upper',2400);
  await record('lower',1800);
  await record('book',0,'reading',9);
  assert.equal(await score(group.id),4200,'two sources summed, other themes ignored');
  const firstStart = await scalar(`select started_at::text from public.group_activity_links where group_id='${group.id}' and source_id='upper'`);
  await link(group.id,['upper','lower','upper']);
  assert.equal(await scalar(`select started_at::text from public.group_activity_links where group_id='${group.id}' and source_id='upper'`),firstStart,'unchanged link start retained');
  assert.equal(await score(group.id),4200,'duplicate source selection not double counted');
  await assert.rejects(link(group.id,['book']),/incompatible/);
  assert.equal(await activeLinks(`group_id='${group.id}'`),2,'failed changes atomic');
  await link(group.id,['lower']);
  await record('upper',600);
  assert.equal(await score(group.id),4200,'unlinked gap excluded, old contributions retained');
  await link(group.id,['upper','lower']);
  await record('upper',300);
  assert.equal(await score(group.id),4500,'relink counts only new interval');
  // The same activity may feed several groups of its theme.
  const other = await create('exercises',['upper']);
  await record('upper',100);
  assert.equal(await score(other.id),100);
  assert.equal(await score(group.id),4600,'each group counts its own link period');
  // A group can start empty and be given activities later.
  const empty = await create('exercises');
  assert.equal(await activeLinks(`group_id='${empty.id}'`),0);
  await record('lower',50);
  assert.equal(await score(empty.id),0,'nothing counts without a link');
  await user(member);
  const invitation = await scalar(`select id from public.group_invitations where group_id='${group.id}'`);
  await db.exec(`select public.accept_group_invitation('${invitation}');`);
  assert.equal(await scalar('select count(*)::int from public.user_subjects'),1,'joining creates no copy');
  assert.equal(await activeLinks(`user_id='${member}'`),0,'joining links nothing on its own');
  await link(group.id,['gym']);
  await record('gym',120);
  assert.equal(await score(group.id,member),120,'member uses own selection');
  const options = await scalar(`select public.group_activity_link_options('${group.id}')`);
  assert.equal(options.theme,'exercises');
  assert.deepEqual(options.options.map(x=>x.id),['gym'],'options contain only own sources of the theme');
  assert.deepEqual(options.selected_ids,['gym']);
  await assert.rejects(link(group.id,['upper']),/incompatible/);
  await assert.rejects(db.exec(`insert into public.group_activity_links(group_id,user_id,source_id) values ('${group.id}','${member}','gym')`),/permission denied/);
  assert.equal(await scalar(`select count(*)::int from public.activity_entries where user_id='${owner}'`),0,'peer entries stay private');
  await user(stranger);
  await assert.rejects(db.exec(`select public.group_activity_link_options('${group.id}')`),/not a group member/);
  await assert.rejects(link(group.id,[]),/not a group member/);
  await assert.rejects(db.exec(`select public.update_group('${group.id}','Hijacked','')`),/only the group owner/);
  await user(owner);
  const edited = (await db.query(`select * from public.update_group('${group.id}','Renamed','Legs',4294901760)`)).rows[0];
  assert.deepEqual([edited.name,edited.description,edited.color_value],['Renamed','Legs',4294901760]);
  await db.exec(`select public.update_group('${group.id}','Renamed','Legs');`);
  assert.equal(await scalar(`select color_value from public.groups where id='${group.id}'`),4294901760,'an edit without a color keeps it');
  assert.equal(await scalar("select name from public.user_subjects where id='upper'"),'Upper','group edits never touch personal activities');
  await db.exec(`select public.reset_group_progress('${group.id}');`);
  assert.equal(await score(group.id),0,'group reset excludes earlier contributions');
  assert.equal(await score(other.id),100,'reset stays within its group');
  await record('lower',60);
  assert.equal(await score(group.id),60);
  assert.equal(await scalar("select count(*)::int from public.activity_entries where subject_id='upper'"),5,'personal history remains');
  // A daily-goals group takes one goal. Its dates are deduplicated, baseline
  // completions excluded, and snapshots survive unlinking and personal edits.
  await db.exec(`insert into public.daily_goals(id,user_id,name,color_value,completed_dates)
    values ('water','${owner}','Water',1,array[current_date::text]),('walk','${owner}','Walk',1,'{}');`);
  await assert.rejects(create('dailyGoals',['water','walk']),/single goal/);
  await assert.rejects(create('dailyGoals',['upper']),/incompatible/);
  const goals = await create('dailyGoals',['water']);
  assert.equal(await score(goals.id),0,'already checked day excluded');
  await assert.rejects(link(goals.id,['water','walk']),/single goal/);
  await link(goals.id,['walk']);
  assert.equal(await activeLinks(`group_id='${goals.id}'`),1,'choosing another goal replaces the linked one');
  await db.exec(`update public.daily_goals set completed_dates=array[current_date::text] where id='walk';`);
  assert.equal(await score(goals.id),1);
  await db.exec(`update public.daily_goals set completed_dates='{}' where id='walk';`);
  assert.equal(await score(goals.id),0,'undo while linked removes check');
  await db.exec(`update public.daily_goals set completed_dates=array[current_date::text] where id='walk';`);
  await link(goals.id,[]);
  await db.exec(`update public.daily_goals set completed_dates='{}' where id='walk';`);
  assert.equal(await score(goals.id),1,'unlink retains prior day');
  await link(goals.id,['walk']);
  await db.exec(`update public.daily_goals set completed_dates=array[current_date::text] where id='walk';`);
  assert.equal(await score(goals.id),1,'same date across link periods counted once');
  assert.deepEqual((await scalar(`select public.group_activity_link_options('${goals.id}')`)).options.map(x=>x.id),['walk','water'],'a daily-goals group offers goals');
  const reading = await create('reading',['book']);
  await record('book',0,'reading',12);
  assert.equal(await score(reading.id),12,'reading counts pages');
  // Leaving closes periods without deleting sources. Rejoin does not restart
  // links automatically or import activity recorded while away.
  await user(member);
  await db.exec(`delete from public.group_members where group_id='${group.id}' and user_id=auth.uid();`);
  assert.equal(await scalar("select count(*)::int from public.user_subjects where id='gym'"),1,'leave preserves activity');
  assert.equal(await activeLinks(`user_id='${member}'`),0);
  await record('gym',300);
  await db.exec(`select public.join_group_by_invite_code('${group.invite_code}');`);
  assert.equal(await activeLinks(`user_id='${member}'`),0,'rejoin waits for selection');
  // The last member leaving removes the group and its links.
  await user(owner);
  await db.exec(`delete from public.group_members where group_id='${other.id}' and user_id=auth.uid();`);
  await admin();
  assert.equal(await scalar(`select count(*)::int from public.groups where id='${other.id}'`),0);
  assert.equal(await scalar(`select count(*)::int from public.group_activity_links where group_id='${other.id}'`),0);
  // Deploy twice to catch accidental duplicate backfills.
  await loadSchema();
  await user(owner);
  assert.equal(await score(goals.id),1,'redeployment preserves intervals');
  assert.equal(await score(group.id),60,'redeployment preserves the reset');
  await user(legacyUser);
  assert.equal(await score(linkedGroup,legacyUser),70);
  console.log('PASS: upgrade from shared activities, theme-bound linking, single goal, periods, deduplication, privacy, edit, reset, pages, leave, idempotent deployment');
} finally { await db.close(); }
