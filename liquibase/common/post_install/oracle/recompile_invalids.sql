--liquibase formatted sql
--changeset jozsef.szollosi:${schema_name}_recompile_invalid_objects runAlways:true dbms:oracle endDelimiter:/ 
--comment Recompile invalid packages, functions, procedures, triggers...
declare
cursor c is
select 'ALTER ' || case when object_type = 'PACKAGE BODY' then 'PACKAGE' else object_type end || ' ' || object_name || ' COMPILE' stmt
  from user_objects
 where status = 'INVALID'
   and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER');
begin
   for i in c loop
      execute immediate i.stmt;
   end loop;
end;
/
