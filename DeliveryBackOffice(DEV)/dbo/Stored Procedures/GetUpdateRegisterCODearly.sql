
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-12-03>
-- Description:	<Calcula las reglas de negocio que necesita COD anticipado>
-- =============================================
--EXEC GetUpdateRegisterCODearly
ALTER PROCEDURE [dbo].[GetUpdateRegisterCODearly] @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    BEGIN TRY
        DECLARE @GuideValueMount INT,
                @ReturnPercentMax INT,
                @DayMaxCOD DECIMAL(18, 2),
                @DayMount DATE,
                @DayThreeMount DATE,
                @CurrentRow INT = 1,
                @IdKindOfVPBusiness INT

        DECLARE @TempData TblAnticipatedCODCustomerBalance

        SET @GuideValueMount =
        (
            SELECT Value
            FROM ConfigParams
            WHERE Name = 'MinGuidesPerMonthParam'
                  AND IdCountry = @IdCountry
        )

        SET @ReturnPercentMax =
        (
            SELECT Value
            FROM ConfigParams
            WHERE Name = 'ReturnPercentParam'
                  AND IdCountry = @IdCountry
        )

        SET @DayMaxCOD =
        (
            SELECT Value
            FROM ConfigParams
            WHERE Name = 'IsOldestParam'
                  AND IdCountry = @IdCountry
        )

        SET @IdKindOfVPBusiness =
        (
            SELECT IdKindOfVPBusiness
            FROM KindOfVPBusiness
            WHERE KindOfVPNameBussiness = 'EXPRESS CENTER'
                  AND ISNULL(IdCountry, 'GT') = @IdCountry
        )

        SET @DayMount = (DATEADD(DAY, -30, GETDATE()))
        SET @DayThreeMount = (DATEADD(DAY, -90, GETDATE()))

        IF OBJECT_ID('tempdb.dbo.#TempDate', 'U') IS NOT NULL
            DROP TABLE #TempDate;

        IF OBJECT_ID('tempdb.dbo.#Temp30Days', 'U') IS NOT NULL
            DROP TABLE #Temp30Days;

        IF OBJECT_ID('tempdb.dbo.#Temp90Days', 'U') IS NOT NULL
            DROP TABLE #Temp90Days;

        IF OBJECT_ID('tempdb.dbo.#TempFlagDatee', 'U') IS NOT NULL
            DROP TABLE #TempFlagDatee;

        IF OBJECT_ID('tempdb.dbo.#TempMinDate', 'U') IS NOT NULL
            DROP TABLE #TempMinDate;

        IF OBJECT_ID('tempdb.dbo.#TempGuideSummary', 'U') IS NOT NULL
            DROP TABLE #TempGuideSummary;

        IF OBJECT_ID('tempdb.dbo.#TempReturnSummary', 'U') IS NOT NULL
            DROP TABLE #TempReturnSummary;

        IF OBJECT_ID('tempdb.dbo.#CodAnticipated', 'U') IS NOT NULL
            DROP TABLE #CodAnticipated;

        IF OBJECT_ID('tempdb.dbo.#TempMinDates', 'U') IS NOT NULL
            DROP TABLE #TempMinDates;

        BEGIN TRANSACTION

        -- FECHA MINIMA
       SELECT C.IdCustomer,
              NULL AS PortfolioID,
              CLIENT.FirstDate
         INTO #TempDate
         FROM DeliveryBackOffice.dbo.Customer C WITH (NOLOCK)
              OUTER APPLY (
                          SELECT ISNULL(MIN(CAST(do.DateCreated AS DATE) ),NULL) AS FirstDate
                            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                           WHERE C.IdCustomer = do.IdCustomer
                           GROUP BY do.IdCustomer
              ) AS Client
        WHERE C.IdCustomerType IN ( 1, 3 )
          AND ISNULL(C.CountryID, 'GT') = @IdCountry
        ORDER BY IdCustomer DESC

        CREATE NONCLUSTERED INDEX IX_TempDate_IdCustomer
        ON #TempDate (IdCustomer);

        -- DATOS DE 30 DÍAS
        SELECT C.IdCustomer,
               NULL AS PortfolioID,
               (
                   SELECT COUNT(Guide_Number)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = c.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayMount AND GETDATE()
               ) AS NumbersGuides,
               (
                   SELECT SUM(Collect_OnDelivery)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = c.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayMount AND GETDATE()
               ) AS AmountCOD
        INTO #Temp30Days
        FROM #TempDate C


        -- DATOS DE 90 DÍAS
        SELECT c.IdCustomer,
               NULL AS PortfolioID,
               (
                   SELECT COUNT(IsReturn)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = c.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayThreeMount AND GETDATE()
                         AND do.IsReturn = 1
               ) AS IsReturn,
               (
                   SELECT COUNT(IsReturn)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = c.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayThreeMount AND GETDATE()
               ) CountReturn
        INTO #Temp90Days
        FROM #TempDate c

        PRINT 'FIN A CLIENTES TIPO 1 Y 3'
        --CLIENTES TIPO 2

        /**************TRAEMOS TODOS LOS CLIENTES DE CARTERA DE LOS EXPRES CENTER************************/
        SELECT do.IdCustomer,
               do.VisitPointClientPortfolioId AS PortfolioID,
               MIN(CAST(do.DateCreated AS DATE)) AS FirstDate
        INTO #TempMinDates
        FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
        GROUP BY do.IdCustomer,
                 DO.VisitPointClientPortfolioId

        SELECT CT.IdCustomer,
               VPP.IdVisitPointByClientPortfolio AS PortfolioID,
               TM.FirstDate
        INTO #TempMinDate
        FROM DeliveryBackOffice.dbo.VisitPointClient VP WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPP WITH (NOLOCK)
                ON VP.IdVisitPointClient = VPP.VisitPointId
            INNER JOIN DeliveryBackOffice.dbo.Customer CT WITH (NOLOCK)
                ON VP.CustomerID = CT.IdCustomer
            LEFT JOIN #TempMinDates TM
                ON TM.IdCustomer = CT.IdCustomer
                   AND TM.PortfolioID = VPP.IdVisitPointByClientPortfolio
        WHERE CT.IdCustomerType = 2
              AND ISNULL(VP.CountryID, 'GT') = @IdCountry
              AND IdKindOfVPBusiness = @IdKindOfVPBusiness

        PRINT 'FIN PRIMERA FECHA'

        CREATE NONCLUSTERED INDEX IX_TempMinDate_IdCustomer
        ON #TempMinDate
        (
            IdCustomer,
            PortfolioID
        );

        SELECT CU.IdCustomer,
               CU.PortfolioID AS PortfolioID,
               (
                   SELECT COUNT(Guide_Number)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = CU.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayMount AND GETDATE()
                         AND DO.VisitpointClientPortfolioId = CU.PortfolioID
               ) AS NumbersGuides,
               (
                   SELECT SUM(Collect_OnDelivery)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = CU.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayMount AND GETDATE()
                         AND DO.VisitpointClientPortfolioId = CU.PortfolioID
               ) AS AmountCOD
        INTO #TempGuideSummary
        FROM #TempMinDate CU

        PRINT 'FIN 30 DÍAS'


        SELECT CU.IdCustomer,
               CU.PortfolioID AS PortfolioID,
               (
                   SELECT COUNT(IsReturn)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = CU.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayThreeMount AND GETDATE()
                         AND DO.VisitpointClientPortfolioId = CU.PortfolioID
                         AND do.IsReturn = 1
               ) AS IsReturn,
               (
                   SELECT COUNT(IsReturn)
                   FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                   WHERE do.IdCustomer = CU.IdCustomer
                         AND do.DateCreated
                         BETWEEN @DayThreeMount AND GETDATE()
                         AND DO.VisitpointClientPortfolioId = CU.PortfolioID
               ) CountReturn
        INTO #TempReturnSummary
        FROM #TempMinDate CU

        PRINT 'SE EMPIEZAN HACER LOS CALCULOS'

        --INSERT A TABLA CABECERA DE CLIENTES PARA COD ANTICIPADO
        SELECT IdCustomer,
               PortfolioId,
               CAST(GETDATE() AS DATE) AS DailyDate,
               ISNULL(DATEDIFF(DAY, FirstDate, GETDATE()), 0) AS IsOldest,
               ISNULL((IsReturn * 100.0) / NULLIF(CountReturn, 0), 0) AS ReturnPercent,
               NumbersGuide AS MinGuidesPerMonth,
               CAST(AmountCOD / 30 AS DECIMAL(12, 2)) AS DailyAmount,
               CASE
                   WHEN NumbersGuide > @GuideValueMount
                        AND CAST((ISNULL((IsReturn * 100.0) / NULLIF(CountReturn, 0), 0)) AS DECIMAL(8, 2)) < @ReturnPercentMax
                        AND ISNULL(DATEDIFF(DAY, FirstDate, GETDATE()), 0) > @DayMaxCOD THEN
                       1
                   ELSE
                       0
               END AS IsCODAnticipatedValid,
               1 AS RowStatus,
               'SYS-GetUpdateRegisterCODearly' AS TokenCreated,
               CAST(GETDATE() AS DATE) AS DateCreated
        INTO #CodAnticipated
        FROM
        (
            SELECT DISTINCT
                TMD.IdCustomer,
                TMD.FirstDate,
                NULL AS PortfolioId,
                ISNULL(TM30.NumbersGuides, 0) AS NumbersGuide,
                ISNULL(TM30.AmountCOD, 0) AS AmountCOD,
                ISNULL(TM90.IsReturn, 0) AS IsReturn,
                ISNULL(TM90.CountReturn, 0) AS CountReturn
            FROM #TempDate TMD
                LEFT JOIN #Temp30Days TM30
                    ON TMD.IdCustomer = TM30.IdCustomer
                LEFT JOIN #Temp90Days TM90
                    ON TMD.IdCustomer = TM90.IdCustomer
            UNION ALL
            SELECT DISTINCT
                TMD.IdCustomer,
                TMD.FirstDate,
                TMD.PortfolioID,
                ISNULL(TM30.NumbersGuides, 0) AS NumbersGuide,
                ISNULL(TM30.AmountCOD, 0) AS AmountCOD,
                ISNULL(TM90.IsReturn, 0) AS IsReturn,
                ISNULL(TM90.CountReturn, 0) AS CountReturn
            FROM #TempMinDate TMD
                LEFT JOIN #TempGuideSummary TM30
                    ON TMD.IdCustomer = TM30.IdCustomer
                       AND TMD.PortfolioID = TM30.PortfolioID
                LEFT JOIN #TempReturnSummary TM90
                    ON TMD.IdCustomer = TM90.IdCustomer
                       AND TMD.PortfolioID = TM90.PortfolioID
        ) CodData


        IF
        (
            SELECT COUNT(*) FROM AnticipatedCODHeader WITH (NOLOCK)
        ) = 0
        BEGIN

            INSERT INTO DeliveryBackOffice.dbo.AnticipatedCODHeader
            (
                CustomerId,
                PortfolioId,
                DailyDate,
                IsOldest,
                ReturnPercent,
                MinGuidesPerMonth,
                DailyAmount,
                IsCODAnticipatedValid,
                Balance,
                AgaintsBalance,
                RowStatus,
                TokenCreated,
                DateCreated
            )
            SELECT IdCustomer,
                   PortfolioId,
                   DailyDate,
                   IsOldest,
                   ReturnPercent,
                   MinGuidesPerMonth,
                   DailyAmount,
                   IsCODAnticipatedValid,
                   0,
                   0,
                   RowStatus,
                   TokenCreated,
                   DateCreated
            FROM #CodAnticipated

            INSERT INTO @TempData
            (
                CustomerId,
                PortfolioId
            )
            SELECT IdCustomer,
                   PortfolioId
            FROM #CodAnticipated

            EXEC spUpdateBalanceByIdClient @TempData

        END
        ELSE
        BEGIN

            --ACTUALIZACION DE CLIENTES EXISTENTES EN TABLA CABECERA DE CLIENTES TIPO 1 Y 3
            UPDATE DeliveryBackOffice.dbo.AnticipatedCODHeader
            SET DailyDate = ca.DailyDate,
                IsOldest = ca.IsOldest,
                ReturnPercent = ca.ReturnPercent,
                MinGuidesPerMonth = ca.MinGuidesPerMonth,
                DailyAmount = ca.DailyAmount,
                IsCODAnticipatedValid = ca.IsCODAnticipatedValid,
                DateUpdated = GETDATE(),
                TokenUpdated = 'SYS-GetUpdateRegisterCODearly'
            FROM #CodAnticipated ca
                INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH (NOLOCK)
                    ON ach.CustomerId = ca.IdCustomer
                       AND CA.PortfolioId IS NULL
                       AND ACH.PortfolioId IS NULL


            --ACTUALIZACION DE CLIENTES EXISTENTES EN TABLA CABECERA DE CLIENTES TIPO 2
            UPDATE DeliveryBackOffice.dbo.AnticipatedCODHeader
            SET DailyDate = ca.DailyDate,
                IsOldest = ca.IsOldest,
                ReturnPercent = ca.ReturnPercent,
                MinGuidesPerMonth = ca.MinGuidesPerMonth,
                DailyAmount = ca.DailyAmount,
                IsCODAnticipatedValid = ca.IsCODAnticipatedValid,
                DateUpdated = GETDATE(),
                TokenUpdated = 'SYS-GetUpdateRegisterCODearly'
            FROM #CodAnticipated ca
                INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH (NOLOCK)
                    ON ach.CustomerId = ca.IdCustomer
                       AND CA.PortfolioId = ach.PortfolioId


            --INSERCION DE NUEVOS CLIENTES QUE NO ESTABAN ANTES EN LA TABLA DE CABECERA CLIENTES TIPO 1 Y 3
            INSERT INTO DeliveryBackOffice.dbo.AnticipatedCODHeader
            (
                CustomerId,
                PortfolioId,
                DailyDate,
                IsOldest,
                ReturnPercent,
                MinGuidesPerMonth,
                DailyAmount,
                IsCODAnticipatedValid,
                Balance,
                AgaintsBalance,
                RowStatus,
                TokenCreated,
                DateCreated
            )
            SELECT AN.IdCustomer,
                   AN.PortfolioId,
                   AN.DailyDate,
                   AN.IsOldest,
                   AN.ReturnPercent,
                   AN.MinGuidesPerMonth,
                   AN.DailyAmount,
                   AN.IsCODAnticipatedValid,
                   0,
                   0,
                   AN.RowStatus,
                   AN.TokenCreated,
                   AN.DateCreated
            FROM #CodAnticipated AN
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM DeliveryBackOffice.dbo.AnticipatedCODHeader B WITH (NOLOCK)
                WHERE B.CustomerId = AN.IdCustomer
            )

            --INSERCION DE NUEVOS CLIENTES QUE NO ESTABAN ANTES EN LA TABLA DE CABECERA CLIENTES TIPO 2
            INSERT INTO DeliveryBackOffice.dbo.AnticipatedCODHeader
            (
                CustomerId,
                PortfolioId,
                DailyDate,
                IsOldest,
                ReturnPercent,
                MinGuidesPerMonth,
                DailyAmount,
                IsCODAnticipatedValid,
                Balance,
                AgaintsBalance,
                RowStatus,
                TokenCreated,
                DateCreated
            )
            SELECT AN.IdCustomer,
                   AN.PortfolioId,
                   AN.DailyDate,
                   AN.IsOldest,
                   AN.ReturnPercent,
                   AN.MinGuidesPerMonth,
                   AN.DailyAmount,
                   AN.IsCODAnticipatedValid,
                   0,
                   0,
                   AN.RowStatus,
                   AN.TokenCreated,
                   AN.DateCreated
            FROM #CodAnticipated AN
            WHERE AN.PortfolioId IS NOT NULL
                  AND NOT EXISTS
            (
                SELECT 1
                FROM DeliveryBackOffice.dbo.AnticipatedCODHeader B WITH (NOLOCK)
                WHERE B.CustomerId = AN.IdCustomer
                      AND B.PortfolioId = AN.PortfolioId
            )

            INSERT INTO @TempData
            (
                CustomerId,
                PortfolioId
            )
            SELECT IdCustomer,
                   PortfolioId
              FROM #CodAnticipated

            EXEC spUpdateBalanceByIdClient @TempData

        END

        PRINT 'TranCount: ' + CAST(@@TRANCOUNT AS NVARCHAR);

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT @@ERROR AS Error,
               ERROR_MESSAGE() AS ErrorMenssaje,
               ERROR_LINE() AS ErrorLine
    END CATCH
END