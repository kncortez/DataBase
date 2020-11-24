USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_settlement_guide_returned]    Script Date: 22/11/2020 14:36:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-22>
-- Description:	<Registrar transacción de liquidación para material devuelto>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_returned]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Token NVARCHAR(50),
		@IdManifest INT
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Amount DECIMAL (14,2)

	BEGIN TRANSACTION

		BEGIN TRY
			
			SET @Amount = (SELECT Collect_OnDelivery FROM DeliveryBackOffice.dbo.DeliveryOrder WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET 
				Settlement_Collect_OnDelivery = @Amount, 
				SettlementCollect_TokenCreated = @Token, 
				SettlementCollect_DateCreated = GETDATE(), 
				Guide_Settlement = 1, -- guía liquidada en bodega
				Guide_Returned = 1,  -- guía liquidada vía comprobante de entrega
				Guide_Delivered = 0,  -- guía liquidada vía comprobante de entrega
				Guide_Discharged = 1 -- guía liquidad en COD (inactivar esta opción cuando se cree el segundo formulario)
			WHERE 
				Guide_Serie = @GuideSerie 
				AND Guide_Number = @GuideNumber 
				AND ID_DeliveryOrderBySettlement = @IdManifest

			SET @RModified = @@ROWCOUNT

			-- registrar checkpoint de devolución
			INSERT INTO [dbo].[DeliveryOrderDetail]
			   ([Guide_Serie]
			   ,[Guide_Number]
			   ,[StatusOrderId]
			   ,[UserCreated]
			   ,[DateCreated]
			   ,[DateCreatedInSystem]
			   ,[Observations]
			   ,[Temperature_Celsius])
			 VALUES
				   (@GuideSerie
				   ,@GuideNumber
				   ,8 -- retornado a Forza
				   ,@Token
				   ,GETDATE()
				   ,GETDATE()
				   ,NULL
				   ,NULL)
			
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount'
END
GO


