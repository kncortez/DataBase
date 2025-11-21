
-------------------------------------------------------
-- 1) Creamos una tabla fisica, por la cantidad de registros que son 12M en develop
-------------------------------------------------------
IF OBJECT_ID('dbo.GuideStationStaging', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GuideStationStaging
    (
        GuideStationStagin BIGINT PRIMARY KEY IDENTITY(1,1),
		Guide_Serie NVARCHAR(10) NOT NULL,
        Guide_Number BIGINT NOT NULL,
        IdStation INT NOT NULL,
        CONSTRAINT UX_GuideStationStaging UNIQUE (Guide_Serie, Guide_Number) 
    );

    CREATE NONCLUSTERED INDEX IX_GSS_Guide
    ON dbo.GuideStationStaging (Guide_Serie, Guide_Number);

END
BEGIN TRY
    -------------------------------------------------------
    -- INSERTAMOS LAS GUIAS Y ESTACIONES QUE VAMOS ACTUALIZAR
    -------------------------------------------------------
    -- IMPORTANTE! TENER EN CUENTA QUE SON 12M DE REGSITROS EN DEVELOP POR LO QUE EL INSERT PODRIA TARDAR SIGNIFICATIVAMENTE
    TRUNCATE TABLE dbo.GuideStationStaging;

    ;WITH Candidates
    AS 
	(
		SELECT DISTINCT
            DOD.Guide_Serie,
            DOD.Guide_Number,
            cs2.IdStation,
            cs2.DateUpdated
        FROM dbo.LogTokenPOD LTK WITH (NOLOCK)
            INNER JOIN dbo.SenderReceiver SR WITH (NOLOCK)
                ON LTK.IdCourierman = SR.ID
            INNER JOIN dbo.DeliveryOrderBySettlement DBS WITH (NOLOCK)
                ON DBS.ID_Courier = SR.ID
            INNER JOIN dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
                ON DSD.ID_DeliveryOrderBySettlement = DBS.ID
            INNER JOIN dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
                ON DSD.Guide_Serie = DOD.Guide_Serie
                   AND DSD.Guide_Number = DOD.Guide_Number
            CROSS APPLY
        (
            SELECT TOP 1
                cs2.IdStation,
                cs2.DateUpdated
            FROM dbo.CatStation cs2 WITH (NOLOCK)
            WHERE cs2.HubLogisticId = SR.HubLogisticId
                  AND cs2.RowStatus = 1
            ORDER BY cs2.DateUpdated DESC
        ) cs2
        WHERE SR.HubLogisticId IS NOT NULL
              AND SR.Estatus = 1
       ),
          Ranked
    AS (SELECT *,
               ROW_NUMBER() OVER (PARTITION BY Guide_Serie,
                                               Guide_Number
                                  ORDER BY DateUpdated DESC,
                                           IdStation
                                 ) AS RN
        FROM Candidates
       )
    INSERT INTO dbo.GuideStationStaging
    (
        Guide_Serie,
        Guide_Number,
        IdStation
    )
    SELECT Guide_Serie,
           Guide_Number,
           IdStation
    FROM Ranked
    WHERE RN = 1;

    -------------------------------------------------------
    -- SELECCIONAOS LA CANTIDAD DE REGISTROS POR LOTE PARA PROCESARLAS
    -------------------------------------------------------
    DECLARE @BatchSize INT = 5000; 
    DECLARE @RowsAffected INT = 1;
    DECLARE @BatchesDone INT = 0;

    WHILE 1 = 1
    BEGIN
        -- TERMINAR SI YA NO HAY NADA PARA PROCESAR
        IF(SELECT COUNT(*) FROM dbo.GuideStationStaging) = 0
        BEGIN
            PRINT 'Staging vacío. Proceso terminado.';
            BREAK;
        END

        BEGIN TRAN;

        -- LLENAMOS LA TABLA CON LAS GUIAS QUE SE VAN A PROCESAR
        IF OBJECT_ID('tempdb..#Batch') IS NOT NULL
            DROP TABLE #Batch;

        SELECT TOP (@BatchSize)
            Guide_Serie,
            Guide_Number,
            IdStation
        INTO #Batch
        FROM dbo.GuideStationStaging
        ORDER BY Guide_Serie,
                 Guide_Number;

        -- VALIDAMOS QUE TENGA DATOS, SI NO SALIMOS DEL WHILE
        IF
        (
            SELECT COUNT(*) FROM #Batch
        ) = 0
        BEGIN
            DROP TABLE IF EXISTS #Batch;
            COMMIT;
            BREAK;
        END

        CREATE NONCLUSTERED INDEX IX_Batch_Guide
        ON #Batch
        (
            Guide_Serie,
            Guide_Number
        );


        UPDATE D
        SET D.StationId = B.IdStation
        FROM dbo.DeliveryOrderDetail D
            INNER JOIN #Batch B
                ON D.Guide_Serie = B.Guide_Serie
                   AND D.Guide_Number = B.Guide_Number
        WHERE D.StationId IS NULL;

        SET @RowsAffected = @@ROWCOUNT;

        -- BORRAMOS LAS GUIAS QUE YA FUERON PROCESADAS
        DELETE GS
        FROM dbo.GuideStationStaging GS
            INNER JOIN #Batch B2
                ON GS.Guide_Serie = B2.Guide_Serie
                   AND GS.Guide_Number = B2.Guide_Number;

        COMMIT;

        SET @BatchesDone = @BatchesDone + 1;
        PRINT CONCAT('Batch ', @BatchesDone, ' - Filas actualizadas: ', @RowsAffected);

        DROP TABLE IF EXISTS #Batch;
    END

    PRINT 'Proceso de actualización completado.';
END TRY
BEGIN CATCH
    SELECT @@ERROR,
           ERROR_MESSAGE(),
           ERROR_LINE()
END CATCH