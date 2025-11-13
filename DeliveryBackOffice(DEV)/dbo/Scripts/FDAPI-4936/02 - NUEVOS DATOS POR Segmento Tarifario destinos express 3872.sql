BEGIN TRY

DECLARE @IdRate INT = (select RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario destinos express center' AND CountryId = 'HN')
-- NACIONAL
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'NAH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
FROM dbo.RateTownshipCoverage rt WITH(NOLOCK)
    INNER JOIN dbo.Township   TWO WITH(NOLOCK)
        ON TWO.IdTownship = rt.TownshipSourceId
    INNER JOIN dbo.Township   TWD WITH(NOLOCK)
        ON TWD.IdTownship = rt.TownshipDestinyId
    INNER JOIN dbo.Province   PRO WITH(NOLOCK)
        ON PRO.IdProvince = TWO.IdProvince
    INNER JOIN dbo.Province   PRD WITH(NOLOCK)
        ON PRD.IdProvince = TWD.IdProvince
WHERE rt.RateId = @IdRate
      AND rt.RowStatus = 1



--METRO

UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment  WITH(NOLOCK) WHERE CrsShortName = 'MEH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt  WITH(NOLOCK)
		INNER JOIN dbo.Township TWO  WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD  WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO  WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD  WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	AND rt.TownshipSourceId = RT.TownshipDestinyId 
	AND TWO.IdTownship IN(455,408)
	AND TWD.IdTownship IN (455,408)


--LOCAL
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment  WITH(NOLOCK) WHERE CrsShortName = 'LOH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt WITH(NOLOCK)
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	AND rt.TownshipSourceId = RT.TownshipDestinyId 
	AND rt.SegmentTypeId NOT IN (
					SELECT CrsId FROM CatRateSegment WHERE CrsShortName IN ('MEH')
					);


--DEPARTAMENTAL
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'DEH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	AND TWO.IdProvince = TWD.IdProvince
	AND rt.SegmentTypeId NOT IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH')
					);

--REGION OCCIDENTE
-- Atlantida		23
-- Cortés			27
-- Santa Bárbara	38
-- Copán			26
-- Ocotepeque		36
-- Lempira			35
-- Intibucá 		32
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'REH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt  WITH(NOLOCK)
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	AND TWO.IdProvince IN(23,27,38,26,36,35,32)
	and TWD.IdProvince IN (23,27,38,26,36,35,32)
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment  WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH', 'DEH')
					);




--REGION CENTRO SUR
-- Francisco Morazán 30
-- Comayagua		25
-- La Paz		34
-- Valle		39
-- Choluteca	28
-- El Paraíso	29
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment  WITH(NOLOCK) WHERE CrsShortName = 'REH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	AND TWO.IdProvince IN(30,25,34,39,28,29)
	and TWD.IdProvince IN (30,25,34,39,28,29)
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH', 'DEH')
					);




--REGION NOR ORIENTE
-- Yoro    40
-- Olancho 37
-- Colón.  24
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'REH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	AND TWO.IdProvince IN(40,37,24)
	and TWD.IdProvince in (40,37,24)
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment  WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH', 'DEH')
					);



--REGION BAHIA(33	Islas de la Bahía)
-- Roatan	506
-- Utila	509
-- Guanaja	507
-- Jose santos guardiola	508
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'REH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt  WITH(NOLOCK)
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	and pro.IdProvince = prd.IdProvince
	and TWO.IdProvince = 33
	and TWO.IdTownship IN (506,507,508,509)
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH')
					);



--REGION GRACIAS(31	Gracias a Dios)
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'REH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt  WITH(NOLOCK)
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	AND pro.IdProvince = prd.IdProvince
	AND two.IdProvince = 31
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH')
					);




--FOREANEO OLANCHO
-- Campamento,	574
-- Concordia,	576
-- Guayape,		583
-- yocón,		594
-- El Rosario,	578
-- Salama,		588
-- Silca,		593
-- Manto,		587
-- San Francisco de la Paz	591
-- Juticalpa	573
-- San Francisco de Becerra	590
-- Patuca		595
-- Catacamas	575
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FOH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	and TWD.IdTownship IN ( 574,576,583,594,578,588,593,587,591,573,590,595,575)
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH', 'DEH','REH')
					);


--FOREANEO ISLAS DE LA BAHIA
-- Roatan	506
-- Utila	509
-- Guanaja	507
-- Jose santos guardiola	508
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FIH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	and TWD.IdTownship IN (506,507,508,509)
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH', 'DEH','REH')
					);



-- FORANEO GRACIAS A DIOS
IF NOT EXISTS(
		SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FGH'
)
BEGIN
INSERT INTO dbo.CatRateSegment
(
    CrsName
  , CrsShortName
  , CrsDescription
  , CrsRowStatus
  , CrsTokenCreated
  , CrsDateCreated
  , CrsTokenUpdated
  , CrsDateUpdated
)
VALUES
(   'FORANEO GRACIAS A DIOS' 
  , 'FGH' 
  , 'Foraneo Gracias a Dios' 
  , 1 
  , 'SYS-BPEDROZA' 
  , GETDATE() 
  , NULL 
  , NULL 
    )
END

--FOREANEO GRACIAS A DIOS (31	Gracias a Dios)
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'FGH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	and PRD.IdProvince = 31
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH', 'DEH','REH')
					);



--ESPECIAL
 --Dulce nombre de culmí	577
 --San esteban				589
 --Gualaco,					580
 --Guarizama,				581
 --Santa maria del real		592
 --Jano						584 
 --Guata 					582
 --Esquipulas del Norte     579
 --La Union         		585
 --Magulile					586
 UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'ESH'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = @IdRate 
	AND rt.RowStatus = 1 
	and TWD.IdTownship IN (577,589,580,581,592,584,582,579,585,586)
	AND rt.SegmentTypeId not IN (
					SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName IN ('MEH', 'LOH', 'DEH','REH')
					);
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH