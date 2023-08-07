-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2023-04-10>
-- Description:	<Sp para crear un hub y una estacion en modo centinela>
-- =============================================

CREATE PROCEDURE [dbo].[SupportCreateSentry]
    @SentryName NVARCHAR(50)
  , @SentryAbrevation NVARCHAR(5)
  , @SupportToken NVARCHAR(50)
  , @SentryDescription NVARCHAR(100)
  , @StationName NVARCHAR(50)
  , @CodeOfReferenceExc INT
  , @Routes INT
AS
BEGIN

    DECLARE @NewHublogisticsId INT;


    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.CatStation
        WHERE CodeOfReference = @CodeOfReferenceExc
              AND HubLogisticId IS NOT NULL
    )
    BEGIN

        IF @Routes
           BETWEEN 1 AND 9
        BEGIN

            IF EXISTS
            (
                SELECT 1
                FROM dbo.VisitPointClient vp
                WHERE vp.CodeOfReference = @CodeOfReferenceExc
                      AND vp.IdKindOfVPClient = 1
                      AND vp.IdKindOfVPBusiness = 8
                      AND vp.StatusClient = 1
            )
            BEGIN
                BEGIN TRY

                    BEGIN TRANSACTION;
                    INSERT dbo.HubLogistics
                    (
                        HubName
                      , HubAbbreviation
                      , HubStatus
                      , IdStation
                      , IdCountry
                      , TokenCreated
                      , DateCreated
                      , TokenUpdate
                      , DateUpdated
                      , IsGateway
                      , HubLatitude
                      , HubLongitude
                      , DescriptionCC
                    )
                    VALUES
                    (   @SentryName        -- HubName - varchar(50)
                      , @SentryAbrevation  -- HubAbbreviation - varchar(5)
                      , '1'                -- HubStatus - bit
                      , NULL               -- IdStation - int
                      , 'GT'               -- IdCountry - varchar(2)
                      , @SupportToken      -- TokenCreated - varchar(50)
                      , GETDATE()          -- DateCreated - datetime
                      , NULL               -- TokenUpdate - varchar(50)
                      , NULL               -- DateUpdated - datetime
                      , 0                  -- IsGateway - bit
                      , NULL               -- HubLatitude - nvarchar(20)
                      , NULL               -- HubLongitude - nvarchar(20)
                      , @SentryDescription -- DescriptionCC - nvarchar(100)
                        );

                    SELECT @NewHublogisticsId = SCOPE_IDENTITY();
                    INSERT dbo.CatStation
                    (
                        StationName
                      , CountryId
                      , StationType
                      , HubLogisticId
                      , CodeOfReference
                      , RowStatus
                      , TokenCreated
                      , DateCreated
                      , TokenUpdated
                      , DateUpdated
                    )
                    VALUES
                    (   @StationName        -- StationName - nvarchar(100)
                      , 'GT'                -- CountryId - varchar(2)
                      , 1                   -- StationType - int
                      , @NewHublogisticsId  -- HubLogisticId - int
                      , @CodeOfReferenceExc -- CodeOfReference - int
                      , 1                   -- RowStatus - bit
                      , @SupportToken       -- TokenCreated - nvarchar(50)
                      , GETDATE()           -- DateCreated - datetime
                      , NULL                -- TokenUpdated - nvarchar(50)
                      , NULL                -- DateUpdated - datetime
                        );
                    DECLARE @NewStationId INT;

                    SET @NewStationId = SCOPE_IDENTITY();


                    DECLARE @count INT = 1;

                    WHILE @count <= @Routes
                    BEGIN

                        DECLARE @IdTownship INT =
                                (
                                    SELECT TOP 1
                                           vp.IdTownship
                                    FROM dbo.VisitPointClient vp WITH (NOLOCK)
                                    WHERE @CodeOfReferenceExc = @CodeOfReferenceExc
                                );

                        INSERT INTO dbo.CatRoute
                        (
                            CodeRoute
                          , Description
                          , IdTownship
                          , IdTypeRoute
                          , Zone
                          , RowStatus
                          , TokenCreated
                          , DateCreated
                          , TokenUpdated
                          , DateUpdated
                        )
                        VALUES
                        (   CONCAT(@SentryAbrevation, '-', CONVERT(NVARCHAR(1), @count)) -- CodeRoute - varchar(100)
                          , @SentryName                                                  -- Description - varchar(200)
                          , @IdTownship                                                  -- IdTownship - int
                          , 4                                                            -- IdTypeRoute - int -- rutas de última milla
                          , NULL                                                         -- Zone - varchar(50)
                          , 1                                                            -- RowStatus - bit
                          , @SupportToken                                                -- TokenCreated - varchar(50)
                          , GETDATE()                                                    -- DateCreated - datetime
                          , NULL                                                         -- TokenUpdated - varchar(50)
                          , NULL                                                         -- DateUpdated - datetime
                            );


                        SET @count = @count + 1;

                    END;



                    COMMIT TRANSACTION;
                    SELECT 'Datos insertados correctamente';
                    SELECT hb.IdHubLogistic
                         , hb.HubName
                         , hb.HubAbbreviation
                    FROM dbo.HubLogistics hb
                    WHERE hb.IdHubLogistic = @NewHublogisticsId;

                    SELECT cs.IdStation
                         , cs.StationName
                         , cs.CodeOfReference
                    FROM dbo.CatStation                 cs
                        INNER JOIN dbo.VisitPointClient vp
                            ON vp.CodeOfReference = cs.CodeOfReference
                    WHERE cs.IdStation = @NewStationId;


                    SELECT cr.IdRoute
                         , cr.CodeRoute
                         , cr.Description
                    FROM dbo.CatRoute cr WITH (NOLOCK)
                    WHERE cr.Description = @SentryName
                          AND cr.RowStatus = 1;

                END TRY
                BEGIN CATCH
                    ROLLBACK TRANSACTION;

                    SELECT ERROR_LINE()
                         , ERROR_MESSAGE()
                         , ERROR_NUMBER()
                         , ERROR_PROCEDURE()
                         , ERROR_STATE();
                END CATCH;
            END;
            ELSE
            BEGIN

                SELECT 'El punto de visita no exite o no esta configurado como exc, por favor verifica los campos IdKindOfVPClient = 1 , IdKindOfVPBusiness =8 y StatusClient= 1 ';

            END;

        END;
        ELSE
        BEGIN
            SELECT 'El número de rutas debe ser un número entero entre 1 y 9';
        END;
    END;
    ELSE
    BEGIN
        SELECT 'Este punto de visita ya esta configurado como centinela, verifique las tablas CatStation, HubLogistics y Catroute';
    END;

END;