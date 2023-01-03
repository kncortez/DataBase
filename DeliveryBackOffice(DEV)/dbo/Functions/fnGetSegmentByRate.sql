


CREATE FUNCTION [dbo].[fnGetSegmentByRate]
(
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
	@IdRate INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

    DECLARE @Segment NVARCHAR(10);
	DECLARE @HeaderCodeSource NVARCHAR(5);
	DECLARE @HeaderCodeDestiny NVARCHAR(5);

	SELECT
		@HeaderCodeSource = ISNULL(TwnOriById.HeaderCode, TwnOriByName.HeaderCode),
		@HeaderCodeDestiny = ISNULL(TwnDesById.HeaderCode, TwnDesByName.HeaderCode)
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnOriById WITH(NOLOCK)
			ON
				DO.SenderIdTownship = TwnOriById.IdTownship
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnOriByName WITH(NOLOCK)
			ON
				DO.Sender_Town = TwnOriByName.TownshipName COLLATE Latin1_General_CI_AI
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnDesById WITH(NOLOCK)
			ON
				DO.ReceiverIdTownship = TwnDesById.IdTownship
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnDesByName WITH(NOLOCK)
			ON
				DO.Receiver_Town = TwnOriByName.TownshipName COLLATE Latin1_General_CI_AI
	WHERE
		DO.Guide_Serie = @GuideSerie
		AND
		DO.Guide_Number = @GuideNumber

	-- HeaderCodes Iguales - LOC
	IF(@HeaderCodeSource = @HeaderCodeDestiny)
	BEGIN
		SELECT 
			TOP 1 
				@Segment = CTS.CrsShortName 
		FROM 
			dbo.CatRateSegment CTS WITH(NOLOCK)
		WHERE 
			CTS.CrsShortName ='LOC'
	END

	-- HeaderCodes diferentes - revisar tabla
	ELSE
	BEGIN
		SELECT
			TOP 1
				@Segment = CRS.CrsShortName 
		FROM
			[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTC WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Township] TwnSource WITH(NOLOCK)
				ON
					RTC.TownshipSourceId = TwnSource.IdTownship
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Township] TwnDestiny WITH(NOLOCK)
				ON
					RTC.TownshipDestinyId = TwnDestiny.IdTownship
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK)
				ON
					RTC.SegmentTypeId = CRS.CrsId
		WHERE
			RTC.RateId = @IdRate
			AND
			(TwnSource.HeaderCode = @HeaderCodeSource)
			AND
			(TwnDestiny.HeaderCode = @HeaderCodeDestiny 
			)
			AND RTC.RowStatus = 1

	END

	IF(@Segment IS NULL)-- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
	BEGIN
		SELECT
			TOP 1 
				@Segment = CTS.CrsShortName 
		FROM 
			[DeliveryBackOffice].dbo.CatRateSegment CTS WITH(NOLOCK) 
		WHERE 
			CTS.CrsShortName ='FOR' COLLATE Latin1_General_CI_AI
	END

    RETURN ISNULL(@Segment, 'FOR');
END;