
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-10-19>
-- Description: <Obtener informacion de las guias para mostrar al momento de actualizar los checkpoints>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getGuides]
    @Guide_Serie VARCHAR(2),
    @Guide_Number INT
AS
BEGIN
    
    SELECT Guide_Serie, Guide_Number, Pieces_Dry+Pieces_Cold, c.Name, Receiver_Address, so.OrderDescription
    FROM DeliveryBackOffice.dbo.DeliveryOrder AS do
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient AS vpc
    ON do.Sender_ID = vpc.CodeOfReference
    LEFT JOIN DeliveryBackOffice.dbo.Customer AS c
    on c.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
    INNER JOIN DeliveryBackOffice.dbo.StatusOrder AS so
    ON do.StatusOrderId = so.StatusOrderId
    WHERE Guide_Serie = @Guide_Serie
    AND Guide_Number = @Guide_Number

END