-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-11>
-- Description:	<Obtenemos el path del comprobante de entrega digitalizado(escaneado)>
-- =============================================
CREATE PROCEDURE [dbo].[GetScannedVoucherURL]
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		do.Guide_Number,
		(Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR(50))) as VARCHAR(300))) AS Url
	FROM [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
	WHERE do.Guide_Serie = @_serie
		AND do.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number, ','))
		AND do.Guide_Number IS NOT NULL
		
END