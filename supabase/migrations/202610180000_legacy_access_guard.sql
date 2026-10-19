-- Temporary access boundary for legacy databases awaiting stock reconciliation.
-- Does not change inventory balances, borrowing statuses, or account roles.
-- Safe to repeat BEFORE the full secure-inventory migration. When that migration
-- is already installed, this guard deliberately does nothing.
begin;
do $$
declare t text; policy record; cols text;
begin
  if to_regclass('public.profiles') is not null
    or to_regprocedure('public.process_borrowing(uuid,text,text,boolean,uuid)') is not null then
    return;
  end if;
  foreach t in array array['items', 'borrowings'] loop
    if to_regclass('public.' || t) is null then continue; end if;
    execute format('alter table public.%I enable row level security', t);
    for policy in select policyname from pg_policies where schemaname='public' and tablename=t loop
      execute format('drop policy %I on public.%I', policy.policyname, t);
    end loop;
    execute format('revoke all privileges on table public.%I from public, anon, authenticated', t);
    select string_agg(quote_ident(column_name), ',') into cols from information_schema.columns
      where table_schema='public' and table_name=t;
    execute format('revoke all privileges (%s) on table public.%I from public, anon, authenticated', cols, t);
    execute format('grant select on table public.%I to authenticated', t);
    if t='items' then
      execute 'create policy lab_legacy_item_read on public.items for select to authenticated
        using ((select auth.uid()) is not null
          and not coalesce(((select auth.jwt())->>''is_anonymous'')::boolean, false))';
    else
      execute 'create policy lab_legacy_borrowing_read on public.borrowings for select to authenticated
        using (user_id=(select auth.uid())
          and not coalesce(((select auth.jwt())->>''is_anonymous'')::boolean, false))';
    end if;
  end loop;
end $$;
notify pgrst, 'reload schema';
commit;
