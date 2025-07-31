-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-30>
-- Description:	<Login Portal Web>
-- =============================================


CREATE PROCEDURE [dbo].[CreateRateCoverage_CRAS]
    @HeaderCode NVARCHAR(5)
  , @Segmento NVARCHAR(3)
AS
BEGIN

    --SELECT * FROM dbo.Township TT
    --WHERE TT.HeaderCode = @HeaderCode

    BEGIN TRY

        DECLARE @RateId INT;

        SELECT @RateId = RheId
        FROM dbo.RateHeader
        WHERE RheName = 'Tarifario de servicio estandar'
              AND CountryId = 'HN';

        DECLARE @IDtONSHIP INT;

        SELECT @IDtONSHIP = TT.IdTownship
        FROM dbo.Township TT
        WHERE TT.HeaderCode = @HeaderCode;



        DECLARE @IdSegment INT;

        SELECT @IdSegment = CrsId
        FROM dbo.CatRateSegment
        WHERE CrsShortName = @Segmento;

        BEGIN TRANSACTION;

        INSERT INTO dbo.RateTownshipCoverage
        (
            RateId
          , TownshipSourceId
          , TownshipDestinyId
          , SegmentTypeId
          , RowStatus
          , TokenCreated
          , DateCreated
          , TokenUpdated
          , DateUpdated
        )
        SELECT @RateId
             , T.IdTownship
             , @IDtONSHIP
             , @IdSegment
             , 1
             , 'SYS-CAQUINO'
             , GETDATE()
             , NULL
             , NULL
        FROM dbo.Province           P
            INNER JOIN dbo.Township T
                ON T.IdProvince = P.IdProvince
        WHERE P.IdCountry = 'HN'
              AND T.IdTownship != @IDtONSHIP;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;
END;