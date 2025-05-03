--CLONAR PARA SV
--SELECT * FROM DeliveryBackOffice.dbo.AlternativeRateByCustomer
--where CustomerId IN (81,68381) --EJEMPLO DEVELOP

DECLARE @IdRate INT;
DECLARE @IdCustomer INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SELECT @IdRate = RheId FROM DeliveryBackOffice.dbo.RateHeader
	WHERE RheName = 'Tarifario destinos express center' AND CountryId = 'SV'

	SELECT @IdCustomer = IdCustomer FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
	WHERE Name = 'FD EXPRESS CENTER SV' AND Description = 'FD EXPRESS CENTER SV'
	AND RowSatus = 1 AND CountryID = 'SV'

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
			   ,GETDATE()
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