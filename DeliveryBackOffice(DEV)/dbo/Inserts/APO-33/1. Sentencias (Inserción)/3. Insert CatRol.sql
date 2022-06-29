-- CatRol - Registro de rol para sistema Hermes Mobile
-- Editar el parámetro RolIdSystem por el valor generado en la tabla CatSystem para el sistema Hermes Mobile
INSERT INTO CatRol(RolIdSystem, RolName, RolDescription, RolAdminBrothers, RolAdminClient, RolRowStatus, RolTokenCreated, RolDateCreated)
VALUES (10, 'Admin Hermes Mobile', 'Admin Hermes Mobile', 0, 0, 1, 'SYS-ADMIN', SYSDATETIME());
