--EXEC   [dbo].[GetGeneratedBatchCOD]
CREATE PROCEDURE [dbo].[GetGeneratedBatchCOD]
AS
BEGIN	

	BEGIN TRY

	DECLARE @ACTIVE BIT = 'FALSE';

	IF (@ACTIVE = 'TRUE')
	BEGIN
		SELECT bcod.BankId AS PayingBank, bcod.IdBatchCOD,bcod.BatchNumber AS BATCHNUMBER, 'TRUE' AS blnResult, bcod.BatchTimeRange 
									FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pg
									INNER JOIN  DeliveryBackOffice.dbo.BatchCOD bcod ON pg.BatchCODId = bcod.IdBatchCOD
									WHERE 
									pg.BatchNotified IS NULL
									AND pg.BatchCODId IS NOT NULL
									AND pg.BatchCODIdCommission IS NOT NULL
									AND pg.RowStatus = 1
									AND bcod.BankId IN (5, 33)
									--AND pg.Date BETWEEN '2021-08-25 00:00:00.000' AND '2021-08-25 23:59:59.999'
									GROUP BY bcod.BankId , bcod.IdBatchCOD,bcod.BatchNumber, bcod.BatchTimeRange 
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

		
	END CATCH;	
	
END
