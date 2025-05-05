BEGIN TRY
    BEGIN TRANSACTION;

INSERT INTO DeliveryBackOffice_bckp.dbo.CatSaleAdvisor
(SaleAdvisorCode,SaleAdvisorDescription,EmployeID,SAPSellerID,CountryID,SaleAdvisorStatus,TokenCreated,DateCreated)
VALUES ('EXP CENTER','Clientes de EXC',0,NULL,'SV',1,'SYS-ORODRIGUEZ',GETDATE())

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
