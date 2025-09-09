-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-11>
-- Description:	<Obtenemos el path del comprobante de entrega digitalizado(escaneado)>
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date: <11/07/2025>
-- Description:	<Se agrega la base de la URL ya que cambio la respuesta de la función fn_get_document_image_url>
-- =============================================
CREATE PROCEDURE [dbo].[GetScannedVoucherURL]
	@_serie NVARCHAR(2) = 'FD'
	,@_number NVARCHAR(max)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ConfigParamName NVARCHAR(10) = 'BaseURL';

	SELECT
		DO.Guide_Number,
		CONCAT(CP.Value, CAST(DeliveryBackOffice.dbo.fn_get_document_image_url(DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(50))) AS NVARCHAR(300))) AS Url
	FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.ConfigParams CP WITH(NOLOCK)
		ON CP.IdCountry = DO.SenderCountryId
	WHERE DO.Guide_Serie = @_serie
		AND DO.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number, ','))
		AND CP.Name = @ConfigParamName;		
END
