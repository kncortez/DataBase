-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-09-25>
-- Description:	<Carga la informacion de los links por cuenta y pais>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-27>
-- Description:	<Comprobar caducidad de links y cambio de estado a Caducado.>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetDeliveryLink]
				 @AccountId INT,
				 @IdCountry NVARCHAR(2) = 'GT'
AS

BEGIN
	BEGIN TRY
	BEGIN TRANSACTION 

	DECLARE @Status INT = (SELECT IdDeliveryLinkStatus FROM DeliveryLinkStatus WHERE Name = 'Caducado')
	DECLARE @StatusAcepted INT = (SELECT IdDeliveryLinkStatus FROM DeliveryLinkStatus WHERE Name = 'Enviado')
	--Procedimiento para saber si su link esta caducado
	UPDATE DeliveryBackOffice.dbo.DeliveryLink
	SET DeliveryLinkStatusId = @Status
	WHERE AccountId = @AccountId AND ExpirationDate < GETDATE() AND DeliveryLinkStatusId = @StatusAcepted

	SELECT 1 AS StatusCode,
		   'Registros encontrados' AS Description

	SELECT DL.IdDeliveryLink,
		   DL.ReceiverName,
		   DLP.Quantity,
		   DL.ReceiverPhone,
		   DL.ReceiverAddress,
		   DL.DateCreated,
		   DLS.Name AS Status
	FROM DeliveryLink DL WITH (NOLOCK)
		INNER JOIN VisitPointClient VP WITH (NOLOCK)
			ON DL.DestinyCodeOfReference = VP.CodeOfReference
		INNER JOIN DeliveryLinkProducts DLP WITH (NOLOCK)
			ON DLP.DeliveryLinkId = DL.IdDeliveryLink
		INNER JOIN DeliveryLinkStatus DLS WITH (NOLOCK)
			ON DLS.IdDeliveryLinkStatus = DL.DeliveryLinkStatusId
	WHERE VP.CountryId = @IdCountry
		  AND DL.AccountId = @AccountId

	COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

		SELECT 0 AS StatusCode,
			   ERROR_MESSAGE() AS Description,
			   ERROR_LINE() AS ErrorLine
	END CATCH
END