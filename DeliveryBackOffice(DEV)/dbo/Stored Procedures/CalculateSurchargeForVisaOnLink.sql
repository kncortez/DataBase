-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-24>
-- Description:	<Cálcula y guarda los montos de los recargos por pago en VisaOnLink>
-- =============================================
CREATE PROCEDURE [dbo].[CalculateSurchargeForVisaOnLink]
	-- Add the parameters for the stored procedure here
	@TblGuides TblGuides READONLY,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	BEGIN TRY

		--Validar que sean del mismo cliente
		IF ( SELECT
				COUNT(1)
			FROM (SELECT
					IdCustomer
				FROM DeliveryOrder do WITH (NOLOCK)
				INNER JOIN @TblGuides tg
					ON tg.Guide_Serie = do.Guide_Serie 
					AND tg.Guide_Number = do.Guide_Number
				GROUP BY do.IdCustomer) sub)
		= 1
		BEGIN
			
			--Deshabilitar registros anteriores
			UPDATE dos
			SET RowStatus = 0
			   ,DateUpdated = GETDATE()
			   ,TokenUpdated = @Token
			FROM DeliveryOrderSurcharge dos
			INNER JOIN @TblGuides tg
				ON tg.Guide_Serie = dos.GuideSerie
				AND tg.Guide_Number = dos.GuideNumber

			--Cálcular e insertar en tabla
			INSERT INTO DeliveryOrderSurcharge ([GuideSerie]
			, [GuideNumber]
			, [GuideOriginalPriceShipment]
			, [GuideOriginalCollectOnDelivery]
			, [TotalSurcharge]
			, [InternalSurchargeAmount]
			, [ExternalSurchargeAmount]
			, [GuideSurchargedShipment]
			, [GuideSurchargedCollectOnDelivery]
			, [GuidePaymentLink]
			, [RowStatus]
			, [DateCreated]
			, [TokenCreated]
			, [DateUpdated]
			, [TokenUpdated])
				SELECT
					tg.Guide_Serie
				   ,tg.Guide_Number
				   ,do.PriceShippment
				   ,do.Collect_OnDelivery
				   ,ROUND((do.PriceShippment + ISNULL(do.Collect_OnDelivery,0)) * 0.05,2)
				   ,ROUND(ROUND((do.PriceShippment + ISNULL(do.Collect_OnDelivery,0)) * 0.05,2) - ROUND((do.PriceShippment + ISNULL(do.Collect_OnDelivery,0)) * 0.025,2),2)
				   ,ROUND((do.PriceShippment + ISNULL(do.Collect_OnDelivery,0)) * 0.025,2)
				   ,ROUND(do.PriceShippment * 1.05,2)
				   ,ROUND(ISNULL(do.Collect_OnDelivery,0) * 1.05,2)
				   ,NULL
				   ,1
				   ,GETDATE()
				   ,@Token
				   ,NULL
				   ,NULL
				FROM @TblGuides tg
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = tg.Guide_Serie
						AND do.Guide_Number = tg.Guide_Number
			SELECT
			1 'ResponseCode'
			,'Cálculo exitoso' 'Description'

			SELECT dos.GuideSerie
				,dos.GuideNumber
				,dos.GuideSurchargedShipment
				,dos.GuideSurchargedCollectOnDelivery
				,dos.TotalSurcharge
			FROM DeliveryOrderSurcharge dos
			INNER JOIN @TblGuides tg
				ON tg.Guide_Serie = dos.GuideSerie
				AND tg.Guide_Number = dos.GuideNumber
			WHERE dos.RowStatus = 1

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION
		END
		ELSE 
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
				2 'ResponseCode'
			   ,'Las guías no pertenecen al mismo cliente' 'Description'
		END

		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SELECT
			0 'ResponseCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';

		
	END CATCH
	
END