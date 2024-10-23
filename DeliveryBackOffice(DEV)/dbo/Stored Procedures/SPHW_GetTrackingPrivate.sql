-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-10>
-- Description:	<Delivery Tracking - Método para obtener información privada para rastreo de parquete.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetTrackingPrivate]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Phone NVARCHAR(200)
AS
BEGIN
BEGIN TRY

	DECLARE @Receiver_Phone NVARCHAR(200) = (SELECT RIGHT(LTRIM(RTRIM(Receiver_Phone)), 8) FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
											 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

	DECLARE @CodeArea NVARCHAR(5) = (
		SELECT 
			CASE 
				-- Caso 1: El número comienza con '+' y tiene al menos 11 dígitos (ej. +50244444444)
				WHEN LEFT(DO.Receiver_Phone, 1) = '+' AND LEN(DO.Receiver_Phone) >= 11 THEN 
					SUBSTRING(DO.Receiver_Phone, 2, 3)

				-- Caso 2: El número comienza con un código de área sin '+' y tiene al menos 10 dígitos (ej. 50244444444)
				WHEN LEN(DO.Receiver_Phone) >= 10 AND ISNUMERIC(LEFT(DO.Receiver_Phone, 3)) = 1 THEN 
					LEFT(DO.Receiver_Phone, 3)

				-- Caso 3: Si no tiene código de área válido, devuelve NULL (ej. 2345-6789)
				ELSE ISNULL(C.[Value],'502')
			END AS 'AreaCode'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams C WITH(NOLOCK)
			ON C.[Name] = 'AreaCode' AND ISNULL(DO.ReceiverCountryId,'GT') = C.IdCountry
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
	)

	--Validación del telefono
	IF((@Phone = @Receiver_Phone) OR (@Phone = @CodeArea + @Receiver_Phone) OR (@Phone = '+' + @CodeArea + @Receiver_Phone))
	BEGIN
		SELECT 
			  200						 AS 'IdResult'
			, 'Exitoso.'				 AS 'Message'
			, ISNULL(S.Settlement,'')    AS 'Poblado'
			, IIF(T.TownshipName IS NOT NULL,T.TownshipName,ISNULL(T2.TownshipName,'')) AS 'Municipio'
			, IIF(P.ProvinceName IS NOT NULL,P.ProvinceName,ISNULL(P2.ProvinceName,'')) AS 'Departamento'
			, ISNULL(DO.Receiver_Address,'')											AS 'AddressDestiny'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.Settlement S WITH(NOLOCK)
			ON DO.ReceiverIdSettlement = S.IdSettlement
		LEFT JOIN DeliveryBackOffice.dbo.Township T WITH(NOLOCK)
			ON S.IdTownship = T.IdTownship
		LEFT JOIN DeliveryBackOffice.dbo.Province P WITH(NOLOCK)
			ON S.IdProvince = P.IdProvince
		LEFT JOIN DeliveryBackOffice.dbo.Township T2 WITH(NOLOCK)
			ON DO.ReceiverIdTownship = T2.IdTownship
		LEFT JOIN DeliveryBackOffice.dbo.Province P2 WITH(NOLOCK)
			ON T2.IdProvince = P2.IdProvince
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