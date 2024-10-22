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

    DECLARE @CountryId NVARCHAR(3) = (SELECT ISNULL(ReceiverCountryId,'GT') FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
											 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

	DECLARE @CodeArea NVARCHAR(5) = (SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
											WHERE [Name] = 'AreaCode' AND IdCountry = @CountryId)
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