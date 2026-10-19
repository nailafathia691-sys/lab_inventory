import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import { PGlite } from '@electric-sql/pglite';

// Reconstruct the exported application schema/data in memory. No network or
// production credentials are used; the source backup is never modified.
const filename = process.argv[2];
if (!filename) throw new Error('Usage: node rehearse-migration.mjs PRIVATE_BACKUP.json');
const backup = JSON.parse(await readFile(filename, 'utf8'));
const migration = await readFile(new URL('../../supabase/migrations/202610180001_secure_inventory.sql', import.meta.url), 'utf8');
assert.equal(backup.transaction_rpc_installed, false, 'Backup must precede the full migration');
assert.equal(backup.triggers.length, 0, 'Existing triggers require separate review');
const names = ['profiles', 'items', 'borrowings'];
const quote = value => '"' + value.replaceAll('"', '""') + '"';
const validTypes = new Set(['uuid','varchar','text','int4','timestamp','timestamptz','bool']);

async function restore() {
  const db = new PGlite();
  await db.exec(`
    create role anon nologin; create role authenticated nologin;
    create schema auth; create schema private;
    create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}'::jsonb);
    create function auth.uid() returns uuid language sql stable as $$
      select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid;
    $$;
    create function auth.jwt() returns jsonb language sql stable as $$
      select jsonb_build_object('is_anonymous',false);
    $$;
    grant usage on schema auth,public,private to anon,authenticated;
    grant execute on function auth.uid(),auth.jwt() to anon,authenticated;
  `);
  const ids = new Set([...backup.data.profiles.map(row=>row.id), ...backup.data.borrowings.map(row=>row.user_id)]);
  for (const id of ids) {
    await db.query('insert into auth.users(id,email) values($1,$2)',[id,`${id}@rehearsal.invalid`]);
  }
  for (const name of names) {
    const columns = backup.columns.filter(column=>column.table_name===name);
    assert.ok(columns.length, `Missing schema: ${name}`);
    const declarations = columns.map(column=>{
      assert.ok(validTypes.has(column.udt_name), `Unsupported type: ${column.udt_name}`);
      return `${quote(column.column_name)} ${column.udt_name}` +
        (column.column_default === null ? '' : ` default ${column.column_default}`) +
        (column.is_nullable === 'NO' ? ' not null' : '');
    });
    await db.exec(`create table public.${quote(name)} (${declarations.join(',')});`);
    const columnNames=columns.map(column=>quote(column.column_name)).join(',');
    await db.query(`insert into public.${quote(name)} (${columnNames})
      select ${columnNames} from jsonb_populate_recordset(null::public.${quote(name)},$1::jsonb)`,
      [JSON.stringify(backup.data[name])]);
  }
  // Primary/unique constraints must precede references to those columns.
  const constraints=[...backup.constraints].sort((a,b)=>
    Number(a.definition.startsWith('FOREIGN KEY'))-Number(b.definition.startsWith('FOREIGN KEY')));
  for (const constraint of constraints) {
    const name=constraint.table.replace(/^public\./,'');
    assert.ok(names.includes(name));
    await db.exec(`alter table public.${quote(name)} add constraint ${quote(constraint.name)} ${constraint.definition}`);
  }
  for (const helper of backup.helpers) await db.exec(helper.definition);
  await db.exec(`grant execute on function private.is_active_user(),private.is_admin() to authenticated;`);
  for (const name of names) {
    await db.exec(`alter table public.${quote(name)} enable row level security;
      revoke all on public.${quote(name)} from public,anon,authenticated;
      grant select on public.${quote(name)} to authenticated;`);
  }
  for (const policy of backup.policies) {
    assert.ok(names.includes(policy.tablename));
    const roles=policy.roles.map(quote).join(',');
    await db.exec(`create policy ${quote(policy.policyname)} on public.${quote(policy.tablename)}
      for ${policy.cmd} to ${roles} using (${policy.qual})`);
  }
  return db;
}

async function asActor(db,id,sql,params=[]) {
  await db.exec('begin; set local role authenticated');
  try {
    await db.query("select set_config('request.jwt.claim.sub',$1,true)",[id]);
    const result=await db.query(sql,params);
    await db.exec('commit');
    return result;
  } catch(error) { await db.exec('rollback'); throw error; }
}

const results=[];
for (const mode of ['review_required','available','total']) {
  const db=await restore();
  try {
    const sql=migration.replace("= 'review_required'",`= '${mode}'`);
    if (mode==='review_required') {
      await assert.rejects(db.exec(sql),/LEGACY_STOCK_REVIEW_REQUIRED/);
      await db.exec('rollback');
      for (const item of backup.data.items) {
        assert.equal((await db.query('select stok from public.items where id=$1',[item.id])).rows[0].stok,item.stok);
      }
      assert.equal((await db.query('select bool_or(transactions_enabled) as ready from public.profiles')).rows[0].ready,false);
      results.push({mode,unreviewedMigrationBlocked:true,balancesPreserved:true});
      continue;
    }
    await db.exec(sql);
    assert.equal((await db.query('select count(*)::int as n from public.borrowings')).rows[0].n,backup.data.borrowings.length);
    const stock=[];
    for (const item of backup.data.items) {
      const reserved=backup.data.borrowings.filter(loan=>loan.item_id===item.id&&loan.status==='approved')
        .reduce((sum,loan)=>sum+loan.jumlah,0);
      const expected=item.stok-(mode==='total'?reserved:0);
      const row=(await db.query('select stok from public.items where id=$1',[item.id])).rows[0];
      assert.equal(row.stok,expected);
      const opening=(await db.query("select quantity_delta from public.inventory_movements where item_id=$1 and kind='opening'",[item.id])).rows[0];
      assert.equal(opening.quantity_delta,expected);
      stock.push({itemId:item.id,stock:expected});
    }
    for (const profile of backup.data.profiles) {
      const after=(await db.query('select role,transactions_enabled from public.profiles where id=$1',[profile.id])).rows[0];
      assert.equal(after.role,profile.role);
      assert.equal(after.transactions_enabled,true);
      const own=(await asActor(db,profile.id,'select id,role from public.profiles where id=$1',[profile.id])).rows[0];
      assert.equal(own.role,profile.role);
    }
    const admin=backup.data.profiles.find(profile=>profile.role==='admin');
    const student=backup.data.profiles.find(profile=>profile.role==='student');
    assert.ok(admin&&student,'Both server roles must exist');
    const today=(await db.query("select (now() at time zone 'Asia/Jakarta')::date::text as day")).rows[0].day;
    const item=(await asActor(db,admin.id,
      'select public.create_inventory_item($1,$2,$3,$4,$5,$6,$7) as result',
      ['Rehearsal item','Komputer','Baik',1,'Local only','Local migration rehearsal',randomUUID()])).rows[0].result;
    const loan=(await asActor(db,student.id,
      'select public.request_borrowing($1,1,$2::date,$2::date,$3,$4) as result',
      [item.id,today,'Local rehearsal',randomUUID()])).rows[0].result;
    const approveKey=randomUUID();
    const approveArgs=[loan.id,'approved','',null,approveKey];
    for(let retry=0;retry<2;retry++) await asActor(db,admin.id,
      'select public.process_borrowing($1,$2,$3,$4,$5)',approveArgs);
    assert.equal((await db.query('select stok from public.items where id=$1',[item.id])).rows[0].stok,0);
    await asActor(db,admin.id,'select public.process_borrowing($1,$2,$3,$4,$5)',
      [loan.id,'returned','Local rehearsal',true,randomUUID()]);
    assert.equal((await db.query('select stok from public.items where id=$1',[item.id])).rows[0].stok,1);
    results.push({mode,originalRowsPreserved:true,rolesPreserved:true,transactionsEnabled:true,
      stock,requestApproveRetryReturnPassed:true});
  } finally { await db.close(); }
}
console.log(JSON.stringify({scope:'Local PGlite reconstruction; production unchanged',backupCapturedAt:backup.captured_at,results},null,2));
