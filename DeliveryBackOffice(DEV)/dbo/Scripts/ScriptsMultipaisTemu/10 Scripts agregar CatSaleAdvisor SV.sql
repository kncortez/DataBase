BEGIN TRY
    BEGIN TRANSACTION;
    
    --Datos NO proporcionados por producto
    --Datos de prueba
    
    INSERT INTO [CatSaleAdvisor] (
        SaleAdvisorCode,
        SaleAdvisorDescription,
        EmployeID,
        SAPSellerID,
        CountryID,
        SaleAdvisorStatus,
        TokenCreated,
        DateCreated,
        TokenUpdated,
        DateUpdated
    )
    SELECT 
        REPLACE(SaleAdvisorCode, 'HN', 'SV') AS SaleAdvisorCode,
        SaleAdvisorDescription,
        EmployeID,
        SAPSellerID,
        'SV' AS CountryID,
        SaleAdvisorStatus,
        'SYS-JRAMIREZ' AS TokenCreated,
        GETDATE() AS DateCreated,
        NULL AS TokenUpdated,
        NULL AS DateUpdated
    FROM [CatSaleAdvisor]
    WHERE CountryID = 'HN'
     AND SaleAdvisorStatus = 'TRUE'
    AND SaleAdvisorCode LIKE 'HN%';
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
