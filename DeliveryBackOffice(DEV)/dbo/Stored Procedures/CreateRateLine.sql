CREATE PROCEDURE [dbo].[CreateRateLine]
    @RateId INT                -- = 2285;
  , @ServiceType NVARCHAR(50)  -- = N'Servicio Estándar';
  , @PackageType NVARCHAR(100) -- = N'PAQUETE PEQUEÑO';
  , @SegmentType NVARCHAR(100) --= N'DEPARTAMENTAL NORTE';
  , @Price DECIMAL(12, 2)      -- = 30;
AS
BEGIN
    BEGIN TRY

        DECLARE @ServiceTypeId INT;
        DECLARE @PackageTypeId INT;
        DECLARE @SegmentTypeId INT;

        SELECT @ServiceTypeId = CtsId
        FROM dbo.CatTypeService
        WHERE CtsName = @ServiceType;


        SELECT @PackageTypeId = ac.AbcId
        FROM dbo.CatArticle                  ca
            INNER JOIN dbo.ArticleByCustomer ac
                ON ac.AbcIdArticle = ca.ArtId
        WHERE ca.ArtName = @PackageType;


        SELECT @SegmentTypeId = sg.CrsId
        FROM dbo.CatRateSegment sg
        WHERE sg.CrsName = @SegmentType;

        BEGIN TRANSACTION;

        IF (
               @ServiceTypeId IS NOT NULL
               AND @PackageTypeId IS NOT NULL
               AND @SegmentTypeId IS NOT NULL
           )
        BEGIN

		 SELECT 'Datos ok'
                 , @SegmentTypeId
                 , @PackageTypeId
                 , @ServiceTypeId;

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
            VALUES
            (   @RateId        -- RateId - int
              , @ServiceTypeId -- TypeServiceId - int
              , @SegmentTypeId -- TypeSegmentId - int
              , NULL           -- HubSourceId - int
              , NULL           -- HubDestinyId - int
              , @PackageTypeId -- ArticleId - int
              , @Price         -- RateValue - decimal(14, 2)
              , 1              -- RowStatus - bit
              , 'SYS-CAQUINO2'  -- TokenCreated - varchar(50)
              , GETDATE()      -- DateCreated - datetime
              , NULL           -- TokenUpdated - varchar(50)
              , NULL           -- DateUpdated - datetime
              , NULL           -- LimitHourDelivery - time(7)
              , NULL           -- LimitHourPickup - time(7)
              , NULL           -- WeightFrom - decimal(12, 2)
              , NULL           -- WeightTo - decimal(12, 2)
              , NULL           -- PackagesFrom - int
              , NULL           -- PackagesTo - int
                );

				SELECT SCOPE_IDENTITY()
				
        END;
        ELSE
        BEGIN
            SELECT 'Error datos nulos'
                 , @SegmentTypeId
                 , @PackageTypeId
                 , @ServiceTypeId;
        END;

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 500             'ResultCode'
             , ERROR_MESSAGE() 'ResultMessage';

    END CATCH;
END;