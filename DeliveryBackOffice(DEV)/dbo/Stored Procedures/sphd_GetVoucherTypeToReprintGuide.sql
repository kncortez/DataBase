-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-10-11>
-- Description:	<Valida si la guía ya tiene el comprobante de entrega digitalizado(escaneado)>
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
		WHERE DDO.Guide_Serie = @GuideSerie 
			AND DDO.Guide_Number = @GuideNumber 
			AND ISNULL(DDO.SenderCountryId,'GT') = @IdCountry 

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;
