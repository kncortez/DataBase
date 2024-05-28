CREATE PROCEDURE [dbo].[GetDynamicCatalog_old]
    @TypeMethod VARCHAR(100) = 'GetTypePayment',
    @IdAccount INT = 1,
    @Token VARCHAR(100) = '0BE2F8F3BD53652635746ACD069954B5',
    @GuideSerie VARCHAR(2) = 'FD',
    @GuideNumber VARCHAR(100) = '12345',
    @Others VARCHAR(500) = ''
AS
BEGIN

    IF @IdAccount = '' 
	BEGIN
		SET @IdAccount = NULL;
	END

    IF (@TypeMethod = 'GetCustomerType')
    BEGIN

		SELECT [idCustomerType], [Description], [CustomerTypeStatus] 
		FROM dbo.CustomerType
        
    END;
	ELSE IF (@TypeMethod = 'GetClientActive')
    BEGIN

		SELECT	[idCustomer], CONCAT([Name],' ',[Description]) 
		FROM	dbo.Customer 
		WHERE	RowSatus = 1
				AND  (  
						(@Others = '' AND IdCustomerType IN (1, 2))
						OR 
						(@Others <> '' AND IdCustomerType = CONVERT(INT,@Others))
                      ) 
        
    END;
    ELSE 
    BEGIN

		 SELECT '404', 'CONSULTA NO ENCONTRADA' ;
       
    END;

END;
