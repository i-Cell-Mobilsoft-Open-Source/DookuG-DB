-- Creates the dookug schema, users, and roles
-- Database: dookug_db
-- Must be run with the owner user of the dookug_db database
CREATE SCHEMA dookug;

CREATE ROLE dookug_read;
CREATE ROLE dookug_write;
CREATE ROLE dookug_exec;

GRANT dookug_read TO dookug_write;
GRANT dookug_write TO dookug_exec;

GRANT USAGE ON SCHEMA dookug TO dookug_read;

CREATE ROLE dookug WITH LOGIN PASSWORD '<dookug_password>';

GRANT USAGE, CREATE ON SCHEMA dookug TO dookug;

CREATE ROLE dookug_service WITH LOGIN PASSWORD '<dookug_service_password>';

GRANT dookug_exec TO dookug_service;
