-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-25>
-- Description:	<SP edición de guías desde carrito de compras>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_EditGuidesfromShoppingCart] 
@GuideSerie AS nvarchar(2),
@GuideNumber AS Int,
@NewInsuranceAmount AS Decimal(12,2) = NULL,
@NewCollect_OnDelivery AS Decimal(14,2) = NULL,
@IdDeliveryFavCOD AS INT = NULL,
@Token AS NVARCHAR(50),
@GuideUsedMembership BIT = 0
AS
BEGIN
	
	DECLARE @TCCPaymendId INT = (SELECT TOP 1 TOIOOM.tio_pk_id FROM [DeliveryBackOffice].[dbo].[ctgTypeOfInOutOfMoney] TOIOOM WITH(NOLOCK) WHERE TOIOOM.tio_pk_name = 'pago con tarjeta' );
	DECLARE @IsTCCPaid BIT = 0;

	SET NOCOUNT ON;
	
	IF (EXISTS(SELECT TOP 1 1 FROM  [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH (NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber))
	BEGIN
     
		BEGIN TRANSACTION
		BEGIN TRY  

			SET @IsTCCPaid = ISNULL( (SELECT TOP 1 (CASE WHEN DOPD.TypeofInOutMoneyId = @TCCPaymendId THEN 1 ELSE 0 END) FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH(NOLOCK) WHERE DOPD.GuideSerie = @GuideSerie AND DOPD.GuideNumber = @GuideNumber) ,0)

			IF (ISNULL(@NewInsuranceAmount,0)>0)
			BEGIN
				UPDATE 
					[DeliveryBackOffice].[dbo].[DeliveryOrder] 
				SET 
					InsuranceAmount = @NewInsuranceAmount
					,IsInsuarance = 1
				WHERE 
					Guide_Serie = @GuideSerie 
					AND Guide_Number = @GuideNumber
			END
			ELSE IF (@NewInsuranceAmount IS NOT NULL AND @NewInsuranceAmount = 0)
			BEGIN
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] 
				SET InsuranceAmount = 0
				,IsInsuarance = 0
				WHERE Guide_Serie = @GuideSerie AND 
				Guide_Number = @GuideNumber
			END
		 
			IF (ISNULL(@NewCollect_OnDelivery,0)>0)
			BEGIN
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] 
				SET Collect_OnDelivery = @NewCollect_OnDelivery
				WHERE Guide_Serie = @GuideSerie AND 
				Guide_Number = @GuideNumber          
			END
		   
			IF (ISNULL(@IdDeliveryFavCOD,0)>0)
			BEGIN
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] 
				SET DCBA_ID = @IdDeliveryFavCOD
				WHERE Guide_Serie = @GuideSerie AND 
				Guide_Number = @GuideNumber  
			END

			EXEC [dbo].[spws_revalue_guide]
				@GuideSerie   = @GuideSerie
				,@GuideNumber = @GuideNumber
				,@CodeApp = ''
				,@Format =''
				,@CalculateTaxes = 'false' -- Dado a nuevas tarifas, no cálcular impuestos
				,@IdModule = 1
				,@SetUpdate = 'true' -- Actualizar registros
				,@Token = @Token
				,@ParIsCreditCard = @IsTCCPaid
				,@UseMembership = @GuideUsedMembership

			COMMIT TRANSACTION
				SELECT 
					Result= 1
					,Messg='Modificación Exitosa'

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION;

			SELECT 
				Result= 0
				,Messg='Modificación Fallo'

		END CATCH
			
	END 
	ELSE
	BEGIN
		SELECT 
			Result = 2
			,Messg ='Guía no existe'
	END
END