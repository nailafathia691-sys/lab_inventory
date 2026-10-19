import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { readFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import { PGlite } from '@electric-sql/pglite';

const migration = await readFile(new URL('../../supabase/migrations/202610180001_secure_inventory.sql', import.meta.url), 'utf8');
const accessGuard = await readFile(new URL('../../supabase/migrations/202610180000_legacy_access_guard.sql', import.meta.url), 'utf8');
const loginBridge = await readFile(new URL('../../supabase/staged_login_profiles.sql', import.meta.url), 'utf8');
const admin = randomUUID(), student = randomUUID(), otherStudent = randomUUID();
let db, today;
const bootstrap = `
  create role anon nologin;
  create role authenticated nologin;
  create schema auth;
  create table auth.users(id uuid primary key, email text, raw_user_meta_data jsonb default '{}'::jsonb);
  create function auth.uid() returns uuid language sql stable as $$
    select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
  $$;
  create function auth.jwt() returns jsonb language sql stable as $$
    select jsonb_build_object('is_anonymous',
      coalesce(nullif(current_setting('request.jwt.claim.is_anonymous', true), '')::boolean, false));
  $$;
  grant usage on schema auth, public to anon, authenticated;
  grant execute on function auth.uid() to anon, authenticated;
  grant execute on function auth.jwt() to anon, authenticated;
`;

before(async () => {
  db = new PGlite();
  await db.exec(bootstrap);
  await db.exec(migration);
  for (const [id, name] of [[admin, 'Laboran'], [student, 'Mahasiswa A'], [otherStudent, 'Mahasiswa B']]) {
    await db.query('insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)',
      [id, `${id}@example.test`, JSON.stringify({ nama: name, role: 'admin' })]);
  }
  await db.query("update public.profiles set role='admin' where id=$1", [admin]);
  today = (await db.query("select to_char((now() at time zone 'Asia/Jakarta')::date, 'YYYY-MM-DD') as today")).rows[0].today;
});
after(async () => { await db?.close(); });

async function asActor(actor, sql, params = [], role = 'authenticated') {
  await db.exec('begin');
  try {
    await db.exec(`set local role ${role}`);
    await db.query("select set_config('request.jwt.claim.sub', $1, true)", [actor ?? '']);
    const result = await db.query(sql, params);
    await db.exec('commit');
    return result;
  } catch (error) { await db.exec('rollback'); throw error; }
}
async function createItem(stock = 2, condition = 'Baik', request = randomUUID(), actor = admin) {
  return (await asActor(actor, `select public.create_inventory_item($1,'Komputer',$2,$3,'Rak A','Deskripsi tersimpan',$4) as result`,
    ['Laptop ' + request, condition, stock, request])).rows[0].result;
}
async function requestItem(itemId, quantity = 1, actor = student, request = randomUUID(), start = today, due = today, purpose = 'Praktikum') {
  return (await asActor(actor, 'select public.request_borrowing($1,$2,$3,$4,$5,$6) as result',
    [itemId, quantity, start, due, purpose, request])).rows[0].result;
}
async function processLoan(id, status, good = null, request = randomUUID(), actor = admin, notes = '') {
  return (await asActor(actor, 'select public.process_borrowing($1,$2,$3,$4,$5) as result',
    [id, status, notes, good, request])).rows[0].result;
}
async function stock(id) { return (await db.query('select stok, stok_rusak from public.items where id=$1', [id])).rows[0]; }

test('new profiles never trust role supplied in signup metadata', async () => {
  assert.equal((await db.query('select role from public.profiles where id=$1', [student])).rows[0].role, 'student');
});
test('anonymous users cannot read inventories, profiles, or loans or invoke commands', async () => {
  for (const table of ['profiles', 'items', 'borrowings', 'audit_events']) {
    await assert.rejects(asActor(null, `select * from public.${table}`, [], 'anon'), /permission denied/);
  }
  await assert.rejects(asActor(null, `select public.request_borrowing($1,1,$2,$2,'test',$3)`,
    [randomUUID(), today, randomUUID()], 'anon'), /permission denied/);
});
test('a role-authenticated request without a user claim is rejected', async () => {
  await assert.rejects(requestItem(randomUUID(), 1, null), /AUTH_REQUIRED/);
});
test('Supabase anonymous-auth sessions cannot read data or execute commands even with a profile', async () => {
  await db.exec('begin; set local role authenticated;');
  try {
    await db.query("select set_config('request.jwt.claim.sub',$1,true)",[student]);
    await db.query("select set_config('request.jwt.claim.is_anonymous','true',true)");
    for (const table of ['profiles', 'items', 'borrowings']) {
      assert.equal((await db.query(`select * from public.${table}`)).rows.length,0);
    }
    await assert.rejects(db.query("select public.request_borrowing($1,1,$2,$2,'test',$3)",
      [randomUUID(),today,randomUUID()]),/AUTH_REQUIRED/);
  } finally { await db.exec('rollback'); }
});
test('students cannot create items, process loans, or execute private mutation helpers', async () => {
  await assert.rejects(createItem(1, 'Baik', randomUUID(), student), /FORBIDDEN/);
  await assert.rejects(processLoan(randomUUID(), 'approved', null, randomUUID(), student), /FORBIDDEN/);
  await assert.rejects(asActor(student, 'select private.require_actor(false)'), /permission denied/);
  await assert.rejects(asActor(student, "select private.lock_request($1,'test','{}')", [randomUUID()]), /permission denied/);
});
test('all clients including admins are blocked from direct table mutations', async () => {
  const item = await createItem();
  for (const actor of [admin, student]) {
    await assert.rejects(asActor(actor, "update public.items set stok=999 where id=$1", [item.id]), /permission denied/);
    await assert.rejects(asActor(actor, "update public.profiles set role='admin' where id=$1", [student]), /permission denied/);
    await assert.rejects(asActor(actor, "insert into public.borrowings(id) values($1)", [randomUUID()]), /permission denied/);
    await assert.rejects(asActor(actor, 'delete from public.borrowings'), /permission denied/);
    await assert.rejects(asActor(actor, "delete from public.audit_events"), /permission denied/);
  }
});
test('student RLS isolates rows even without a client owner filter', async () => {
  const item = await createItem();
  const a = await requestItem(item.id, 1, student), b = await requestItem(item.id, 1, otherStudent);
  const aRows = (await asActor(student, 'select id from public.borrowings where id in ($1,$2)', [a.id, b.id])).rows;
  assert.deepEqual(aRows.map(r => r.id), [a.id]);
  assert.equal((await asActor(admin, 'select id from public.borrowings where id in ($1,$2)', [a.id,b.id])).rows.length, 2);
  assert.equal((await asActor(student, 'select * from public.profiles where id=$1', [otherStudent])).rows.length, 0);
  assert.equal((await asActor(student, 'select * from public.audit_events')).rows.length, 0);
});
test('inactive profiles lose both data access and command permissions', async () => {
  const id = randomUUID();
  await db.query('insert into auth.users(id,email) values($1,$2)', [id, 'inactive@example.test']);
  await db.query('update public.profiles set is_active=false where id=$1', [id]);
  assert.equal((await asActor(id, 'select * from public.items')).rows.length, 0);
  await assert.rejects(requestItem(randomUUID(), 1, id), /PROFILE_REQUIRED/);
});
test('new items get unique server codes and persist descriptions', async () => {
  const a = await createItem(), b = await createItem();
  assert.notEqual(a.kode_barang, b.kode_barang);
  assert.equal((await db.query('select deskripsi from public.items where id=$1', [a.id])).rows[0].deskripsi, 'Deskripsi tersimpan');
});
test('item creation retries return one item and one ledger entry', async () => {
  const request = randomUUID();
  const a = await createItem(2, 'Baik', request), b = await createItem(2, 'Baik', request);
  assert.equal(a.id, b.id);
  assert.equal((await db.query('select * from public.inventory_movements where item_id=$1', [a.id])).rows.length, 1);
});
test('pending requests do not reserve stock and names come from server records', async () => {
  const item = await createItem(2);
  const loan = await requestItem(item.id, 2);
  assert.equal((await stock(item.id)).stok, 2);
  const row = (await db.query('select nama_peminjam,nama_barang,status from public.borrowings where id=$1', [loan.id])).rows[0];
  assert.equal(row.nama_peminjam, 'Mahasiswa A');
  assert.equal(row.status, 'pending');
  assert.ok(row.nama_barang.startsWith('Laptop '));
});
test('borrowing retries survive changed stock and return the committed result', async () => {
  const item = await createItem(1), request = randomUUID();
  const a = await requestItem(item.id, 1, student, request);
  await processLoan(a.id, 'approved');
  const b = await requestItem(item.id, 1, student, request);
  assert.equal(a.id, b.id);
  assert.equal((await db.query('select id from public.borrowings where item_id=$1', [item.id])).rows.length, 1);
});
test('same request key cannot be reused for different input or a different operation', async () => {
  const item = await createItem(3), request = randomUUID();
  await requestItem(item.id, 1, student, request);
  await assert.rejects(requestItem(item.id, 2, student, request), /REQUEST_CONFLICT/);
  const adminRequest = randomUUID();
  await createItem(1, 'Baik', adminRequest);
  await assert.rejects(requestItem(item.id, 1, admin, adminRequest), /REQUEST_CONFLICT/);
});
test('quantity and purpose validation run on the server', async () => {
  const item = await createItem(2);
  for (const q of [0, -1, null]) await assert.rejects(requestItem(item.id, q), /INVALID_INPUT/);
  await assert.rejects(requestItem(item.id, 3), /INSUFFICIENT_STOCK/);
  await assert.rejects(requestItem(item.id, 1, student, randomUUID(), today, today, '   '), /INVALID_INPUT/);
  await assert.rejects(requestItem(item.id, 1, student, randomUUID(), today, today, 'x'.repeat(2001)), /INVALID_INPUT/);
});
test('past, reversed, and missing dates are rejected server-side', async () => {
  const item = await createItem();
  await assert.rejects(requestItem(item.id, 1, student, randomUUID(), '2000-01-01', today), /INVALID_DATES/);
  await assert.rejects(requestItem(item.id, 1, student, randomUUID(), today, '2000-01-01'), /INVALID_DATES/);
  await assert.rejects(requestItem(item.id, 1, student, randomUUID(), null, today), /INVALID_DATES/);
});
test('damaged and inactive items cannot be requested or approved', async () => {
  const damaged = await createItem(2, 'Perlu Perbaikan');
  await assert.rejects(requestItem(damaged.id), /ITEM_UNAVAILABLE/);
  const item = await createItem(2), loan = await requestItem(item.id);
  await db.query('update public.items set is_active=false where id=$1', [item.id]);
  await assert.rejects(requestItem(item.id), /ITEM_UNAVAILABLE/);
  await assert.rejects(processLoan(loan.id, 'approved'), /ITEM_UNAVAILABLE/);
});
test('only one pending loan can consume the last available unit', async () => {
  const item = await createItem(1);
  const a = await requestItem(item.id), b = await requestItem(item.id, 1, otherStudent);
  await processLoan(a.id, 'approved');
  await assert.rejects(processLoan(b.id, 'approved'), /INSUFFICIENT_STOCK/);
  assert.equal((await stock(item.id)).stok, 0);
  assert.equal((await db.query('select status from public.borrowings where id=$1', [b.id])).rows[0].status, 'pending');
});
test('approve is idempotent with both identical and new request keys', async () => {
  const item = await createItem(2), loan = await requestItem(item.id), key = randomUUID();
  await processLoan(loan.id, 'approved', null, key);
  await processLoan(loan.id, 'approved', null, key);
  await processLoan(loan.id, 'approved');
  assert.equal((await stock(item.id)).stok, 1);
  assert.equal((await db.query("select * from public.inventory_movements where borrowing_id=$1 and kind='reserved'", [loan.id])).rows.length, 1);
});
test('rejected pending requests do not change stock and cannot later be approved', async () => {
  const item = await createItem(2), loan = await requestItem(item.id);
  await processLoan(loan.id, 'rejected');
  assert.equal((await stock(item.id)).stok, 2);
  await assert.rejects(processLoan(loan.id, 'approved'), /INVALID_TRANSITION/);
});
test('good returns restore stock exactly once and record the actor and actual return time', async () => {
  const item = await createItem(2), loan = await requestItem(item.id, 2), key = randomUUID();
  await processLoan(loan.id, 'approved');
  await processLoan(loan.id, 'returned', true, key);
  await processLoan(loan.id, 'returned', true, key);
  await processLoan(loan.id, 'returned', true);
  assert.deepEqual(await stock(item.id), { stok: 2, stok_rusak: 0 });
  const row = (await db.query('select returned_at,updated_by,returned_good from public.borrowings where id=$1', [loan.id])).rows[0];
  assert.ok(row.returned_at);
  assert.equal(row.updated_by, admin);
  assert.equal(row.returned_good, true);
});
test('damaged returns increase damaged inventory without restoring usable stock', async () => {
  const item = await createItem(2), loan = await requestItem(item.id);
  await processLoan(loan.id, 'approved');
  await processLoan(loan.id, 'returned', false);
  assert.deepEqual(await stock(item.id), { stok: 1, stok_rusak: 1 });
  await assert.rejects(processLoan(loan.id, 'returned', true), /INVALID_TRANSITION/);
});
test('return requires approved state and an explicit inspection result', async () => {
  const item = await createItem(), loan = await requestItem(item.id);
  await assert.rejects(processLoan(loan.id, 'returned', true), /INVALID_TRANSITION/);
  await processLoan(loan.id, 'approved');
  await assert.rejects(processLoan(loan.id, 'returned'), /INVALID_INPUT/);
  await assert.rejects(processLoan(loan.id, 'pending'), /INVALID_INPUT/);
});
test('failed commands roll back their operation request, stock, and audit', async () => {
  const item = await createItem(1), loan = await requestItem(item.id), key = randomUUID();
  await assert.rejects(processLoan(loan.id, 'returned', true, key), /INVALID_TRANSITION/);
  assert.equal((await db.query('select * from private.operation_requests where request_id=$1', [key])).rows.length, 0);
  assert.equal((await stock(item.id)).stok, 1);
  assert.equal((await db.query("select * from public.audit_events where entity_id=$1 and action='borrowing_returned'", [loan.id])).rows.length, 0);
});
test('stock and ledger balances agree after all tested operations', async () => {
  const rows = (await db.query(`select i.id from public.items i
    left join public.inventory_movements m on m.item_id=i.id group by i.id
    having i.stok <> coalesce(sum(m.quantity_delta),0)
      or i.stok_rusak <> coalesce(sum(m.damaged_delta),0)`)).rows;
  assert.deepEqual(rows, []);
});

// PGlite executes on one PostgreSQL connection. These tests exercise real SQL,
// constraints, grants and RLS; multi-connection lock contention must additionally
// be tested on staging PostgreSQL (see docs/TAHAP_1_DAN_2.md).
test('migration refuses legacy active loans until stock is reconciled', async () => {
  const legacy = new PGlite();
  try {
    await legacy.exec(bootstrap);
    await legacy.query('insert into auth.users(id,email) values($1,$2)', [student, 'legacy@example.test']);
    // Build a supported legacy shape with an active approved borrowing.
    const schema = migration.slice(migration.indexOf('create table if not exists public.items'), migration.indexOf('-- Fail rather'));
    await legacy.exec(schema);
    const item = randomUUID();
    await legacy.query("insert into public.items(id,nama_barang,kode_barang,kategori,kondisi,stok,lokasi) values($1,'Legacy','LEGACY','Komputer','Baik',2,'Rak')", [item]);
    await legacy.query("insert into public.borrowings(user_id,item_id,nama_peminjam,nama_barang,jumlah,tgl_pinjam,tgl_kembali,keperluan,status) values($1,$2,'A','Legacy',1,$3,$3,'Praktikum','approved')", [student,item,today]);
    await assert.rejects(legacy.exec(migration), /LEGACY_STOCK_REVIEW_REQUIRED/);
    await legacy.exec('rollback');
    assert.equal((await legacy.query('select stok from public.items')).rows[0].stok, 2);
    assert.equal((await legacy.query('select count(*)::int as count from public.borrowings')).rows[0].count, 1);
  } finally { await legacy.close(); }
});

async function legacyDatabase({ active = false, columnGrant = false } = {}) {
  const legacy = new PGlite();
  await legacy.exec(bootstrap);
  await legacy.query('insert into auth.users(id,email) values($1,$2)', [student, 'legacy@example.test']);
  await legacy.exec(migration.slice(migration.indexOf('create table if not exists public.items'), migration.indexOf('-- Fail rather')));
  const itemId = randomUUID();
  await legacy.query("insert into public.items(id,nama_barang,kode_barang,kategori,kondisi,stok,lokasi) values($1,'Legacy','LEGACY','Komputer','Baik',2,'Rak')", [itemId]);
  await legacy.query("insert into public.borrowings(user_id,item_id,nama_peminjam,nama_barang,jumlah,tgl_pinjam,tgl_kembali,keperluan,status) values($1,$2,'A','Legacy',1,$3,$3,'Praktikum',$4)",
    [student, itemId, today, active ? 'approved' : 'pending']);
  if (columnGrant) {
    await legacy.exec(`grant update(stok) on public.items to authenticated;
      grant select on public.borrowings to anon, authenticated;
      alter table public.items enable row level security;
      create policy legacy_allow_all on public.items for all using(true) with check(true);`);
  }
  return { legacy, itemId };
}
for (const [mode, expected] of [['available',2], ['total',1]]) {
  test(`verified legacy ${mode} stock mode preserves loans and establishes the right opening balance`, async () => {
    const { legacy, itemId } = await legacyDatabase({ active:true });
    try {
      await legacy.exec(migration.replace("= 'review_required'", `= '${mode}'`));
      assert.equal((await legacy.query('select stok from public.items where id=$1',[itemId])).rows[0].stok,expected);
      assert.equal((await legacy.query('select quantity_delta from public.inventory_movements where item_id=$1',[itemId])).rows[0].quantity_delta,expected);
      assert.equal((await legacy.query('select status from public.borrowings')).rows[0].status,'approved');
      assert.equal((await legacy.query('select role from public.profiles where id=$1',[student])).rows[0].role,'student');
    } finally { await legacy.close(); }
  });
}
test('migration removes legacy permissive policies and column update grants without deleting data', async () => {
  const { legacy, itemId } = await legacyDatabase({ columnGrant:true });
  try {
    await legacy.exec(migration);
    assert.equal((await legacy.query('select count(*)::int as count from public.borrowings')).rows[0].count,1);
    assert.equal((await legacy.query("select count(*)::int as count from pg_policies where policyname='legacy_allow_all'")).rows[0].count,0);
    await legacy.exec('begin; set local role authenticated;');
    await legacy.query("select set_config('request.jwt.claim.sub',$1,true)",[student]);
    await assert.rejects(legacy.query('update public.items set stok=999 where id=$1',[itemId]),/permission denied/);
    await legacy.exec('rollback');
    assert.equal((await legacy.query('select stok from public.items')).rows[0].stok,2);
  } finally { await legacy.close(); }
});
test('migration refuses unknown legacy definer RPCs instead of leaving a mutation bypass', async () => {
  const { legacy } = await legacyDatabase();
  try {
    await legacy.exec("create function public.unsafe_old_rpc() returns void language sql security definer as $$ update public.items set stok=999 $$;");
    await assert.rejects(legacy.exec(migration),/LEGACY_RPC_REVIEW_REQUIRED/);
    await legacy.exec('rollback');
    assert.equal((await legacy.query('select stok from public.items')).rows[0].stok,2);
  } finally { await legacy.close(); }
});

test('legacy access guard blocks public access and direct writes while preserving all balances and statuses', async () => {
  const { legacy, itemId } = await legacyDatabase({ active:true, columnGrant:true });
  try {
    await legacy.exec(accessGuard);
    await legacy.exec(accessGuard);
    assert.equal((await legacy.query('select stok from public.items where id=$1',[itemId])).rows[0].stok,2);
    assert.equal((await legacy.query('select status from public.borrowings')).rows[0].status,'approved');
    await legacy.exec('begin; set local role anon;');
    await assert.rejects(legacy.query('select * from public.borrowings'),/permission denied/);
    await legacy.exec('rollback; begin; set local role authenticated;');
    await legacy.query("select set_config('request.jwt.claim.sub',$1,true)",[student]);
    assert.equal((await legacy.query('select * from public.items')).rows.length,1);
    assert.equal((await legacy.query('select * from public.borrowings')).rows.length,1);
    await legacy.query("select set_config('request.jwt.claim.sub',$1,true)",[otherStudent]);
    assert.equal((await legacy.query('select * from public.borrowings')).rows.length,0);
    await assert.rejects(legacy.query('update public.items set stok=999'),/permission denied/);
    await legacy.exec('rollback');
    await legacy.exec(migration.replace("= 'review_required'", "= 'total'"));
    assert.equal((await legacy.query('select stok from public.items')).rows[0].stok,1);
    // Replaying the guard after the full migration must preserve its policies.
    await legacy.exec(accessGuard);
    assert.equal((await legacy.query("select count(*)::int as count from pg_policies where policyname='lab_borrowing_read'")).rows[0].count,1);
  } finally { await legacy.close(); }
});
test('full migration supports legacy varchar actor IDs without losing values', async () => {
  const { legacy } = await legacyDatabase();
  try {
    await legacy.exec('alter table public.borrowings alter column updated_by type varchar(50) using updated_by::text;');
    await legacy.query('update public.borrowings set updated_by=$1',[student]);
    await legacy.exec(migration);
    const row=(await legacy.query("select updated_by::text as actor,pg_typeof(updated_by)::text as type from public.borrowings")).rows[0];
    assert.deepEqual(row,{actor:student,type:'uuid'});
  } finally { await legacy.close(); }
});
test('full migration refuses non-UUID legacy actor labels without deleting them', async () => {
  const { legacy } = await legacyDatabase();
  try {
    await legacy.exec('alter table public.borrowings alter column updated_by type varchar(50) using updated_by::text;');
    await legacy.query('update public.borrowings set updated_by=$1',['Laboran lama']);
    await assert.rejects(legacy.exec(migration),/LEGACY_ACTOR_REVIEW_REQUIRED/);
    await legacy.exec('rollback');
    assert.equal((await legacy.query('select updated_by from public.borrowings')).rows[0].updated_by,'Laboran lama');
  } finally { await legacy.close(); }
});

async function stagedLoginDatabase() {
  const { legacy, itemId } = await legacyDatabase({active:true});
  await legacy.query('insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)',
    [admin,'verified-admin@example.test',JSON.stringify({role:'admin'})]);
  await legacy.query('insert into auth.users(id,email) values($1,$2)',[otherStudent,'other@example.test']);
  await legacy.exec(accessGuard);
  await legacy.exec(loginBridge);
  return {legacy,itemId};
}
async function stagedActor(legacy, id, sql, role='authenticated', anonymous=false) {
  await legacy.exec(`begin; set local role ${role};`);
  try {
    await legacy.query("select set_config('request.jwt.claim.sub',$1,true)",[id??'']);
    await legacy.query("select set_config('request.jwt.claim.is_anonymous',$1,true)",[String(anonymous)]);
    return await legacy.query(sql);
  } finally { await legacy.exec('rollback'); }
}
test('login bridge preserves stock, ignores signup roles, and is repeatable', async () => {
  const {legacy,itemId}=await stagedLoginDatabase();
  try {
    assert.deepEqual((await legacy.query('select distinct role,transactions_enabled from public.profiles')).rows,
      [{role:'student',transactions_enabled:false}]);
    await legacy.query("update public.profiles set role='admin' where id=$1",[admin]);
    await legacy.exec(loginBridge);
    assert.equal((await legacy.query('select role from public.profiles where id=$1',[admin])).rows[0].role,'admin');
    assert.equal((await legacy.query('select stok from public.items where id=$1',[itemId])).rows[0].stok,2);
    assert.equal((await legacy.query('select status from public.borrowings')).rows[0].status,'approved');
  } finally { await legacy.close(); }
});
test('login bridge enforces server roles and owner isolation without client writes', async () => {
  const {legacy}=await stagedLoginDatabase();
  try {
    await legacy.query("update public.profiles set role='admin' where id=$1",[admin]);
    assert.equal((await stagedActor(legacy,student,'select id from public.profiles')).rows.length,1);
    assert.equal((await stagedActor(legacy,student,'select id from public.borrowings')).rows.length,1);
    assert.equal((await stagedActor(legacy,otherStudent,'select id from public.borrowings')).rows.length,0);
    assert.equal((await stagedActor(legacy,admin,'select id from public.borrowings')).rows.length,1);
    assert.equal((await stagedActor(legacy,student,'select id from public.items')).rows.length,1);
    for (const table of ['profiles','items','borrowings']) {
      await assert.rejects(stagedActor(legacy,null,`select * from public.${table}`,'anon'),/permission denied/);
      assert.equal((await stagedActor(legacy,student,`select * from public.${table}`,'authenticated',true)).rows.length,0);
    }
    await assert.rejects(stagedActor(legacy,student,"update public.profiles set role='admin'"),/permission denied/);
    await assert.rejects(stagedActor(legacy,admin,'update public.items set stok=99'),/permission denied/);
  } finally { await legacy.close(); }
});
test('inactive staged users cannot read inventory or their profile', async () => {
  const {legacy}=await stagedLoginDatabase();
  try {
    await legacy.query('update public.profiles set is_active=false where id=$1',[student]);
    assert.equal((await stagedActor(legacy,student,'select id from public.profiles')).rows.length,0);
    assert.equal((await stagedActor(legacy,student,'select id from public.items')).rows.length,0);
  } finally { await legacy.close(); }
});
test('reviewed full migration upgrades the login bridge and preserves assigned roles', async () => {
  const {legacy,itemId}=await stagedLoginDatabase();
  try {
    await legacy.query("update public.profiles set role='admin' where id=$1",[admin]);
    await legacy.exec(migration.replace("= 'review_required'","= 'available'"));
    assert.equal((await legacy.query('select role,transactions_enabled from public.profiles where id=$1',[admin])).rows[0].role,'admin');
    assert.equal((await legacy.query('select bool_and(transactions_enabled) as ready from public.profiles')).rows[0].ready,true);
    assert.equal((await legacy.query('select stok from public.items where id=$1',[itemId])).rows[0].stok,2);
    await assert.rejects(legacy.exec(loginBridge),/FULL_SCHEMA_ALREADY_INSTALLED/);
    await legacy.exec('rollback');
  } finally { await legacy.close(); }
});
test('unreviewed full migration keeps the staged login bridge read-only', async () => {
  const {legacy,itemId}=await stagedLoginDatabase();
  try {
    await assert.rejects(legacy.exec(migration),/LEGACY_STOCK_REVIEW_REQUIRED/);
    await legacy.exec('rollback');
    assert.equal((await legacy.query('select bool_or(transactions_enabled) as ready from public.profiles')).rows[0].ready,false);
    assert.equal((await legacy.query('select stok from public.items where id=$1',[itemId])).rows[0].stok,2);
  } finally { await legacy.close(); }
});
