--liquibase formatted sql
--changeset jozsef.szollosi:${schema_name}_grant_object_privileges runAlways:true runOnChange:true dbms:oracle endDelimiter:/ 
--comment Assigning grants to roles of the current schema...
DECLARE
   CURSOR c IS
      SELECT table_name
        FROM user_tables
       WHERE table_name NOT IN ('DATABASECHANGELOG', 'DATABASECHANGELOGLOCK')
         AND table_name NOT LIKE 'BIN$%';
   CURSOR c2 IS
      SELECT DISTINCT object_name
        FROM user_procedures
       WHERE object_name NOT LIKE 'BIN$%'
         and object_type in ('PROCEDURE','FUNCTION','PACKAGE','TYPE');
   CURSOR c3 IS
      SELECT view_name
        FROM user_views
       WHERE view_name NOT LIKE 'BIN$%';
   PROCEDURE grant_to(p_table_name   VARCHAR2,
                      p_priv         VARCHAR2,
                      p_user_or_role VARCHAR2) IS
      l_sqlerrm varchar2(1000);
      l_stmt varchar2(300);
   BEGIN
      EXECUTE IMMEDIATE 'grant ' || p_priv || ' on ' || p_table_name || ' to ' || p_user_or_role;
--   EXCEPTION WHEN OTHERS THEN -- Don't want to break the install
--      l_sqlerrm := substr(sqlerrm,1,700);
--      logger.error(p_log_text => l_stmt || ' => ' || l_sqlerrm, p_procedure_name => 'GRANT', p_package_name => 'GRANT');
   END;
   PROCEDURE grant_read(p_table_name VARCHAR2) IS
   BEGIN
      grant_to(p_table_name, 'SELECT', USER || '_READ');
   END;
   PROCEDURE grant_write(p_table_name VARCHAR2) IS
   BEGIN
      grant_to(p_table_name, 'INSERT,UPDATE,DELETE', USER || '_WRITE');
   END;
   PROCEDURE grant_exec(p_object_name VARCHAR2) IS
   BEGIN
      grant_to(p_object_name, 'EXECUTE', USER || '_EXEC');
   END;
BEGIN
   FOR i IN c LOOP
      grant_read(i.table_name);
      grant_write(i.table_name);
   END LOOP;
   FOR i IN c2 LOOP
      grant_exec(i.object_name);
   END LOOP;
   FOR i IN c3 LOOP
      grant_read(i.view_name);
   END LOOP;
END;
/
