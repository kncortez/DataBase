CREATE PROCEDURE [dbo].[supportCreateSettlement]
    @SettlementName NVARCHAR(200)
  , @IdTownship INT
  , @HubAbrevation NVARCHAR(3)
  , @RouteName NVARCHAR(50)
  , @IdCountry NVARCHAR(2)
  , @token NVARCHAR(50)
AS
BEGIN

    BEGIN TRY


        DECLARE @IdProvince INT =
                (
                    SELECT TOP 1 IdProvince FROM dbo.Township WHERE IdTownship = @IdTownship
                );

        DECLARE @NewIdSettlement INT;

        DECLARE @HeaderCode NVARCHAR(20) =
                (
                    SELECT TOP 1 HeaderCode FROM dbo.Township WHERE IdTownship = @IdTownship
                );


        BEGIN TRANSACTION;

        INSERT INTO dbo.Settlement
        (
            Settlement
          , SettlementLatitud
          , SettlementLongitud
          , PostalCode
          , SettlementSatus
          , IdTownship
          , IdProvince
          , IdCountry
          , IsSpecial
          , TokenCreated
          , DateCreated
          , TokenUpdated
          , DateUpdated
          , oldSettlement
        )
        VALUES
        (   @SettlementName -- Settlement - nvarchar(100)
          , NULL            -- SettlementLatitud - decimal(9, 6)
          , NULL            -- SettlementLongitud - decimal(9, 6)
          , NULL            -- PostalCode - nvarchar(5)
          , 1               -- SettlementSatus - bit
          , @IdTownship     -- IdTownship - int
          , @IdProvince     -- IdProvince - int
          , @IdCountry      -- IdCountry - nvarchar(2)
          , 0               -- IsSpecial - bit
          , @token          -- TokenCreated - nvarchar(50)
          , GETDATE()       -- DateCreated - datetime
          , NULL            -- TokenUpdated - nvarchar(50)
          , NULL            -- DateUpdated - datetime
          , NULL            -- oldSettlement - nvarchar(100)
            );


        SET @NewIdSettlement = SCOPE_IDENTITY();


        INSERT INTO dbo.DumpServiceCoverage
        (
            DumpFileName
          , DumpVersion
          , HeaderCode
          , IdSettlement
          , Coverage
          , DeliveryTime
          , Hub
          , RouteCode
          , SDD
          , NDD
          , TDA
          , RowStatus
          , TokenCreated
          , DateCreated
          , TokenUpdated
          , DateUpdated
        )
        VALUES
        (   'sp_support'     -- DumpFileName - nvarchar(100)
          , NULL             -- DumpVersion - nvarchar(50)
          , @HeaderCode      -- HeaderCode - varchar(10)
          , @NewIdSettlement -- IdSettlement - bigint
          , 'Lun-Sab'        -- Coverage - nvarchar(50)
          , '24 - 48 Horas'  -- DeliveryTime - nvarchar(50)
          , @HubAbrevation   -- Hub - nvarchar(50)
          , @RouteName       -- RouteCode - nvarchar(100)
          , 0                -- SDD - bit
          , 1                -- NDD - bit
          , 0                -- TDA - bit
          , 1                -- RowStatus - bit
          , @token           -- TokenCreated - nvarchar(50)
          , GETDATE()        -- DateCreated - datetime
          , NULL             -- TokenUpdated - nvarchar(50)
          , NULL             -- DateUpdated - datetime
            );

        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
    END CATCH;



END;