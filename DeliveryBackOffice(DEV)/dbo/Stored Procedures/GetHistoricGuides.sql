-- =============================================
-- Author:		<Marco, Jiménez>
-- Create date: <2021-09-09>
-- Description:	<Histórico de guías rápidas generadas por el corporativo>
-- =============================================
CREATE PROCEDURE [dbo].[GetHistoricGuides]
    @Token AS VARCHAR(200) = '',
    @IdVisitPointByClientPortfolio AS INT = 0
AS
BEGIN

    --DECLARE @IdUser AS INT = 6969
    --DECLARE @IdVisitPointByClientPortfolio AS INT = 2064
    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @IdUser BIGINT =
                  (
                      SELECT TOP 1 t.TknIdUser FROM TokenLog t WHERE t.TknIdToken = @Token
                  );

    SET @jsonResult =
    (
        SELECT STUFF(
                        (
                            SELECT ',{"ClientName":"'
                                   + ISNULL(CONCAT(VCP.ContactName, ' ', VCP.FirstName, ' ', VCP.LastName), '') + '",'
                                   + '"PackageCountGlobal":"'
                                   + CAST(
                                     (
                                         SELECT COUNT(1)
                                         FROM GuideBatch GB1
                                             INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO1 WITH(NOLOCK)
                                                 ON GB1.GuideSeries = DO1.Guide_Serie AND GB1.GuideNumber = DO1.Guide_Number
                                             LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DT1 WITH(NOLOCK)
                                                 ON DT1.Guide_Serie = DO1.Guide_Serie
                                                    AND DT1.Guide_Number = DO1.Guide_Number
                                         WHERE GB1.IdUser = @IdUser
                                               AND GB1.RowStatus = 1
                                               AND DT1.StatusOrderId IN ( 5,12)
                                               AND (
                                                       @IdVisitPointByClientPortfolio = 0
                                                       OR GB1.IdVisitPointByClientPortfolio = @IdVisitPointByClientPortfolio
                                                   )
                                     ) AS VARCHAR(5)) + '",' + '"GuideNumber":"' + ISNULL(GB.GuideNumber, '') + '",'
                                   + '"PackageCount":"' + CAST(ISNULL(COUNT(DOP.GuideNumber), 0) AS VARCHAR) + '",'
                                   + '"DeliveryTime":"'
                                   + CAST(ISNULL(DATEDIFF(DAY, DT_ARRIBO.DateCreated, DT_ENTREGA.DateCreated), 0) AS VARCHAR)
                                   + '",' + +'"DeliveryDate":"'
                                   + CONVERT(varchar, ISNULL(DT_ENTREGA.DateCreated, 0), 3) + '",'
                                   + CASE
                                         WHEN
                                         (
                                             DA.Delivered = 1
                                             AND DA.Accepted = 1
                                             AND DT.StatusOrderId = 5
                                         ) THEN
                                             +'"Status":"' + ISNULL(SO.OrderDescription, '') + '"'
                                         WHEN
                                         (
                                             DA.Accepted = 0
                                             AND DA.ID_Incident IS NOT NULL
                                         ) THEN
                                             +'"Status":"' + ISNULL(I.Description, '') + '"'
                                         ELSE
                                             +'"Status":"' + ISNULL(SO.OrderDescription, '') + '"'
                                     END + '}'
                            FROM GuideBatch GB WITH(NOLOCK)
                                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
                                    ON GB.GuideSeries = do.Guide_Serie 
									AND GB.GuideNumber = DO.Guide_Number
                                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
                                    ON DOP.GuideSerie = DO.Guide_Serie
                                       AND DOP.GuideNumber = DO.Guide_Number
                                INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VCP WITH(NOLOCK)
                                    ON GB.IdVisitPointByClientPortfolio = VCP.IdVisitPointByClientPortfolio
                                LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DT_ARRIBO WITH(NOLOCK)
                                    ON DT_ARRIBO.Guide_Serie = DO.Guide_Serie
                                       AND DT_ARRIBO.Guide_Number = DO.Guide_Number
                                       AND DT_ARRIBO.StatusOrderId IN ( 11, 2 )
                                LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DT_ENTREGA WITH(NOLOCK)
                                    ON DT_ENTREGA.Guide_Serie = DO.Guide_Serie
                                       AND DT_ENTREGA.Guide_Number = DO.Guide_Number
                                       AND DT_ENTREGA.StatusOrderId IN (5,12)
                                LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DT WITH(NOLOCK)
                                    ON DT.Guide_Serie = DO.Guide_Serie
                                       AND DT.Guide_Number = DO.Guide_Number
                                LEFT JOIN DeliveryBackOffice.dbo.StatusOrder SO
                                    ON DT.StatusOrderId = SO.StatusOrderId
                                LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
                                    ON DO.Guide_Serie = DA.Guide_Serie
                                       AND DO.Guide_Number = DA.Guide_Number
                                LEFT JOIN DeliveryBackOffice.dbo.Incident I WITH(NOLOCK)
                                    ON DA.ID_Incident = I.ID
                            WHERE GB.IdUser = @IdUser
                                  AND GB.RowStatus = 1
                                  AND DT.StatusOrderId IN(5,12)
                                  AND (
                                          @IdVisitPointByClientPortfolio = 0
                                          OR GB.IdVisitPointByClientPortfolio = @IdVisitPointByClientPortfolio
                                      )
                            GROUP BY VCP.ContactName,
                                     VCP.FirstName,
                                     VCP.LastName,
                                     GB.GuideNumber,
                                     DT_ARRIBO.DateCreated,
                                     DT_ENTREGA.DateCreated,
                                     DA.Delivered,
                                     DA.Accepted,
                                     DT.StatusOrderId,
                                     SO.OrderDescription,
                                     DA.ID_Incident,
                                     I.Description
                            ORDER BY DT_ENTREGA.DateCreated DESC
                            FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'),
                        1,
                        1,
                        ''
                    )
    );

    -- Returns the results 
    SELECT ('[' + ISNULL(@jsonResult, '{"Message":"No se encontraron guias generadas.", "Results":"False"}') + ']') jsonResult;


END;