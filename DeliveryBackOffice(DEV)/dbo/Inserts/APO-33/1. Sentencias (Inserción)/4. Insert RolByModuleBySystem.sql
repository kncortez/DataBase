-- RolByModuleBySystem
-- Editar el parámetro RmsIdRol por el valor generado en la tabla CatRol para el sistema Hermes Mobile
-- Editar el parámetro RmsIdSystem por el valor generado en la tabla CatSystem para el sistema Hermes Mobile
-- Editar el parámetro RmsIdModule por el valor generado en la tabla CatModule para los distintos módulos del sistema Hermes Mobile

INSERT INTO RolByModuleBySystem(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated)
VALUES(25, 10, 66, 1, 'SYS-ADMIN',SYSDATETIME());

INSERT INTO RolByModuleBySystem(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated)
VALUES(25, 10, 67, 1, 'SYS-ADMIN',SYSDATETIME());