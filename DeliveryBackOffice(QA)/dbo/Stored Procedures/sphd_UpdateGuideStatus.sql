
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-10-19>
-- Description: <Actualiza el estado de la guia e inserta el detalle en la tabla DeliveryOrderDetail>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_UpdateGuideStatus]
	@Guide_Serie VARCHAR(2),
	@Guide_Number INT,
	@newStatus INT,
	@UserToken VARCHAR(50),
	@Observations VARCHAR(200)
AS
BEGIN
	UPDATE DeliveryBackOffice.dbo.DeliveryOrder	
	SET StatusOrderId = @newStatus
    WHERE Guide_Serie =  @Guide_Serie
    AND Guide_Number = @Guide_Number

    INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail( Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations)
    VALUES (@Guide_Serie, @Guide_Number, @newStatus, @UserToken, GETDATE(), GETDATE(), @Observations) 
END
