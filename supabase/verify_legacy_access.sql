-- Read-only checks for a legacy database after the access guard. Requires an
-- operator session and at least one borrowing plus a different Auth user.
begin read only;
do $$
declare owner_id uuid; other_id uuid; expected_loans bigint; expected_items bigint; visible bigint; original_role text := current_user;
begin
  select user_id into owner_id from public.borrowings limit 1;
  select id into other_id from auth.users where id<>owner_id limit 1;
  if owner_id is null or other_id is null then raise exception 'Missing test identities'; end if;
  select count(*) into expected_loans from public.borrowings where user_id=owner_id;
  select count(*) into expected_items from public.items;
  execute 'set local role authenticated';
  perform set_config('request.jwt.claim.sub',owner_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',owner_id,'role','authenticated','is_anonymous',false)::text,true);
  select count(*) into visible from public.borrowings;
  if visible<>expected_loans then raise exception 'Owner read failed'; end if;
  select count(*) into visible from public.items;
  if visible<>expected_items then raise exception 'Authenticated inventory read failed'; end if;
  perform set_config('request.jwt.claim.sub',other_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',other_id,'role','authenticated','is_anonymous',false)::text,true);
  select count(*) into visible from public.borrowings where user_id=owner_id;
  if visible<>0 then raise exception 'Cross-account isolation failed'; end if;
  perform set_config('request.jwt.claim.sub',owner_id::text,true);
  perform set_config('request.jwt.claims',jsonb_build_object('sub',owner_id,'role','authenticated','is_anonymous',true)::text,true);
  select count(*) into visible from public.items;
  if visible<>0 then raise exception 'Anonymous-auth inventory isolation failed'; end if;
  select count(*) into visible from public.borrowings;
  if visible<>0 then raise exception 'Anonymous-auth borrowing isolation failed'; end if;
  execute format('set local role %I',original_role);
end $$;
rollback;
