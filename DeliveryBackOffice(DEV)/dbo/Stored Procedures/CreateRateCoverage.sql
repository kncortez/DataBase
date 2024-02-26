
CREATE PROCEDURE [dbo].[CreateRateCoverage]
    @RateId INT -- = 2285;
  , @TownshipDestinyId INT
  , @Segment NVARCHAR(50)
AS
BEGIN
    BEGIN TRY

        DECLARE @SegmentId INT;

        SELECT @SegmentId = CrsId
        FROM dbo.CatRateSegment
        WHERE CrsName = @Segment;

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
             , tw.IdTownship
             , @TownshipDestinyId
             , @SegmentId
             , 1
             , 'SYS-CAQUINO'
             , GETDATE()
             , NULL
             , NULL
        FROM dbo.Township tw
        WHERE tw.TownshipStatus = 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 500             'ResultCode'
             , ERROR_MESSAGE() 'ResultMessage';

    END CATCH;
END;