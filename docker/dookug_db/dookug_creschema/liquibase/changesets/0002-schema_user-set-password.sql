--liquibase formatted sql
--changeset tibor.ivan:CRE0002 labels:00.01.00 runOnChange:true dbms:postgresql
--comment: Schema user jelszó beállítás

ALTER ROLE ${dookug_schema} WITH PASSWORD '${dookug_password}';

--changeset tibor.ivan:CRE0002 labels:00.01.00 runOnChange:true dbms:oracle
--comment: Schema user jelszó beállítás
ALTER USER ${dookug_schema} IDENTIFIED BY ${dookug_password};
