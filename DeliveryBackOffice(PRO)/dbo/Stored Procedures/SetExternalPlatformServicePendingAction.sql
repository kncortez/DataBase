

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-17>
-- Description:	< Permite ingresar a la bitácora de acciones pendientes un registro para procesar >
-- =============================================
CREATE PROCEDURE [dbo].[SetExternalPlatformServicePendingAction]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@ExternalPlatform AS INT,
	@PendingAction AS INT,
	@Token AS NVARCHAR(50)
AS
BEGIN
	
	DECLARE @PendingActionExists BIT = 0;

	IF(@PendingAction = 1) -- SERVICIOS POR INGRESAR
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			SET @PendingActionExists = ISNULL((
				SELECT 
					TOP 1
						1
				FROM
					[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL
				WHERE
					EPSPAL.GuideSerie = @GuideSerie
					AND
					EPSPAL.GuideNumber = @GuideNumber
					AND
					EPSPAL.RowStatus = 1
					AND
					EPSPAL.IsPendingInsert = 1
					AND
					CAST(EPSPAL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			),0)

			IF(@PendingActionExists = 0)
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog]
				(ExternalPlatformId, GuideSerie, GuideNumber, IsPendingInsert, RowStatus, TokenCreated, DateCreated)
				VALUES
				(@ExternalPlatform, @GuideSerie, @GuideNumber, 1, 1, @Token, GETDATE())

				IF(@@TRANCOUNT > 0)
					COMMIT TRANSACTION
				SELECT
					1 [blnResult],
					'Dato de inserción ingresado exitosamente' AS [Description],
					CONCAT(@GuideSerie, @GuideNumber) AS [Guide]
			END
			ELSE
			BEGIN
				SELECT
					0 [blnResult],
					0 AS [ErrorNumber],
					0 AS [ErrorSeverity],
					0 AS [ErrorState],
					0 AS [ErrorProcedure],
					0 AS [ErrorLine],
					'Acción ya fue ingresada y sigue pendiente' AS [ErrorMessage];
				ROLLBACK TRANSACTION
			END
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

			SET @PendingActionExists = ISNULL((
				SELECT 
					TOP 1
						1
				FROM
					[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL
				WHERE
					EPSPAL.GuideSerie = @GuideSerie
					AND
					EPSPAL.GuideNumber = @GuideNumber
					AND
					EPSPAL.RowStatus = 1
					AND
					EPSPAL.IsPendingUpdate = 1
					AND
					CAST(EPSPAL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			),0)

			IF(@PendingActionExists = 0)
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog]
				(ExternalPlatformId, GuideSerie, GuideNumber, IsPendingUpdate, RowStatus, TokenCreated, DateCreated)
				VALUES
				(@ExternalPlatform, @GuideSerie, @GuideNumber, 1, 1, @Token, GETDATE())

				IF(@@TRANCOUNT > 0)
					COMMIT TRANSACTION
				SELECT
					1 [blnResult],
					'Dato de actualización ingresado exitosamente' AS [Description],
					CONCAT(@GuideSerie, @GuideNumber) AS [Guide]
			END
			ELSE
			BEGIN
				SELECT
					0 [blnResult],
					0 AS [ErrorNumber],
					0 AS [ErrorSeverity],
					0 AS [ErrorState],
					0 AS [ErrorProcedure],
					0 AS [ErrorLine],
					'Acción ya fue ingresada y sigue pendiente' AS [ErrorMessage];
				ROLLBACK TRANSACTION
			END
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

			SET @PendingActionExists = ISNULL((
				SELECT 
					TOP 1
						1
				FROM
					[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL
				WHERE
					EPSPAL.GuideSerie = @GuideSerie
					AND
					EPSPAL.GuideNumber = @GuideNumber
					AND
					EPSPAL.RowStatus = 1
					AND
					EPSPAL.IsPendingDelete = 1
					AND
					CAST(EPSPAL.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			),0)

			IF(@PendingActionExists = 0)
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog]
				(ExternalPlatformId, GuideSerie, GuideNumber, IsPendingDelete, RowStatus, TokenCreated, DateCreated)
				VALUES
				(@ExternalPlatform, @GuideSerie, @GuideNumber, 1, 1, @Token, GETDATE())

				IF(@@TRANCOUNT > 0)
					COMMIT TRANSACTION
				SELECT
					1 [blnResult],
					'Dato de inserción ingresado exitosamente' AS [Description],
					CONCAT(@GuideSerie, @GuideNumber) AS [Guide]
			END
			ELSE
			BEGIN
				SELECT
					0 [blnResult],
					0 AS [ErrorNumber],
					0 AS [ErrorSeverity],
					0 AS [ErrorState],
					0 AS [ErrorProcedure],
					0 AS [ErrorLine],
					'Acción ya fue ingresada y sigue pendiente' AS [ErrorMessage];
				ROLLBACK TRANSACTION
			END
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
	END
END