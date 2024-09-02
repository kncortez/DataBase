--CLONAR X TARIFARIO
SELECT  *  FROM [DeliveryBackOffice].[dbo].[RateTownshipCoverage]  WITH (NOLOCK) --LLENAR X TARIFARIO
WHERE RateId = 2285 
--WHERE RateId BETWEEN 346 AND 643

SELECT * FROM DeliveryBackOffice.dbo.Township
where IdProvince BETWEEN 23 and  40

SELECT * FROM DeliveryBackOffice.dbo.Province
where Idcountry = 'HN'

SELECT * FROM DeliveryBackOffice.dbo.CatRateSegment 
WHERE IdCountry = 'HN'

SELECT  SegmentTypeId, COUNT(*)  FROM [DeliveryBackOffice].[dbo].[RateTownshipCoverage]  WITH (NOLOCK) --LLENAR X TARIFARIO
WHERE RateId = 2285 
GROUP BY SegmentTypeId

SELECT SegmentTypeId, TownshipSourceId, COUNT(*)  FROM [DeliveryBackOffice].[dbo].[RateTownshipCoverage]  WITH (NOLOCK) --LLENAR X TARIFARIO
WHERE RateId = 2285 
GROUP BY SegmentTypeId, TownshipSourceId
order by SegmentTypeId, TownshipSourceId


--SCRIPT PARA INGRESAR DATOS DE HN

DECLARE @RateID INT = 3675 --(TARIFARIO 3675 , ALTERNATIVO 3676)
DECLARE @Segment INT = 14 --(14 AL 26 CORRIDO)
DECLARE @MinTownship INT = 23  --Valor minimo de Id que tenga township en HN
DECLARE @MaxTownship INT = 40  --Valor maximo de Id que tenga township en HN
DECLARE @Status INT = 1 --activos
Declare @TokenCreated NVARCHAR(50) = 'SYS-WOROZCO'
DECLARE @DateCreated DATETIME = GETDATE();

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @SourceId INT;
    DECLARE @DestinyId INT;

    SET @SourceId = @MinTownship;
    WHILE @SourceId <= @MaxTownship
    BEGIN
        SET @DestinyId = @MinTownship;
        WHILE @DestinyId <= @MaxTownship
        BEGIN
            IF @SourceId <> @DestinyId
            BEGIN
                INSERT INTO [dbo].[RateTownshipCoverage]
                    ([RateId]
                    ,[TownshipSourceId]
                    ,[TownshipDestinyId]
                    ,[SegmentTypeId]
                    ,[RowStatus]
                    ,[TokenCreated]
                    ,[DateCreated]
                    ,[TokenUpdated]
                    ,[DateUpdated])
                VALUES
                    (@RateID
                    ,@SourceId
                    ,@DestinyId
                    ,@Segment
                    ,@Status
                    ,@TokenCreated
                    ,@DateCreated
                    ,NULL
                    ,NULL);
            END;
            SET @DestinyId = @DestinyId + 1;
        END;
        SET @SourceId = @SourceId + 1;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Imprimir los detalles del error para fines de depuración
    PRINT 'Error inserting data: ' + @ErrorMessage;
    PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS NVARCHAR);
    PRINT 'Error State: ' + CAST(@ErrorState AS NVARCHAR);
END CATCH;








