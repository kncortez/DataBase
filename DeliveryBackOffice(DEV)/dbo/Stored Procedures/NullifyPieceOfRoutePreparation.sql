
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-19>
-- Description:	< Extracción de pieza de RoutePreparation .>
-- =============================================

CREATE PROCEDURE [dbo].[NullifyPieceOfRoutePreparation]
	@IdRoutePreparation INT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Token NVARCHAR(50)
AS
BEGIN
	--- Conteo para verificar cantidad correcta de validaciones
	DECLARE @RModified INT = 0

	--- Variables para manejo de preparación de ruta
	DECLARE @IdRoutePreparationDetail INT;
	
	--- Variables para manejo de piezas
	DECLARE @GuidePieceExists BIT;

	--- Variables para despliegue de errores
	DECLARE @FatalError INT = 0;

	BEGIN TRANSACTION

		BEGIN TRY

			SELECT
				@IdRoutePreparationDetail = RPD.IdRoutePreparationDetail
			FROM
				[DeliveryBackOffice].[dbo].[RoutePreparation] RP
				JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
					ON
						RP.IdRoutePreparation = RPD.RoutePreparationId
						AND
						RPD.RowStatus = 1
			WHERE
				RPD.Guide_Serie = @GuideSerie
				AND
				RPD.Guide_Number = @GuideNumber
				AND
				RP.IdRoutePreparation = @IdRoutePreparation
				AND
				RP.RowStatus = 1

			--- Verificar si se obtuvo el detalle referente a la guía de la preparación de ruta
			IF(@IdRoutePreparationDetail > 0)
			BEGIN
				
				--- Anular todas las piezas ya registradas de la preparación de ruta
				UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
				SET
					RowStatus = 0
					,TokenUpdated = @Token
					,DateUpdated = GETDATE()
				WHERE
					RoutePreparationDetailId = @IdRoutePreparationDetail
					
				IF COALESCE(@@ROWCOUNT,0) > 0
					SET @RModified = @RModified + 1

				--- Actualizar el detalle de la preparación de ruta
				UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
				SET
					RowStatus = 0
					,TokenUpdated = @Token
					,DateUpdated = GETDATE()
				WHERE
					IdRoutePreparationDetail = @IdRoutePreparationDetail
					
				IF COALESCE(@@ROWCOUNT,0) > 0
					SET @RModified = @RModified + 1
			END
			ELSE
			BEGIN

				--- No se pudo recuperar el detalle de la preparación de ruta correspondiente a la guía a extraer
				SET @FatalError = 1;
			END

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
