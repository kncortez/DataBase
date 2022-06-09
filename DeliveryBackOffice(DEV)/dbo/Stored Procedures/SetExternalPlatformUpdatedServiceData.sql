
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-07>
-- Description:	< Liberación de bitácora de guías siendo procesadas para traslado a plataformas externas >
-- =============================================
CREATE PROCEDURE [dbo].[SetExternalPlatformUpdatedServiceData]
	@TblSimplirouteVisits AS TblGuides READONLY,
	@ExternalPlatform AS INT,
	@ServiceInputType AS INT,
	@UserToken AS NVARCHAR(50)
AS
BEGIN
	IF(@ExternalPlatform = 2) -- SIMPLIROUTE
	BEGIN
		IF(@ServiceInputType = 1) -- VISITAS GENERADAS EXITOSAMENTE
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE EPSL
				SET EPSL.RowStatus = 0, EPSL.TokenUpdated = 'SYS-HERMESROUTES', EPSL.DateUpdated = GETDATE()
				FROM [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL
				JOIN @TblSimplirouteVisits TSV
				ON EPSL.GuideSerie = TSV.Guide_Serie
				AND EPSL.GuideNumber = TSV.Guide_Number
			END TRY
			BEGIN CATCH
				SELECT
					0 AS 'StatusCode',
					ERROR_MESSAGE() AS 'Description';
				ROLLBACK TRANSACTION;
			END CATCH
		END
	END
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
		SELECT
			1 AS 'StatusCode',
			'Registros guardados correctamente' AS 'Description';
	END
END
