-- =============================================
-- Author:      <Juan Ramirez>
-- Create date: <2025-01-02>
-- Description: <Procedimiento para obtener el reporte de cod anticipado>
-- =============================================
CREATE PROCEDURE [dbo].[GetResumeReportCODAnticipatedByCustomer]
(
 @startDate  DATE,
 @endDate    DATE,
 @IdClient   BIGINT = 0,
 @Portfolio  BIGINT = 0,
 @TypeClient TINYINT = 0,
 @IdCountry  VARCHAR(2) = 'GT'
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
                   cdcod.Amount AS [AnticipatedCOD],
                   cdcod.ComisionCODAnticipated AS [AnticipatedCODComission],
                   acd.CollectOnDelivery AS [AmountCOD],
                   cdcod.Commission AS [Comission],
                   do.PriceShippment AS [Delivery],
                   CASE 
                       WHEN acd.BalanceStatus = 'PENDIENTE'
                           THEN acd.CollectOnDelivery
                       ELSE 0.00
                   END AS [CODInProcess],
                   CASE 
                       WHEN acd.BalanceStatus = 'COBRADO'
                           THEN acd.CollectOnDelivery
                       ELSE 0.00
                   END AS [CODPayed],
                   CASE
                       WHEN acd.BalanceStatus = 'DEVOLUCION'
                           THEN acd.CollectOnDelivery
                       ELSE 0.00
                   END AS [CODToReceivable],
                   0 AS [CODcollected]
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

        IF @TypeClient = 1
        BEGIN
            SELECT td.HermesCode AS [HermesCode],
                   MAX(cst.[Name]) AS [Name],
                   SUM(td.AnticipatedCOD) AS [AnticipatedCOD],
                   SUM(td.AnticipatedCODComission) AS [AnticipatedCODComission],
                   SUM(td.AmountCOD) AS [AmountCOD],
                   SUM(td.Comission) AS [Comission],
                   SUM(td.Delivery) AS [Delivery],
                   SUM(td.CODInProcess) AS [CODInProcess],
                   SUM(td.CODPayed) AS [CODPayed],
                   SUM(td.CODToReceivable) AS [CODToReceivable],
                   SUM(td.CODcollected) AS [CODcollected]
              FROM #TempDataByCustomer td
                   INNER JOIN Customer cst ON td.HermesCode = cst.IdCustomer
             WHERE td.HermesCode = @IdClient
               AND td.PortfolioId IS NULL
             GROUP BY td.HermesCode
             ORDER BY td.HermesCode DESC
        END
        ELSE IF @TypeClient = 2
        BEGIN 
            SELECT td.PortfolioId AS [HermesCode],
                   CONCAT(MAX(VPP.FirstName),' ',
                          MAX(VPP.SecondName),' ',
                          MAX(VPP.LastName),' ',
                          MAX(VPP.SecondLastName)) AS [Name],
                   SUM(td.AnticipatedCOD) AS [AnticipatedCOD],
                   SUM(td.AnticipatedCODComission) AS [AnticipatedCODComission],
                   SUM(td.AmountCOD) AS [AmountCOD],
                   SUM(td.Comission) AS [Comission],
                   SUM(td.Delivery) AS [Delivery],
                   SUM(td.CODInProcess) AS [CODInProcess],
                   SUM(td.CODPayed) AS [CODPayed],
                   SUM(td.CODToReceivable) AS [CODToReceivable],
                   SUM(td.CODcollected) AS [CODcollected]
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
             WHERE td.PortfolioId = @Portfolio
               AND td.PortfolioId IS NOT NULL
             GROUP BY td.PortfolioId
             ORDER BY td.PortfolioId DESC
        END
        ELSE IF @TypeClient = 0
        BEGIN 
            SELECT [HermesCode],
                   [Name],
                   [AnticipatedCOD],
                   [AnticipatedCODComission],
                   [AmountCOD],
                   [Comission],
                   [Delivery],
                   [CODInProcess],
                   [CODPayed],
                   [CODToReceivable],
                   [CODcollected]
              FROM (
                    SELECT td.HermesCode AS [HermesCode],
                           MAX(cst.[Name]) AS [Name],
                           SUM(td.AnticipatedCOD) AS [AnticipatedCOD],
                           SUM(td.AnticipatedCODComission) AS [AnticipatedCODComission],
                           SUM(td.AmountCOD) AS [AmountCOD],
                           SUM(td.Comission) AS [Comission],
                           SUM(td.Delivery) AS [Delivery],
                           SUM(td.CODInProcess) AS [CODInProcess],
                           SUM(td.CODPayed) AS [CODPayed],
                           SUM(td.CODToReceivable) AS [CODToReceivable],
                           SUM(td.CODcollected) AS [CODcollected]
                      FROM #TempDataByCustomer td
                           INNER JOIN Customer cst ON td.HermesCode = cst.IdCustomer
                     WHERE td.PortfolioId IS NULL
                     GROUP BY td.HermesCode
                     UNION ALL
                    SELECT td.PortfolioId AS [HermesCode],
                           CONCAT(MAX(VPP.FirstName),' ',
                                  MAX(VPP.SecondName),' ',
                                  MAX(VPP.LastName),' ',
                                  MAX(VPP.SecondLastName)) AS [Name],
                           SUM(td.AnticipatedCOD) AS [AnticipatedCOD],
                           SUM(td.AnticipatedCODComission) AS [AnticipatedCODComission],
                           SUM(td.AmountCOD) AS [AmountCOD],
                           SUM(td.Comission) AS [Comission],
                           SUM(td.Delivery) AS [Delivery],
                           SUM(td.CODInProcess) AS [CODInProcess],
                           SUM(td.CODPayed) AS [CODPayed],
                           SUM(td.CODToReceivable) AS [CODToReceivable],
                           SUM(td.CODcollected) AS [CODcollected]
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
                     GROUP BY td.PortfolioId
              ) AS T
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