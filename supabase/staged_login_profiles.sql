-- Restore server roles/read access while physical legacy stock is unresolved.
-- Apply manually after the legacy access guard, before the full migration.
-- Does not change inventory balances/statuses or enable transaction RPCs.
begin;

do $$
begin
  if to_regprocedure('public.process_borrowing(uuid,text,text,boolean,uuid)') is not null then
    raise exception 'FULL_SCHEMA_ALREADY_INSTALLED: do not apply the staged login bridge';
  end if;
end $$;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete restrict,
  nama text not null,
  npm text not null default '',
  role text not null default 'student' check (role in ('student','admin')),
  is_active boolean not null default true,
  transactions_enabled boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

insert into public.profiles(id,nama,npm,role)
select u.id, coalesce(nullif(left(trim(u.raw_user_meta_data->>'nama'),100),''),
  nullif(left(split_part(u.email,'@',1),100),''),'Pengguna'),
  left(coalesce(u.raw_user_meta_data->>'npm',''),30), 'student'
from auth.users u where u.email is not null
on conflict(id) do nothing;

-- User-supplied signup metadata never sets roles. The operator assigns a
-- verified admin separately; rerunning this script preserves existing roles.
create or replace function private.is_active_user() returns boolean
language sql stable security definer set search_path = '' as $$
  select not coalesce((auth.jwt()->>'is_anonymous')::boolean,false)
    and exists(select 1 from public.profiles where id=auth.uid() and is_active);
$$;
create or replace function private.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select not coalesce((auth.jwt()->>'is_anonymous')::boolean,false)
    and exists(select 1 from public.profiles where id=auth.uid() and is_active and role='admin');
$$;
revoke all on function private.is_active_user(),private.is_admin() from public,anon,authenticated;
grant execute on function private.is_active_user(),private.is_admin() to authenticated;

do $$
declare t text; p record; cols text;
begin
  foreach t in array array['profiles','items','borrowings'] loop
    execute format('alter table public.%I enable row level security',t);
    for p in select policyname from pg_policies where schemaname='public' and tablename=t loop
      execute format('drop policy %I on public.%I',p.policyname,t);
    end loop;
    execute format('revoke all privileges on table public.%I from public,anon,authenticated',t);
    select string_agg(quote_ident(column_name),',') into cols from information_schema.columns
      where table_schema='public' and table_name=t;
    execute format('revoke all privileges (%s) on table public.%I from public,anon,authenticated',cols,t);
    execute format('grant select on table public.%I to authenticated',t);
  end loop;
end $$;

create policy lab_profile_read on public.profiles for select to authenticated
  using ((id=(select auth.uid()) and (select private.is_active_user())) or (select private.is_admin()));
create policy lab_item_read on public.items for select to authenticated
  using ((select private.is_active_user()));
create policy lab_borrowing_read on public.borrowings for select to authenticated
  using ((select private.is_active_user()) and (user_id=(select auth.uid()) or (select private.is_admin())));

-- No auth trigger here: signup UI is not enabled during the staged rollout.
-- New accounts need operator backfill until the full migration is applied.
notify pgrst,'reload schema';
commit;
