-- =============================================  
-- Author:  <Aylinne Recinos>  
-- Create date: <2024-22-11>  
-- Description: <Delivery Tracking - Método para validar que se encuentra en estado en ruta 
-- =============================================  
  
CREATE PROCEDURE [dbo].[SPHW_ValidateStatusCancel]  
@GuideSerie NVARCHAR(4),  
@GuideNumber INT  
AS  
BEGIN  
BEGIN TRY  
  DECLARE @StatusOrder INT  = (    
  SELECT StatusOrderId FROM DeliveryBackOffice.dbo.DeliveryOrder    
  WHERE Guide_Serie = @GuideSerie and Guide_Number = @GuideNumber
  )    
  
  IF(@StatusOrder = 4)
  BEGIN
    SELECT 1 AS 'StatusCode'
  END
  ELSE
  BEGIN 
    SELECT 0 AS 'StatusCode'
  END
END TRY  
BEGIN CATCH  
    DECLARE @ErrorMessage NVARCHAR(4000);  
    SELECT @ErrorMessage = ERROR_MESSAGE();  
    PRINT 'Error: ' + @ErrorMessage;  
END CATCH;  
END;