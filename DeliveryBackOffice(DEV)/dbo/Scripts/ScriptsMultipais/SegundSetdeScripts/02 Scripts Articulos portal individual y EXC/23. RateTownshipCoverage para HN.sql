DECLARE @IdRateStandar INT;
DECLARE @IdRateEXC INT;
SET @IdRateStandar =
(
    SELECT RheId
    FROM RateHeader
    where RheName = 'Tarifario de servicio estandar'
          AND CountryId = 'HN'
)
SET @IdRateEXC =
(
    SELECT RheId
    FROM RateHeader
    where RheName = 'Tarifario destinos express center'
          AND CountryId = 'HN'
)
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
SELECT @IdRateStandar,
       T1.IdTownship TownshipSourceId,
       T2.IdTownship TowshipDestinyId,
       1,
       1,
       'SYS-BPEDROZA',
       GETDATE(),
       NULL,
       NULL
FROM Township T1
    CROSS JOIN Township T2
WHERE T1.IdProvince in (
                           SELECT IdProvince FROM Province WHERE IdCountry = 'HN'
                       )
      AND T2.IdProvince in (
                               SELECT IdProvince FROM Province WHERE IdCountry = 'HN'
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
SELECT @IdRateEXC,
       T1.IdTownship TownshipSourceId,
       T2.IdTownship TowshipDestinyId,
       1,
       1,
       'SYS-BPEDROZA',
       GETDATE(),
       NULL,
       NULL
FROM Township T1
    CROSS JOIN Township T2
WHERE T1.IdProvince in (
                           SELECT IdProvince FROM Province WHERE IdCountry = 'HN'
                       )
      AND T2.IdProvince in (
                               SELECT IdProvince FROM Province WHERE IdCountry = 'HN'
                           );