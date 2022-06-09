---=========================================
---==== Marco,Jiménez
---==== Actualiza el campo CommissionNotified a 1, 
---==== para indicar que ya fue enviado correctamente 
---==== el correo con el excel de comisiones y envíos
---=========================================

CREATE PROCEDURE [dbo].[setCommissionNotified]
@BatchCODId AS INT,
@CatType AS INT = 1
AS
BEGIN
	

	BEGIN TRANSACTION;
  
	BEGIN TRY
	IF @CatType = 1 
	BEGIN
	UPDATE BatchDetailCOD 
	SET CommissionNotified = 1
	WHERE BatchCODId = @BatchCODId
	END
	ELSE IF @CatType = 3
	BEGIN
	UPDATE BatchDetailCOD 
	SET CommissionNotified = 1
	WHERE CollectId = @BatchCODId
	END
	ELSE IF @CatType = 4
	BEGIN
	UPDATE BatchDetailCOD 
	SET CommissionNotified = 1
	WHERE RecolectionId = @BatchCODId
	END

								
	END TRY
	BEGIN CATCH
		SELECT 'RollBackTransaction' AS message,
				'FALSE'	blnResult,
				CAST(-1 AS VARCHAR(5)) IdResult,
				CAST(500 AS VARCHAR(5)) StatusResult,
				CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
				CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
				CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
				CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
				CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
				CAST(ERROR_MESSAGE() AS VARCHAR) AS ResultMessage;

		ROLLBACK TRANSACTION;
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
		
		SELECT  'TRUE' AS blnResult 		

		COMMIT TRANSACTION;
	END
	ELSE
	BEGIN
		COMMIT TRANSACTION;
	END
END
