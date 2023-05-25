

CREATE PROCEDURE [dbo].[TestTSE]  
	@IdRoute INT
AS
BEGIN

	DECLARE @TempPieces TABLE (
		RowNum INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		Detail NVARCHAR(2500)
	);

	;WITH PiezasEnProcesoTSE AS
	(
		SELECT
			ROW_NUMBER() OVER (PARTITION BY [TRPD].[GuideNumber] ORDER BY [TRPD].[GuideNumber]) [RowNum]
			,[TRPD].[GuideSerie]
			,[TRPD].[GuideNumber]
			,[DOP].[Detail]
			,(
				SELECT 
					COUNT([DOPaux].[Detail]) 
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOPaux  WITH(NOLOCK) 
				WHERE
					[DOPaux].[GuideSerie] = [DOP].[GuideSerie]
					AND
					[DOPaux].[GuideNumber] = [DOP].[GuideNumber]
			) [MaxValue]
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP  WITH(NOLOCK) 
			INNER JOIN
				[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TRPD  WITH(NOLOCK) 
				ON
					[DOP].[GuideSerie] = [TRPD].[GuideSerie]
					AND
					[DOP].[GuideNumber] = [TRPD].[GuideNumber]
					AND
					[TRPD].[RowStatus] = 1
			INNER JOIN
				[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TRPH  WITH(NOLOCK) 
				ON
					[TRPD].[TSERoutePreparationHeaderID] = [TRPH].[IDTSERoutePreparationHeader]
		WHERE
			[TRPH].[IdCatRoute] = @IdRoute
			AND
			[TRPH].[RowStatus] = 1
		UNION ALL
		SELECT
			([RowNum] + 1) [RowNum],
			[GuideSerie],
			[GuideNumber],
			CAST('' AS VARCHAR(2500)) [Detail],
			[MaxValue]
		FROM
			[PiezasEnProcesoTSE]
		WHERE
			[RowNum] < 40
			AND
			([RowNum] + 1) > [MaxValue]
	)
	INSERT INTO @TempPieces
	(
		[RowNum],
		[GuideSerie],
		[GuideNumber],
		[Detail]
	)
	SELECT 
		[PiezasEnProcesoTSE].[RowNum],
		[PiezasEnProcesoTSE].[GuideSerie],
		[PiezasEnProcesoTSE].[GuideNumber],
		[PiezasEnProcesoTSE].[Detail]
	FROM 
		PiezasEnProcesoTSE

	SELECT 
		DISTINCT 
			TRPD.GuideNumber,
			TRPD.IDTSERoutePreparationDetail,
			[DO].[Receiver_Address] [VoteCenter],
			(
				SELECT
					SUM
					(
						CASE
							WHEN LTRIM(RTRIM([TP].[Detail])) <> '' THEN 1
							ELSE 0
						END
					)
				FROM
					@TempPieces TP
				WHERE
					TP.GuideSerie = TRPD.GuideSerie 
					AND 
					TP.GuideNumber = TRPD.GuideNumber
				GROUP BY
					[TP].[GuideSerie],
					[TP].[GuideNumber]
			) TotalPieces,
			(
				SELECT 
					STUFF
					(
						( 
							SELECT ',' + TP.Detail 
							FROM @TempPieces TP
							WHERE  TP.GuideSerie = TRPD.GuideSerie And 
							TP.GuideNumber = TRPD.GuideNumber
							FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
					) 
			) Pieces
	FROM
		[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TRPD  WITH(NOLOCK) 
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			ON
				[DO].[Guide_Serie] = [TRPD].[GuideSerie]
				AND
				[DO].[Guide_Number] = [TRPD].[GuideNumber]
		INNER JOIN
			[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TRPH  WITH(NOLOCK) 
			ON 
				TRPH.IdTSERoutePreparationHeader = TRPD.TSERoutePreparationHeaderID
	WHERE 
		TRPH.IdCatRoute = @IdRoute 
		AND 
		TRPD.RowStatus=1

END;