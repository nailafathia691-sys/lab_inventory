-- Apply to staging first. This migration is atomic and does not discard data.
begin;
set local timezone = 'Asia/Jakarta';
-- For legacy approved loans ONLY, choose after a physical stock reconciliation:
-- 'available': existing stok already excludes approved units.
-- 'total': existing stok includes approved units; subtract them once below.
-- Keep review_required until the actual stock semantics have been verified.
set local lab_inventory.legacy_stock_mode = 'review_required';

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete restrict,
  nama text not null,
  npm text not null default '',
  role text not null default 'student',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.items (
  id uuid primary key default gen_random_uuid(),
  nama_barang text not null,
  kode_barang text not null,
  kategori text not null,
  kondisi text not null,
  stok integer not null default 0,
  lokasi text not null default '',
  created_at timestamptz not null default now()
);
create table if not exists public.borrowings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  item_id uuid not null,
  nama_peminjam text not null,
  nama_barang text not null,
  jumlah integer not null,
  tgl_pinjam date not null,
  tgl_kembali date not null,
  keperluan text not null,
  status text not null default 'pending',
  catatan_kondisi text,
  updated_by uuid,
  created_at timestamptz not null default now()
);

-- Fail rather than silently converting unknown IDs or running old stock triggers twice.
do $$
declare r record;
begin
  for r in select * from (values
    ('profiles', 'id'), ('items', 'id'), ('borrowings', 'id'),
    ('borrowings', 'user_id'), ('borrowings', 'item_id')
  ) as required(table_name, column_name) loop
    if not exists (select 1 from information_schema.columns c
      where c.table_schema = 'public' and c.table_name = r.table_name
        and c.column_name = r.column_name and c.udt_name = 'uuid') then
      raise exception 'LEGACY_SCHEMA_REVIEW_REQUIRED: %.% must be uuid; no data was converted', r.table_name, r.column_name;
    end if;
  end loop;
  if exists (select 1 from pg_trigger t
    where t.tgrelid in ('public.items'::regclass, 'public.borrowings'::regclass)
      and not t.tgisinternal) then
    raise exception 'LEGACY_TRIGGER_REVIEW_REQUIRED: inspect existing inventory/borrowing triggers before applying';
  end if;
  if exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prosecdef and not exists
      (select 1 from pg_depend d where d.objid = p.oid and d.classid = 'pg_proc'::regclass and d.deptype = 'e')) then
    raise exception 'LEGACY_RPC_REVIEW_REQUIRED: audit or revoke old public SECURITY DEFINER functions before applying';
  end if;
  if exists (select 1 from pg_trigger t where t.tgrelid = 'auth.users'::regclass and not t.tgisinternal) then
    raise exception 'LEGACY_AUTH_TRIGGER_REVIEW_REQUIRED: consolidate existing auth.users triggers before applying';
  end if;
end $$;

alter table public.profiles add column if not exists npm text not null default '';
alter table public.profiles add column if not exists is_active boolean not null default true;
alter table public.profiles add column if not exists transactions_enabled boolean not null default true;
alter table public.profiles alter column transactions_enabled set default true;
alter table public.items add column if not exists deskripsi text not null default '';
alter table public.items add column if not exists is_active boolean not null default true;
alter table public.items add column if not exists stok_rusak integer not null default 0;
alter table public.borrowings add column if not exists catatan_kondisi text;
alter table public.borrowings add column if not exists updated_by uuid;
alter table public.borrowings add column if not exists approved_at timestamptz;
alter table public.borrowings add column if not exists returned_at timestamptz;
alter table public.borrowings add column if not exists returned_good boolean;
alter table public.borrowings add column if not exists updated_at timestamptz not null default now();

-- The live legacy schema stores updated_by as varchar. Convert only valid UUIDs
-- or empty values, and keep invalid actor labels for an explicit operator review.
do $$
begin
  if exists (select 1 from public.borrowings
    where nullif(trim(updated_by::text), '') is not null
      and trim(updated_by::text) !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') then
    raise exception 'LEGACY_ACTOR_REVIEW_REQUIRED: reconcile non-UUID updated_by values before applying';
  end if;
end $$;
alter table public.borrowings alter column updated_by type uuid
  using nullif(trim(updated_by::text), '')::uuid;

-- Widen legacy varchar columns to match RPC validation without truncating data.
alter table public.items alter column nama_barang type text;
alter table public.items alter column kode_barang type text;
alter table public.items alter column kategori type text;
alter table public.items alter column kondisi type text;
alter table public.items alter column lokasi type text;
alter table public.borrowings alter column nama_peminjam type text;
alter table public.borrowings alter column nama_barang type text;
alter table public.borrowings alter column status type text;

-- Date-only business fields; timezone above preserves the Jakarta calendar date
-- for supported legacy timestamp/timestamptz columns.
alter table public.borrowings alter column tgl_pinjam type date using tgl_pinjam::date;
alter table public.borrowings alter column tgl_kembali type date using tgl_kembali::date;

insert into public.profiles (id, nama, npm, role)
select u.id, coalesce(nullif(left(trim(u.raw_user_meta_data->>'nama'), 100), ''),
  nullif(left(split_part(u.email, '@', 1), 100), ''), 'Pengguna'),
  left(coalesce(u.raw_user_meta_data->>'npm', ''), 30), 'student'
from auth.users u on conflict (id) do nothing;

do $$
begin
  if exists (select 1 from public.borrowings b
    left join auth.users u on u.id = b.user_id
    left join public.items i on i.id = b.item_id
    where u.id is null or i.id is null) then
    raise exception 'LEGACY_ORPHANS_REVIEW_REQUIRED: reconcile borrowing owners/items; no rows were deleted';
  end if;
  if exists (select 1 from public.borrowings where status = 'approved') then
    if current_setting('lab_inventory.legacy_stock_mode') = 'total' then
      update public.items i set stok = i.stok - active.quantity
      from (select item_id, sum(jumlah)::integer as quantity from public.borrowings
        where status = 'approved' group by item_id) active where active.item_id = i.id;
    elsif current_setting('lab_inventory.legacy_stock_mode') <> 'available' then
      raise exception 'LEGACY_STOCK_REVIEW_REQUIRED: reconcile active loans and choose available or total at migration header';
    end if;
  end if;
end $$;

alter table public.profiles add constraint lab_profile_role check (role in ('student', 'admin'));
alter table public.profiles add constraint lab_profile_name check (length(trim(nama)) between 1 and 100);
alter table public.profiles add constraint lab_profile_identity check (length(npm) <= 30);
alter table public.items add constraint lab_item_stock check (stok >= 0 and stok_rusak >= 0);
alter table public.items add constraint lab_item_name check (length(trim(nama_barang)) between 1 and 150);
alter table public.items add constraint lab_item_condition check (kondisi in ('Baik', 'Sangat Baik', 'Perlu Perbaikan'));
alter table public.items add constraint lab_item_category check (kategori in ('Elektronik', 'Komputer', 'Aksesoris'));
alter table public.items add constraint lab_item_description check (length(deskripsi) <= 2000);
alter table public.items add constraint lab_item_code_unique unique (kode_barang);
alter table public.borrowings add constraint lab_borrowing_owner foreign key (user_id) references public.profiles(id) on delete restrict;
alter table public.borrowings add constraint lab_borrowing_item foreign key (item_id) references public.items(id) on delete restrict;
alter table public.borrowings add constraint lab_borrowing_actor foreign key (updated_by) references public.profiles(id) on delete restrict;
alter table public.borrowings add constraint lab_borrowing_quantity check (jumlah > 0);
alter table public.borrowings add constraint lab_borrowing_dates check (tgl_kembali >= tgl_pinjam);
alter table public.borrowings add constraint lab_borrowing_status check (status in ('pending', 'approved', 'rejected', 'returned'));
alter table public.borrowings add constraint lab_borrowing_purpose check (length(trim(keperluan)) between 1 and 2000);
alter table public.borrowings alter column user_id set not null;
alter table public.borrowings alter column item_id set not null;
alter table public.borrowings alter column jumlah set not null;
alter table public.borrowings alter column tgl_pinjam set not null;
alter table public.borrowings alter column tgl_kembali set not null;
alter table public.borrowings alter column status set not null;
alter table public.borrowings alter column keperluan set not null;
alter table public.items alter column stok set not null;
alter table public.items alter column nama_barang set not null;
alter table public.items alter column kode_barang set not null;
alter table public.items alter column kategori set not null;
alter table public.items alter column kondisi set not null;
alter table public.items alter column is_active set not null;
alter table public.items alter column stok_rusak set not null;
alter table public.items alter column id set default gen_random_uuid();
alter table public.borrowings alter column id set default gen_random_uuid();
alter table public.borrowings alter column nama_peminjam set not null;
alter table public.borrowings alter column nama_barang set not null;
alter table public.profiles alter column nama set not null;
alter table public.profiles alter column role set not null;
alter table public.profiles alter column role set default 'student';
alter table public.profiles alter column is_active set not null;

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.items(id) on delete restrict,
  borrowing_id uuid references public.borrowings(id) on delete restrict,
  actor_id uuid references public.profiles(id) on delete restrict,
  kind text not null check (kind in ('opening', 'added', 'reserved', 'returned_good', 'returned_damaged')),
  quantity_delta integer not null,
  damaged_delta integer not null default 0,
  created_at timestamptz not null default now()
);
create table public.audit_events (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id) on delete restrict,
  entity_id uuid not null,
  action text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create table private.operation_requests (
  actor_id uuid not null references auth.users(id) on delete restrict,
  request_id uuid not null,
  action text not null,
  payload jsonb not null,
  result jsonb,
  created_at timestamptz not null default now(),
  primary key (actor_id, request_id)
);
alter table private.operation_requests enable row level security;
revoke all on private.operation_requests from public, anon, authenticated;

-- The ledger starts from the verified available balance, not reconstructed history.
insert into public.inventory_movements (item_id, kind, quantity_delta, damaged_delta)
select id, 'opening', stok, stok_rusak from public.items;
insert into public.audit_events (entity_id, action, details)
select id, 'migration_baseline', jsonb_build_object('status', status) from public.borrowings;

create sequence public.inventory_code_seq;
revoke all on sequence public.inventory_code_seq from public, anon, authenticated;
create index lab_borrowing_owner_created on public.borrowings(user_id, created_at desc);
create index lab_borrowing_status_created on public.borrowings(status, created_at desc);
create index lab_borrowing_item on public.borrowings(item_id);
create index lab_movement_item_created on public.inventory_movements(item_id, created_at desc);

-- Helpers are SECURITY DEFINER to avoid recursive profile RLS. They read only
-- the authenticated caller; all identifiers are schema-qualified.
create or replace function private.is_active_user() returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce((auth.jwt()->>'is_anonymous')::boolean, false) = false
    and exists (select 1 from public.profiles where id = auth.uid() and is_active);
$$;
create or replace function private.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce((auth.jwt()->>'is_anonymous')::boolean, false) = false
    and exists (select 1 from public.profiles where id = auth.uid() and is_active and role = 'admin');
$$;
revoke all on function private.is_active_user(), private.is_admin() from public, anon, authenticated;
grant execute on function private.is_active_user(), private.is_admin() to authenticated;

-- Replace legacy permissive policies, including legacy column-level grants.
do $$
declare t text; p record; cols text;
begin
  foreach t in array array['profiles', 'items', 'borrowings', 'inventory_movements', 'audit_events'] loop
    execute format('alter table public.%I enable row level security', t);
    for p in select policyname from pg_policies where schemaname = 'public' and tablename = t loop
      execute format('drop policy %I on public.%I', p.policyname, t);
    end loop;
    execute format('revoke all privileges on table public.%I from public, anon, authenticated', t);
    select string_agg(quote_ident(column_name), ',') into cols
      from information_schema.columns where table_schema = 'public' and table_name = t;
    execute format('revoke all privileges (%s) on table public.%I from public, anon, authenticated', cols, t);
    execute format('grant select on table public.%I to authenticated', t);
  end loop;
end $$;
create policy lab_profile_read on public.profiles for select to authenticated
  using ((id = (select auth.uid()) and (select private.is_active_user())) or (select private.is_admin()));
create policy lab_item_read on public.items for select to authenticated
  using ((select private.is_active_user()) and (is_active or (select private.is_admin())));
create policy lab_borrowing_read on public.borrowings for select to authenticated
  using ((select private.is_active_user()) and (user_id = (select auth.uid()) or (select private.is_admin())));
create policy lab_movement_read on public.inventory_movements for select to authenticated
  using ((select private.is_admin()));
create policy lab_audit_read on public.audit_events for select to authenticated
  using ((select private.is_admin()));

create function private.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id, nama, npm, role)
  values (new.id, coalesce(nullif(left(trim(new.raw_user_meta_data->>'nama'), 100), ''),
    nullif(left(split_part(new.email, '@', 1), 100), ''), 'Pengguna'),
    left(coalesce(new.raw_user_meta_data->>'npm', ''), 30), 'student');
  return new;
end $$;
revoke all on function private.handle_new_user() from public, anon, authenticated;
create trigger lab_auth_user_profile after insert on auth.users
for each row execute function private.handle_new_user();

create function private.require_actor(p_admin boolean default false) returns public.profiles
language plpgsql security definer set search_path = '' as $$
declare actor public.profiles;
begin
  if auth.uid() is null or coalesce((auth.jwt()->>'is_anonymous')::boolean, false) then
    raise exception using message = 'AUTH_REQUIRED', errcode = 'P0001';
  end if;
  select * into actor from public.profiles where id = auth.uid() and is_active for share;
  if not found then raise exception using message = 'PROFILE_REQUIRED', errcode = 'P0001'; end if;
  if p_admin and actor.role <> 'admin' then raise exception using message = 'FORBIDDEN', errcode = 'P0001'; end if;
  return actor;
end $$;
revoke all on function private.require_actor(boolean) from public, anon, authenticated;

-- ON CONFLICT and FOR UPDATE serialize two requests with the same key. The
-- pending request, business changes and final result commit/roll back together.
create function private.lock_request(p_request_id uuid, p_action text, p_payload jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare previous private.operation_requests;
begin
  if p_request_id is null then raise exception using message = 'INVALID_INPUT', errcode = 'P0001'; end if;
  insert into private.operation_requests(actor_id, request_id, action, payload)
    values (auth.uid(), p_request_id, p_action, p_payload) on conflict do nothing;
  select * into previous from private.operation_requests
    where actor_id = auth.uid() and request_id = p_request_id for update;
  if previous.action <> p_action or previous.payload <> p_payload then
    raise exception using message = 'REQUEST_CONFLICT', errcode = 'P0001';
  end if;
  return previous.result;
end $$;
revoke all on function private.lock_request(uuid, text, jsonb) from public, anon, authenticated;

create function public.create_inventory_item(p_name text, p_category text, p_condition text,
  p_stock integer, p_location text, p_description text, p_request_id uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare actor public.profiles; item public.items; response jsonb;
begin
  actor := private.require_actor(true);
  response := private.lock_request(p_request_id, 'create_inventory_item', jsonb_build_object(
    'name', p_name, 'category', p_category, 'condition', p_condition,
    'stock', p_stock, 'location', p_location, 'description', p_description));
  if response is not null then return response; end if;
  if p_name is null or length(trim(p_name)) not between 1 and 150
    or p_category is null or p_category not in ('Elektronik', 'Komputer', 'Aksesoris')
    or p_condition is null or p_condition not in ('Baik', 'Sangat Baik', 'Perlu Perbaikan')
    or p_stock is null or p_stock < 0 or p_location is null or length(p_location) > 200
    or p_description is null or length(p_description) > 2000 then
    raise exception using message = 'INVALID_INPUT', errcode = 'P0001';
  end if;
  insert into public.items(nama_barang, kode_barang, kategori, kondisi, stok, lokasi, deskripsi)
  values (trim(p_name), 'INV-' || upper(left(p_category, 3)) || '-' || lpad(nextval('public.inventory_code_seq')::text, 8, '0'),
    p_category, p_condition, p_stock, trim(p_location), trim(p_description)) returning * into item;
  insert into public.inventory_movements(item_id, actor_id, kind, quantity_delta)
    values (item.id, actor.id, 'added', p_stock);
  insert into public.audit_events(actor_id, entity_id, action, details)
    values (actor.id, item.id, 'item_created', jsonb_build_object('stock', p_stock));
  response := jsonb_build_object('id', item.id, 'kode_barang', item.kode_barang);
  update private.operation_requests set result = response where actor_id = actor.id and request_id = p_request_id;
  return response;
end $$;

create function public.request_borrowing(p_item_id uuid, p_quantity integer,
  p_borrow_date date, p_due_date date, p_purpose text, p_request_id uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare actor public.profiles; item public.items; borrowing public.borrowings; response jsonb;
begin
  actor := private.require_actor(false);
  response := private.lock_request(p_request_id, 'request_borrowing', jsonb_build_object(
    'item', p_item_id, 'quantity', p_quantity, 'borrow_date', p_borrow_date,
    'due_date', p_due_date, 'purpose', p_purpose));
  if response is not null then return response; end if;
  if p_quantity is null or p_quantity <= 0 or p_purpose is null
    or length(trim(p_purpose)) not between 1 and 2000 then
    raise exception using message = 'INVALID_INPUT', errcode = 'P0001';
  end if;
  if p_borrow_date is null or p_due_date is null or p_due_date < p_borrow_date
    or p_borrow_date < (now() at time zone 'Asia/Jakarta')::date then
    raise exception using message = 'INVALID_DATES', errcode = 'P0001';
  end if;
  select * into item from public.items where id = p_item_id for update;
  if not found then raise exception using message = 'NOT_FOUND', errcode = 'P0001'; end if;
  if not item.is_active or item.kondisi not in ('Baik', 'Sangat Baik') then
    raise exception using message = 'ITEM_UNAVAILABLE', errcode = 'P0001';
  end if;
  if item.stok < p_quantity then raise exception using message = 'INSUFFICIENT_STOCK', errcode = 'P0001'; end if;
  insert into public.borrowings(user_id, item_id, nama_peminjam, nama_barang, jumlah,
    tgl_pinjam, tgl_kembali, keperluan, status)
  values (actor.id, item.id, actor.nama, item.nama_barang, p_quantity,
    p_borrow_date, p_due_date, trim(p_purpose), 'pending') returning * into borrowing;
  insert into public.audit_events(actor_id, entity_id, action, details)
    values (actor.id, borrowing.id, 'borrowing_requested', jsonb_build_object('quantity', p_quantity, 'item_id', item.id));
  response := jsonb_build_object('id', borrowing.id, 'status', borrowing.status);
  update private.operation_requests set result = response where actor_id = actor.id and request_id = p_request_id;
  return response;
end $$;

create function public.process_borrowing(p_borrowing_id uuid, p_status text,
  p_notes text, p_returned_good boolean, p_request_id uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare actor public.profiles; borrowing public.borrowings; item public.items; response jsonb; old_status text;
begin
  actor := private.require_actor(true);
  response := private.lock_request(p_request_id, 'process_borrowing', jsonb_build_object(
    'borrowing', p_borrowing_id, 'status', p_status, 'notes', p_notes, 'returned_good', p_returned_good));
  if response is not null then return response; end if;
  if p_status is null or p_status not in ('approved', 'rejected', 'returned') or p_notes is null
    or length(p_notes) > 2000 or (p_status = 'returned' and p_returned_good is null)
    or (p_status <> 'returned' and p_returned_good is not null) then
    raise exception using message = 'INVALID_INPUT', errcode = 'P0001';
  end if;
  select * into borrowing from public.borrowings where id = p_borrowing_id for update;
  if not found then raise exception using message = 'NOT_FOUND', errcode = 'P0001'; end if;
  old_status := borrowing.status;
  -- A repeated action with a new key must still never change stock twice.
  if borrowing.status = p_status and (p_status <> 'returned'
    or (borrowing.returned_good is not distinct from p_returned_good and coalesce(borrowing.catatan_kondisi, '') = trim(p_notes))) then
    response := jsonb_build_object('id', borrowing.id, 'status', borrowing.status);
    update private.operation_requests set result = response where actor_id = actor.id and request_id = p_request_id;
    return response;
  end if;
  if not ((borrowing.status = 'pending' and p_status in ('approved', 'rejected'))
    or (borrowing.status = 'approved' and p_status = 'returned')) then
    raise exception using message = 'INVALID_TRANSITION', errcode = 'P0001';
  end if;
  select * into item from public.items where id = borrowing.item_id for update;
  if p_status = 'approved' then
    if borrowing.tgl_kembali < (now() at time zone 'Asia/Jakarta')::date then
      raise exception using message = 'INVALID_DATES', errcode = 'P0001';
    end if;
    if not item.is_active or item.kondisi not in ('Baik', 'Sangat Baik') then
      raise exception using message = 'ITEM_UNAVAILABLE', errcode = 'P0001';
    end if;
    -- Row lock + conditional update protects the last unit under concurrent approvals.
    update public.items set stok = stok - borrowing.jumlah
      where id = item.id and stok >= borrowing.jumlah;
    if not found then raise exception using message = 'INSUFFICIENT_STOCK', errcode = 'P0001'; end if;
    insert into public.inventory_movements(item_id, borrowing_id, actor_id, kind, quantity_delta)
      values (item.id, borrowing.id, actor.id, 'reserved', -borrowing.jumlah);
  elsif p_status = 'returned' then
    update public.items set stok = stok + case when p_returned_good then borrowing.jumlah else 0 end,
      stok_rusak = stok_rusak + case when p_returned_good then 0 else borrowing.jumlah end where id = item.id;
    insert into public.inventory_movements(item_id, borrowing_id, actor_id, kind, quantity_delta, damaged_delta)
      values (item.id, borrowing.id, actor.id,
        case when p_returned_good then 'returned_good' else 'returned_damaged' end,
        case when p_returned_good then borrowing.jumlah else 0 end,
        case when p_returned_good then 0 else borrowing.jumlah end);
  end if;
  update public.borrowings set status = p_status, updated_by = actor.id, updated_at = now(),
    catatan_kondisi = trim(p_notes),
    approved_at = case when p_status = 'approved' then now() else approved_at end,
    returned_at = case when p_status = 'returned' then now() else returned_at end,
    returned_good = case when p_status = 'returned' then p_returned_good else returned_good end
    where id = borrowing.id;
  insert into public.audit_events(actor_id, entity_id, action, details)
    values (actor.id, borrowing.id, 'borrowing_' || p_status,
      jsonb_build_object('from', old_status, 'to', p_status, 'quantity', borrowing.jumlah, 'returned_good', p_returned_good));
  response := jsonb_build_object('id', borrowing.id, 'status', p_status);
  update private.operation_requests set result = response where actor_id = actor.id and request_id = p_request_id;
  return response;
end $$;

revoke all on function public.create_inventory_item(text, text, text, integer, text, text, uuid),
  public.request_borrowing(uuid, integer, date, date, text, uuid),
  public.process_borrowing(uuid, text, text, boolean, uuid) from public, anon, authenticated;
grant execute on function public.create_inventory_item(text, text, text, integer, text, text, uuid),
  public.request_borrowing(uuid, integer, date, date, text, uuid),
  public.process_borrowing(uuid, text, text, boolean, uuid) to authenticated;

-- The staged login bridge was read-only. Enable client transactions only
-- when this entire stock-reviewed migration successfully commits.
update public.profiles set transactions_enabled = true;
notify pgrst, 'reload schema';
commit;
