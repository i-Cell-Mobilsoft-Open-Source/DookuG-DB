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


--changeset tibor.ivan:DOOKUG0001 labels:00.01.00 dbms:oracle 
--comment: Oracle - dookug schema and related roles, permissions setup

CREATE ROLE ${dookug_schema}_read;
CREATE ROLE ${dookug_schema}_write;
CREATE ROLE ${dookug_schema}_exec;

GRANT ${dookug_schema}_read TO ${dookug_schema}_write;
GRANT ${dookug_schema}_write TO ${dookug_schema}_exec;

CREATE USER ${dookug_schema} IDENTIFIED BY "tmppwd";
ALTER USER ${dookug_schema} DEFAULT TABLESPACE ${dookug_tablespace} TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON ${dookug_tablespace};

GRANT CONNECT TO ${dookug_schema};
GRANT RESOURCE TO ${dookug_schema};
GRANT CREATE VIEW TO ${dookug_schema};
ALTER USER ${dookug_schema} DEFAULT ROLE ALL;

CREATE USER ${dookug_schema}_service IDENTIFIED BY "tmppwd";
ALTER USER ${dookug_schema}_service DEFAULT TABLESPACE ${dookug_tablespace} TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON ${dookug_tablespace};

GRANT CONNECT TO ${dookug_schema}_service;
GRANT ALTER SESSION TO ${dookug_schema}_service;
GRANT ${dookug_schema}_exec TO ${dookug_schema}_service;
ALTER USER ${dookug_schema}_service DEFAULT ROLE ALL;
