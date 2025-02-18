--liquibase formatted sql

---------------------------------------------------------------------------------------------------
--changeset bertalan.pasztor:${schema_name}_ADD_PRIVILEGES_TO_ALL_TABLES runOnChange:true dbms:postgresql endDelimiter:/
--comment Creating add_privileges_to_all_tables procedure...
---------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS ${schema_name}.add_privileges_to_all_tables(text);

CREATE OR REPLACE PROCEDURE ${schema_name}.add_privileges_to_all_tables(IN p_table_schema text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  rec RECORD;
BEGIN

  FOR rec IN SELECT schemaname, tablename FROM pg_catalog.pg_tables WHERE schemaname = p_table_schema AND tablename NOT LIKE '%hist'
  LOOP
    call add_privileges_to_table(rec.schemaname, rec.tablename);
  END LOOP;

  FOR rec IN SELECT schemaname, tablename FROM pg_catalog.pg_tables WHERE schemaname = p_table_schema AND tablename LIKE '%hist'
  LOOP
	  EXECUTE 'GRANT SELECT ON TABLE '||rec.tablename||' TO '||rec.schemaname||'_sel';
  END LOOP;

END;
$procedure$
;

/

-- Permissions
ALTER PROCEDURE ${schema_name}.add_privileges_to_all_tables(text) OWNER TO ${dba_user_name};

GRANT EXECUTE ON PROCEDURE ${schema_name}.add_privileges_to_all_tables(text) TO ${schema_name}_exec;

