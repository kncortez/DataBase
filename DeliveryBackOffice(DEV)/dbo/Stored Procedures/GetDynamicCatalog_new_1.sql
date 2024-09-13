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
		
			IF @Others = ''
			BEGIN
				SELECT  [idCustomer], 
						CONCAT(dbo.fnt_String_Escape([Name],'json'), ' ', dbo.fnt_String_Escape([Description],'json')) AS [Customer]
				FROM
					[DeliveryBackOffice].[dbo].[Customer] WITH (NOLOCK)
				WHERE RowSatus = 1
					AND IdCustomerType = 1
				UNION 
				SELECT 81 [idCustomer], 'FDC EXPRESS CENTER' [Customer]
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT Item FROM dbo.SplitUnlimited(@Others, ',') WHERE Item = 2 )
				BEGIN
					SELECT [idCustomer], 
							CONCAT(dbo.fnt_String_Escape([Name],'json'), ' ', dbo.fnt_String_Escape([Description],'json')) AS [Customer]
					FROM [DeliveryBackOffice].[dbo].[Customer] WITH (NOLOCK)
					WHERE	RowSatus = 1
							AND IdCustomerType IN (
													SELECT Item 
													FROM dbo.SplitUnlimited(@Others, ',') 
													WHERE Item <> 2 -- Omite Redistribuidores
												   )
					UNION 
						SELECT 81 [idCustomer], 'FD EXPRESS CENTER' [Customer]
				END
				ELSE
				BEGIN
					SELECT [idCustomer], 
							CONCAT(dbo.fnt_String_Escape([Name],'json'), ' ', dbo.fnt_String_Escape([Description],'json')) AS [Customer]
					FROM [DeliveryBackOffice].[dbo].[Customer] WITH (NOLOCK)
					WHERE	RowSatus = 1
							AND IdCustomerType IN ( SELECT Item FROM dbo.SplitUnlimited(@Others, ',') )
				END
			END
    END;
	ELSE IF (@TypeMethod = 'GetActiveVisitPointByClient')
    BEGIN
		
		IF @Others = ''
		BEGIN
				SELECT vpc.[CodeOfReference], CONCAT( dbo.fnt_String_Escape(c.[Description],'json'), ' ',  dbo.fnt_String_Escape(vpc.[DescriptionOfClient],'json') ) ClientVisitPoint
				FROM [DeliveryBackOffice].[dbo].[Customer]					c   WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
						ON c.IdCustomer = vpc.CustomerID
				WHERE  IdCustomerType = 1
					  AND c.RowSatus = 1
					  AND vpc.StatusClient = 1
				UNION
				SELECT A2.[CodeOfReference], CONCAT(A1.[Description] , ' ' , A2.[DescriptionOfClient])
				FROM [DeliveryBackOffice].[dbo].[Customer] A1
					INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
					ON A2.CustomerID = A1.IdCustomer
				WHERE	  IdCustomerType = 2 
					AND A2.StatusClient = 1
					AND A2.IdKindOfVPClient = 1	
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT Item FROM dbo.SplitUnlimited(@Others, ',') WHERE Item = 81 )
			BEGIN
					SELECT vpc.[CodeOfReference], CONCAT( dbo.fnt_String_Escape(c.[Description],'json'), ' ',  dbo.fnt_String_Escape(vpc.[DescriptionOfClient],'json') ) ClientVisitPoint
					FROM [DeliveryBackOffice].[dbo].[Customer]					c   WITH (NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
							ON c.IdCustomer = vpc.CustomerID
					WHERE c.IdCustomer  IN (SELECT Item FROM dbo.SplitUnlimited(@Others, ',') WHERE Item <> 2339 )-- Omite Redistribuidores
						  AND IdCustomerType = 1
						  AND c.RowSatus = 1
						  AND vpc.StatusClient = 1
					UNION
					SELECT A2.[CodeOfReference], CONCAT(A1.[Description] , ' ' , A2.[DescriptionOfClient])
					FROM [DeliveryBackOffice].[dbo].[Customer] A1
						INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
						ON A2.CustomerID = A1.IdCustomer
					WHERE	  IdCustomerType = 2 
						AND A2.StatusClient = 1
						AND A2.IdKindOfVPClient = 1	
			END
			ELSE
			BEGIN

					SELECT vpc.[CodeOfReference], CONCAT( dbo.fnt_String_Escape(c.[Description],'json'), ' ',  dbo.fnt_String_Escape(vpc.[DescriptionOfClient],'json') ) ClientVisitPoint
					FROM [DeliveryBackOffice].[dbo].[Customer]					c   WITH (NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
							ON c.IdCustomer = vpc.CustomerID
					WHERE c.IdCustomer  IN (SELECT Item FROM dbo.SplitUnlimited(@Others, ',')) 
						  AND IdCustomerType = 1
						  AND c.RowSatus = 1
						  AND vpc.StatusClient = 1
			END
		END
		
    END;
	ELSE IF (@TypeMethod = 'GetActiveTypeIncidenceDelivery')
    BEGIN

		SELECT 
				cti.NameIncidence									[NameIncidence],
				cti.IdIncidenceType									[IncidenceId],
				cti.NameIncidence									[IncidenceName],												
				cti.IncidenceClasificationId						[IncidenceClasificationId],
				cic.IncidenceTypeName								[IncidenceClasificationName],
				cti.IdIncidenceType									[IdIncidenceType]
		FROM [DeliveryBackOffice].[dbo].CatTypeIncidence AS cti WITH(NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] AS cic WITH(NOLOCK) 
								ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
		WHERE cti.ServiceType = 'DELIVERY'
			  AND cti.RowStatus = 1

    END;
    ELSE 
    BEGIN

		 SELECT '404', 'CONSULTA NO ENCONTRADA' ;
       
    END;

END;