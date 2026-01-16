/* =================================================
   SP:        sps_settlement
   Propósito: Guarda información para generar manifiesto de liquidación
   Autor:     Carlos Cano
   Historia:  ---
   Fecha:     2020-11-24

=== CHANGELOG ============================

2025-12-23 | Historia/épica: FDAPI-4748   | Autor: Brandon Pedroza | Mejoras al guardar idstation

=========================================== */
CREATE PROCEDURE [dbo].[sps_settlement]
		@IdManifest INT,
		@GuideQuantity INT,
		@RouteReceived DATETIME,
		@Token NVARCHAR(50),
		@StationId INT = NULL
AS
BEGIN
	
	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT

	BEGIN TRANSACTION

		BEGIN TRY
			-- Obtener las guías que se actuaizará el ultimo estado en bitacora para actualizar el último estado de una guía asignada a un manifiesto
		;WITH LatestOrder AS (
			SELECT 
				[dod].[Guide_Serie],
				[dod].[Guide_Number],
				[dod].[StatusOrderId],
				ROW_NUMBER() OVER (PARTITION BY [dod].[Guide_Number] ORDER BY [dod].[DateCreated] DESC) AS rn
			FROM 
				[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] dod WITH(NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ds WITH(NOLOCK)
				ON dod.Guide_Serie = ds.Guide_Serie
					AND dod.Guide_Number = ds.Guide_Number
			WHERE [ds].[ID_DeliveryOrderBySettlement] = @IdManifest
		)
		UPDATE ds
		SET [ds].[StatusOrderId] = [lo].[StatusOrderId]
		FROM 
			[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ds WITH(NOLOCK)
		INNER JOIN [LatestOrder] lo 
			ON	[ds].[Guide_Serie] = [lo].[Guide_Serie] AND
				[ds].[Guide_Number] = [lo].[Guide_Number]
		WHERE 
			[lo].[rn] = 1
			AND [ds].[ID_DeliveryOrderBySettlement] = @IdManifest
			AND ds.StatusOrderId NOT IN (5,8,14,20);

			-- Actualizar registro en control de manifiestos de despacho
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]
			SET
				User_Received = @Token,
				Date_Received = GETDATE(),
				--Pieces_Dry_Received = @PiecesDryReceived,
				--Pieces_Cold_Received = @PiecesColdReceived,
				Guides_Received = @GuideQuantity,
				Route_Received = GETDATE(),
				SettlementStationId = @StationId
			WHERE ID = @IdManifest

			SET @RUpdated = @@ROWCOUNT

			IF EXISTS(SELECT 1 FROM [DeliveryBackOffice].[dbo].[RoutePreparation] WHERE DeliveryOrderBySettlementId = @IdManifest AND RowStatus = 1)
			BEGIN
				UPDATE
					[DeliveryBackOffice].[dbo].[RoutePreparation]
				SET
					RowStatus = 0
					,TokenUpdated = @Token
					,DateUpdated = GETDATE()
				WHERE
					DeliveryOrderBySettlementId = @IdManifest
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
			IF (@IdManifest > 0)
				SELECT			  
					@IdManifest AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END
