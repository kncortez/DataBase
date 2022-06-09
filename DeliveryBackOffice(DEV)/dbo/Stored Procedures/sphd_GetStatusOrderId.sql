CREATE PROCEDURE sphd_GetStatusOrderId
    @OrderDescription NVARCHAR(100)
AS
BEGIN
    SELECT StatusOrder.StatusOrderId
    FROM DeliveryBackOffice.dbo.StatusOrder
    WHERE OrderDescription = @OrderDescription
END