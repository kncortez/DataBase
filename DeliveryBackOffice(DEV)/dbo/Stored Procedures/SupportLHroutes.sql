CREATE PROCEDURE [dbo].[SupportLHroutes]
    @CodeRoute NVARCHAR(100),
    @HubOrigenAbbr VARCHAR(10),
    @Cobertura VARCHAR(MAX)
AS
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @NewRouteId INT;

    --  2. CONVERTIR COBERTURA A TABLA
    IF OBJECT_ID('tempdb..#Cobertura') IS NOT NULL
        DROP TABLE #Cobertura;

    SELECT DISTINCT
           TRIM(Item) AS HubAbbreviation
    INTO #Cobertura
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@Cobertura, ',');


    -- 3. OBTENER ID DEL HUB ORIGEN
    DECLARE @HubOriginId INT;

    SELECT @HubOriginId = IdHubLogistic
    FROM dbo.HubLogistics
    WHERE HubAbbreviation = @HubOrigenAbbr;

    IF @HubOriginId IS NULL
    BEGIN
        RAISERROR('EL HUB ORIGEN NO EXISTE EN HubLogistics', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;


    --  4. OBTENER IDS DE HUBS DESTINO
    IF OBJECT_ID('tempdb..#HubsDestino') IS NOT NULL
        DROP TABLE #HubsDestino;

    SELECT h.IdHubLogistic,
           h.HubAbbreviation
    INTO #HubsDestino
    FROM HubLogistics h
        INNER JOIN #Cobertura c
            ON c.HubAbbreviation = h.HubAbbreviation
    WHERE h.HubStatus = 1;


    --  5. VALIDAR HUBS INEXISTENTES
    IF EXISTS
    (
        SELECT 1
        FROM #Cobertura c
            LEFT JOIN #HubsDestino h
                ON c.HubAbbreviation = h.HubAbbreviation
        WHERE h.IdHubLogistic IS NULL
    )
    BEGIN
        RAISERROR('EXISTEN HUBS DE COBERTURA QUE NO EXISTEN EN HubLogistics', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;


    IF EXISTS
    (
        SELECT *
        FROM dbo.CatRoute ct
        WHERE ct.CodeRoute = @CodeRoute
              AND ct.IdTypeRoute = 2
    )
    BEGIN
        SELECT 'error la ruta ya existe';


    END;
    ELSE
    BEGIN

        INSERT INTO dbo.CatRoute
        (
            CodeRoute,
            Description,
            IdTownship,
            IdTypeRoute,
            Zone,
            RowStatus,
            TokenCreated,
            DateCreated,
            TokenUpdated,
            DateUpdated,
            CountryId
        )
        VALUES
        (   @CodeRoute, -- CodeRoute - varchar(100)
            @CodeRoute, -- Description - varchar(200)
            NULL,       -- IdTownship - int
            2,          -- IdTypeRoute - int
            NULL,       -- Zone - varchar(50)
            0,          -- RowStatus - bit
            'NEWROUTE', -- TokenCreated - varchar(50)
            GETDATE(),  -- DateCreated - datetime
            NULL,       -- TokenUpdated - varchar(50)
            NULL,       -- DateUpdated - datetime
            'GT'        -- CountryId - varchar(2)
            );
        SET @NewRouteId = SCOPE_IDENTITY();




    END;

    --   6. INSERT MASIVO EN LinehaulCoverage
    INSERT INTO dbo.LinehaulCoverage
    (
        CatRouteId,
        HubOriginId,
        HubDestinyId,
        ReportEmails,
        RowStatus,
        TokenCreated,
        DateCreated,
        TokenUpdated,
        DateUpdated,
        ReportPhones
    )
    SELECT @NewRouteId,
           @HubOriginId,
           h.IdHubLogistic,
           '',
           1,
           'NEWROUTECOVERAGE',
           GETDATE(),
           NULL,
           NULL,
           NULL
    FROM #HubsDestino h
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.LinehaulCoverage lc
        WHERE lc.CatRouteId = @NewRouteId
              AND lc.HubOriginId = @HubOriginId
              AND lc.HubDestinyId = h.IdHubLogistic
    );


    COMMIT TRANSACTION;
    PRINT 'LINEHAUL COVERAGE CREADO CORRECTAMENTE';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    SELECT ERROR_MESSAGE() AS ErrorMessage,
           ERROR_LINE() AS ErrorLine,
           ERROR_PROCEDURE() AS ErrorProcedure;
END CATCH;