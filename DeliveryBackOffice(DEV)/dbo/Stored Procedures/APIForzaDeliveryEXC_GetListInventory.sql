/* =================================================
   SP:        [dbo].[APIForzaDeliveryEXC_GetListInventory]
   Propósito: Obtener la lista de inventario de EXCs en un rango de fechas específico
   Autor:     Bilkar Morataya
   Historia:  FDAPI-5590
   Fecha:     <2026-03-11>
   === CHANGELOG ============================
2026-03-10 | Historia/épica: <FDAPI-5590> | Autor: Bilkar Morataya | Descripción: Asegurar discriminar Guías anuladas
=========================================== */
CREATE PROCEDURE dbo.APIForzaDeliveryEXC_GetListInventory
       @HubEXC NVARCHAR(MAX),
       @IdHubEXC INT,
       @StartDate DATETIME,
       @EndDate DATETIME
AS
BEGIN
       SET NOCOUNT ON;

       SELECT 
              WH.Guide_Serie,
              WH.Guide_Number,
              SO.OrderDescription AS Status,
              CONCAT(DO.Receiver_FirstName, ' ', DO.Receiver_LastName) AS Receiver,
              WH.Rack_Position,
              WH.DateCreated
       FROM Warehouse WH WITH (NOLOCK)
       INNER JOIN StatusOrder SO WITH (NOLOCK) ON WH.StatusOrderId = SO.StatusOrderId
       INNER JOIN DeliveryOrder DO WITH (NOLOCK) ON WH.Guide_Serie = DO.Guide_Serie AND WH.Guide_Number = DO.Guide_Number
       INNER JOIN CatStation CS WITH (NOLOCK) ON WH.StationId = CS.IdStation
       WHERE WH.HubExc = @HubEXC
              AND WH.IdHubExc = @IdHubEXC
              AND WH.DateCreated BETWEEN @StartDate AND @EndDate
              AND WH.Active = 1
              AND DO.StatusOrderId != 7
              AND EXISTS (
                     SELECT 1
                     FROM DeliveryOrderDetail DOD WITH (NOLOCK)
                     WHERE DOD.Guide_Serie = WH.Guide_Serie
                            AND DOD.Guide_Number = WH.Guide_Number
                            AND DOD.RowStatus = 1
                            AND DOD.StatusOrderId != 7
              )
       ORDER BY WH.DateCreated DESC
END