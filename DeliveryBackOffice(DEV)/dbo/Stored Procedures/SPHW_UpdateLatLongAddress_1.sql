-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-12-11>
-- Description:	<Delivery Tracking - Método para actualizar la longitud y la latitud de la ubicación>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_UpdateLatLongAddress]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Token NVARCHAR(50),
@Latitude DECIMAL(18,15),
@Longitude DECIMAL(18,15)
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION  
	UPDATE [DeliveryBackOffice].[dbo].[ServiceDataForGuide]
		SET Latitude = @Latitude, 
			Longitude = @Longitude,
            TokenUpdated = @Token,
		    DateUpdated = GETDATE()
	WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber;
	IF @@TRANCOUNT > 0 
	BEGIN  
	COMMIT TRANSACTION;  
	SELECT 1 AS [StatusCode], 'Actualizacion exitosa' AS[MessageResponse] 
	END  
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;