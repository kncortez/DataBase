

CREATE PROCEDURE [dbo].[SupportCreateSttlement]
    -- Add the parameters for the stored procedure here
    @HeaderCode NVARCHAR(5)
  , @SetlementName VARCHAR(100)
  , @HUB NVARCHAR(3)
  , @Token NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        IF EXISTS
        (
            SELECT *
            FROM dbo.Township twn
            WHERE twn.HeaderCode = @HeaderCode
        )
        BEGIN
            DECLARE @idProvice INT;
            DECLARE @IdTownship INT;
            DECLARE @IdCountry NVARCHAR(2);

            SELECT @idProvice  = pr.IdProvince
                 , @IdTownship = twn.IdTownship
                 , @IdCountry  = pr.IdCountry
            FROM dbo.Township       twn
                INNER JOIN Province pr
                    ON pr.IdProvince = twn.IdProvince
            WHERE twn.HeaderCode = @HeaderCode;


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
            )
            VALUES
            (   @SetlementName -- Settlement - nvarchar(100)
              , NULL           -- SettlementLatitud - decimal(9, 6)
              , NULL           -- SettlementLongitud - decimal(9, 6)
              , NULL           -- PostalCode - nvarchar(5)
              , 1              -- SettlementSatus - bit
              , @IdTownship    -- IdTownship - int
              , @idProvice     -- IdProvince - int
              , @IdCountry     -- IdCountry - nvarchar(2)
              , NULL           -- IsSpecial - bit
              , @Token         -- TokenCreated - nvarchar(50)
              , GETDATE()      -- DateCreated - datetime
              , NULL           -- TokenUpdated - nvarchar(50)
              , NULL           -- DateUpdated - datetime
                );



            DECLARE @IdNewSetlement INT;
            SET @IdNewSetlement = SCOPE_IDENTITY();

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
            (   'Archivo Marco Reyna' -- DumpFileName - nvarchar(100)
              , 'V1.0'                -- DumpVersion - nvarchar(50)
              , @HeaderCode           -- HeaderCode - varchar(10)
              , @IdNewSetlement       -- IdSettlement - bigint
              , 'Lun-Sab'             -- Coverage - nvarchar(50)
              , '24 - 48 Horas'       -- DeliveryTime - nvarchar(50)
              , @HUB                  -- Hub - nvarchar(50)
              , NULL                  -- RouteCode - nvarchar(100)
              , NULL                  -- SDD - bit
              , 1                     -- NDD - bit
              , NULL                  -- TDA - bit
              , 1                     -- RowStatus - bit
              , @Token                -- TokenCreated - nvarchar(50)
              , GETDATE()             -- DateCreated - datetime
              , NULL                  -- TokenUpdated - nvarchar(50)
              , NULL                  -- DateUpdated - datetime
                );



            COMMIT;
        END;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;
END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportCreateSttlement] TO [cvaldes]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportCreateSttlement] TO [cvaldes]
    AS [dbo];

