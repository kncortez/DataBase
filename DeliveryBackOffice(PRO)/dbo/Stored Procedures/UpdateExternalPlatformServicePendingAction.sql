

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-17>
-- Description:	< Permite actualziar la bitácora de acciones pendientes bajo un listado de guías ya procesadas bajo su accion correspondiente >
-- =============================================
CREATE PROCEDURE [dbo].[UpdateExternalPlatformServicePendingAction]
	@Guides TblGuides READONLY,
	@ExternalPlatform AS INT,
	@PendingAction AS INT,
	@Token AS NVARCHAR(50)
AS
BEGIN
	
	IF(@PendingAction = 1) -- SERVICIOS POR INGRESAR
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			UPDATE
				EPSPAL
			SET
				EPSPAL.RowStatus = 0,
				EPSPAL.TokenUpdated = @Token,
				EPSPAL.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL
				JOIN
					@Guides 
					ON
						EPSPAL.GuideSerie = EPSPAL.GuideSerie
						AND
						EPSPAL.GuideNumber = EPSPAL.GuideNumber
						AND
						EPSPAL.IsPendingInsert = 1
						AND
						CAST(EPSPAL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
						
			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SELECT
				0 [blnResult],
				@@ROWCOUNT [UpdatedRegistries],
				'Registros actualizados correctamente' [Description]

			
		END TRY
		BEGIN CATCH
			 SELECT 
				0 [blnResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage];

			ROLLBACK TRANSACTION
		END CATCH
	END
	ELSE IF (@PendingAction = 2 ) -- SERVICIOS POR ACTUALIZAR
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			UPDATE
				EPSPAL
			SET
				EPSPAL.RowStatus = 0,
				EPSPAL.TokenUpdated = @Token,
				EPSPAL.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL
				JOIN
					@Guides 
					ON
						EPSPAL.GuideSerie = EPSPAL.GuideSerie
						AND
						EPSPAL.GuideNumber = EPSPAL.GuideNumber
						AND
						EPSPAL.IsPendingUpdate = 1
						AND
						CAST(EPSPAL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SELECT
				0 [blnResult],
				@@ROWCOUNT [UpdatedRegistries],
				'Registros actualizados correctamente' [Description]

		END TRY
		BEGIN CATCH
			 SELECT 
				0 [blnResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage];

			ROLLBACK TRANSACTION
		END CATCH
	END
	ELSE IF (@PendingAction = 3) -- SERVICIOS POR ELIMINAR
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			UPDATE
				EPSPAL
			SET
				EPSPAL.RowStatus = 0,
				EPSPAL.TokenUpdated = @Token,
				EPSPAL.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL
				JOIN
					@Guides 
					ON
						EPSPAL.GuideSerie = EPSPAL.GuideSerie
						AND
						EPSPAL.GuideNumber = EPSPAL.GuideNumber
						AND
						EPSPAL.IsPendingDelete = 1
						AND
						CAST(EPSPAL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SELECT
				0 [blnResult],
				@@ROWCOUNT [UpdatedRegistries],
				'Registros actualizados correctamente' [Description]

		END TRY
		BEGIN CATCH
			 SELECT 
				0 [blnResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage];

			ROLLBACK TRANSACTION
		END CATCH
	END
	ELSE -- ACCIÓN NO PERMITIDA
	BEGIN
		SELECT
			0 [blnResult],
			0 AS [ErrorNumber],
			0 AS [ErrorSeverity],
			0 AS [ErrorState],
			0 AS [ErrorProcedure],
			0 AS [ErrorLine],
			'Acción no existente para servicio' AS [ErrorMessage];
		ROLLBACK TRANSACTION
	END
END
