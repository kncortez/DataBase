
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-12-03>
-- Description:	<Calcula las reglas de negocio que necesita COD anticipado>
-- =============================================
-- Author:      <Juan Ramirez>
-- Create date: <2024-12-19>
-- Description: <Refactorización de procedimiento>
-- =============================================
--EXEC GetUpdateRegisterCODearly 'GT'
CREATE PROCEDURE [dbo].[GetUpdateRegisterCODearly_CRAS] @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
    BEGIN TRY
        DECLARE @GuideValueMount INT,
                @ReturnPercentMax INT,
                @DayMaxCOD DECIMAL(18, 2),
                @DayMount DATETIME,
                @DayThreeMount DATETIME,
                @CurrentRow INT = 1,
                @IdKindOfVPBusiness INT

        BEGIN TRANSACTION

        DECLARE @TempData TblAnticipatedCODCustomerBalance

        SELECT @GuideValueMount = MAX(MinGuidesPerMonthParam),
               @ReturnPercentMax = MAX(ReturnPercentParam),
               @DayMaxCOD = MAX(IsOldestParam)
          FROM (
                     SELECT CASE 
                                WHEN cf.[name]  = 'MinGuidesPerMonthParam' 
                                   THEN cf.[value]
                                ELSE 0
                            END AS MinGuidesPerMonthParam,
                            CASE 
                                WHEN cf.[name] = 'ReturnPercentParam'
                                   THEN cf.[value]
                                ELSE 0
                            END AS ReturnPercentParam,
                            CASE 
                               WHEN cf.[name] = 'IsOldestParam'
                                  THEN cf.[value]
                               ELSE 0
                            END AS IsOldestParam
                       FROM ConfigParams cf WITH(NOLOCK)
                      WHERE cf.[Name] IN (
                                          'MinGuidesPerMonthParam',
                                          'ReturnPercentParam',
                                          'IsOldestParam'
                                         )
                        AND IdCountry = @IdCountry
               ) AS T

        SET @IdKindOfVPBusiness =
        (
            SELECT IdKindOfVPBusiness
              FROM KindOfVPBusiness WITH(NOLOCK)
             WHERE KindOfVPNameBussiness = 'EXPRESS CENTER'
               AND ISNULL(IdCountry, 'GT') = @IdCountry
        )

        SET @DayMount = (DATEADD(DAY, -30, GETDATE()))
        SET @DayThreeMount = (DATEADD(DAY, -90, GETDATE()))

        IF OBJECT_ID('tempdb..#TempDate', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #TempDate
            DROP CONSTRAINT PK_TempDate
        END

        IF OBJECT_ID('tempdb..#TempDate', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #TempDate
        END

        IF OBJECT_ID('tempdb..#Temp30Days', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #Temp30Days
            DROP CONSTRAINT PK_Temp30Days
        END

        IF OBJECT_ID('tempdb..#Temp30Days', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #Temp30Days
        END

        IF OBJECT_ID('tempdb..#Temp90Days', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #Temp90Days
            DROP CONSTRAINT PK_Temp90Days
        END

        IF OBJECT_ID('tempdb..#Temp90Days', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #Temp90Days
        END

        IF OBJECT_ID('tempdb..#TempMinDate', 'U') IS NOT NULL
            DROP TABLE #TempMinDate;

        IF OBJECT_ID('tempdb..#CodAnticipated', 'U') IS NOT NULL
            DROP TABLE #CodAnticipated;

        CREATE TABLE  #TempDate(
            IdCustomerType INT NOT NULL,
            IdCustomer INT NOT NULL,
            PortfolioId INT NOT NULL,
            FirstDate DATETIME,
            CONSTRAINT PK_TempDate PRIMARY KEY (IdCustomer, PortfolioId)
        );

        CREATE NONCLUSTERED INDEX IDX_TempDate_CustomerPortfolio 
        ON #TempDate (IdCustomer, PortfolioId);

        CREATE TABLE  #Temp30Days(
            IdCustomer INT NOT NULL,
            PortfolioId INT NOT NULL,
            NumberGuides INT,
            AmountDelivery DECIMAL(20,12),
            CONSTRAINT PK_Temp30Days PRIMARY KEY (IdCustomer, PortfolioId)
        );

        CREATE NONCLUSTERED INDEX IDX_Temp30Days_CustomerPortfolio 
        ON #Temp30Days (IdCustomer, PortfolioId);

        CREATE TABLE #Temp90Days(
            IdCustomer INT NOT NULL,
            PortfolioId INT NOT NULL,
            IsReturn INT,
            CountReturn INT,
            CONSTRAINT PK_Temp90Days PRIMARY KEY (IdCustomer, PortfolioId)
        );

        CREATE NONCLUSTERED INDEX IDX_Temp90Days_CustomerPortfolio 
        ON #Temp90Days (IdCustomer, PortfolioId);


        CREATE TABLE #TempMinDate(
            IdCustomer     INT NOT NULL,
            PortfolioId    INT NOT NULL,
            FirstDate      DATETIME,
            CONSTRAINT PK_TempMinDate PRIMARY KEY (IdCustomer, PortfolioId)
        );

        -- FECHA MINIMA
        INSERT INTO #TempDate
        SELECT C.IdCustomerType,
               C.IdCustomer,
               0 AS PortfolioID,
               NULL AS FirstDate
          FROM DeliveryBackOffice.dbo.Customer C WITH (NOLOCK)
         WHERE C.IdCustomerType IN (1, 3)
           AND ISNULL(C.CountryID, 'GT') = @IdCountry
         GROUP BY C.IdCustomerType, C.IdCustomer

        INSERT INTO #TempDate
        SELECT CT.IdCustomerType,
               CT.IdCustomer,
               ISNULL(VPP.IdVisitPointByClientPortfolio,0) AS PortfolioID,
               NULL AS FirstDate
          FROM DeliveryBackOffice.dbo.Customer CT WITH (NOLOCK)
               INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VP WITH (NOLOCK)
                   ON VP.CustomerID = CT.IdCustomer
                  AND VP.StatusClient = 1
               INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPP WITH (NOLOCK)
                   ON ISNULL(VPP.VisitPointId,0) = ISNULL(VP.IdVisitPointClient,0)
                  AND VPP.RowStatus = 1
         WHERE CT.IdCustomerType = 2
           AND ISNULL(CT.CountryID,0) = @IdCountry
         GROUP BY CT.IdCustomerType, CT.IdCustomer,VPP.IdVisitPointByClientPortfolio;

        INSERT INTO #TempMinDate
        SELECT tt.IdCustomer,
               ISNULL(tt.PortfolioID,0) AS PortfolioID,
               MIN(do.DateCreated) AS FirstDate
          FROM #TempDate tt 
               LEFT JOIN DeliveryOrder do WITH(NOLOCK)
                 ON tt.IdCustomer = do.idCustomer
                AND tt.PortfolioId = do.VisitpointClientPortfolioId
                AND do.TypeService = 'COD'
         WHERE tt.IdCustomerType IN (2)
           AND do.IdCustomer IS NOT NULL
         GROUP BY tt.IdCustomer, tt.PortfolioID

        INSERT INTO #TempMinDate
        SELECT tt.IdCustomer,
               ISNULL(tt.PortfolioID,0) AS PortfolioID,
               MIN(do.DateCreated) AS FirstDate
          FROM #TempDate tt 
               LEFT JOIN DeliveryOrder do WITH(NOLOCK)
                 ON tt.IdCustomer = do.idCustomer
                AND do.DateCreated IS NOT NULL
                AND do.TypeService = 'COD'
                AND do.idCustomer IS NOT NULL
         WHERE IdCustomerType IN (1,3)
         GROUP BY tt.IdCustomer, tt.PortfolioID

        CREATE NONCLUSTERED INDEX IX_TempDate_IdCustomer
        ON #TempMinDate (IdCustomer, PortfolioID);
		PRINT 'line 210'
        INSERT INTO #Temp30Days
        SELECT CU.IdCustomer
              ,CU.PortfolioID
              ,COUNT(do.Guide_Number) AS NumbersGuides
              ,SUM(ISNULL(do.Collect_OnDelivery,0)) AS AmountCOD
          FROM #TempDate CU WITH (NOLOCK)
               LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
                 ON do.IdCustomer = CU.IdCustomer
                AND do.VisitpointClientPortfolioId = CU.PortfolioID
                AND do.DateCreated BETWEEN @DayMount AND GETDATE()
                AND do.TypeService = 'COD'
                AND do.DateCreated IS NOT NULL
         WHERE cu.IdCustomerType IN (2)
           AND do.idCustomer IS NOT NULL
         GROUP BY CU.IdCustomer, CU.PortfolioID
         ORDER BY CU.IdCustomer DESC, CU.PortfolioID DESC

		 PRINT 'line 226'
		 PRINT @DayMount

		-- SELECT * FROM #Temp30Days
		 --SELECT * FROM #TempDate
        INSERT INTO #Temp30Days
        SELECT CU.IdCustomer
              ,CU.PortfolioID
              ,COUNT(do.Guide_Number) AS NumbersGuides
              ,SUM(ISNULL(do.Collect_OnDelivery,0)) AS AmountCOD
          FROM #TempDate CU WITH (NOLOCK)
               LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
                 ON do.IdCustomer = CU.IdCustomer
                AND do.DateCreated BETWEEN @DayMount AND GETDATE()
                AND do.TypeService = 'COD'
                AND do.DateCreated IS NOT NULL
         WHERE cu.IdCustomerType IN (1,3)
           AND cu.PortfolioId = 0
           AND do.idCustomer IS NOT NULL
         GROUP BY CU.IdCustomer, CU.PortfolioID
         ORDER BY CU.IdCustomer DESC, CU.PortfolioID DESC
		 PRINT 'line 244'
        INSERT INTO #Temp90Days
        SELECT CU.IdCustomer,
               CU.PortfolioID AS PortfolioID,
               COUNT(CASE WHEN do.IsLastMileReturn IS NOT NULL AND do.IsLastMileReturn = 1 THEN 1 ELSE NULL END) AS IsReturn,
               COUNT(ISNULL(do.IdCustomer,0)) AS CountReturn
          FROM #TempDate CU
               LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                 ON do.IdCustomer = CU.IdCustomer
                AND do.VisitpointClientPortfolioId = cu.PortfolioID
                AND do.DateCreated BETWEEN @DayThreeMount AND CAST(GETDATE() AS DATETIME)
                AND do.TypeService = 'COD'
                AND do.DateCreated IS NOT NULL
         WHERE cu.IdCustomerType IN (2)
           AND do.idCustomer IS NOT NULL
         GROUP BY CU.IdCustomer, CU.PortfolioID;

        INSERT INTO #Temp90Days
        SELECT CU.IdCustomer,
               CU.PortfolioID AS PortfolioID,
               COUNT(CASE WHEN do.IsLastMileReturn IS NOT NULL AND do.IsLastMileReturn = 1 THEN 1 ELSE NULL END) AS IsReturn,
               COUNT(ISNULL(do.IdCustomer,0)) AS CountReturn
          FROM #TempDate CU
               LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                 ON do.IdCustomer = CU.IdCustomer
                AND do.DateCreated BETWEEN @DayThreeMount AND CAST(GETDATE() AS DATETIME)
                AND do.TypeService = 'COD'
                AND do.DateCreated IS NOT NULL
         WHERE cu.IdCustomerType IN (1,3)
           AND cu.PortfolioId = 0
           AND do.idCustomer IS NOT NULL
         GROUP BY CU.IdCustomer, CU.PortfolioID;

        --INSERT A TABLA CABECERA DE CLIENTES PARA COD ANTICIPADO
        SELECT IdCustomer,
               PortfolioId,
               ISNULL(DATEDIFF(DAY, FirstDate, GETDATE()), 0) AS IsOldest,
               CASE 
                   WHEN CountReturn IS NOT NULL
                        AND CountReturn <> 0
                       THEN ISNULL((IsReturn * 100.0) / CountReturn, 0)
                   ELSE 0
               END AS ReturnPercent,
               NumbersGuide AS MinGuidesPerMonth,
               AmountCOD / 30.00 AS DailyAmount,
               CASE
                   WHEN NumbersGuide >= @GuideValueMount
                        AND CountReturn IS NOT NULL
                        AND ((IsReturn * 100.0) / CountReturn) < @ReturnPercentMax
                        AND ISNULL(DATEDIFF(DAY, FirstDate, GETDATE()), 0) >= @DayMaxCOD 
                        THEN 1
                   ELSE 0
               END AS IsCODAnticipatedValid
        INTO #CodAnticipated
        FROM
        (
           SELECT TMD.IdCustomer,
                  TMD.PortfolioID,
                  TMD.FirstDate,
                  TM30.NumberGuides AS NumbersGuide,
                  TM30.AmountDelivery AS AmountCOD,
                  TM90.IsReturn AS IsReturn,
                  TM90.CountReturn AS CountReturn
              FROM #TempMinDate TMD
                  INNER JOIN #Temp30Days TM30
                      ON TMD.IdCustomer = TM30.IdCustomer
                         AND TMD.PortfolioID = TM30.PortfolioID
                  INNER JOIN #Temp90Days TM90
                      ON TMD.IdCustomer = TM90.IdCustomer
                         AND TMD.PortfolioID = TM90.PortfolioID
        ) CodData

        IF NOT EXISTS
        (
            SELECT TOP 1 1
              FROM AnticipatedCODHeader WITH (NOLOCK)
        )
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
                   NULLIF(PortfolioId,0),
                   GETDATE(),
                   IsOldest,
                   ReturnPercent,
                   MinGuidesPerMonth,
                   DailyAmount,
                   IsCODAnticipatedValid,
                   0,
                   0,
                   1,
                   'SYS-GetUpdateRegisterCODearly',
                   GETDATE()
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

            UPDATE DeliveryBackOffice.dbo.AnticipatedCODHeader
               SET DailyDate = GETDATE(),
                   IsOldest = ca.IsOldest,
                   ReturnPercent = ca.ReturnPercent,
                   MinGuidesPerMonth = ca.MinGuidesPerMonth,
                   DailyAmount = ca.DailyAmount,
                   IsCODAnticipatedValid = ca.IsCODAnticipatedValid,
                   DateUpdated = GETDATE(),
                   TokenUpdated = 'SYS-GetUpdateRegisterCODearly'
              FROM #CodAnticipated ca
                   LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH (NOLOCK)
                       ON ach.CustomerId = ca.IdCustomer
                      AND ach.PortfolioId IS NULL
             WHERE ca.PortfolioId = 0
               AND ach.CustomerId IS NOT NULL;

            UPDATE DeliveryBackOffice.dbo.AnticipatedCODHeader
               SET DailyDate = GETDATE(),
                   IsOldest = ca.IsOldest,
                   ReturnPercent = ca.ReturnPercent,
                   MinGuidesPerMonth = ca.MinGuidesPerMonth,
                   DailyAmount = ca.DailyAmount,
                   IsCODAnticipatedValid = ca.IsCODAnticipatedValid,
                   DateUpdated = GETDATE(),
                   TokenUpdated = 'SYS-GetUpdateRegisterCODearly'
              FROM #CodAnticipated ca
                   LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH (NOLOCK)
                     ON ach.CustomerId = ca.IdCustomer
                    AND ach.PortfolioId = ca.PortfolioID
             WHERE ca.PortfolioId != 0
               AND ach.CustomerId IS NOT NULL

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
            SELECT ca.IdCustomer,
                   NULLIF(ca.PortfolioId,0) AS PortfolioId,
                   GETDATE(),
                   ca.IsOldest,
                   ca.ReturnPercent,
                   ca.MinGuidesPerMonth,
                   ca.DailyAmount,
                   ca.IsCODAnticipatedValid,
                   0,
                   0,
                   1,
                   'SYS-GetUpdateRegisterCODearly' AS TokenCreated,
                   GETDATE() AS DateCreated
              FROM #CodAnticipated ca
                   LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH (NOLOCK)
                     ON ach.CustomerId = ca.IdCustomer
                    AND ach.PortfolioId IS NULL
              WHERE ca.PortfolioId = 0
                AND ach.CustomerId IS NULL 

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
            SELECT ca.IdCustomer,
                   ca.PortfolioId AS PortfolioId,
                   GETDATE(),
                   ca.IsOldest,
                   ca.ReturnPercent,
                   ca.MinGuidesPerMonth,
                   ca.DailyAmount,
                   ca.IsCODAnticipatedValid,
                   0,
                   0,
                   1,
                   'SYS-GetUpdateRegisterCODearly',
                   GETDATE()
              FROM #CodAnticipated ca
                   LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH (NOLOCK)
                     ON ach.CustomerId = ca.IdCustomer
                    AND ach.PortfolioId = ca.PortfolioID
                    AND ach.PortfolioId IS NOT NULL
              WHERE ca.PortfolioId != 0
                AND ach.CustomerId IS NULL
                AND ach.PortfolioId IS NULL

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

        COMMIT TRANSACTION;

        IF OBJECT_ID('tempdb..#TempDate', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #TempDate
            DROP CONSTRAINT PK_TempDate
        END

        IF OBJECT_ID('tempdb..#TempDate', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #TempDate
        END

        IF OBJECT_ID('tempdb..#Temp30Days', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #Temp30Days
            DROP CONSTRAINT PK_Temp30Days
        END

        IF OBJECT_ID('tempdb..#Temp30Days', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #Temp30Days
        END

        IF OBJECT_ID('tempdb..#Temp90Days', 'U') IS NOT NULL 
        BEGIN
            ALTER TABLE #Temp90Days
            DROP CONSTRAINT PK_Temp90Days
        END

        IF OBJECT_ID('tempdb..#Temp90Days', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #Temp90Days
        END

        IF OBJECT_ID('tempdb.dbo.#TempMinDate', 'U') IS NOT NULL
            DROP TABLE #TempMinDate;

        IF OBJECT_ID('tempdb.dbo.#CodAnticipated', 'U') IS NOT NULL
            DROP TABLE #CodAnticipated;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT @@ERROR AS Error,
               ERROR_MESSAGE() AS ErrorMenssaje,
               ERROR_LINE() AS ErrorLine
    END CATCH
END