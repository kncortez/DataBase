-- =============================================
-- Author:      <Juan Ramirez>
-- Create date: <2025-01-02>
-- Description: <Procedimiento para obtener el reporte de cod anticipado>
-- =============================================
CREATE PROCEDURE [dbo].[GetReportCODAnticipatedByCustomer]
(
 @startDate DATE,
 @endDate   DATE,
 @IdClient  BIGINT = 0,
 @Portfolio BIGINT = 0,
 @TypeClient TINYINT = 0,
 @IdCountry VARCHAR(2) = 'GT'
)
AS
BEGIN
    BEGIN TRY

        BEGIN TRANSACTION;

        IF OBJECT_ID('tempdb..#TempDataByCustomer', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #TempDataByCustomer
        END

                SELECT ach.CustomerId AS [HermesCode],
                       ach.PortfolioId AS [PortfolioId],
                       CONCAT(acd.GuideSerie, acd.GuideNumber) AS [Guide],
                       cdcod.AuthorizationDate AS [AnticipatedCODDate],
                       cdcod.Amount AS [AnticipatedCOD],
                       cdcod.ComisionCODAnticipated AS [AnticipatedCODComission],
                       acd.CollectOnDelivery AS [AmountCOD],
                       cdcod.Commission AS [Comission],
                       do.PriceShippment AS [Delivery],
                       (CASE 
                           WHEN acd.BalanceStatus = 'PENDIENTE'
                               THEN acd.CollectOnDelivery
                           ELSE 0.00
                       END) AS [CODInProcess],
                       (CASE 
                           WHEN acd.BalanceStatus = 'COBRADO'
                               THEN acd.CollectOnDelivery
                           ELSE 0.00
                       END) AS [CODPayed],
                       (CASE
                           WHEN acd.BalanceStatus = 'COBRADO'
                               THEN acd.DateUpdated
                           ELSE NULL
                       END) AS [DateCODPayed],
                       (CASE
                           WHEN acd.BalanceStatus = 'COBRADO'
                               THEN ISNULL(DATEDIFF(DAY, cdcod.AuthorizationDate, acd.DateUpdated),-1) 
                           ELSE -1
                       END) AS [TimeToPay],
                       (CASE 
                           WHEN acd.BalanceStatus = 'DEVOLUCION'
                               THEN acd.CollectOnDelivery
                           ELSE 0.00
                       END) AS [CODToReceivable],
                       0 AS [CODcollected],
                       acd.BalanceStatus AS [BalanceStatus]
                  INTO #TempDataByCustomer
                  FROM DeliveryBackOffice.dbo.AnticipatedCODDetail acd
                       INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach 
                          ON acd.AnticipatedCODHeaderId = ach.IdAnticipatedCODHeader
                       INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
                          ON do.Guide_Serie = acd.GuideSerie
                         AND do.Guide_Number = acd.GuideNumber
                       LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD cdcod
                          ON cdcod.GuideSerie = acd.GuideSerie
                         AND cdcod.GuideNumber = acd.GuideNumber
                         AND cdcod.CatConceptCODId = 2
                 WHERE CAST(acd.DateCreated AS DATE) >= @startDate
                   AND CAST(acd.DateCreated AS DATE) <= @endDate
                   AND do.SenderCountryId = @IdCountry
			       AND acd.RowStatus = 1
                 ORDER BY ach.CustomerId DESC, ach.PortfolioId DESC, acd.GuideSerie DESC, acd.GuideNumber DESC

        IF @TypeClient = 1
        BEGIN
            SELECT [HermesCode],
                   cst.[Name] AS [Name],
                   [PortfolioId],
                   [Guide],
                   FORMAT([AnticipatedCODDate],'dd/MM/yyyy hh:mm') AS [AnticipatedCODDate],
                   [AnticipatedCOD],
                   [AnticipatedCODComission],
                   [AmountCOD],
                   [Comission],
                   [Delivery],
                   [CODInProcess],
                   [CODPayed],
                   FORMAT([DateCODPayed],'dd/MM/yyyy hh:mm') AS [DateCODPayed],
                   [TimeToPay],
                   [CODToReceivable],
                   [CODcollected],
                   [BalanceStatus]
              FROM #TempDataByCustomer td
                   INNER JOIN Customer cst ON td.HermesCode = cst.IdCustomer
             WHERE td.HermesCode = @IdClient
               AND td.PortfolioId IS NULL
             ORDER BY td.HermesCode DESC, [Guide] DESC
        END
        ELSE IF @TypeClient = 2
        BEGIN 
            SELECT td.[PortfolioId] AS [HermesCode],
                   CONCAT(VPP.FirstName,' ',
                          VPP.SecondName,' ',
                          VPP.LastName,' ',
                          VPP.SecondLastName) AS [Name],
                   [Guide],
                   FORMAT([AnticipatedCODDate],'dd/MM/yyyy hh:mm') AS [AnticipatedCODDate],
                   [AnticipatedCOD],
                   [AnticipatedCODComission],
                   [AmountCOD],
                   [Comission],
                   [Delivery],
                   [CODInProcess],
                   [CODPayed],
                   FORMAT([DateCODPayed],'dd/MM/yyyy hh:mm') AS [DateCODPayed],
                   [TimeToPay],
                   [CODToReceivable],
                   [CODcollected],
                   [BalanceStatus]
              FROM #TempDataByCustomer td
                   INNER JOIN Customer cus WITH(NOLOCK)
                      ON cus.idCustomer = td.HermesCode
                   INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VP WITH (NOLOCK)
                      ON VP.CustomerID = cus.IdCustomer
                     AND VP.StatusClient = 1
                   INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPP WITH (NOLOCK)
                      ON VPP.VisitPointId= VP.IdVisitPointClient
                     AND VPP.IdVisitPointByClientPortfolio = td.PortfolioId
                     AND VPP.RowStatus = 1
             WHERE td.PortfolioId = @Portfolio
               AND td.PortfolioId IS NOT NULL
             ORDER BY td.PortfolioId DESC, [Guide] DESC
        END
        ELSE IF @TypeClient = 0
        BEGIN 
           SELECT [HermesCode],
                  [Name],
                  [Guide],
                  [AnticipatedCODDate],
                  [AnticipatedCOD],
                  [AnticipatedCODComission],
                  [AmountCOD],
                  [Comission],
                  [Delivery],
                  [CODInProcess],
                  [CODPayed],
                  [DateCODPayed],
                  [TimeToPay],
                  [CODToReceivable],
                  [CODcollected],
                  [BalanceStatus]
             FROM (
                   SELECT [HermesCode],
                          cst.[Name] AS [Name],
                          [Guide],
                          FORMAT([AnticipatedCODDate],'dd/MM/yyyy hh:mm') AS [AnticipatedCODDate],
                          [AnticipatedCOD],
                          [AnticipatedCODComission],
                          [AmountCOD],
                          [Comission],
                          [Delivery],
                          [CODInProcess],
                          [CODPayed],
                          FORMAT([DateCODPayed],'dd/MM/yyyy hh:mm') AS [DateCODPayed],
                          [TimeToPay],
                          [CODToReceivable],
                          [CODcollected],
                          [BalanceStatus]
                     FROM #TempDataByCustomer td
                          INNER JOIN Customer cst ON td.HermesCode = cst.IdCustomer
                    WHERE td.PortfolioId IS NULL
                    UNION ALL
                   SELECT td.[PortfolioId] AS [HermesCode],
                           CONCAT(VPP.FirstName,' ',
                                  VPP.SecondName,' ',
                                  VPP.LastName,' ',
                                  VPP.SecondLastName) AS [Name],
                          [Guide],
                          FORMAT([AnticipatedCODDate],'dd/MM/yyyy hh:mm') AS [AnticipatedCODDate],
                          [AnticipatedCOD],
                          [AnticipatedCODComission],
                          [AmountCOD],
                          [Comission],
                          [Delivery],
                          [CODInProcess],
                          [CODPayed],
                          FORMAT([DateCODPayed],'dd/MM/yyyy hh:mm') AS [DateCODPayed],
                          [TimeToPay],
                          [CODToReceivable],
                          [CODcollected],
                          [BalanceStatus]
                     FROM #TempDataByCustomer td
                          INNER JOIN Customer cus WITH(NOLOCK)
                             ON cus.idCustomer = td.HermesCode
                          INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VP WITH (NOLOCK)
                             ON VP.CustomerID = cus.IdCustomer
                            AND VP.StatusClient = 1
                          INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPP WITH (NOLOCK)
                             ON VPP.VisitPointId = VP.IdVisitPointClient
                            AND VPP.IdVisitPointByClientPortfolio = td.PortfolioId
                            AND VPP.RowStatus = 1
                    WHERE td.PortfolioId IS NOT NULL
             ) AS T
         ORDER BY T.[HermesCode] DESC, T.Guide DESC

        END

        IF OBJECT_ID('tempdb..#TempDataByCustomer', 'U') IS NOT NULL 
        BEGIN
            DROP TABLE #TempDataByCustomer
        END

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