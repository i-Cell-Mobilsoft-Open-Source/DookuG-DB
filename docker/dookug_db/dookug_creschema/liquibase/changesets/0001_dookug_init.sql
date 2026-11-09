--liquibase formatted sql
--changeset jozsef.holczer:DOOKUG0001 labels:00.01.00 dbms:postgresql
--comment: Postgresql - DOOKUG séma és kapcsolódó role-ok, jogosultságrendszer létrehozása

CREATE SCHEMA ${dookug_schema};

CREATE ROLE ${dookug_schema}_read;
CREATE ROLE ${dookug_schema}_write;
CREATE ROLE ${dookug_schema}_exec;

GRANT ${dookug_schema}_read TO ${dookug_schema}_write;
GRANT ${dookug_schema}_write TO ${dookug_schema}_exec;

GRANT USAGE ON SCHEMA ${dookug_schema} TO ${dookug_schema}_read;

CREATE ROLE ${dookug_schema} WITH LOGIN PASSWORD 'tmppwd';

GRANT USAGE, CREATE ON SCHEMA ${dookug_schema} TO ${dookug_schema};

CREATE ROLE ${dookug_schema}_service WITH LOGIN PASSWORD 'tmppwd';

GRANT ${dookug_schema}_exec TO ${dookug_schema}_service;


--changeset jozsef.holczer:DOOKUG0001 labels:00.01.00 dbms:oracle splitStatements:false stripComments:false
--comment: Oracle - dookug séma és kapcsolódó role-ok, jogosultságrendszer létrehozása

DECLARE

BEGIN
  EXECUTE IMMEDIATE 'CREATE ROLE ${dookug_schema}_read';
  EXECUTE IMMEDIATE 'CREATE ROLE ${dookug_schema}_write';
  EXECUTE IMMEDIATE 'CREATE ROLE ${dookug_schema}_exec';

  EXECUTE IMMEDIATE 'GRANT ${dookug_schema}_read TO ${dookug_schema}_write';
  EXECUTE IMMEDIATE 'GRANT ${dookug_schema}_write TO ${dookug_schema}_exec';

  EXECUTE IMMEDIATE 'CREATE USER ${dookug_schema} IDENTIFIED BY "tmppwd"';
  EXECUTE IMMEDIATE 'ALTER USER ${dookug_schema} DEFAULT TABLESPACE ${dookug_tablespace} TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON ${dookug_tablespace}';

  EXECUTE IMMEDIATE 'GRANT CONNECT TO ${dookug_schema}';
  EXECUTE IMMEDIATE 'GRANT RESOURCE TO ${dookug_schema}';
  EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO ${dookug_schema}';
  EXECUTE IMMEDIATE 'ALTER USER ${dookug_schema} DEFAULT ROLE ALL';

  EXECUTE IMMEDIATE 'CREATE USER ${dookug_schema}_service IDENTIFIED BY "tmppwd"';
  EXECUTE IMMEDIATE 'ALTER USER ${dookug_schema}_service DEFAULT TABLESPACE ${dookug_tablespace} TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON ${dookug_tablespace}';

  EXECUTE IMMEDIATE 'GRANT CONNECT TO ${dookug_schema}_service';
  EXECUTE IMMEDIATE 'GRANT ALTER SESSION TO ${dookug_schema}_service';
  EXECUTE IMMEDIATE 'GRANT ${dookug_schema}_exec TO ${dookug_schema}_service';
  EXECUTE IMMEDIATE 'ALTER USER ${dookug_schema}_service DEFAULT ROLE ALL';
END;
