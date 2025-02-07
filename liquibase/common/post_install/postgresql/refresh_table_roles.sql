--liquibase formatted sql

--===============================================================================================--
-- SQL ==
---------------------------------------------------------------------------------------------------
--changeset endre.balazs:${schema_name}_REFRESH_TABLE_ROLES runAlways:true dbms:postgresql runOnChange:true
--comment Refreshing the table level privileges at the end of schema modification...
---------------------------------------------------------------------------------------------------
SET search_path = ${schema_name};

call add_privileges_to_all_tables('${schema_name}');

COMMIT;


