-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-05>
-- Description:	<Se agrega parametro para filtrar por pais de origen de guia asociada>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_Linehauls]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Token NVARCHAR(50),
		@IdManifest INT,
		@Subtipe int,
		@NoPiece int,
		@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Amount DECIMAL (14,2)

	BEGIN TRANSACTION

		BEGIN TRY
			
			SET @Amount = (SELECT Collect_OnDelivery FROM DeliveryBackOffice.dbo.DeliveryOrder WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
							AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry)

			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[SettlementByPickupDetail]
			SET 
				TokenUpdated = @Token, 
				DateUpdated = GETDATE(), 
				IsPieceLiquidaded = 1 -- guía liquidada de ingreso a bodega
				from DeliveryBackOffice.dbo.SettlementByPickup stp
				inner join DeliveryBackOffice.dbo.SettlementByPickupDetail spd on stp.Id = spd.SettlementByPickupId
				inner join DeliveryBackOffice.dbo.DeliveryOrder dro on spd.GuideSerie = dro.Guide_Serie and spd.GuideNumber = dro.Guide_Number
				where stp.SequenceCode = @IdManifest and stp.SubTypeServiceManagmentId = @Subtipe and 
				spd.GuideNumber = @GuideNumber and spd.GuideSerie = @GuideSerie and spd.NoPiece = @NoPiece 
				AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry

			SET @RModified = @@ROWCOUNT
			
			-- registrar checkpoint histórico de ingreso a bodega HUB
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
				   ,11 -- retornado a Forza
				   ,@Token
				   ,GETDATE()
				   ,GETDATE()
				   ,NULL
				   ,NULL
				   ,@NoPiece)


				   		UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
				SET StatusOrderId = 11 --retornado a Forza 	
				FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DRO
				ON DOP.GuideSerie = DRO.Guide_Serie AND DOP.GuideNumber = DRO.Guide_Number
				WHERE DOP.GuideSerie = @GuideSerie AND DOP.GuideNumber = @GuideNumber	and DOP.NoPiece = @NoPiece
				AND IIF(DRO.SenderCountryId IS NULL, 'GT',DRO.SenderCountryId)=@IdCountry


			-- registrar último checkpoint de devolución
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder SET StatusOrderId = 11 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
					AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry
			
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




