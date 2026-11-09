--liquibase formatted sql
--changeset tibor.ivan:proc_grant_object_privileges labels:00.01.00 runAlways:true runOnChange:true stripcomments:false dbms:postgresql endDelimiter:/
--comment proc_grant_object_privileges procedure: A standard object - role privileges assignment
CREATE OR REPLACE PROCEDURE proc_grant_object_privileges()
------------------------------------------------
-- 00.01.00   tibor.ivan        Initial version
------------------------------------------------
    LANGUAGE plpgsql
AS $procedure$
DECLARE
    l_current_schema        text;
    i                       RECORD;
BEGIN
    l_current_schema := current_schema;

    -- Táblák
    FOR i IN SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = l_current_schema AND tablename NOT IN ('databasechangelog', 'databasechangeloglock')
    LOOP

        EXECUTE 'GRANT SELECT ON TABLE ' || quote_ident(i.tablename) || ' TO ' || quote_ident(l_current_schema || '_read');

        IF (NOT i.tablename LIKE '%$hist') THEN
            EXECUTE 'GRANT INSERT, UPDATE, DELETE ON TABLE ' || quote_ident(i.tablename) || ' TO ' || quote_ident(l_current_schema || '_write');
        END IF;

    END LOOP;

END;
$procedure$
;
/

--changeset jozsef.holczer:grant_object_privileges runAlways:true runOnChange:true dbms:oracle endDelimiter:/
--comment proc_grant_object_privileges procedure: A standard object - role privileges assignment
CREATE OR REPLACE PROCEDURE proc_grant_object_privileges
IS
    l_current_schema VARCHAR2(128) := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
    CURSOR c IS
        SELECT table_name
          FROM all_tables
         WHERE owner = l_current_schema
           AND table_name NOT IN ('DATABASECHANGELOG', 'DATABASECHANGELOGLOCK')
           AND table_name NOT LIKE 'BIN$%';
    CURSOR c2 IS
        SELECT DISTINCT object_name
          FROM all_procedures
         WHERE owner = l_current_schema
           AND object_name NOT LIKE 'BIN$%'
           and object_type in ('PROCEDURE','FUNCTION','PACKAGE','TYPE');
    CURSOR c3 IS
        SELECT view_name
          FROM all_views
         WHERE owner = l_current_schema
           AND view_name NOT LIKE 'BIN$%';
    PROCEDURE grant_to(p_table_name   VARCHAR2,
                       p_priv         VARCHAR2,
                       p_user_or_role VARCHAR2) IS
        l_sqlerrm varchar2(1000);
        l_stmt varchar2(300);
    BEGIN
        EXECUTE IMMEDIATE 'grant ' || p_priv || ' on ' || p_table_name || ' to ' || p_user_or_role;
    END;

    PROCEDURE grant_read(p_table_name VARCHAR2) IS
    BEGIN
        grant_to(p_table_name, 'SELECT', l_current_schema || '_READ');
    END;

    PROCEDURE grant_write(p_table_name VARCHAR2) IS
    BEGIN
        grant_to(p_table_name, 'INSERT,UPDATE,DELETE', l_current_schema || '_WRITE');
    END;

    PROCEDURE grant_exec(p_object_name VARCHAR2) IS
    BEGIN
        grant_to(p_object_name, 'EXECUTE', l_current_schema || '_EXEC');
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
