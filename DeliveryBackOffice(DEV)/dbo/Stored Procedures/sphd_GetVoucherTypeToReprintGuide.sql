-- =============================================
-- Author:		<Tito Garcia>
-- Created date: <2024-10-11>
-- Description:	<Valida si la guía ya tiene el comprobante de entrega digitalizado(escaneado)>
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date: <2024-11-13>
-- Description:	<Valida si la guía ya se encuentra en estado entregado o devuelto ref.: FDD-1416>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetVoucherTypeToReprintGuide] 
	@GuideSerie AS VARCHAR(2),
	@GuideNumber AS VARCHAR(50),
	@IdCountry AS VARCHAR(2)='GT'
AS
BEGIN	
	SET NOCOUNT ON;
	DECLARE @url VARCHAR(300) = '';

	BEGIN TRY

		SET @url = (Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(@GuideSerie + CAST(@GuideNumber AS VARCHAR)) as VARCHAR(300)));
		--SET @url = 'https://tracking.forzadelivery.com/DocImages/GT.DELIVERYZ12/Copia1/V291/17088433.jpg'; -- usar para pruebas
		 		 	
		SELECT CONCAT(DDO.Guide_Serie,DDO.Guide_Number) AS Guide
			, DDO.Guide_Serie
			, DDO.Guide_Number
			, IIF(@url IS NULL OR @url = '','Digital', 'Digitalizado') AS VoucherType
		FROM [dbo].[DeliveryOrder] DDO WITH (NOLOCK)
		WHERE DDO.Guide_Number IS NOT NULL
			AND DDO.Guide_Serie = @GuideSerie 
			AND DDO.Guide_Number = @GuideNumber 
			AND DDO.SenderCountryId = @IdCountry
			AND DDO.StatusOrderId IN (SELECT StatusOrderId FROM statusOrder WITH(NOLOCK) WHERE OrderDescription IN('Entregado','Devuelto')) 

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;
