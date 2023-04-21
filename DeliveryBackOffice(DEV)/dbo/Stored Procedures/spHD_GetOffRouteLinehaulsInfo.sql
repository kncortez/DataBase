
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-11>
-- Description:	<Obtiene la información para marcar una guía como fuera de ruta Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetOffRouteLinehaulsInfo]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	BEGIN TRY

		SELECT
			1 'StatusCode'
		   ,'Datos obtenidos correctamente.' 'Description'
		   ,CASE
				WHEN do.IsLastMileReturn = 1 THEN do.Sender_Department
				ELSE do.Receiver_Department
			END 'Department'
		   ,CASE
				WHEN do.IsLastMileReturn = 1 THEN do.Sender_Town
				ELSE do.Receiver_Town
			END 'Town'
		   ,CASE
				WHEN do.IsLastMileReturn = 1 THEN do.Sender_Address
				ELSE do.Receiver_Address
			END 'Address'
		FROM DeliveryOrder do WITH(NOLOCK)
		WHERE Guide_Serie = @GuideSerie
		AND Guide_Number = @GuideNumber


	END TRY
	BEGIN CATCH
		SELECT
			-1 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,'' 'Department'
		   ,'' 'Town'
		   ,'' 'Address'
	END CATCH
END