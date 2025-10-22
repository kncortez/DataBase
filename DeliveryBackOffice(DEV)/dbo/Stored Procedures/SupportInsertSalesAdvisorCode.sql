CREATE PROCEDURE SupportInsertSalesAdvisorCode
    @saleAdvisorCode VARCHAR(12)
  , @CountryID VARCHAR(2)
  , @Token VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT *
        FROM dbo.CatSaleAdvisor
        WHERE SaleAdvisorCode = @saleAdvisorCode
    )
    BEGIN

        INSERT dbo.CatSaleAdvisor
        (
            SaleAdvisorCode
          , SaleAdvisorDescription
          , EmployeID
          , SAPSellerID
          , CountryID
          , SaleAdvisorStatus
          , TokenCreated
          , DateCreated
          , TokenUpdated
          , DateUpdated
        )
        VALUES
        (   @saleAdvisorCode -- SaleAdvisorCode - nvarchar(12)
          , N' '             -- SaleAdvisorDescription - nvarchar(50)
          , 0                -- EmployeID - int
          , NULL             -- SAPSellerID - int
          , @CountryID       -- CountryID - varchar(2)
          , 1                -- SaleAdvisorStatus - bit
          , @Token           -- TokenCreated - nvarchar(50)
          , GETDATE()        -- DateCreated - datetime
          , NULL             -- TokenUpdated - nvarchar(50)
          , NULL             -- DateUpdated - datetime
            );
    END;
    ELSE
        SELECT 'esto ya existe';
END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportInsertSalesAdvisorCode] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportInsertSalesAdvisorCode] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportInsertSalesAdvisorCode] TO [cvaldes]
    AS [dbo];

