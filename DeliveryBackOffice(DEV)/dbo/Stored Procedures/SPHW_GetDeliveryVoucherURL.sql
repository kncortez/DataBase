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
		DECLARE @IsVoucherRequired INT;
		DECLARE @URL VARCHAR(300);

		SELECT @IsVoucherRequired = c.IsVoucherRequired
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH(NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[Customer] c WITH(NOLOCK)
            ON do.IdCustomer = c.IdCustomer
        WHERE do.Guide_Serie = @GuideSerie
            AND do.Guide_Number = @GuideNumber
            AND c.RowSatus = 1;

		
		IF @IsVoucherRequired = 1
		BEGIN
			SET @URL = COALESCE(CAST(DeliveryBackOffice.dbo.fn_get_document_image_url(@GuideSerie + CAST(@GuideNumber AS VARCHAR(50))) AS VARCHAR(300)), '');

			IF @URL IS NULL OR @URL = ''
			BEGIN
				SELECT 404 AS StatusCode, 
						'No se encontro URL de comprobante escaneado' AS Description, 
						'' AS URL;
			END
			ELSE
			BEGIN
				SELECT 200 AS StatusCode,
					'Se obtiene URL de comprobante escaneado' AS Description,
					 @URL AS URL
			END   
		END
		ELSE
		BEGIN
			SELECT 404 AS StatusCode,
					'El cliente no tiene configurado la impresion de los comprobantes de entrega' AS Description,
					@URL AS URL
		END   
    
    END TRY
    BEGIN CATCH    
        SELECT 
            500 AS StatusCode, 
            ERROR_MESSAGE() AS Description;
    END CATCH
END
