-- =============================================
-- Author: <Daniel Ramirez>
-- Create date: <2024-09-12>
-- Description: < Procedimiento para actualizar balance por cliente para COD anticipado>
-- =============================================
CREATE PROCEDURE spUpdateBalanceByIdClient
(
 @AnticipatedCODDetail AS TblAnticipatedCODCustomerBalance READONLY
)
AS
BEGIN
    -- Declarar variables para control de transacción
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    -- Iniciar bloque TRY
    BEGIN TRY
        -- Iniciar una transacción
       BEGIN TRANSACTION;

       -- Valida la existencia de las tablas temporales
       IF OBJECT_ID('tempdb..#CustomerAnticipatedCOD', 'U') IS NOT NULL 
       BEGIN
           ALTER TABLE #CustomerAnticipatedCOD
           DROP CONSTRAINT PK_spUpdateBalanceByIdClient_CACOD
       END

       -- Valida la existencia de las tablas temporales
       IF OBJECT_ID('tempdb..#CustomerAnticipatedCOD', 'U') IS NOT NULL 
       BEGIN
           DROP TABLE #CustomerAnticipatedCOD
       END

       IF OBJECT_ID('tempdb..#AnticipatedCODSummary', 'U') IS NOT NULL 
       BEGIN
           ALTER TABLE #AnticipatedCODSummary
           DROP CONSTRAINT UQ_AnticipatedCODSummary
       END

       IF OBJECT_ID('tempdb..#AnticipatedCODSummary', 'U') IS NOT NULL 
       BEGIN
           DROP TABLE #AnticipatedCODSummary
       END

       -- Crear la tabla temporal
       CREATE TABLE #CustomerAnticipatedCOD (
           CustomerId                 INT            NOT NULL,  -- ID del cliente
           PortfolioId                INT            NOT NULL, -- ID del portafolio
           IdAnticipatedCODHeader     INT            NOT NULL,  -- ID del encabezado de COD anticipado
           IdAnticipatedCODDetail     INT            NOT NULL,      -- ID del detalle de COD anticipado
           CollectOnDelivery          DECIMAL(18, 2) NULL,      -- Monto diario
           BalanceStatus              NVARCHAR(100)  NULL       -- Estado del saldo
       );

       -- Crear una llave primaria clúster en la tabla temporal
       ALTER TABLE #CustomerAnticipatedCOD
       ADD CONSTRAINT PK_spUpdateBalanceByIdClient_CACOD PRIMARY KEY CLUSTERED (IdAnticipatedCODHeader,IdAnticipatedCODDetail,PortfolioId,CustomerId);

        -- Crear la tabla temporal
        CREATE TABLE #AnticipatedCODSummary (
            IdAnticipatedCODHeader INT NOT NULL,         -- ID del encabezado de COD anticipado
            CustomerId             INT NOT NULL,         -- ID del cliente
            PortfolioId            INT NOT NULL,         -- ID del portafolio
            Amount                 DECIMAL(18, 2) NULL,  -- Monto total
            AmountByPayed          DECIMAL(18, 2) NULL,  -- Monto pagado
            Result AS (Amount - AmountByPayed)           -- Resultado calculado (columna computada)
        );

        ALTER TABLE #AnticipatedCODSummary
        ADD CONSTRAINT UQ_AnticipatedCODSummary PRIMARY KEY CLUSTERED (IdAnticipatedCODHeader,CustomerId,PortfolioId);

        INSERT INTO #CustomerAnticipatedCOD
        SELECT ach.CustomerId, 
               ISNULL(ach.PortfolioId,0), 
               ach.IdAnticipatedCODHeader,
               acd.IdAnticipatedCODDetail,
               acd.CollectOnDelivery, 
               acd.BalanceStatus
          FROM @AnticipatedCODDetail td 
               LEFT JOIN AnticipatedCODHeader ach
                  ON ach.CustomerId = td.CustomerId
                 AND ach.PortfolioId IS NULL
                 AND ach.RowStatus = 1
               INNER JOIN AnticipatedCODDetail acd WITH(NOLOCK)
                  ON ach.IdAnticipatedCODHeader = acd.AnticipatedCODHeaderId
                 AND acd.RowStatus = 1
         WHERE td.PortfolioId = 0
           AND ach.CustomerId IS NOT NULL

        INSERT INTO #CustomerAnticipatedCOD
        SELECT ach.CustomerId, 
               ISNULL(ach.PortfolioId,0), 
               ach.IdAnticipatedCODHeader,
               acd.IdAnticipatedCODDetail,
               acd.CollectOnDelivery, 
               acd.BalanceStatus
          FROM @AnticipatedCODDetail td 
               LEFT JOIN AnticipatedCODHeader ach
                  ON ach.CustomerId = td.CustomerId
                 AND ach.PortfolioId = td.PortfolioId
                 AND ach.RowStatus = 1
               INNER JOIN AnticipatedCODDetail acd WITH(NOLOCK)
                  ON ach.IdAnticipatedCODHeader = acd.AnticipatedCODHeaderId
                 AND acd.RowStatus = 1
         WHERE td.PortfolioId != 0
           AND ach.CustomerId IS NOT NULL

        INSERT INTO #AnticipatedCODSummary
        SELECT achs.IdAnticipatedCODHeader,
               achs.CustomerId,
               ISNULL(achs.PortfolioId,0) AS PortfolioId,
               ISNULL(AllDetail.Amount,0) AS Total, 
               ISNULL(AmountByPayed.Amount,0) AS Pagada
          FROM AnticipatedCODHeader achs WITH(NOLOCK)
               OUTER APPLY (
                      SELECT ISNULL(SUM(CollectOnDelivery),0) AS Amount, 
                             dts.CustomerId,
                             dts.PortfolioId
                        FROM #CustomerAnticipatedCOD dts 
                       WHERE dts.CustomerId = achs.CustomerId
                         AND dts.PortfolioId = 0
                         AND dts.BalanceStatus IN ('DEVOLUCION',
                                                   'PENDIENTE',
                                                   'PAGADO')
                       GROUP BY dts.CustomerId, dts.PortfolioId
               ) AS AllDetail
               OUTER APPLY (
                      SELECT ISNULL(SUM(CollectOnDelivery),0) AS Amount,
                             dts.CustomerId,
                             dts.PortfolioId
                        FROM #CustomerAnticipatedCOD dts 
                       WHERE dts.CustomerId = achs.CustomerId
                         AND dts.PortfolioId = 0
                         AND dts.BalanceStatus IN ('PAGADO')
                       GROUP BY dts.CustomerId, dts.PortfolioId
               ) AS AmountByPayed
               RIGHT JOIN #CustomerAnticipatedCOD cacod 
                     ON cacod.CustomerId = achs.CustomerId
                    AND cacod.PortfolioId = 0
                    AND achs.CustomerId IS NOT NULL
        WHERE achs.PortfolioId IS NULL
        GROUP BY achs.IdAnticipatedCODHeader,
                 achs.CustomerId,
                 achs.PortfolioId,
                 AllDetail.Amount,
                 AmountByPayed.Amount

        INSERT INTO #AnticipatedCODSummary
        SELECT achs.IdAnticipatedCODHeader,
               achs.CustomerId,
               ISNULL(achs.PortfolioId,0) AS PortfolioId,
               ISNULL(AllDetail.Amount,0) AS Total, 
               ISNULL(AmountByPayed.Amount,0) AS Pagada
          FROM AnticipatedCODHeader achs WITH(NOLOCK)
               OUTER APPLY (
                      SELECT ISNULL(SUM(CollectOnDelivery),0) AS Amount, 
                             dts.CustomerId,
                             dts.PortfolioId
                        FROM #CustomerAnticipatedCOD dts
                       WHERE dts.CustomerId = achs.CustomerId
                         AND dts.PortfolioId = achs.PortfolioId
                         AND dts.PortfolioId != 0
                         AND dts.BalanceStatus IN ('DEVOLUCION',
                                                   'PENDIENTE',
                                                   'PAGADO')
                       GROUP BY dts.CustomerId, dts.PortfolioId
               ) AS AllDetail
               OUTER APPLY (
                      SELECT ISNULL(SUM(CollectOnDelivery),0) AS Amount,
                             dts.CustomerId,
                             dts.PortfolioId
                        FROM #CustomerAnticipatedCOD dts
                       WHERE dts.CustomerId = achs.CustomerId
                         AND dts.PortfolioId = achs.PortfolioId
                         AND dts.PortfolioId != 0
                         AND dts.BalanceStatus IN ('PAGADO')
                       GROUP BY dts.CustomerId, dts.PortfolioId
               ) AS AmountByPayed
               RIGHT JOIN #CustomerAnticipatedCOD cacod 
                       ON cacod.CustomerId = achs.CustomerId
                      AND cacod.PortfolioId = achs.PortfolioId
                      AND cacod.PortfolioId != 0
                      AND achs.CustomerId IS NOT NULL
         WHERE achs.PortfolioId IS NOT NULL
         GROUP BY achs.IdAnticipatedCODHeader,
                  achs.CustomerId,
                  achs.PortfolioId,
                  AllDetail.Amount,
                  AmountByPayed.Amount

        UPDATE ach
           SET ach.Balance = da.Result
          FROM #AnticipatedCODSummary da 
               LEFT JOIN AnticipatedCODHeader ach WITH(NOLOCK)
                 ON ach.customerId = da.customerId
                AND ach.PortfolioId IS NULL
                AND ach.IdAnticipatedCODHeader = da.IdAnticipatedCODHeader
          WHERE da.PortfolioId = 0
            AND ach.CustomerId IS NOT NULL;

        IF @@ROWCOUNT = 0
        BEGIN
            -- Si no hubo modificaciones, puedes registrar un mensaje o manejarlo
            PRINT 'No hay filas modificadas con PortFolioId Nulo';
        END;

        UPDATE ach
           SET ach.Balance = da.Result
          FROM #AnticipatedCODSummary da 
               LEFT JOIN AnticipatedCODHeader ach WITH(NOLOCK)
                 ON ach.customerId = da.customerId
                AND ach.PortfolioId = da.PortfolioId
                AND ach.IdAnticipatedCODHeader = da.IdAnticipatedCODHeader
          WHERE da.PortfolioId != 0
            AND ach.CustomerId IS NOT NULL;

        IF @@ROWCOUNT = 0
        BEGIN
            -- Si no hubo modificaciones, puedes registrar un mensaje o manejarlo
            PRINT 'No hay filas modificadas con PortFolioId ';
        END;

       -- Valida la existencia de las tablas temporales
       IF OBJECT_ID('tempdb..#CustomerAnticipatedCOD', 'U') IS NOT NULL 
       BEGIN
           ALTER TABLE #CustomerAnticipatedCOD
           DROP CONSTRAINT PK_spUpdateBalanceByIdClient_CACOD
       END

       -- Valida la existencia de las tablas temporales
       IF OBJECT_ID('tempdb..#CustomerAnticipatedCOD', 'U') IS NOT NULL 
       BEGIN
           DROP TABLE #CustomerAnticipatedCOD
       END

       IF OBJECT_ID('tempdb..#AnticipatedCODSummary', 'U') IS NOT NULL 
       BEGIN
           ALTER TABLE #AnticipatedCODSummary
           DROP CONSTRAINT UQ_AnticipatedCODSummary
       END

       IF OBJECT_ID('tempdb..#AnticipatedCODSummary', 'U') IS NOT NULL 
       BEGIN
           DROP TABLE #AnticipatedCODSummary
       END

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description',
               ERROR_LINE() AS 'ERROR_LINE',
               ERROR_PROCEDURE() AS 'ERROR_PROCEDURE',
               CONVERT(BIGINT, 0) AS 'NumTransferID';

        -- Obtener detalles del error
        IF XACT_STATE() = -1
        BEGIN
            -- Si la transacción está en un estado no válido
            PRINT 'Ocurrio un error, la transacción fue revertida.';
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            -- Si la transacción sigue activa, pero se puede cometer
            PRINT 'Error durante la transacción';
        END;

        print ERROR_MESSAGE()
        PRINT ERROR_MESSAGE()   ;
        PRINT ERROR_LINE()      ;
        PRINT ERROR_PROCEDURE() ;

        -- Valida la existencia de las tablas temporales
        IF OBJECT_ID('tempdb..#CustomerAnticipatedCOD', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #CustomerAnticipatedCOD
            DROP CONSTRAINT PK_spUpdateBalanceByIdClient_CACOD
        END

        -- Valida la existencia de las tablas temporales
        IF OBJECT_ID('tempdb..#CustomerAnticipatedCOD', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #CustomerAnticipatedCOD
        END

        IF OBJECT_ID('tempdb..#AnticipatedCODSummary', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #AnticipatedCODSummary
            DROP CONSTRAINT UQ_AnticipatedCODSummary
        END

        IF OBJECT_ID('tempdb..#AnticipatedCODSummary', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #AnticipatedCODSummary
        END

        ROLLBACK TRANSACTION;
    END CATCH
END;
GO