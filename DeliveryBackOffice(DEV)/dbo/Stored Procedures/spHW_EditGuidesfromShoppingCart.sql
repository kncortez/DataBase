-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-25>
-- Description:	<SP edición de guías desde carrito de compras>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_EditGuidesfromShoppingCart] 
@IdAccount INT,
@GuideSerie AS nvarchar(2),
@GuideNumber AS Int,
@NewInsuranceAmount AS Decimal(12,2),
@NewPriceShippment AS Decimal (14,2),
@NewCollect_OnDelivery AS Decimal(14,2),
@IdDeliveryFavCOD AS INT,
@revalue_guide AS BIT,
@Token AS NVARCHAR(50)



AS
BEGIN
	
	

	SET NOCOUNT ON;
	
	

		IF (EXISTS(SELECT TOP 1 1 FROM  [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH (NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber))
		BEGIN
     
	       BEGIN TRANSACTION
	       BEGIN TRY  

           IF (@NewInsuranceAmount>0)
		   
			   UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] 
				 SET InsuranceAmount = @NewInsuranceAmount
				 WHERE Guide_Serie = @GuideSerie AND 
					   Guide_Number = @GuideNumber
		 


		   IF (@NewPriceShippment>0)
			   UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] 
				 SET  PriceShippment = @NewPriceShippment
				 WHERE Guide_Serie = @GuideSerie AND 
					   Guide_Number = @GuideNumber

		   

		   IF (@NewCollect_OnDelivery>0)
			   UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] 
				 SET Collect_OnDelivery = @NewCollect_OnDelivery
				 WHERE Guide_Serie = @GuideSerie AND 
				   Guide_Number = @GuideNumber          
           
		   

		   IF (@IdDeliveryFavCOD>0)
		   BEGIN
				UPDATE [dbo].[DeliveryFavCOD] 
				SET IsDefault = 0
				WHERE IdAccountFavCOD = @IdAccount AND IsDefault=1
				
	

				UPDATE [dbo].[DeliveryFavCOD] 
				SET IsDefault = 1
				WHERE IdAccountFavCOD = @IdAccount AND IdDeliveryFavCOD = @IdDeliveryFavCOD
			END


		   
		   
		 
			


		  IF(@revalue_guide=1)
		   BEGIN
				EXEC [dbo].[spws_revalue_guide]
											@GuideSerie   = @GuideSerie
											,@GuideNumber = @GuideNumber
											,@CodeApp = ''
											,@Format =''
											,@CalculateTaxes = 'false' -- Dado a nuevas tarifas, no cálcular impuestos
											,@IdModule = 1
											,@SetUpdate = 'true' -- Actualizar registros
											,@Token = @Token
			END
			  COMMIT TRANSACTION
			SELECT Result= 1, Messg='Modificación Exitosa'

			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SELECT Result= 0, Messg='Modificación Fallo'

				SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
			END CATCH
			
		END 
		ELSE
		BEGIN
		 SELECT Result= 2, Messg='Guía no existe'
		END

 
	

	

  
END