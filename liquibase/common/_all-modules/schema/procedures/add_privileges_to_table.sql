--liquibase formatted sql

---------------------------------------------------------------------------------------------------
--changeset bertalan.pasztor:${schema_name}_ADD_PRIVILEGES_TO_TABLE runOnChange:true dbms:postgresql endDelimiter:/
--comment Creating add_privileges_to_table procedure...
---------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS ${schema_name}.add_privileges_to_table(text, text);

CREATE OR REPLACE PROCEDURE ${schema_name}.add_privileges_to_table(IN p_table_schema text, IN p_table_name text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

  EXECUTE 'GRANT SELECT ON TABLE '||p_table_name||' TO '||p_table_schema||'_sel';
  EXECUTE 'GRANT INSERT, UPDATE ON TABLE '||p_table_name||' TO '||p_table_schema||'_mod';
  EXECUTE 'GRANT DELETE, TRUNCATE ON TABLE '||p_table_name||' TO '||p_table_schema||'_del';
  EXECUTE 'ALTER TABLE '||p_table_name||' REPLICA IDENTITY FULL';

END;
$procedure$
;

/

-- Permissions

ALTER PROCEDURE ${schema_name}.add_privileges_to_table(text, text) OWNER TO ${dba_user_name};

GRANT EXECUTE ON PROCEDURE ${schema_name}.add_privileges_to_table(text, text) TO ${schema_name}_exec;

