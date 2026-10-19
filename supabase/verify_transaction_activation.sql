-- Exercise the real RPCs with real account identities; rollback all test rows.
begin;
set local timezone='Asia/Jakarta';
do $li_verify$
<<li_verify>>
declare
  admin_id uuid:='58247a30-e35b-4ea6-99cf-6c1d3d96bc43';
  student_id uuid:='5dccf229-91ad-4771-b93e-1d2d9dbff89d';
  other_id uuid:='36f32dae-3f6b-4b27-aac3-1df206b5df77';
  original_role text:=current_user; actor uuid; result jsonb; item_id uuid; loan_id uuid;
  rejected_id uuid; damaged_id uuid; request_key uuid:=gen_random_uuid();
  approval_key uuid:=gen_random_uuid(); return_key uuid:=gen_random_uuid();
  today date:=(now() at time zone 'Asia/Jakarta')::date;
  count_rows bigint; balance integer; damaged integer; ledger_balance bigint; ledger_damaged bigint;
begin
  if (select stok from public.items where id='0fe110a1-828f-4d1a-9106-e44107b944a3')<>1
    then raise exception 'RECONCILIATION_FAILED'; end if;
  if (select count(*) from public.items)<>4 or (select count(*) from public.borrowings)<>1
    then raise exception 'UNEXPECTED_BASELINE'; end if;
  if exists(select 1 from public.profiles where not transactions_enabled)
    then raise exception 'TRANSACTIONS_DISABLED'; end if;
  if exists(select 1 from pg_class where oid in('public.profiles'::regclass,'public.items'::regclass,
    'public.borrowings'::regclass,'public.inventory_movements'::regclass,'public.audit_events'::regclass,
    'private.operation_requests'::regclass) and not relrowsecurity) then raise exception 'RLS_DISABLED'; end if;
  if has_table_privilege('anon','public.items','SELECT') or has_table_privilege('authenticated','public.items','UPDATE')
    or has_table_privilege('authenticated','public.profiles','UPDATE')
    or has_function_privilege('anon','public.process_borrowing(uuid,text,text,boolean,uuid)','EXECUTE')
    then raise exception 'UNSAFE_GRANT'; end if;

  execute 'set local role authenticated';
  perform set_config('request.jwt.claim.sub',admin_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',admin_id,'role','authenticated','is_anonymous',false)::text,true);
  result:=public.create_inventory_item('Uji aktivasi - rollback','Komputer','Baik',1,'Pengujian sementara','Tidak disimpan setelah pengujian',gen_random_uuid());
  item_id:=(result->>'id')::uuid;

  perform set_config('request.jwt.claim.sub',student_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',student_id,'role','authenticated','is_anonymous',false)::text,true);
  result:=public.request_borrowing(item_id,1,today,today,'Uji aktivasi pengembalian baik',request_key);
  loan_id:=(result->>'id')::uuid;
  result:=public.request_borrowing(item_id,1,today,today,'Uji aktivasi pengembalian baik',request_key);
  if (result->>'id')::uuid<>loan_id then raise exception 'REQUEST_RETRY_DUPLICATED'; end if;
  select stok into balance from public.items where id=item_id;
  if balance<>1 then raise exception 'PENDING_RESERVED_STOCK'; end if;
  begin
    perform public.process_borrowing(loan_id,'approved','',null,gen_random_uuid());
    raise exception 'STUDENT_APPROVAL_BYPASS';
  exception when sqlstate 'P0001' then
    if sqlerrm<>'FORBIDDEN' then raise; end if;
  end;

  perform set_config('request.jwt.claim.sub',other_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',other_id,'role','authenticated','is_anonymous',false)::text,true);
  select count(*) into count_rows from public.borrowings where id=loan_id;
  if count_rows<>0 then raise exception 'OWNER_ISOLATION_FAILED'; end if;

  perform set_config('request.jwt.claim.sub',admin_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',admin_id,'role','authenticated','is_anonymous',false)::text,true);
  perform public.process_borrowing(loan_id,'approved','',null,approval_key);
  perform public.process_borrowing(loan_id,'approved','',null,approval_key);
  perform public.process_borrowing(loan_id,'approved','',null,gen_random_uuid());
  select stok into balance from public.items where id=item_id;
  if balance<>0 then raise exception 'APPROVAL_STOCK_OR_RETRY_FAILED'; end if;

  perform set_config('request.jwt.claim.sub',student_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',student_id,'role','authenticated','is_anonymous',false)::text,true);
  begin
    perform public.request_borrowing(item_id,1,today,today,'Stok tidak cukup',gen_random_uuid());
    raise exception 'STOCK_OVERSOLD';
  exception when sqlstate 'P0001' then
    if sqlerrm<>'INSUFFICIENT_STOCK' then raise; end if;
  end;

  perform set_config('request.jwt.claim.sub',admin_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',admin_id,'role','authenticated','is_anonymous',false)::text,true);
  perform public.process_borrowing(loan_id,'returned','Baik',true,return_key);
  perform public.process_borrowing(loan_id,'returned','Baik',true,return_key);
  perform public.process_borrowing(loan_id,'returned','Baik',true,gen_random_uuid());
  select stok into balance from public.items where id=item_id;
  if balance<>1 then raise exception 'GOOD_RETURN_RETRY_FAILED'; end if;

  perform set_config('request.jwt.claim.sub',student_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',student_id,'role','authenticated','is_anonymous',false)::text,true);
  result:=public.request_borrowing(item_id,1,today,today,'Uji aktivasi penolakan',gen_random_uuid());
  rejected_id:=(result->>'id')::uuid;
  perform set_config('request.jwt.claim.sub',admin_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',admin_id,'role','authenticated','is_anonymous',false)::text,true);
  perform public.process_borrowing(rejected_id,'rejected','Ditolak untuk pengujian',null,gen_random_uuid());
  select stok into balance from public.items where id=item_id;
  if balance<>1 then raise exception 'REJECTION_CHANGED_STOCK'; end if;

  perform set_config('request.jwt.claim.sub',student_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',student_id,'role','authenticated','is_anonymous',false)::text,true);
  result:=public.request_borrowing(item_id,1,today,today,'Uji aktivasi pengembalian rusak',gen_random_uuid());
  damaged_id:=(result->>'id')::uuid;
  perform set_config('request.jwt.claim.sub',admin_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',admin_id,'role','authenticated','is_anonymous',false)::text,true);
  perform public.process_borrowing(damaged_id,'approved','',null,gen_random_uuid());
  perform public.process_borrowing(damaged_id,'returned','Rusak',false,gen_random_uuid());
  select stok,stok_rusak into balance,damaged from public.items where id=item_id;
  if balance<>0 or damaged<>1 then raise exception 'DAMAGED_RETURN_FAILED'; end if;
  select sum(quantity_delta),sum(damaged_delta) into ledger_balance,ledger_damaged from public.inventory_movements where public.inventory_movements.item_id=li_verify.item_id;
  if ledger_balance<>balance or ledger_damaged<>damaged then raise exception 'LEDGER_MISMATCH'; end if;

  execute format('set local role %I',original_role);
  if (select status from public.borrowings where id='8d5ea7fa-07b4-4da6-be0a-47699e06a928')<>'approved'
    or (select stok from public.items where id='0fe110a1-828f-4d1a-9106-e44107b944a3')<>1
    then raise exception 'ORIGINAL_DATA_CHANGED'; end if;
  perform set_config('lab_inventory.live_verification',jsonb_build_object(
    'pending_stock_unchanged',true,'request_retry_idempotent',true,'student_cannot_approve',true,
    'owner_isolation',true,'approval_retry_idempotent',true,'insufficient_stock_rejected',true,
    'good_return_retry_idempotent',true,'rejection_stock_unchanged',true,'damaged_return_ledger_correct',true,
    'rls_enabled',true,'anonymous_denied',true,'direct_writes_denied',true,'legacy_loan_preserved',true,
    'test_rows_rolled_back',true)::text,true);
end $li_verify$;
select current_setting('lab_inventory.live_verification')::jsonb as transaction_verification;
rollback;
