-- READ ONLY. Run as the project operator in the Supabase SQL Editor.
-- Save results privately; they describe the existing schema, policies and RPCs.
select table_name, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public' and table_name in ('profiles', 'items', 'borrowings')
order by table_name, ordinal_position;

select schemaname, tablename, policyname, roles, cmd, qual, with_check
from pg_policies where schemaname = 'public'
  and tablename in ('profiles', 'items', 'borrowings');

select n.nspname, c.relname, c.relrowsecurity, c.relacl
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relname in ('profiles', 'items', 'borrowings');

select c.relname, a.attname, a.attacl
from pg_attribute a join pg_class c on c.oid = a.attrelid
where a.attrelid in (to_regclass('public.profiles'), to_regclass('public.items'), to_regclass('public.borrowings'))
  and a.attnum > 0 and not a.attisdropped and a.attacl is not null;

select t.tgname, t.tgrelid::regclass as target, pg_get_triggerdef(t.oid) as definition
from pg_trigger t where not t.tgisinternal
  and t.tgrelid in (to_regclass('public.items'), to_regclass('public.borrowings'), to_regclass('auth.users'));

select n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as arguments,
  p.prosecdef, p.proacl, p.proconfig
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and not exists
  (select 1 from pg_depend d where d.objid = p.oid and d.classid = 'pg_proc'::regclass and d.deptype = 'e');

-- For an existing items/borrowings schema, also run the stock reconciliation
-- queries in docs/TAHAP_1_DAN_2.md and compare against the physical inventory.
