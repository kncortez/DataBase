-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-10>
-- Description:	<Delivery Tracking - Método para obtener información privada para rastreo de parquete.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetTrackingPrivate]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Phone INT
AS
BEGIN
BEGIN TRY

	DECLARE @Receiver_Phone NVARCHAR(200) = (SELECT Receiver_Phone FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
											 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

	--Validación del telefono
	IF((@Phone = @Receiver_Phone) OR (@Phone = '502' + @Receiver_Phone))
	BEGIN
		SELECT 
			  200						 AS 'IdResult'
			, 'Exitoso.'				 AS 'Message'
			, ISNULL(DO.Receiver_Lat,'') AS 'Latitud'
			, ISNULL(DO.Receiver_Lng,'') AS 'Longitud'
			, ISNULL(S.Settlement,'')    AS 'Poblado'
			, ISNULL(T.TownshipName,'')  AS 'Municipio'
			, ISNULL(P.ProvinceName,'')  AS 'Departamento'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.Settlement S WITH(NOLOCK)
			ON DO.ReceiverIdSettlement = S.IdSettlement
		LEFT JOIN DeliveryBackOffice.dbo.Township T WITH(NOLOCK)
			ON S.IdTownship = T.IdTownship
		LEFT JOIN DeliveryBackOffice.dbo.Province P WITH(NOLOCK)
			ON S.IdProvince = P.IdProvince
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
	END
	ELSE
	BEGIN
		SELECT 
		  409 AS 'IdResult'
		, 'El número ingresado no coincide con el registrado para este envío.' AS 'Message'
	END

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;