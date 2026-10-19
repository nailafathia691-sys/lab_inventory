-- Read-only verification for the confirmed live project/accounts.
begin read only;
do $verify$
declare actor uuid; original_role text:=current_user; report jsonb:='[]'::jsonb; profile jsonb; items bigint; loans bigint;
begin
  foreach actor in array array['58247a30-e35b-4ea6-99cf-6c1d3d96bc43'::uuid,'5dccf229-91ad-4771-b93e-1d2d9dbff89d'::uuid,'36f32dae-3f6b-4b27-aac3-1df206b5df77'::uuid] loop
    execute 'set local role authenticated';
    perform set_config('request.jwt.claim.sub',actor::text,true);
    perform set_config('request.jwt.claims',jsonb_build_object('sub',actor,'role','authenticated','is_anonymous',false)::text,true);
    select jsonb_build_object('role',role,'active',is_active,'transactions_enabled',transactions_enabled) into profile from public.profiles where id=actor;
    if profile is null then raise exception 'PROFILE_NOT_READABLE'; end if;
    select count(*) into items from public.items;
    select count(*) into loans from public.borrowings;
    if items<>4 then raise exception 'INVENTORY_NOT_READABLE'; end if;
    if actor='58247a30-e35b-4ea6-99cf-6c1d3d96bc43'::uuid and (profile->>'role'<>'admin' or loans<>1) then raise exception 'ADMIN_READ_FAILED'; end if;
    if actor='5dccf229-91ad-4771-b93e-1d2d9dbff89d'::uuid and (profile->>'role'<>'student' or loans<>1) then raise exception 'STUDENT_READ_FAILED'; end if;
    if actor='36f32dae-3f6b-4b27-aac3-1df206b5df77'::uuid and loans<>0 then raise exception 'OWNER_ISOLATION_FAILED'; end if;
    if has_table_privilege('authenticated','public.profiles','UPDATE') or has_table_privilege('authenticated','public.items','UPDATE') or has_table_privilege('anon','public.profiles','SELECT') then raise exception 'UNSAFE_GRANT'; end if;
    report:=report||jsonb_build_array(jsonb_build_object('actor',actor,'profile',profile,'items_visible',items,'loans_visible',loans));
    execute format('set local role %I',original_role);
  end loop;
  perform set_config('lab_inventory.verified_login',report::text,true);
end $verify$;
select current_setting('lab_inventory.verified_login')::jsonb as verified_login_access;
rollback;
