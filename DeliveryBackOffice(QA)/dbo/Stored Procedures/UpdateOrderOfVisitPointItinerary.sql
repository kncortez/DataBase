-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-05-12>
-- Description:	<Actualiza el orden para las recolecciones programadas>
-- =============================================
CREATE PROCEDURE UpdateOrderOfVisitPointItinerary
	@IdVPItenerary BIGINT,
	@Order SMALLINT,
	@Token VARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT = 0

	BEGIN TRANSACTION

		BEGIN TRY

			UPDATE VisitPointItinerary
			SET OrderSequence = @Order
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			WHERE IdVPItinerary = @IdVPItenerary

			SET @RModified = @@ROWCOUNT

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			
		END CATCH;

	IF (@@TRANCOUNT > 0)
	BEGIN
		IF (@RModified > 0)
		BEGIN
			COMMIT TRANSACTION;
			SELECT			  
				200 AS 'StatusCode',
				'Registro actualizado correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SELECT			  
				0 AS 'StatusCode',
				'Registros no actualizado' AS 'Description', 
				0 AS 'NumTransferID'
			
		END
	END
	ELSE
	BEGIN
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END
END;