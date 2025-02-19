-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <15/02/2025>
-- Description:	< Se obtiene la URL del comprobante de entrega escaneado de lo clientes corporativos que tienen configurado que desean comprobante impreso>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetDeliveryVoucherURL]
@GuideSerie NVARCHAR(2),
@GuideNumber INT

AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT 
            200 AS StatusCode,
            'Se obtiene URL de comprobante escaneado' AS Description,
            COALESCE(CAST(DeliveryBackOffice.dbo.fn_get_document_image_url(@GuideSerie + CAST(@GuideNumber AS VARCHAR(50))) AS VARCHAR(300)), '') AS URL
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do
        INNER JOIN [DeliveryBackOffice].[dbo].[Customer] c 
            ON do.IdCustomer = c.IdCustomer
        WHERE do.Guide_Serie = @GuideSerie
            AND do.Guide_Number = @GuideNumber
            AND c.IsVoucherRequired = 1
            AND c.RowSatus = 1;
        
        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 404 AS StatusCode, 
                   'No se encontró URL de comprobante escaneado' AS Description, 
                   '' AS URL;
        END       
    
    END TRY
    BEGIN CATCH    
        SELECT 
            500 AS StatusCode, 
            ERROR_MESSAGE() AS Description;
    END CATCH
END
