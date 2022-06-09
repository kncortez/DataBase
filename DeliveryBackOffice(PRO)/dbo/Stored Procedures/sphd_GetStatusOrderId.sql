
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-10-19>
-- Description: <Obtiene el StatusOrderId de un estado especifico segun la descripcion>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_GetStatusOrderId]
    @OrderDescription NVARCHAR(100)
AS
BEGIN
    SELECT StatusOrder.StatusOrderId
    FROM DeliveryBackOffice.dbo.StatusOrder
    WHERE OrderDescription = @OrderDescription
END
