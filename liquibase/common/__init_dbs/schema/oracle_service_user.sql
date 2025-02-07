--liquibase formatted sql

--changeset jozsef.holczer:${schema_name}-CREATE_SERVICE_USER dbms:oracle endDelimiter:/
--comment Creating Service User...

DECLARE
   l_schemaname VARCHAR2(30)  := UPPER('${schema_name}');
   l_passw      VARCHAR2(100) := '${schema_password}';
   l_sql        VARCHAR2(1000);
BEGIN
   EXECUTE IMMEDIATE 'alter session set "_oracle_script"=true';       
   
   BEGIN
      FOR r IN (SELECT 1 FROM dba_users WHERE UPPER(username) = UPPER('${schema_name}_service')) LOOP
         RETURN;
      END LOOP;

      l_sql := 'CREATE USER ' || l_schemaname || '_SERVICE IDENTIFIED BY ' || l_passw || ' DEFAULT TABLESPACE TS_' || l_schemaname || ' TEMPORARY TABLESPACE TEMP';
      EXECUTE IMMEDIATE l_sql;
   END;

   l_sql := 'GRANT ALTER SESSION TO ' || l_schemaname || '_SERVICE'; 
   EXECUTE IMMEDIATE l_sql;
   
   l_sql := 'GRANT ' || l_schemaname || '_EXEC TO ' || l_schemaname || '_SERVICE'; 
   EXECUTE IMMEDIATE l_sql;
   
   l_sql := 'ALTER USER ' || l_schemaname || '_SERVICE DEFAULT ROLE ALL'; 
   EXECUTE IMMEDIATE l_sql;

END;
/
