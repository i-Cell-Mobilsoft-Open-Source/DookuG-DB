--liquibase formatted sql
--changeset tibor.ivan:CRE0003 labels:00.01.00 runOnChange:true dbms:postgresql
--comment: Service user jelszó beállítás

ALTER ROLE ${dookug_schema}_service WITH PASSWORD '${dookug_service_password}';

--changeset tibor.ivan:CRE0003 labels:00.01.00 runOnChange:true dbms:oracle
--comment: Service user jelszó beállítás
ALTER USER ${dookug_schema}_service IDENTIFIED BY ${dookug_service_password};
