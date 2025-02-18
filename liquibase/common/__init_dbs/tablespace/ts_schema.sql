--liquibase formatted sql

--changeset jozsef.holczer:${schema_name}-CREATE_TABLESPACE dbms:oracle endDelimiter:$
--comment Creating Table Space...
declare
   l_datafile_dir varchar2(300);
   l_sql          varchar2(1000);
   l_ts_name      VARCHAR2(50) := UPPER('ts_${schema_name}');
begin
   BEGIN
      FOR r IN (SELECT 1 FROM dba_data_files WHERE UPPER(tablespace_name) = UPPER('ts_${schema_name}') ) LOOP
         RETURN;
      END LOOP;

      select nvl (substr (file_name, 1, instr (file_name, '\', -1)), 
               substr (file_name, 1, instr (file_name, '/', -1))) 
               datafile_dir
        into l_datafile_dir
        from dba_data_files 
       where tablespace_name = 'SYSTEM';

      l_sql := 'CREATE TABLESPACE ' || UPPER(''||l_ts_name||'') || ' DATAFILE ''' || l_datafile_dir || '/' || l_ts_name || '.dbf'' SIZE 100M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE 1024M';
      execute immediate l_sql;
   END;
end;
$
