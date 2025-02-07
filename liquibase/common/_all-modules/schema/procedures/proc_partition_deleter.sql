--liquibase formatted sql

---------------------------------------------------------------------------------------------------
--changeset bertalan.pasztor:${schema_name}-PROC_PARTITION_DELETER_PROCEDURE dbms:postgresql runOnChange:true endDelimiter:/
--comment Creating proc_partition_deleter procedure...
---------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS public.proc_partition_deleter(text, text);
DROP PROCEDURE IF EXISTS public.proc_partition_deleter(text);

CREATE OR REPLACE PROCEDURE public.proc_partition_deleter(IN _SCHNAME text) 
LANGUAGE 'plpgsql' AS 
$BODY$
DECLARE

TABLEPARTREC RECORD;
TABLEPARTNAME TEXT;

BEGIN
TABLEPARTNAME := '%_p2%';

FOR TABLEPARTREC IN
    (SELECT TABLENAME
	FROM PG_TABLES
	WHERE TABLENAME LIKE(TABLEPARTNAME)
	    AND SCHEMANAME = $1
	    AND TRIM(TABLENAME) NOT IN
		(SELECT BT.RELNAME
		    FROM PG_CLASS CT
		    JOIN PG_NAMESPACE CNS ON CT.RELNAMESPACE = CNS.OID
			AND CNS.NSPNAME = $1
		    JOIN PG_INHERITS I ON I.INHPARENT = CT.OID
		    JOIN PG_CLASS BT ON I.INHRELID = BT.OID
		    JOIN PG_NAMESPACE BNS ON BT.RELNAMESPACE = BNS.OID
		) 
    ) 
    LOOP
		EXECUTE 'DROP TABLE '|| $1 || '.' || tablepartrec.tablename || ' ';
    END LOOP;	
	
END;
$BODY$;
/