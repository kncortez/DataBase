
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-19>
-- Description:	< reorganización de orden de servicios de RoutePreparation .>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-08-05>
-- Description:	< orden de guía como decimal.>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-08-05>
-- Description:	< Cambio para uso de orden como decimal y ETA de servicio .>
-- =============================================

CREATE PROCEDURE [dbo].[UpdateOrderOfRoutePreparation]
	@IdRoutePreparation INT,
	@GuidesToUpdate TblGuideOrderETA READONLY,
	@Token NVARCHAR(50)
AS
BEGIN
	--- Conteo para verificar cantidad correcta de validaciones
	DECLARE @RModified INT = 0
	
	--- Variables para despliegue de errores
	DECLARE @FatalError INT = 0;

	BEGIN TRANSACTION

		BEGIN TRY

			UPDATE RPD
			SET
				RPD.GuideOrder = IIF(GTU.Guide_Order IS NULL, RPD.GuideOrder, GTU.Guide_Order)
				,RPD.ETAGuide = IIF(GTU.Guide_ETA IS NULL, RPD.ETAGuide, GTU.Guide_ETA)
				,RPD.TokenUpdated = @Token
				,RPD.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
				JOIN
					@GuidesToUpdate GTU
					ON
						RPD.Guide_Serie = GTU.Guide_Serie
						AND
						RPD.Guide_Number = GTU.Guide_Number
			WHERE
				RPD.RowStatus = 1
				AND
				RPD.RoutePreparationId = @IdRoutePreparation

			SET @RModified = @RModified + 1

		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;
	--- END TRANSACTION

	IF (@@TRANCOUNT > 0)
	BEGIN
		IF (@FatalError > 0)
		BEGIN
			IF (@FatalError = 1)
			BEGIN
				SELECT			  
					0 AS 'StatusCode',
					'Error al obtener la información de la preparación de ruta' AS 'Description', 
					0 AS 'NumTransferID'
			END
			ROLLBACK TRANSACTION
		END
		ELSE IF (@RModified > 0)
		BEGIN
			SELECT			  
				200 AS 'StatusCode',
				'Registros guardados correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'
			COMMIT TRANSACTION;
		END
		ELSE
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				'Registros no guardados' AS 'Description', 
				0 AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END
	END
	ELSE
	BEGIN
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END
END;
