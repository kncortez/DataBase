-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-10-19>
-- Description: <Obtiene los estados de la tabla StatusOrder>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetStates]
AS
BEGIN
    SELECT StatusOrderId,OrderDescription
    FROM DeliveryBackOffice.dbo.StatusOrder
	WHERE StatusOrderId NOT IN (5,14,22,23,50,12,45)    
END
