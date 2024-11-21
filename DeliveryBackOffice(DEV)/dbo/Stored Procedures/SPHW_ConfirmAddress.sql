-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-11-21>
-- Description:	<Delivery Tracking - Método para confirmar dirección del destinatario.>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_ConfirmAddress]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Address NVARCHAR(200),
@Longitude NVARCHAR(200),
@Latitude NVARCHAR(200),
@Token NVARCHAR(200)
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION;
    
    SELECT
		  '1' AS StatusCode
		, 'Tu dirección ha sido confirmada exitosamente.' AS MessageResponse
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;