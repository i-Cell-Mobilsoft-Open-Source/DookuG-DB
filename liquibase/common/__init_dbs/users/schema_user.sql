--liquibase formatted sql

--changeset jozsef.holczer:${schema_name}-CREATE_USER dbms:oracle endDelimiter:/
--comment Creating user...

DECLARE
   l_schemaname VARCHAR2(30)  := UPPER('${schema_name}');
   l_passw      VARCHAR2(100) := '${schema_password}';
   l_sql        VARCHAR2(1000);
BEGIN
   EXECUTE IMMEDIATE 'alter session set "_oracle_script"=true';       
   
   BEGIN
      FOR r IN (SELECT 1 FROM dba_users WHERE UPPER(username) = UPPER('${schema_name}')) LOOP
         RETURN;
      END LOOP;

      l_sql := 'CREATE USER ' || l_schemaname || ' IDENTIFIED BY ' || l_passw || ' DEFAULT TABLESPACE TS_' || l_schemaname || ' TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON TS_'||l_schemaname;
      EXECUTE IMMEDIATE l_sql;
   END;

   l_sql := 'GRANT CREATE SESSION TO ' || l_schemaname; 
   EXECUTE IMMEDIATE l_sql;

   l_sql := 'GRANT CREATE TABLE TO ' || l_schemaname; 
   EXECUTE IMMEDIATE l_sql;

   l_sql := 'ALTER USER ' || l_schemaname || ' DEFAULT ROLE ALL'; 
   EXECUTE IMMEDIATE l_sql;
   
   l_sql := 'GRANT CREATE VIEW TO ' || l_schemaname; 
   EXECUTE IMMEDIATE l_sql;

END;
/
