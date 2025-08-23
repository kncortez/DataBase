-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-11>
-- Description:	<Obtenemos el path del comprobante de entrega digitalizado(escaneado)>
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date: <11/07/2025>
-- Description:	<Se agrega la base de la URL ya que cambio la respuesta de la función>
-- =============================================
CREATE PROCEDURE [dbo].[GetScannedVoucherURL]
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @URLBase VARCHAR(50);
	SET @URLBase = (SELECT Value FROM DeliveryBackOffice.dbo.ConfigParams WHERE Name = 'BaseURL');

    SELECT
		do.Guide_Number,
		CONCAT(@URLBase,(Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR(50))) as VARCHAR(300)))) AS Url
	FROM [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
	WHERE do.Guide_Serie = @_serie
		AND do.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number, ','))
		AND do.Guide_Number IS NOT NULL;
		
END