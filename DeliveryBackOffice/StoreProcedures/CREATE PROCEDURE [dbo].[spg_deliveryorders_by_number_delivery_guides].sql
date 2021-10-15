USE [DeliveryBackOffice]
GO

CREATE PROCEDURE [dbo].[spg_deliveryorders_by_number_delivery_guides]
	@Serie nvarchar(2),
	@Number nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#listGuidesSPGDOBNDG', 'U') IS NOT NULL DROP TABLE #listGuidesSPGDOBNDG;

	SELECT
		--SUBSTRING(Item, 1, 2) ItemSerie,
		--SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
		SUBSTRING(Item, 1, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
		SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
	INTO #listGuidesSPGDOBNDG
	FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Number, ',');

    DECLARE @GuidesAcepted VARCHAR(MAX) = (SELECT STUFF((SELECT ',' + CAST(do.Guide_Number AS VARCHAR)
														 FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
														 WHERE do.Guide_Serie = @Serie
														 AND do.Guide_Number IN (SELECT ItemNumber FROM #listGuidesSPGDOBNDG)
														 AND do.Guide_Number IS NOT NULL
														 AND CAST(IIF(do.IsCollect = 'TRUE', ISNULL(do.PriceShippment,0), 0) AS MONEY) <= 0
														 AND CAST(ISNULL(do.Collect_OnDelivery,0) AS MONEY) <= 0
														 ORDER BY do.Guide_Number ASC
														 FOR XML PATH ('')
													    ), 1, 1, ''));

	--SET @GuidesAcepted = SUBSTRING(@GuidesAcepted, 1, (LEN(@GuidesAcepted) - 1));
	SET @GuidesAcepted = SUBSTRING(@GuidesAcepted, 1, LEN(@GuidesAcepted));

	SELECT @GuidesAcepted AS GuidesAcepted;
END
