-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-30>
-- Description:	<Login Portal Web>
-- =============================================


CREATE PROCEDURE [dbo].[CreateRateHN_CRAS]
    @IdArticule INT
  , @Price DECIMAL(14, 2)
  , @TypeService NVARCHAR(3)
  , @TypeSegment NVARCHAR(3)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @RateId INT;

        SELECT @RateId = RheId
        FROM dbo.RateHeader
        WHERE RheName = 'Tarifario de servicio estandar'
              AND CountryId = 'HN';

        DECLARE @TypeServiceId INT;

        SELECT @TypeServiceId = CtsId
        FROM dbo.CatTypeService
        WHERE CtsShortName = @TypeService;



        DECLARE @TypeSegmentId INT;

        SELECT @TypeSegmentId = CrsId
        FROM dbo.CatRateSegment
        WHERE CrsShortName = @TypeSegment;

        PRINT @TypeServiceId;
        INSERT INTO dbo.RateData
        (
            RateId
          , TypeServiceId
          , TypeSegmentId
          , HubSourceId
          , HubDestinyId
          , ArticleId
          , RateValue
          , RowStatus
          , TokenCreated
          , DateCreated
          , TokenUpdated
          , DateUpdated
          , LimitHourDelivery
          , LimitHourPickup
          , WeightFrom
          , WeightTo
          , PackagesFrom
          , PackagesTo
        )
        SELECT @RateId
             , @TypeServiceId
             , @TypeSegmentId
             , NULL
             , NULL
             , @IdArticule
             , @Price
             , 1
             , 'sys-caquino'
             , GETDATE()
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_NUMBER()
             , ERROR_MESSAGE()
             , ERROR_LINE();
    END CATCH;

END;