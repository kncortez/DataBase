-- =============================================  
-- Author:  <Aylinne Recinos>  
-- Create date: <2024-22-11>  
-- Description: <Delivery Tracking - Método para devolver el ID de la incidencia según el país
-- =============================================  
  
CREATE PROCEDURE [dbo].[SPHW_IncidenceByCountry]  
@CountryId NVARCHAR(2)
AS  
BEGIN  
BEGIN TRY  
  DECLARE @IncidenceId INT  = ISNULL(    
  (SELECT IdIncidenceType FROM DeliveryBackOffice.dbo.CatTypeIncidence    
  WHERE CountryId = @CountryId AND NameIncidence = 'Remitente solicita devolución'), 0)    
  PRINT @IncidenceId
  IF(@IncidenceId != 0)
  BEGIN
	SELECT 1 AS StatusCode, 'Consulta exitosa' AS Message, @IncidenceId AS IncidenceId
  END
  ELSE
  BEGIN
	SELECT 0 AS StatusCode, 'Ocurrió un problema al realizar la consulta' AS Message
  END
  
END TRY  
BEGIN CATCH  
    DECLARE @ErrorMessage NVARCHAR(4000);  
    SELECT @ErrorMessage = ERROR_MESSAGE();  
    PRINT 'Error: ' + @ErrorMessage;  
END CATCH;  
END;