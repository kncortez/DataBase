

-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-12-29>
-- Description:	<Reasigna una guía en despacho de entregas.>
-- =============================================

CREATE PROCEDURE [dbo].[ReAssingRoutePreparation]
    -- Add the parameters for the stored procedure here
	@IdRoute INT,
	@Date DATE,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@IdRoutePreparationOld INT,
	@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT = 0
	DECLARE @IdRoutePreparation INT = 0
	DECLARE @Id_Manifest INT = 0

	BEGIN TRANSACTION

		BEGIN TRY

			--- Verificar existencia de preparación de ruta y de despacho de entrega
			SELECT 
				@IdRoutePreparation = IdRoutePreparation,
				@Id_Manifest = COALESCE(DeliveryOrderBySettlementId,0)
			FROM RoutePreparation
			WHERE CatRouteId = @IdRoute AND DateRoutePreparation = @Date AND RowStatus = 1

			--- Verificar que no haya sido despachada
			IF @Id_Manifest = 0
			BEGIN

				--- Verificar si se debe generar nueva preparación o actualizar existente
				IF @IdRoutePreparation = 0
				BEGIN

					--- Ingresar nueva preparación de ruta por reasignación 
					INSERT INTO [dbo].[RoutePreparation]
						   ([CatRouteId]
						   ,[DateRoutePreparation]
						   ,[GuidesQuantity]
						   ,[PiecesDry]
						   ,[PiecesCold]
						   ,[RowStatus]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[TokenUpdated]
						   ,[DateUpdated])
					 SELECT
						   @IdRoute
						   ,@Date
						   ,1
						   ,0
						   ,0
						   ,1
						   ,@Token
						   ,GETDATE()
						   ,NULL
						   ,NULL
						FROM DeliveryOrder do
						WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

					SET @IdRoutePreparation = SCOPE_IDENTITY()

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1
				END
				ELSE
				BEGIN

					--- Actualizar la preparación de ruta existente
					UPDATE rp
						SET rp.GuidesQuantity = rp.GuidesQuantity+1
							,rp.TokenUpdated = @Token
							,rp.DateUpdated = GETDATE()
					FROM RoutePreparation rp
					JOIN DeliveryOrder do
						ON do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber
					WHERE rp.IdRoutePreparation = @IdRoutePreparation AND rp.RowStatus = 1

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1
					
				END

				--- Verificar la existencia de la preparación de ruta
				IF @IdRoutePreparation > 0
				BEGIN

					--- Ingresar guía a detalle de preparación de ruta
					INSERT INTO [dbo].[RoutePreparationDetail]
							([RoutePreparationId]
							,[Guide_Serie]
							,[Guide_Number]
							,[RowStatus]
							,[TokenCreated]
							,[DateCreated]
							,[TokenUpdated]
							,[DateUpdated])
					VALUES (@IdRoutePreparation, @GuideSerie, @GuideNumber, 1, @Token, GETDATE(), NULL, NULL)

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1

					--- Deshabilitar las piezas de la guía en otras preparaciones
					UPDATE RPDP
					SET RPDP.RowStatus = 0,
						RPDP.TokenUpdated = @Token,
						RPDP.DateUpdated = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP
						JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
							ON
							RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
							AND
							RPD.RowStatus = 1
						JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparation] RP
							ON 
							RPD.RoutePreparationId = RP.IdRoutePreparation
							AND
							RP.RowStatus = 1
					WHERE 
						RPDP.RowStatus = 1
						AND
						RPD.Guide_Serie = @GuideSerie 
						AND 
						RPD.Guide_Number = @GuideNumber
						AND 
						RP.IdRoutePreparation <> @IdRoutePreparation
						AND
						RP.DateRoutePreparation = @Date

					--- Deshabilitar guía del detalle en otras preparaciones
					UPDATE RPD
					SET RPD.RowStatus = 0,
						RPD.TokenUpdated = @Token,
						RPD.DateUpdated = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
						JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparation] RP
							ON 
							RPD.RoutePreparationId = RP.IdRoutePreparation
							AND
							RP.RowStatus = 1
					WHERE 
						RPD.RowStatus = 1
						AND
						RPD.Guide_Serie = @GuideSerie 
						AND 
						RPD.Guide_Number = @GuideNumber
						AND 
						RP.IdRoutePreparation <> @IdRoutePreparation
						AND
						RP.DateRoutePreparation = @Date
				END

				-- Deshabilitar piezas de vieja preparación
					UPDATE RPDP
					SET RPDP.RowStatus = 0,
						RPDP.TokenUpdated = @Token,
						RPDP.DateUpdated = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP
						JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
							ON
							RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
						JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparation] RP
							ON 
							RPD.RoutePreparationId = RP.IdRoutePreparation
					WHERE 
						RPD.Guide_Serie = @GuideSerie 
						AND 
						RPD.Guide_Number = @GuideNumber
						AND 
						RP.IdRoutePreparation = @IdRoutePreparationOld
						AND
						RP.DateRoutePreparation = @Date

				--- Actualziar el estado de las piezas de las guías por el reproceso
				UPDATE 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
				SET
					StatusOrderId = NULL --- Programado para entrega
				WHERE
					GuideSerie = @GuideSerie
					AND
					GuideNumber = @GuideNumber

				-- Deshabilitar guías de vieja preparación
				UPDATE rpd
				SET rpd.RowStatus = 0,
					rpd.TokenUpdated = @Token,
					rpd.DateUpdated = GETDATE()
				FROM  RoutePreparationDetail rpd
				JOIN RoutePreparation rp 
					ON rpd.RoutePreparationId = rp.IdRoutePreparation
				WHERE rpd.Guide_Serie = @GuideSerie AND rpd.Guide_Number = @GuideNumber
					AND rp.IdRoutePreparation = @IdRoutePreparationOld 

				--- Actualizar vieja preparación de ruta
				UPDATE rp
				SET
					rp.GuidesQuantity = rp.GuidesQuantity-1,
					rp.TokenUpdated = @Token,
					rp.DateUpdated = GETDATE()
				FROM RoutePreparation rp
				JOIN DeliveryOrder do
					ON do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber
				WHERE rp.IdRoutePreparation = @IdRoutePreparationOld
			END
		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN

			IF (@Id_Manifest > 0)
			BEGIN 
				SELECT			  
					0 AS 'StatusCode',
					'La ruta ya ha sido liquidada' AS 'Description', 
					0 AS 'NumTransferID'
				ROLLBACK TRANSACTION
			END
			ELSE 
			BEGIN
				IF (@RModified = 2)
				BEGIN
					SELECT			  
						1 AS 'StatusCode',
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
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END;
