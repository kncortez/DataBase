



-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2020-11-22>
-- Description:	<Registrar transacción de liquidación para material devuelto>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_returned_Delivery]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Token NVARCHAR(50),
		@IdManifest INT,
		@Subtipe int,
		@NoPiece int
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Amount DECIMAL (14,2)

	BEGIN TRANSACTION

		BEGIN TRY
			
			SET @Amount = (SELECT Collect_OnDelivery 
							FROM DeliveryBackOffice.dbo.DeliveryOrder 
							WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)
			
			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET 
				Settlement_Collect_OnDelivery = @Amount, 
				SettlementCollect_TokenCreated = @Token, 
				SettlementCollect_DateCreated = GETDATE(), 
				Guide_Settlement = 1, -- guía liquidada en bodega
				Guide_Returned = 1,  -- guía liquidada vía material devuelto
				Guide_Delivered = 0,  -- guía liquidada vía comprobante de entrega
				StatusOrderId = 8
			WHERE 
				Guide_Serie = @GuideSerie 
				AND Guide_Number = @GuideNumber 
				AND ID_DeliveryOrderBySettlement = @IdManifest

			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[SettlementByPickupDetail]
			SET 
				TokenUpdated = @Token, 
				DateUpdated = GETDATE(), 
				IsReturn = 1 -- guía retornada en bodega
				from DeliveryBackOffice.dbo.SettlementByPickup stp
				inner join DeliveryBackOffice.dbo.SettlementByPickupDetail spd on stp.Id = spd.SettlementByPickupId
				where stp.SequenceCode = @IdManifest and stp.SubTypeServiceManagmentId = @Subtipe and 
				spd.GuideNumber = @GuideNumber and spd.GuideSerie = @GuideSerie and spd.NoPiece = @NoPiece 

			SET @RModified = @@ROWCOUNT

			-- registrar checkpoint histórico de devolución
			INSERT INTO [dbo].[DeliveryOrderDetail]
			   ([Guide_Serie]
			   ,[Guide_Number]
			   ,[StatusOrderId]
			   ,[UserCreated]
			   ,[DateCreated]
			   ,[DateCreatedInSystem]
			   ,[Observations]
			   ,[Temperature_Celsius]
			   ,[PieceId])
			 VALUES
				   (@GuideSerie
				   ,@GuideNumber
				   ,8 -- retornado a Forza
				   ,@Token
				   ,GETDATE()
				   ,GETDATE()
				   ,NULL
				   ,NULL
				   ,@NoPiece)


			UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
				SET StatusOrderId = 8 --retornado a Forza 			
			WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber	and NoPiece = @NoPiece

			-- registrar último checkpoint de devolución
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder 
				SET StatusOrderId = 8 
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
			
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) + '-'  + CONVERT(nvarchar,@NoPiece)  AS 'Guide',
				@Amount AS 'Amount',
				0 AS 'SubStatusCode'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) + '-' + CONVERT(nvarchar,@NoPiece) AS 'Guide',
					@Amount AS 'Amount',
					0 AS 'SubStatusCode'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) + '-'  + CONVERT(nvarchar,@NoPiece) AS 'Guide',
					@Amount AS 'Amount',
					0 AS 'SubStatusCode'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) + '-'  + CONVERT(nvarchar,@NoPiece) AS 'Guide',
				@Amount AS 'Amount',
				0 AS 'SubStatusCode'
END