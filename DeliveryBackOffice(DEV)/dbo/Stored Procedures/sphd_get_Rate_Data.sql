
-- =============================================
-- Author:      <César, Aquino>
-- Create date: <2021-04-22>
-- Description: <Devuelve un tarifa todo destino identificada por id>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_get_Rate_Data]
    @IdRate INT,
    @TypeRateId INT
AS
BEGIN

    SELECT rd.RheId [ID],
           rd.RheName [RateName],
           rd.RheDescription [RateDescription],
           rd.WeightLimit [LimitWeight],
           rd.AdditionalWeightRate [AdditionalRate],
           rd.InsuranceRate [InsuranceRate],
           rd.InsuranceExempt [InsuranceExempt],
           rd.CreditCardRate [CreditCardRate],
           rd.ReturnRate [ReturnRate],
           rd.RateTypeId [TypeRate],
           rd.FragilRate [FragilRate],
           rd.Attempt [Attempt],
           rd.CurrencyId [CurrencyId],
           rd.CollectRate [CollectRate],
           cr.Currency_Name [Currency],
           rd.PiecesIncluded [PiecesIncluded],
		   rd.CutOffDate [CutOffDate]
    FROM dbo.RateHeader rd
        LEFT JOIN dbo.DeliveryCurrency cr
            ON cr.Currency_Id = rd.CurrencyId
    WHERE rd.RheId = @IdRate;


    IF @TypeRateId = 1
    BEGIN
        SELECT rd.RateId [RateId],
               ct.CtsShortName [ServiceType],
               sg.CrsShortName [SegmentType],
               rd.RateValue [RateValue],
               hbo.IdHubLogistic [IdHubSource],
               hbo.HubAbbreviation [HubSource],
               hbd.IdHubLogistic [IdHubDestiny],
               hbd.HubAbbreviation [HubDestiny]
        FROM dbo.RateData rd
            LEFT JOIN dbo.CatTypeService ct
                ON ct.CtsId = rd.TypeServiceId
            LEFT JOIN dbo.CatRateSegment sg
                ON sg.CrsId = rd.TypeSegmentId
            LEFT JOIN dbo.HubLogistics hbo
                ON hbo.IdHubLogistic = rd.HubSourceId
            LEFT JOIN dbo.HubLogistics hbd
                ON hbd.IdHubLogistic = rd.HubDestinyId
        WHERE rd.RateId = @IdRate
              AND rd.ArticleId IS NULL
              AND rd.TypeSegmentId IS NULL
        ORDER BY ct.CtsShortName,
                 hbo.IdHubLogistic,
                 hbd.IdHubLogistic;
    END;

    ELSE IF @TypeRateId = 2
       OR @TypeRateId = 3 -- tarifas todo destino
	   OR @TypeRateId = 6 -- Coberturas
    BEGIN

        SELECT rd.RateId [RateId],
               ct.CtsShortName [ServiceType],
               sg.CrsShortName [SegmentType],
               rd.RateValue [RateValue],
               hbo.IdHubLogistic [IdHubSource],
               hbo.HubAbbreviation [HubSource],
               hbd.IdHubLogistic [IdHubDestiny],
               hbd.HubAbbreviation [HubDestiny]
        FROM dbo.RateData rd
            LEFT JOIN dbo.CatTypeService ct
                ON ct.CtsId = rd.TypeServiceId
            LEFT JOIN dbo.CatRateSegment sg
                ON sg.CrsId = rd.TypeSegmentId
            LEFT JOIN dbo.HubLogistics hbo
                ON hbo.IdHubLogistic = rd.HubSourceId
            LEFT JOIN dbo.HubLogistics hbd
                ON hbd.IdHubLogistic = rd.HubDestinyId
        WHERE rd.RateId = @IdRate
              AND rd.ArticleId IS NULL
              AND rd.HubSourceId IS NULL
        ORDER BY ct.CtsShortName,
                 sg.CrsShortName;

    END;
	ELSE IF @TypeRateId = 5
	BEGIN
		SELECT
			rd.WeightFrom
		   ,rd.WeightTo
		   ,rd.RateValue
		   ,ts.CtsShortName Service
		   ,rs.CrsShortName Segment
		FROM RateData rd
		INNER JOIN CatTypeService ts
			ON ts.CtsId = rd.TypeServiceId
		INNER JOIN CatRateSegment rs
			ON rs.CrsId = rd.TypeSegmentId
		WHERE rd.RateId = @IdRate
			AND rd.RowStatus = 'TRUE'
	END
	ELSE IF @TypeRateId = 7
	BEGIN
		SELECT
			rd.PackagesFrom
		   ,rd.PackagesTo
		   ,rd.RateValue
		   ,ts.CtsShortName Service
		   ,rs.CrsShortName Segment
		FROM RateData rd
		INNER JOIN CatTypeService ts
			ON ts.CtsId = rd.TypeServiceId
		INNER JOIN CatRateSegment rs
			ON rs.CrsId = rd.TypeSegmentId
		WHERE rd.RateId = @IdRate
			AND rd.RowStatus = 'TRUE'
	END
    ELSE
    BEGIN
        SELECT 1;
    END;

    -- cargar tarifario COD
    DECLARE @IntHaveDataCOD INT = 0;
    SELECT @IntHaveDataCOD = COUNT(*)
    FROM dbo.RateCOD rod
        LEFT JOIN dbo.CatTypeService cs
            ON cs.CtsId = rod.TypeServiceId
        LEFT JOIN dbo.CatRateSegment cg
            ON cg.CrsId = rod.TypeSegmentId
    WHERE rod.RateId = @IdRate
          AND rod.RowStatus = 1;

    IF @IntHaveDataCOD > 0
    BEGIN
        SELECT rod.RateId [IdRate],
               rod.TypeServiceId [IdService],
               cs.CtsShortName [ServiceType],
               rod.TypeSegmentId [IdSegment],
               cg.CrsShortName [SegmentType],
               rod.CODRate [CODRate],
               rod.CODExempt [CODExempt]
        FROM dbo.RateCOD rod
            LEFT JOIN dbo.CatTypeService cs
                ON cs.CtsId = rod.TypeServiceId
            LEFT JOIN dbo.CatRateSegment cg
                ON cg.CrsId = rod.TypeSegmentId
        WHERE rod.RateId = @IdRate
              AND rod.RowStatus = 1
        ORDER BY rod.TypeServiceId,
                 rod.TypeSegmentId;
    END;
    ELSE
        SELECT -1 [IdRate],
               -1 [IdService],
               'NDD' [ServiceType],
               'LOC' [IdSegment],
               'LOCA' [SegmentType],
               0 [CODRate],
               0 [CODExempt];


    -- tarifas por articulo
    IF @TypeRateId = 3
    BEGIN
        SELECT --dt1.RateId,
        dt1.ArticleId,
               dt1.Code,
               SUM(dt1.LOCRate) LocRate,
               SUM(dt1.METRate) MetRate,
               SUM(dt1.FORRate) ForRate,
			   SUM(dt1.ESPRate) EspRate,
			   dt1.TypeRate TypeRate,
               1 'Status'
        FROM
        (
            SELECT rd.RateId,
                   rd.ArticleId,
                   CONCAT( ac.Code,'  -  ', ta.TarName,'-', ca.ArtName)Code,
                   --,sg.CrsShortName
                   IIF(sg.CrsShortName = 'FOR', SUM(ISNULL(rd.RateValue, 0)), 0) FORRate,
                   IIF(sg.CrsShortName = 'MET', SUM(ISNULL(rd.RateValue, 0)), 0) METRate,
                   IIF(sg.CrsShortName = 'LOC', SUM(ISNULL(rd.RateValue, 0)), 0) LOCRate,
				   IIF(sg.CrsShortName = 'ESP', SUM(ISNULL(rd.RateValue, 0)), 0) ESPRate,
				   ct.CtsShortName TypeRate
            FROM dbo.RateData rd
                LEFT JOIN dbo.CatTypeService ct
                    ON ct.CtsId = rd.TypeServiceId
                LEFT JOIN dbo.CatRateSegment sg
                    ON sg.CrsId = rd.TypeSegmentId
                LEFT JOIN dbo.ArticleByCustomer ac
                    ON ac.AbcId = rd.ArticleId
                LEFT JOIN DBO.CatArticle ca ON ca.ArtId = ac.AbcIdArticle
                LEFT JOIN dbo.CatTypeArticle ta ON ta.TarId =ca.ArtIdTypeArticle
            WHERE rd.RateId = @IdRate
                  AND rd.ArticleId IS NOT NULL
                  AND rd.RowStatus = 1
            GROUP BY rd.RateId,
                     rd.ArticleId,
                     sg.CrsShortName,
                     CONCAT( ac.Code,'  -  ', ta.TarName,'-', ca.ArtName),
					 ct.CtsShortName
        ) AS dt1
        GROUP BY dt1.RateId,
                 dt1.ArticleId,
                 dt1.Code,
				 dt1.TypeRate;

    END;
END;