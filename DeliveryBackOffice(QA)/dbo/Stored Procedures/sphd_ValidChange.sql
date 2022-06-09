
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-10-19>
-- Description: <Obtiene los estados no validos para actualizar guias>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_ValidChange]
    @statusOrderId INT,
    @InvalidUpdate INT
AS
BEGIN
    SELECT * 
    FROM DeliveryBackOffice.dbo.StatusOrderUpdate 
    WHERE StatusOrderId = @statusOrderId
    AND InvalidIdUpdate = @InvalidUpdate
END
