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

		SET @url = (Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(@GuideSerie + CAST(@GuideNumber AS VARCHAR(50))) as VARCHAR(300)));
		 		 	
		SELECT CONCAT(DDO.Guide_Serie,DDO.Guide_Number) AS Guide
			, DDO.Guide_Serie
			, DDO.Guide_Number
			, IIF(@url IS NULL OR @url = '','Digital', 'Digitalizado') AS VoucherType
			,   CASE 
				   WHEN DDO.StatusOrderId = 5 THEN 'Entregado'
				   WHEN DDO.StatusOrderId = 14 THEN 'Devuelto'
				   ELSE 'Otro Estado'
			   	END AS StatusOrderId
		FROM [dbo].[DeliveryOrder] DDO WITH (NOLOCK)
		WHERE DDO.Guide_Serie = @GuideSerie 
			AND DDO.Guide_Number = @GuideNumber 
			AND DDO.SenderCountryId = @IdCountry

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;
