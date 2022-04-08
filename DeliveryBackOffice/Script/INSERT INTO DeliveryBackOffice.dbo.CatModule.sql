BEGIN TRANSACTION
BEGIN TRY
INSERT INTO DeliveryBackOffice.dbo.CatModule
(
ModName,
ModIdModuleParent,
ModPath,
ModDescription,
ModOrder,
ModMetadata,
ModVisible,
ModRowStatus,
ModTokenCreated,
ModDateCreated
)
VALUES
(
'Manifiestos',              --ModName,
NULL,                         --ModIdModuleParent,
'/manifiestos',             --ModPath,
'Manifiestos Corporativos', --ModDescription,
17,                           --ModOrder,
'file.png',                   --ModMetadata,
1,                            --ModVisible, 
1,                            --ModRowStatus,
'SYS-MESPINOZA',              --ModTokenCreated,
GETDATE()                     --ModDateCreated
)

DECLARE @IdParent AS BIGINT =  SCOPE_IDENTITY();

INSERT INTO DeliveryBackOffice.dbo.CatModule
(
ModName,
ModIdModuleParent,
ModPath,
ModDescription,
ModOrder,
ModMetadata,
ModVisible,
ModRowStatus,
ModTokenCreated,
ModDateCreated
)
VALUES
(
'Resumen',              --ModName,
@IdParent,                         --ModIdModuleParent,
'/resumen-manifiestos',             --ModPath,
'Resumen manifiestos corporativos', --ModDescription,
1,                           --ModOrder,
'file.png',                   --ModMetadata,
1,                            --ModVisible, 
1,                            --ModRowStatus,
'SYS-MESPINOZA',              --ModTokenCreated,
GETDATE()                     --ModDateCreated
),
(
'Generar',              --ModName,
@IdParent,                         --ModIdModuleParent,
'/generar-manifiestos',             --ModPath,
'generacion manifiestos corporativos', --ModDescription,
2,                           --ModOrder,
'file.png',                   --ModMetadata,
1,                            --ModVisible, 
1,                            --ModRowStatus,
'SYS-MESPINOZA',              --ModTokenCreated,
GETDATE()                     --ModDateCreated
)

END TRY
BEGIN CATCH
SELECT 'Error al Crear Modulos' AS message,
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

SELECT *
FROM DeliveryBackOffice.dbo.CatModule;

END
