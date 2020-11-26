USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_settlement_guide_returned]    Script Date: 25/11/2020 14:13:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-25>
-- Description:	<Registrar transacción de liquidación (cobro) de guías en área de COD>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_COD]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY
			
			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET 
				GuideDischarged_TokenCreated = @Token, 
				GuideDischarged_DateCreated = GETDATE(), 
				Guide_Discharged = 1 -- guía liquidada en COD
			WHERE 
				Guide_Serie = @GuideSerie 
				AND Guide_Number = @GuideNumber 
				AND Guide_Settlement = 1 -- guía liquidada previamente en bodega

			SET @RModified = @@ROWCOUNT
						
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
END
GO


