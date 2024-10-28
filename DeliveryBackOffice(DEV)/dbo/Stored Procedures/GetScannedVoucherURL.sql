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

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
	DROP TABLE #listGuides;

	SELECT
		SUBSTRING(Item, 1, 2) ItemSerie
		,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
		,SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
	INTO #listGuides
	FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number, ',')

    SELECT
		do.Guide_Number,
		--'https://tracking.forzadelivery.com/DocImages/GT.DELIVERYZ12/Copia1/V291/17088433.jpg' AS Url  -- Usar para pruebas
		(Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR)) as VARCHAR(300))) AS Url
	FROM [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
	WHERE do.Guide_Serie = @_serie
		AND do.Guide_Number IN (SELECT ItemNumber FROM #listGuides)
		and do.Guide_Number IS NOT NULL
	ORDER BY do.Guide_Number ASC
END