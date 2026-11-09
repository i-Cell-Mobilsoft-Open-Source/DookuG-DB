--liquibase formatted sql
--changeset tibor.ivan:grant_object_privileges runOnChange:true runAlways:true 
--comment Jogosultságok kiosztása az adott sémához tartozó role-oknak

CALL proc_grant_object_privileges();