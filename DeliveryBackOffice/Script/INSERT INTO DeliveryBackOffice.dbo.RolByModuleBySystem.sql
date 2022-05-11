DECLARE @rol BIGINT = (SELECT RolIdRol FROM DeliveryBackOffice.dbo.CatRol WHERE RolName='Concesionario');

--RmsIdSystem numero 1 es Portal Web

BEGIN TRANSACTION

BEGIN TRY

DECLARE @modules TABLE (
		idModule INT
	)

INSERT INTO @modules
(idModule)
SELECT cm.ModIdModule FROM 
DeliveryBackOffice.dbo.CatModule cm WHERE cm.ModName 
IN(
'Login',
'Mi perfil',
'Mis Envíos',
'Crear Guías',
'Rastreo',
'Mis Datos',
'Cartera Clientes',
'Cierres',
'Reportes',
'Servicios',
'Recepción',
'Entrega',
'Devolución',
'Traslados'
)
AND cm.ModRowStatus=1 AND cm.ModVisible=1

INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem 
(
RmsIdRol,
RmsIdSystem,
RmsIdModule,
RmsRowStatus,
RmsTokenCreated,
RmsDateCreated
)
SELECT 
@rol, --RmsIdRol,
1, --RmsIdSystem,
mdl.idModule, --RmsIdModule,
1, --RmsRowStatus,
'SYS-MESPINOZA', --RmsTokenCreated,
GETDATE() --RmsDateCreated
FROM @modules mdl

END TRY

BEGIN CATCH

SELECT 'Error al Configurar Modulos' AS message,
				'FALSE'	blnResult,
				CAST(-1 AS VARCHAR(5)) IdResult,
				CAST(500 AS VARCHAR(5)) StatusResult,
				CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
				CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
				CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
				CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
				CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
				CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage;

ROLLBACK TRANSACTION;

END CATCH

IF @@TRANCOUNT > 0 BEGIN

COMMIT TRANSACTION;

---- Script para confirmar los modulos que tiene asignado el rol
SELECT cm.ModName, RmsIdModule, cm.ModPath FROM DeliveryBackOffice.dbo.RolByModuleBySystem 
JOIN DeliveryBackOffice.dbo.CatModule cm ON cm.ModIdModule=RmsIdModule 
WHERE RmsIdRol=@rol AND RmsRowStatus=1

END


