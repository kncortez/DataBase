BEGIN TRY
BEGIN TRANSACTION
Declare @IdRate INT = (
                          select RheId
                          from RateHeader with (nolock)
                          where RheName IN ( 'Tarifario de servicio estandar' )
                                and CountryID = 'SV'
                      );

-- SEGMENTO NACIONAL
IF NOT EXISTS
(
    SELECT CrsId
    FROM dbo.CatRateSegment with (nolock)
    WHERE CrsShortName = 'NAS'
)
BEGIN
    INSERT INTO dbo.CatRateSegment
    (
        CrsName,
        CrsShortName,
        CrsDescription,
        CrsRowStatus,
        CrsTokenCreated,
        CrsDateCreated,
        CrsTokenUpdated,
        CrsDateUpdated
    )
    VALUES
    ('NACIONAL SV', 'NAS', 'Nacional El Salvador', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL)
END;

DECLARE @IdSegmentNacional INT = (
                                     SELECT CrsId FROM dbo.CatRateSegment with (nolock) WHERE CrsShortName = 'NAS'
                                 );

INSERT INTO RateTownshipCoverage
(
    RateId,
    TownshipSourceId,
    TownshipDestinyId,
    SegmentTypeId,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
SELECT @IdRate,
       TWO.IdTownship,
       TWD.IdTownship,
       @IdSegmentNacional,
       1,
       'SYS-BPEDROZA',
	   GETDATE(),
       NULL,
       NULL
FROM Township TWO  with (nolock)
    CROSS JOIN Township TWD  with (nolock)
where TWO.IdProvince IN (
                            select IdProvince from Province with (nolock) where IdCountry = 'SV'
                        )
      and TWD.IdProvince IN (
                                select IdProvince from Province with (nolock) where IdCountry = 'SV'
                            );


--SEGMENTO METRO
IF NOT EXISTS
(
    SELECT CrsId
    FROM dbo.CatRateSegment with (nolock)
    WHERE CrsShortName = 'MES'
)
BEGIN
    INSERT INTO dbo.CatRateSegment
    (
        CrsName,
        CrsShortName,
        CrsDescription,
        CrsRowStatus,
        CrsTokenCreated,
        CrsDateCreated,
        CrsTokenUpdated,
        CrsDateUpdated
    )
    VALUES
    ('METRO SV', 'MES', 'Metro El Salvador', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL)
END;

DECLARE @IdSegmentMetro INT = (
                                  SELECT CrsId FROM dbo.CatRateSegment with (nolock) WHERE CrsShortName = 'MES'
                              );

UPDATE rt
SET rt.SegmentTypeId =
    (
        SELECT CrsId
        FROM dbo.CatRateSegment WITH (NOLOCK)
        WHERE CrsShortName = 'MES'
    ),
    rt.TokenUpdated = 'SYS-BPEDROZA',
    rt.DateUpdated = GETDATE()
FROM dbo.RateTownshipCoverage rt
    INNER JOIN dbo.Township TWO 
        ON TWO.IdTownship = rt.TownshipSourceId
    INNER JOIN dbo.Township TWD
        ON TWD.IdTownship = rt.TownshipDestinyId
    INNER JOIN dbo.Province PRO
        ON PRO.IdProvince = TWO.IdProvince
    INNER JOIN dbo.Province PRD
        ON PRD.IdProvince = TWD.IdProvince
WHERE rt.RateId = @IdRate
      AND rt.RowStatus = 1
      AND PRO.ProvinceName = 'San Salvador'
      AND PRD.ProvinceName = 'San Salvador'


	   COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH