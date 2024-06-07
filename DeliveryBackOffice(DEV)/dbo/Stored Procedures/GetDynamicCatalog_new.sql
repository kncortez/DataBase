CREATE PROCEDURE [dbo].[GetDynamicCatalog_new]
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
		FROM [DeliveryBackOffice].[dbo].[CustomerType] WITH (NOLOCK)
        
    END;
	ELSE IF (@TypeMethod = 'GetClientActive')
    BEGIN

		SELECT	[idCustomer], CONCAT([Name],' ',[Description]) [Customer]
		FROM	[DeliveryBackOffice].[dbo].[Customer] WITH (NOLOCK)
		WHERE	RowSatus = 1
				AND  (  
						(@Others = '' AND IdCustomerType IN (1, 2))
						OR 
						(@Others <> '' AND IdCustomerType = CONVERT(INT,@Others))
                      ) 
        
    END;
	ELSE IF (@TypeMethod = 'GetActiveVisitPointByClient')
    BEGIN

		SELECT vpc.[CodeOfReference], CONCAT(c.[Description], '', vpc.[DescriptionOfClient]) ClientVisitPoint
		FROM [DeliveryBackOffice].[dbo].[Customer]					c   WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
				ON c.IdCustomer = vpc.CustomerID
		WHERE (  
					(@Others = '' AND IdCustomerType IN (1, 2))
					OR 
					(@Others <> '' AND c.IdCustomer  IN (SELECT Item FROM dbo.SplitUnlimited(@Others, ',')))
                )
			  AND c.RowSatus = 1
			  AND vpc.StatusClient = 1
    END;
	ELSE IF (@TypeMethod = 'GetActiveTypeIncidenceDelivery')
    BEGIN

		SELECT [IdIncidenceType], [NameIncidence]
		FROM [DeliveryBackOffice].[dbo].CatTypeIncidence
		WHERE ServiceType = 'DELIVERY'
			  AND RowStatus = 1

    END;
    ELSE 
    BEGIN

		 SELECT '404', 'CONSULTA NO ENCONTRADA' ;
       
    END;

END;
