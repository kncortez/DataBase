-- ADMINISTRADOR

DECLARE @rol BIGINT = (SELECT RolIdRol FROM DeliveryBackOffice.dbo.CatRol WHERE RolName='ADMINISTRACION Y CIERRES EXC PORTAL WEB');

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
	RmsIdRol,
	RmsIdSystem,
	RmsIdModule,
	RmsRowStatus,
	RmsTokenCreated,
	RmsDateCreated
	)
	VALUES
	(
	@rol,									--RmsIdRol
	1,										--RmsIdSystem
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Cierre Operador'),		--RmsIdModule
	1,										--RmsRowStatus
	'SYS-ORODRIGUEZ',						--RmsTokenCreated
	GETDATE()								--RmsDateCreated
)

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
	RmsIdRol,
	RmsIdSystem,
	RmsIdModule,
	RmsRowStatus,
	RmsTokenCreated,
	RmsDateCreated
	)
	VALUES
	(
	@rol,									--RmsIdRol
	1,										--RmsIdSystem
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Cierre General'),		--RmsIdModule
	1,										--RmsRowStatus
	'SYS-ORODRIGUEZ',						--RmsTokenCreated
	GETDATE()								--RmsDateCreated
)

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
	RmsIdRol,
	RmsIdSystem,
	RmsIdModule,
	RmsRowStatus,
	RmsTokenCreated,
	RmsDateCreated
	)
	VALUES
	(
	@rol,									--RmsIdRol
	1,										--RmsIdSystem
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Reporte Operador'),	--RmsIdModule
	1,										--RmsRowStatus
	'SYS-ORODRIGUEZ',						--RmsTokenCreated
	GETDATE()								--RmsDateCreated
)

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
	RmsIdRol,
	RmsIdSystem,
	RmsIdModule,
	RmsRowStatus,
	RmsTokenCreated,
	RmsDateCreated
	)
	VALUES
	(
	@rol,									--RmsIdRol
	1,										--RmsIdSystem
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Reporte General'),		--RmsIdModule
	1,										--RmsRowStatus
	'SYS-ORODRIGUEZ',						--RmsTokenCreated
	GETDATE()								--RmsDateCreated
)


-- ENCARGADO

SET @rol = (SELECT RolIdRol FROM DeliveryBackOffice.dbo.CatRol WHERE RolName='ENCARGADO EXPRESS CENTER FD HERMES');

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
	RmsIdRol,
	RmsIdSystem,
	RmsIdModule,
	RmsRowStatus,
	RmsTokenCreated,
	RmsDateCreated
	)
	VALUES
	(
	@rol,									--RmsIdRol
	1,										--RmsIdSystem
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Cierre Operador'),		--RmsIdModule
	1,										--RmsRowStatus
	'SYS-ORODRIGUEZ',						--RmsTokenCreated
	GETDATE()								--RmsDateCreated
)

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
	RmsIdRol,
	RmsIdSystem,
	RmsIdModule,
	RmsRowStatus,
	RmsTokenCreated,
	RmsDateCreated
	)
	VALUES
	(
	@rol,									--RmsIdRol
	1,										--RmsIdSystem
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Reporte Operador'),	--RmsIdModule
	1,										--RmsRowStatus
	'SYS-ORODRIGUEZ',						--RmsTokenCreated
	GETDATE()								--RmsDateCreated
)