--CLONAR
--SELECT * FROM DeliveryBackOffice.dbo.AlternativeRateByCustomer
--where CustomerId IN (81,68381) --EJEMPLO DEVELOP

DECLARE @IdRate INT;
DECLARE @IdCustomer INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SELECT @IdRate = RheId FROM DeliveryBackOffice.dbo.RateHeader
	WHERE RheName = 'Tarifario destinos express center' AND CountryId = 'HN'

	SELECT @IdCustomer = IdCustomer FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
	WHERE Name = 'FD EXPRESS CENTER HN' AND Description = 'FD EXPRESS CENTER HN'
	AND RowSatus = 1 AND CountryID = 'HN'

	INSERT INTO [dbo].[AlternativeRateByCustomer]
			   ([RateId]
			   ,[CustomerId]
			   ,[VisitPointClientId]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated])
		 VALUES
			   (@IdRate
			   ,@IdCustomer
			   ,NULL
			   ,1
			   ,'SYS-WOROZCO'
			   ,'2024-08-13 10:22:00.000'
			   ,NULL
			   ,NULL)

	   COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;