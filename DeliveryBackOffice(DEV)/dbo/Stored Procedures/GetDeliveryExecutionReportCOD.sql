-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-29>
-- Description:	<Guias por pagar COD>
-- =============================================
CREATE PROCEDURE [dbo].[GetDeliveryExecutionReportCOD]
    -- Add the parameters for the stored procedure here
    @IdCustomer INT
AS
BEGIN


    SELECT s1.*,
           ISNULL(DATEDIFF(DAY, convert(date, s1.FechaArribo, 103), convert(date, s1.FechaEntrega, 103)),0) AS DiasEntrega,
		   FORMAT(GETDATE(), 'dd/MM/yyyy hh:mm:ss tt') AS ActualizadoAl
    FROM
    (
        SELECT cs.Name Cliente,
               CONCAT(ord.Guide_Serie, ord.Guide_Number) GuideNumber,
               (ord.Pieces_Dry + ord.Pieces_Cold) Piezas,
               (
                   SELECT SUM(ISNULL(dp.MassWeight, dp.PieceWeight))
                   FROM dbo.DeliveryOrderPiece dp
                   WHERE dp.GuideSerie = ord.Guide_Serie
                         AND dp.GuideNumber = ord.Guide_Number
               ) Peso,
               ISNULL(prv.ProvinceName, pr.ProvinceName) Departamento,
               ISNULL(twn.TownshipName, tw.TownshipName) Municipio,
               ISNULL(CONCAT(ord.Receiver_FirstName, ' ', ord.Receiver_LastName), '') Destinatario,
               FORMAT((
                   SELECT TOP 1
                          dt.DateCreated
                   FROM dbo.DeliveryOrderDetail dt
                   WHERE dt.Guide_Serie = ord.Guide_Serie
                         AND dt.Guide_Number = ord.Guide_Number
                         AND dt.StatusOrderId IN ( 11, 2 )
               ), 'dd/MM/yyyy hh:mm:ss tt') FechaArribo,
               FORMAT((
                   SELECT TOP 1
                          dt.DateCreated
                   FROM dbo.DeliveryOrderDetail dt
                   WHERE dt.Guide_Serie = ord.Guide_Serie
                         AND dt.Guide_Number = ord.Guide_Number
                         AND dt.StatusOrderId = 5
               ), 'dd/MM/yyyy hh:mm:ss tt') FechaEntrega,
               ord.Collect_OnDelivery COD,
               ISNULL(ord.TypeService, 'NDD') TipoServicio,
               IIF(ord.IsCollect = 'true',
                   'Collect',
                   (IIF(ISNULL(cs.ConditionOfPaymentID, 0) > 1, 'Crédito', 'Prepago'))) TipodePago,
               ISNULL(ord.PriceShippment, 0) ValorEnvio,
               'En Tiempo' Status -- TODO Verificar algoritmo de  calculo
        FROM dbo.DeliveryOrder ord
            LEFT JOIN dbo.Township twn
                ON twn.IdTownship = ord.ReceiverIdTownship
            LEFT JOIN dbo.Township tw
                ON tw.TownshipName = ord.Receiver_Town
            LEFT JOIN dbo.Province prv
                ON prv.IdProvince = twn.IdProvince
            LEFT JOIN dbo.Province pr
                ON pr.IdProvince = tw.IdProvince
            LEFT JOIN dbo.VisitPointClient vpc
                ON vpc.CodeOfReference = ord.Sender_ID
            LEFT JOIN dbo.Customer cs
                ON cs.IdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
        WHERE MONTH(ord.DateCreated) = MONTH(GETDATE())
              AND
              (
                  ord.IdCustomer = @IdCustomer
                  OR ord.Sender_ID IN
                     (
                         SELECT CodeOfReference
                         FROM dbo.VisitPointClient
                         WHERE CustomerID = @IdCustomer
                     )
              )
              AND ord.StatusOrderId NOT IN ( 7, 15 )
    ) s1
    ORDER BY s1.GuideNumber;


END;