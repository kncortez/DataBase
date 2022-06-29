-- RolByUserBySystem
-- Editar el parámetro RusIdRol por el valor generado en la tabla CatRol para el sistema Hermes Mobile
-- Editar el parámetro RusIdSystem por el valor generado en la tabla CatSystem para el sistema Hermes Mobile
-- Editar el parámetro RusIdUser por el valor generado en la tabla RegisteredUser para el usuario al cual se le asignarán los permisos de rol

INSERT INTO RolByUserBySystem(RusIdRol, RusIdSystem, RusIdUser, RusRowStatus, RusTokenCreated, RusDateCreated, StationId)
VALUES (25, 10, 28535, 1, 'SYS-ADMIN', SYSDATETIME(), 1); 