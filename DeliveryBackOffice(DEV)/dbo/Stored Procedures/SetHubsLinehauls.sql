CREATE PROCEDURE [dbo].[SetHubsLinehauls]
@Guide_Serie AS VARCHAR(2), 
@Guide_Number AS INT,
@HubOriginId  AS INT, 
@HubDestinationId AS INT
AS
BEGIN
	
	DECLARE @Updated INT

	BEGIN TRANSACTION

		BEGIN TRY

			UPDATE DeliveryBackOffice.dbo.DeliveryOrder 
			SET
			HubOriginId = @HubOriginId,
			HubDestinationId = @HubDestinationId
			WHERE 
				Guide_Serie = @Guide_Serie
				AND Guide_Number = @Guide_Number				

			SET @Updated = @@ROWCOUNT
			PRINT @Updated


		END TRY

	BEGIN CATCH
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;
	
	IF @@TRANCOUNT > 0
	BEGIN
		IF (@Updated > 0)
			SELECT			  
				1 AS 'StatusCode',
				'Registros actualizados correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'
		ELSE
			SELECT			  
				0 AS 'StatusCode',
				'No se actualizó ningún registro' AS 'Description', 
				0 AS 'NumTransferID'

		COMMIT TRANSACTION;			
	END
	ELSE
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
END