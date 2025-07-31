--SCRIPT PARA ENLAZAR UNA TARIFA CON UN CLIENTE
--SELECT * FROM DeliveryBackOffice.dbo.RatebyCustomer
--WHERE RbcIdCustomer = 81 OR RbcIdRate = 2286 OR RbcIdCustomer = 68381 --EJEMPLO DEVELOP

DECLARE @IdRate INT;
DECLARE @IdCustomer INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SELECT @IdRate = RheId FROM DeliveryBackOffice.dbo.RateHeader
	WHERE RheName = 'Tarifario de servicio estandar' AND CountryId = 'SV'

	SELECT @IdCustomer = IdCustomer FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
	WHERE Name = 'FD EXPRESS CENTER SV' AND Description = 'FD EXPRESS CENTER SV'
	AND RowSatus = 1 AND CountryID = 'SV'

	INSERT INTO [dbo].[RatebyCustomer]
			   ([RbcIdRate]
			   ,[RbcIdCustomer]
			   ,[RbcRowStatus]
			   ,[RbcTokenCreated]
			   ,[RbcDateCreated]
			   ,[RbcTokenUpdated]
			   ,[RbcDateUpdated]
			   ,[RbcCodeOfReference])
		 VALUES
			   (@IdRate
			   ,@IdCustomer
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
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
