CREATE PROCEDURE sphd_ValidChange
    @statusOrderId INT,
    @InvalidUpdate INT
AS
BEGIN
    SELECT * 
    FROM DeliveryBackOffice.dbo.StatusOrderUpdate 
    WHERE StatusOrderId = @statusOrderId
    AND InvalidIdUpdate = @InvalidUpdate
END