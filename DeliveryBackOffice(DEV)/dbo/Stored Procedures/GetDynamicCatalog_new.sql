-- =============================================
-- Modified:	<Brandon, Pedroza >
-- Create date: <2024-07-05>
-- Description:	<Se agrega parametro para filtrar por pais, GT por defecto>
-- =============================================
-- Modified:    <Daniel, Ramirez>
-- Create date: <2024-22-07>
-- Description: <Se agrega catalogo y filtro para obtener por pais los vehiculos para portal corporativo>
-- =============================================
CREATE PROCEDURE [dbo].[GetDynamicCatalog_new]
    @TypeMethod VARCHAR(100) = 'GetCustomerType'
  , @IdAccount INT = null
  , @Token VARCHAR(100) = '0BE2F8F3BD53652635746ACD069954B5'
  , @GuideSerie VARCHAR(2) = 'FD'
  , @GuideNumber VARCHAR(100) = '12345'
  , @Others VARCHAR(500) = ''
  , @IdCountry NVARCHAR(2) = 'GT'
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
					AND ISNULL(CountryID, 'GT')= @IdCountry
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
							AND ISNULL(CountryID, 'GT')= @IdCountry
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
							AND ISNULL(CountryID, 'GT')= @IdCountry
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
					  AND ISNULL(vpc.CountryId, 'GT')= @IdCountry
				UNION
				SELECT A2.[CodeOfReference], CONCAT(A1.[Description] , ' ' , A2.[DescriptionOfClient])
				FROM [DeliveryBackOffice].[dbo].[Customer] A1
					INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
					ON A2.CustomerID = A1.IdCustomer
				WHERE	  IdCustomerType = 2 
					AND A2.StatusClient = 1
					AND A2.IdKindOfVPClient = 1	
					AND ISNULL(A2.CountryId, 'GT')= @IdCountry
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
						  AND ISNULL(vpc.CountryId, 'GT')= @IdCountry
					UNION
					SELECT A2.[CodeOfReference], CONCAT(A1.[Description] , ' ' , A2.[DescriptionOfClient])
					FROM [DeliveryBackOffice].[dbo].[Customer] A1
						INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
						ON A2.CustomerID = A1.IdCustomer
					WHERE	  IdCustomerType = 2 
						AND A2.StatusClient = 1
						AND A2.IdKindOfVPClient = 1	
						AND ISNULL(A2.CountryId, 'GT')= @IdCountry
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
						  AND ISNULL(vpc.CountryId, 'GT')= @IdCountry
			END
		END
		
    END;
	ELSE IF (@TypeMethod = 'GetTypeIncidence')
    BEGIN

		SELECT	[IdIncidenceType]					[Id],
				ISNULL([NameIncidence], 'N/A')		[Name],
				ISNULL(DescriptionIncidence, 'N/A')	[Description]
        FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] WITH(NOLOCK)
        WHERE RowStatus = 1
			AND ServiceType = 'PICKUP'
			AND ISNULL(CountryID, 'GT')= @IdCountry

    END;
	ELSE IF (@TypeMethod = 'GetActiveTypeIncidenceDelivery')
    BEGIN

		SELECT cti.IdIncidenceType									[IncidenceId],
				cti.NameIncidence									[IncidenceName],
				cti.IncidenceClasificationId						[IncidenceClasificationId],
				cic.IncidenceTypeName								[IncidenceClasificationName]
		FROM [DeliveryBackOffice].[dbo].CatTypeIncidence AS cti WITH(NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] AS cic WITH(NOLOCK) 
								ON cti.IncidenceClasificationId = cic.IdCatIncidenceClasification
		WHERE cti.ServiceType = 'DELIVERY'
			  AND cti.RowStatus = 1
			  AND ISNULL(CountryID, 'GT')= @IdCountry

    END;
	ELSE IF (@TypeMethod = 'GetIncidenceByServicesDelivery')
    BEGIN

		SELECT  IdIncidenceType [Id]  
				, ISNULL(NameIncidence, 'N/A') [Name]
				, ISNULL(DescriptionIncidence, 'N/A') [DescriptionIncidence]
				, IIF(COALESCE(EvidenceRequirement,0) = 1, '1','0') [EvidenceRequirement]								   
				, ISNULL(CourierInstructions, 'N/A') [CourierInstructions]
		FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] WITH(NOLOCK)
		WHERE ServiceType = 'DELIVERY'
				AND RowStatus = 1
				AND ISNULL(CountryID, 'GT')= @IdCountry

    END;
	ELSE IF (@TypeMethod = 'GetTypeIncidenceSettlementLastMile')
    BEGIN

		SELECT  IdIncidenceType  [IncidenceId]
			  , ISNULL(NameIncidence, 'N/A')  [IncidenceName]
		FROM DeliveryBackOffice.dbo.CatTypeIncidence  WITH(NOLOCK)
		WHERE ISNULL(CountryId, 'GT') = @IdCountry
			AND ServiceType = 'LAST MILE SETTLEMENT'

    END;
	ELSE IF (@TypeMethod = 'GetTypeIncidenceSettlementCOD')
    BEGIN

		SELECT  IdIncidenceType  [IncidenceId]
			  , ISNULL(NameIncidence, 'N/A')  [IncidenceName]
		FROM DeliveryBackOffice.dbo.CatTypeIncidence  WITH(NOLOCK)
		WHERE ISNULL(CountryId, 'GT') = @IdCountry
			AND ServiceType = 'COD SETTLEMENT'

    END;
	ELSE IF (@TypeMethod = 'GetTypeIncidenceSettlementLastMileCOD')
    BEGIN

		SELECT  IdIncidenceType  [IncidenceId]
			  --,ISNULL(NameIncidence, 'N/A')  [IncidenceName]
			  , IIF(ServiceType = 'COD SETTLEMENT', ISNULL(NameIncidence, 'N/A') + ' - COD',  ISNULL(NameIncidence, 'N/A') + ' - Entrega')  [IncidenceName]
		FROM DeliveryBackOffice.dbo.CatTypeIncidence  WITH(NOLOCK)
		WHERE ISNULL(CountryId, 'GT') = @IdCountry				
			AND (ServiceType = 'COD SETTLEMENT' OR ServiceType = 'LAST MILE SETTLEMENT')
		ORDER BY ServiceType desc

    END;
    ELSE IF (@TypeMethod = 'GetTypeVehicle')
    BEGIN
        SELECT IdTypeVehicle AS [Id],
               [Name] AS [Name],
               [Description] AS [Description]
          FROM CatTypeVehicle
         WHERE RowStatus = 1
           AND Name IN ('Camión','Panel','Motocicleta')
           AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
    END;
	    ELSE IF (@TypeMethod = 'GetSystem')
    BEGIN
        SELECT [SysIdSystem]    AS [Id]
             , [SysNameSystem]  AS [Name]
             , [SysDescription] AS [Description]
          FROM CatSystem WITH(NOLOCK)
         WHERE SysRowStatus = 1
    END;
    ELSE IF (@TypeMethod = 'GetFinalStatusOrder')
    BEGIN
        SELECT StatusOrderId     [Id]
             , OrderDescription  [Name]
             , StatusMessage     [Description]
        FROM StatusOrder WITH (NOLOCK)
        WHERE CatCheckpointTypeId = 3
          AND RowStatus = 1;
    END;
	ELSE IF (@TypeMethod = 'GetConditionPayment')
    BEGIN
        SELECT IdConditionOfPayment           [Id]
             , CASE 
                   WHEN RIGHT(ConditionOfPaymenAbbreviation, 1) LIKE '[0-9]' 
                   THEN LEFT(ConditionOfPaymenAbbreviation, LEN(ConditionOfPaymenAbbreviation) - 1)
                   ELSE ConditionOfPaymenAbbreviation
               END AS [Name]
             , ConditionOfPayment            [Description]
        FROM CatConditionOfPayment WITH (NOLOCK)
        WHERE IdConditionOfPayment in (1,2)
          AND RowStatus = 1;
    END;
	ELSE IF (@TypeMethod = 'GetCorporateCustomers')
    BEGIN
        SELECT CONVERT(NVARCHAR, ISNULL(IdCustomer, 0)) AS [Id]
             , REPLACE(ISNULL([Name], 'N/A'), '"', '') AS [Name]
             , ISNULL([CustomerPhone], '') AS [Phone]
             , ISNULL([ContactEmail], '') AS [Email]
        FROM Customer WITH (NOLOCK)
        WHERE CountryID = @IdCountry
          AND IdCustomerType = 1 
          AND RowSatus = 1
    END;
    ELSE 
    BEGIN

		 SELECT '404', 'CONSULTA NO ENCONTRADA' ;
       
    END;

END;