USE [DeliveryBackOffice];
-- NACIONAL
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'NAG'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA2',
	rt.DateUpdated = GETDATE()
FROM dbo.RateTownshipCoverage rt
    INNER JOIN dbo.Township   TWO
        ON TWO.IdTownship = rt.TownshipSourceId
    INNER JOIN dbo.Township   TWD
        ON TWD.IdTownship = rt.TownshipDestinyId
    INNER JOIN dbo.Province   PRO
        ON PRO.IdProvince = TWO.IdProvince
    INNER JOIN dbo.Province   PRD
        ON PRD.IdProvince = TWD.IdProvince
WHERE rt.RateId = 2286
      AND rt.RowStatus = 1


--configurar segmento metro
UPDATE dbo.RateTownshipCoverage

SET SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'MEG'
    ),
	TokenUpdated = 'SYS-BPEDROZA2',
	DateUpdated = GETDATE()
WHERE RateId = 2286
      AND TownshipSourceId IN ( 84, 73, 86, 87, 79, 80 )
      AND TownshipDestinyId IN ( 84, 73, 86, 87, 79, 80 )
      AND RowStatus = 1;



	     -- DESTINOS EPECIALES
 
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'ESP'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA2',
	rt.DateUpdated = GETDATE()

FROM dbo.RateTownshipCoverage rt WITH(NOLOCK)
		INNER JOIN dbo.Township TWO WITH(NOLOCK) ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD WITH(NOLOCK) ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO WITH(NOLOCK) ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD WITH(NOLOCK) ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = 2286 
	AND rt.RowStatus = 1
AND rt.TownshipDestinyId IN(12,11,9,14,18,13,1,15 ,16,17 ,23 ,20 ,21 ,24 ,19 ,34 ,41 ,35 ,58 ,66 ,82 ,83 ,111,104,100,91 ,110,105,333,332,330,98 ,310,172,289,294,296,93 ,94 ,108,97 ,103,331,107,330,89 ,96 ,109,114,98 ,329,120,117,127,125,124,142,129,143,138,153,144,145,149,148,337,164,170,172,185,183,326,193,184,192,178,196,180,186,182,197,327,206,198,214,221,209,219,207,234,244,245,225,251,335,226,224,231,237,239,248,246,229,230,236,242,240,273,284,275,271,276,277,278,267,283,279,281,272,288,296,287,306,311,319);



	  
	  ---CONFIGURACION LOCAL
UPDATE dbo.RateTownshipCoverage
SET SegmentTypeId =
(
	SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'LOC'
),
TokenUpdated = 'SYS-BPEDROZA2',
DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = 2286 
	AND rt.TownshipSourceId  NOT IN( 84,73, 86, 87, 79, 80) 
	AND rt.TownshipDestinyId NOT IN(84,73, 86, 87, 79, 80)
	AND rt.RowStatus = 1 
	AND TWO.IdProvince = TWD.IdProvince
	AND TWO.IdTownship = TWD.IdTownship
	AND rt.SegmentTypeId NOT IN (
					SELECT CrsId FROM CatRateSegment WHERE CrsShortName IN ('MEG')
					);



-- CONFIGURAR COBERTURA DEPARTAMENTAL
	UPDATE rt
	SET	RT.SegmentTypeId =   (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'FOR'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA2',
	rt.DateUpdated = GETDATE()
	FROM dbo.RateTownshipCoverage rt
		INNER JOIN dbo.Township TWO ON TWO.IdTownship = rt.TownshipSourceId
		INNER JOIN dbo.Township TWD ON TWD.IdTownship = rt.TownshipDestinyId
		INNER JOIN dbo.Province PRO ON PRO.IdProvince = TWO.IdProvince
		INNER JOIN dbo.Province PRD ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = 2286 
	AND rt.RowStatus = 1 
	AND rt.TownshipSourceId != RT.TownshipDestinyId 
	AND TWO.IdProvince = TWD.IdProvince
	AND rt.SegmentTypeId NOT IN (
					SELECT CrsId FROM CatRateSegment WHERE CrsShortName IN ('LOC','MEG')
					);




-- Cobertura Regional -- REGION CENTRAL
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'REG'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA2',
	rt.DateUpdated = GETDATE()
FROM dbo.RateTownshipCoverage rt
    INNER JOIN dbo.Township   TWO
        ON TWO.IdTownship = rt.TownshipSourceId
    INNER JOIN dbo.Township   TWD
        ON TWD.IdTownship = rt.TownshipDestinyId
    INNER JOIN dbo.Province   PRO
        ON PRO.IdProvince = TWO.IdProvince
    INNER JOIN dbo.Province   PRD
        ON PRD.IdProvince = TWD.IdProvince
WHERE rt.RateId = 2286
      AND rt.RowStatus = 1
      AND PRO.IdProvince IN ( 7, 6, 16, 3, 18 )
      AND PRD.IdProvince IN ( 7, 6, 16, 3, 18 )
      AND PRD.IdProvince != PRO.IdProvince;
	--3		Chimaltenango
	--6		Escuintla
	--7		Guatemala
	--16	Sacatepéquez
	--18	Santa Rosa


	  	-- Cobertura Regional -- Region ORIENTE
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'REG'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA2',
	rt.DateUpdated = GETDATE()
FROM dbo.RateTownshipCoverage rt
    INNER JOIN dbo.Township   TWO
        ON TWO.IdTownship = rt.TownshipSourceId
    INNER JOIN dbo.Township   TWD
        ON TWD.IdTownship = rt.TownshipDestinyId
    INNER JOIN dbo.Province   PRO
        ON PRO.IdProvince = TWO.IdProvince
    INNER JOIN dbo.Province   PRD
        ON PRD.IdProvince = TWD.IdProvince
WHERE rt.RateId = 2286
      AND rt.RowStatus = 1
      AND PRO.IdProvince IN (11, 4, 10, 5, 22, 2, 9, 1)
      AND PRD.IdProvince IN (11, 4, 10, 5, 22, 2, 9, 1)
      AND PRD.IdProvince != PRO.IdProvince;
	--11	Jutiapa
	--4		Chiquimula
	--10	Jalapa
	--5		El Progreso
	--22	Zacapa
	--2		Baja Verapaz
	--9		Izabal
	--1		Alta Verapaz


-- Cobertura Regional -- Región OCCIDENTE
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'REG'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA2',
	rt.DateUpdated = GETDATE()
FROM dbo.RateTownshipCoverage rt
    INNER JOIN dbo.Township   TWO
        ON TWO.IdTownship = rt.TownshipSourceId
    INNER JOIN dbo.Township   TWD
        ON TWD.IdTownship = rt.TownshipDestinyId
    INNER JOIN dbo.Province   PRO
        ON PRO.IdProvince = TWO.IdProvince
    INNER JOIN dbo.Province   PRD
        ON PRD.IdProvince = TWD.IdProvince
	WHERE rt.RateId = 2286 
	AND rt.RowStatus = 1 
	AND pro.IdProvince IN(17,19,13,15,20,8,14,21)
	AND PRD.IdProvince IN(17,19,13,15,20,8,14,21)
	AND PRD.IdProvince != PRO.IdProvince
	--13	Quetzaltenango
	--15	Retalhuleu
	--17	San Marcos
	--19	Solola
	--20	Suchitepéquez
	--8		Huehuetenango
	--14	Quiché
	--21	Totonicapán




	-- Foraneo Peten
UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId FROM dbo.CatRateSegment WHERE CrsShortName = 'FPG'
    ),
	rt.TokenUpdated = 'SYS-BPEDROZA2',
	rt.DateUpdated = GETDATE()
FROM dbo.RateTownshipCoverage rt
    INNER JOIN dbo.Township   TWO
        ON TWO.IdTownship = rt.TownshipSourceId
    INNER JOIN dbo.Township   TWD
        ON TWD.IdTownship = rt.TownshipDestinyId
    INNER JOIN dbo.Province   PRO
        ON PRO.IdProvince = TWO.IdProvince
    INNER JOIN dbo.Province   PRD
        ON PRD.IdProvince = TWD.IdProvince
WHERE rt.RateId = 2286
      AND rt.RowStatus = 1
      AND PRD.IdProvince IN ( 12 )
      AND PRD.IdProvince != PRO.IdProvince;

