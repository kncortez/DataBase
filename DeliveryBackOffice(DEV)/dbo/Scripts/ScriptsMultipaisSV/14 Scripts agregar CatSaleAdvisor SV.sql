SELECT * FROM DeliveryBackOffice.dbo.CatSaleAdvisor WITH(NOLOCK)
WHERE CountryID = 'HN' AND TokenCreated = 'SYS-BPEDROZA'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatSaleAdvisor]
           ([SaleAdvisorCode]
           ,[SaleAdvisorDescription]
           ,[EmployeID]
           ,[SAPSellerID]
           ,[CountryID]
           ,[SaleAdvisorStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
	SELECT 
		SaleAdvisorCode
		, SaleAdvisorDescription
		, EmployeID
		, SAPSellerID
		, 'SV'
		, SaleAdvisorStatus
		, 'SYS-WOROZCO'
		, GETDATE()
		, NULL
		, NULL
	FROM DeliveryBackOffice.dbo.CatSaleAdvisor
	WHERE CountryID = 'HN' AND TokenCreated = 'SYS-BPEDROZA' 
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
