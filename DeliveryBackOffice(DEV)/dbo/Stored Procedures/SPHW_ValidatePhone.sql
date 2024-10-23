-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-18-10>
-- Description:	<Delivery Tracking - Método para validar el telefono del cliente>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_ValidatePhone]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Phone NVARCHAR(15)
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
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
	)
	--Validación del telefono
	IF((@Phone = @Receiver_Phone) OR (@Phone = @CodeArea + @Receiver_Phone) OR (@Phone = '+' + @CodeArea + @Receiver_Phone))
	BEGIN
		SELECT 
			  200						 AS 'IdResult'
			, 'Exitoso.'				 AS 'Message'
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