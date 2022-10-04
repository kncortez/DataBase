DECLARE @MainDate DATE = CAST(GETDATE() AS DATE);

DECLARE @StartDate DATETIME = DATEADD(DAY,-90,@MainDate);
DECLARE @EndDate DATETIME = DATEADD(SECOND,-1,CAST(DATEADD(DAY,1,@MainDate) AS DATETIME));

DECLARE @IdDeliveryOptionExc INT = (SELECT TOP 1 CDO.IdDeliveryOption FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] CDO WITH(NOLOCK) WHERE CDO.[Name] = 'Express Center' COLLATE Latin1_General_CI_AI)
DECLARE @IdSmallPackage INT = (SELECT TOP 1 ABC.AbcId FROM [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK) WHERE ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI);

IF OBJECT_ID('tempdb.dbo.#FinalPieceByGuide', 'U') IS NOT NULL DROP TABLE #FinalPieceByGuide;
IF OBJECT_ID('tempdb.dbo.#CleanedPieceByGuide', 'U') IS NOT NULL DROP TABLE #CleanedPieceByGuide;
IF OBJECT_ID('tempdb.dbo.#PieceByGuide', 'U') IS NOT NULL DROP TABLE #PieceByGuide;

SELECT
	CONCAT(DO.Guide_Serie, DO.Guide_Number) 'Guide',
	DO.Guide_Serie 'GuideSerie',
	DO.Guide_Number 'GuideNumber',
	DO.PriceShippment 'PriceShipment',
	CA.ArtName 'Package',
	ABC.Code 'ArticleCode',
	DOP.NoPiece 'PieceNumber',
	(
		CASE
			WHEN DO.DateCreated < '2022-10-01 00:00:00' THEN
				CASE
					WHEN ARBC.IdAlternativeRatebyCustomer IS NOT NULL THEN
						CASE
							WHEN ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI THEN 20.99
							WHEN ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI THEN 23.99
							WHEN ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI THEN 28.99
							WHEN ABC.Code = 'EXP079' COLLATE Latin1_General_CI_AI THEN 32.99
							WHEN ABC.Code = 'EXP080' COLLATE Latin1_General_CI_AI THEN 35.99
							ELSE ABC.PriceDefault
						END
					WHEN RBC.RbcId IS NOT NULL THEN
						CASE
							WHEN ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI THEN 25.99
							WHEN ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI THEN 28.99
							WHEN ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI THEN 33.99
							WHEN ABC.Code = 'EXP079' COLLATE Latin1_General_CI_AI THEN 37.99
							WHEN ABC.Code = 'EXP080' COLLATE Latin1_General_CI_AI THEN 40.99
							ELSE ABC.PriceDefault
						END
					ELSE
						0
				END
			ELSE
				RD.RateValue
		END
	) 'PiecePrice',
	(
		CASE
			WHEN DO.DateCreated < '2022-10-01 00:00:00' THEN
				CASE
					WHEN ARBC.IdAlternativeRatebyCustomer IS NOT NULL THEN
						CASE
							WHEN ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI THEN 20.99
							WHEN ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI THEN 20.99
							WHEN ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI THEN 20.99
							WHEN ABC.Code = 'EXP079' COLLATE Latin1_General_CI_AI THEN 20.99
							WHEN ABC.Code = 'EXP080' COLLATE Latin1_General_CI_AI THEN 20.99
							ELSE ABC.PriceDefault
						END
					WHEN RBC.RbcId IS NOT NULL THEN
						CASE
							WHEN ABC.Code = 'EXP076' COLLATE Latin1_General_CI_AI THEN 25.99
							WHEN ABC.Code = 'EXP077' COLLATE Latin1_General_CI_AI THEN 25.99
							WHEN ABC.Code = 'EXP078' COLLATE Latin1_General_CI_AI THEN 25.99
							WHEN ABC.Code = 'EXP079' COLLATE Latin1_General_CI_AI THEN 25.99
							WHEN ABC.Code = 'EXP080' COLLATE Latin1_General_CI_AI THEN 25.99
							ELSE ABC.PriceDefault
						END
					ELSE
						0
				END
			ELSE
				RDB.RateValue
		END
	) 'BasePrice',
	(
		CASE
			WHEN EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC WITH(NOLOCK) WHERE CCTBC.OrderNumber = CONCAT(DO.Guide_Serie, DO.Guide_Number)) THEN 2
			WHEN EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomerDetail] CCTBCD WITH(NOLOCK) WHERE CCTBCD.SerieNumber = DO.Guide_Serie AND CCTBCD.ProductNumber = DO.Guide_Number) THEN 2
			WHEN DO.IsCollect = 1 THEN 3
			ELSE 0
		END
	) 'ServiceAddedPrice',
	(
		CASE
			WHEN ARBC.IdAlternativeRatebyCustomer IS NOT NULL THEN 1
			ELSE 0
		END
	) 'ExcDestiny',
	(
		CASE
			WHEN DO.DateCreated < '2022-10-01 00:00:00' THEN REPLACE(dbo.fnGetSegmentByRate(DO.Guide_Serie, DO.Guide_Number, ISNULL(ARBC.RateId, RBC.RbcIdRate)),'ESP','FOR')
			ELSE dbo.fnGetSegmentByRate(DO.Guide_Serie, DO.Guide_Number, ISNULL(ARBC.RateId, RBC.RbcIdRate))
		END
	) 'Segment',
	SO.OrderDescription 'Status',
	DO.DateCreated
INTO #PieceByGuide
FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
		ON
			DO.IdCustomer = Cu.IdCustomer
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[VisitPointClient] VPCexc WITH(NOLOCK)
		ON
			DO.Receiver_ID = VPCexc.CodeOfReference
			AND
			DO.Receiver_ID != 0
			AND
			DO.IdDeliveryOption = @IdDeliveryOptionExc
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
		ON
			Cu.IdCustomer = RBC.RbcIdCustomer
			AND
			RBC.RbcRowStatus = 1
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[AlternativeRateByCustomer] ARBC WITH(NOLOCK)
		ON
			Cu.IdCustomer = ARBC.CustomerId
			AND
			VPCexc.CodeOfReference IS NOT NULL
			AND
			ARBC.RowStatus = 1
	INNER JOIN
		[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
		ON
			DO.Guide_Serie = DOP.GuideSerie
			AND
			DO.Guide_Number = DOP.GuideNumber
	INNER JOIN
		[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
		ON
			DOP.ParcelCode= ABC.Code COLLATE Latin1_General_CI_AI
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK)
		ON
			dbo.fnGetSegmentByRate(DO.Guide_Serie, DO.Guide_Number, ISNULL(ARBC.RateId, RBC.RbcIdRate)) = CRS.CrsShortName
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
		ON
			ISNULL(ARBC.RateId, RBC.RbcIdRate) = RD.RateId
			AND
			ABC.AbcId = RD.ArticleId
			AND
			CRS.CrsId = RD.TypeSegmentId
			AND
			RD.RowStatus = 1
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[RateData] RDB WITH(NOLOCK)
		ON
			ISNULL(ARBC.RateId, RBC.RbcIdRate) = RDB.RateId
			AND
			@IdSmallPackage = RDB.ArticleId
			AND
			CRS.CrsId = RDB.TypeSegmentId
			AND
			RDB.RowStatus = 1
	INNER JOIN
		[DeliveryBackOffice].[dbo].[CatArticle] CA WITH(NOLOCK)
		ON
			ABC.AbcIdArticle = CA.ArtId
	INNER JOIN
		[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
		ON
			DO.StatusOrderId = SO.StatusOrderId
WHERE
	DO.DateCreated BETWEEN @StartDate AND @EndDate
	AND
	DO.StatusOrderId NOT IN (7, 15) -- NO: ANULADA, GENERADA
	AND
	(
		Cu.IdCustomerType = 3
		OR
		(Cu.IdCustomerType = 2 AND VPCexc.DescriptionOfClient LIKE 'FD%EXC%' COLLATE Latin1_General_CI_AI)
	)
ORDER BY
	DO.DateCreated DESC
	
SELECT
	PBG.GuideSerie
	,PBG.GuideNumber
	,PBG.Guide
	,PBG.PriceShipment
	,PBG.Package
	,PBG.PieceNumber
	,PBG.PiecePrice
	+
	(
		CASE
			WHEN PBG.Segment = 'FOR' AND PBG.DateCreated < '2022-10-01 00:00:00' THEN 14
			ELSE 0
		END
	) 'PiecePrice'
	,PBG.BasePrice
	+
	(
		CASE
			WHEN PBG.Segment = 'FOR' AND PBG.DateCreated < '2022-10-01 00:00:00' THEN 14
			ELSE 0
		END
	) 'BasePrice'
	,PBG.ServiceAddedPrice
	,PBG.ExcDestiny
	,PBG.[Status]
	,PBG.Segment
	,PBG.DateCreated
INTO #CleanedPieceByGuide
FROM
	#PieceByGuide PBG

	
SELECT
	CPBG.GuideSerie
	,CPBG.GuideNumber
	,CPBG.Guide
	,CPBG.PriceShipment
	,MAX(CPBG.Package) 'Package'
	,CPBG.PieceNumber
	,MAX(CPBG.PiecePrice) 'PiecePrice'
	,MAX(CPBG.BasePrice) 'BasePrice'
	,CPBG.ServiceAddedPrice
	,CPBG.ExcDestiny
	,CPBG.[Status]
	,CPBG.Segment
	,CPBG.DateCreated
INTO #FinalPieceByGuide
FROM
	#CleanedPieceByGuide CPBG
GROUP BY
	CPBG.GuideSerie
	,CPBG.GuideNumber
	,CPBG.Guide
	,CPBG.PriceShipment
	,CPBG.PieceNumber
	,CPBG.ServiceAddedPrice
	,CPBG.ExcDestiny
	,CPBG.[Status]
	,CPBG.Segment
	,CPBG.DateCreated

SELECT
	CPBG.Guide 'Guía'
	,CPBG.DateCreated 'Creación de la guía'
	,CPBG.[Status] 'Estado de guía'
	,CPBG.PriceShipment 'Precio total de servicio'
	,CPBG.ServiceAddedPrice 'Cobro adicional (Pago con tarjeta/Collect)'
	,(CPBG.PriceShipment - CPBG.ServiceAddedPrice) 'Precio de servicio'
	,( SELECT 
		STUFF(( 
			SELECT 
				',' + CPBGAux.Package
			FROM #FinalPieceByGuide CPBGAux
			WHERE
				CPBGAux.GuideSerie = CPBG.GuideSerie
				AND
				CPBGAux.GuideNumber = CPBG.GuideNumber
			ORDER BY
				CPBGAux.PieceNumber ASC
			FOR XML PATH(''), TYPE 
		) 
		.value('.', 'varchar(max)'),1,1,'' 
		)
	) 'Paquetes'
	,( SELECT 
		STUFF(( 
			SELECT 
				',' + CAST(CPBGAux.PiecePrice AS NVARCHAR)
			FROM #FinalPieceByGuide CPBGAux
			WHERE
				CPBGAux.GuideSerie = CPBG.GuideSerie
				AND
				CPBGAux.GuideNumber = CPBG.GuideNumber
			ORDER BY
				CPBGAux.PieceNumber ASC
			FOR XML PATH(''), TYPE 
		) 
		.value('.', 'varchar(max)'),1,1,'' 
		)
	) 'Precio por paquetes'
	,CPBG.BasePrice 'Precio base (paquete pequeño)'
	,(COUNT(DISTINCT CPBG.PieceNumber) * CPBG.BasePrice) 'Precio total de precio base (paquete pequeño)'
	,( SELECT 
		STUFF(( 
			SELECT 
				',' + CAST((CPBGAux.PiecePrice - CPBG.BasePrice) AS NVARCHAR)
			FROM #FinalPieceByGuide CPBGAux
			WHERE
				CPBGAux.GuideSerie = CPBG.GuideSerie
				AND
				CPBGAux.GuideNumber = CPBG.GuideNumber
			ORDER BY
				CPBGAux.PieceNumber ASC
			FOR XML PATH(''), TYPE 
		) 
		.value('.', 'varchar(max)'),1,1,'' 
		)
	) 'Diferencia de precios al precio base por paquetes (paquete pequeño)'
	,CPBG.PriceShipment - CPBG.ServiceAddedPrice - (COUNT(DISTINCT CPBG.PieceNumber) * CPBG.BasePrice) 'Diferencia total de precio a precio base (paquete pequeño)'
FROM
	#FinalPieceByGuide CPBG
GROUP BY
	CPBG.GuideSerie,
	CPBG.GuideNumber,
	CPBG.Guide,
	CPBG.[Status],
	CPBG.PriceShipment,
	CPBG.BasePrice,
	CPBG.ServiceAddedPrice,
	CPBG.DateCreated
HAVING
	(CPBG.PriceShipment - CPBG.ServiceAddedPrice - (COUNT(DISTINCT CPBG.PieceNumber) * CPBG.BasePrice)) > 0
ORDER BY
	CPBG.GuideNumber DESC

IF OBJECT_ID('tempdb.dbo.#PieceByGuide', 'U') IS NOT NULL DROP TABLE #PieceByGuide;
IF OBJECT_ID('tempdb.dbo.#CleanedPieceByGuide', 'U') IS NOT NULL DROP TABLE #CleanedPieceByGuide;
IF OBJECT_ID('tempdb.dbo.#FinalPieceByGuide', 'U') IS NOT NULL DROP TABLE #FinalPieceByGuide;