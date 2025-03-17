-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2025-01-31>
-- Description:	<Se pasa a formato XML por proyecto de compatibilidad de bases de datos>
-- =============================================
CREATE PROCEDURE [dbo].[GetDynamicCatalog]
    @TypeMethod VARCHAR(100) = 'GetTypePayment',
    @IdAccount INT = 1,
    @Token VARCHAR(100) = '0BE2F8F3BD53652635746ACD069954B5',
    @GuideSerie VARCHAR(2) = 'FD',
    @GuideNumber VARCHAR(100) = '12345',
    @Others VARCHAR(500) = ''
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);
    IF @IdAccount = '' SET @IdAccount = NULL;
    --IF (@Others <> 'CourierApp')
    --BEGIN
    --    IF NOT EXISTS
    --    (
    --        SELECT 1
    --        FROM DeliveryBackOffice.dbo.TokenLog WITH(NOLOCK)
    --        WHERE TknRowStatus = 1
    --              AND TknIdToken = @Token
    --              AND CAST(TknDateCreated AS DATE) = CAST(GETDATE() AS DATE)
    --    )
    --    BEGIN
    --        PRINT 'token inválido';
    --        SET @jsonResult =
    --        (
    --            SELECT STUFF(
    --                            (
    --                                SELECT ',{"IdError":' + '500' + ',' + '"DescriptionError":"' + 'Token inválido'
    --                                       + '"' + '}'
    --                                FOR XML PATH(''), TYPE
    --                            ).value('.', 'varchar(max)'),
    --                            1,
    --                            1,
    --                            ''
    --                        )
    --        );
    --        SELECT '[' + @jsonResult + ']' FormatJson;

    --        RETURN;
    --    END;
    --END;
    IF (@TypeMethod = 'GetModules')
    BEGIN
		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY ModIdModule) - 1 AS [@Row],
				  CONVERT(VARCHAR, ModIdModule) AS Id,
				 CONVERT(VARCHAR, ModName) AS [Description]
			FROM DeliveryBackOffice.dbo.CatModule WITH(NOLOCK)
			WHERE ModVisible = 1
			FOR XML PATH('Row'), ROOT('root')
		 )
    END;


    ELSE IF (@TypeMethod = 'GetTypePayment')
    BEGIN
		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY TimePlaId) - 1 AS [@Row],
					CONVERT(NVARCHAR(50), TimePlaId) AS Id,
					TimePlaName AS Name,
					TimePlaDescription AS [Description]
			FROM DeliveryBackOffice.dbo.CatPaymentTime WITH (NOLOCK)
			WHERE TimePlaStatus = 1
			FOR XML PATH('Row'), ROOT('root')
		 )
    END;

    ELSE IF (@TypeMethod = 'GetTypePiece')
    BEGIN

        DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
		DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);
		DECLARE @NewAutoSalesMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' COLLATE Latin1_General_CI_AI);

		SET @jsonResult =
		 (
			SELECT  ROW_NUMBER() OVER (ORDER BY cd.[AbcId]) - 1 AS [@Row],
					CONVERT(NVARCHAR, ISNULL(cd.[AbcId], 0)) AS Id, 
					ISNULL(cd.[Code], '') AS Code,
					(
						CASE
							WHEN cd.IsMainPackage IS NOT NULL AND cd.IsMainPackage = 1 THEN cd.ArtName
							ELSE ISNULL(CONCAT(cd.[Code], '  -  ', cd.[TarName], '-', cd.[ArtName]), '')
						END
					) AS Description, 
					CONVERT(NVARCHAR, ISNULL(cd.[Height], 30)) AS Height, 
					CONVERT(NVARCHAR, ISNULL(cd.[Width], 30)) AS Width, 
					CONVERT(NVARCHAR, ISNULL(cd.[Length], 30)) AS Length, 
					CONVERT(NVARCHAR, ISNULL(cd.MassWeight, 1)) AS Weight,
					IIF(cd.IsMainPackage IS NOT NULL, IIF(cd.IsMainPackage = 1, 'true', 'false'), '') AS IsMainPackage
			FROM (SELECT DISTINCT
					abc.Code
					,abc.AbcId
					,ta.TarName
					,art.ArtName
					,abc.Height
					,abc.Width
					,abc.Length
					,abc.MassWeight
					,IIF(ra.RateId IN (@NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates), IIF(ra.TypeServiceId IS NOT NULL AND ra.TypeSegmentId IS NOT NULL, 1, 0), NULL) 'IsMainPackage'
				FROM dbo.CatArticle art WITH(NOLOCK)
				INNER JOIN dbo.ArticleByCustomer abc WITH(NOLOCK)
					ON abc.AbcIdArticle = art.ArtId
				LEFT JOIN CatTypeArticle ta WITH(NOLOCK)
					ON ta.TarId = art.ArtIdTypeArticle
				INNER JOIN RateData ra WITH(NOLOCK)
					ON ra.ArticleId = abc.AbcId
				INNER JOIN RatebyCustomer rbc WITH(NOLOCK)
					ON rbc.RbcIdRate = ra.RateId
				INNER JOIN Account ac WITH(NOLOCK)
					ON ac.IdCustomer = rbc.RbcIdCustomer
				WHERE ac.AccIdAccount = @IdAccount
				AND art.ArtRowStatus = 'TRUE'
				AND abc.AbcRowStatus = 'TRUE'
				AND ra.RowStatus = 'TRUE'
				AND rbc.RbcRowStatus = 'TRUE'
				AND ac.AccRowStatus = 'TRUE') cd
			ORDER BY cd.AbcId
			FOR XML PATH('Row'), ROOT('root')
		)
    END;

    ELSE IF (@TypeMethod = 'GetTypeIncidence')
    BEGIN
		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY IdIncidenceType) - 1 AS [@Row],
					CONVERT(NVARCHAR, IdIncidenceType) AS Id,
					ISNULL(NameIncidence, 'N/A') AS Name,
					ISNULL(DescriptionIncidence, 'N/A') AS Description
			FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
			WHERE RowStatus = 1
					AND ServiceType = 'PICKUP'
			FOR XML PATH('Row'), ROOT('root')
		 )
    END;

    ELSE IF (@TypeMethod = 'GetIncidenceByServicesReturn')
    BEGIN
        PRINT 'PRUEBA 6';
		SET @jsonResult =
		(
			SELECT  ROW_NUMBER() OVER (ORDER BY IdIncidenceType) - 1 AS [@Row],
					CONVERT(NVARCHAR, IdIncidenceType) AS Id,
					ISNULL(NameIncidence, 'N/A') AS [Name],
					ISNULL(DescriptionIncidence, 'N/A') AS [Description]
			FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
			WHERE RowStatus = 1
					AND ServiceType = 'RETURN'
			FOR XML PATH('Row'), ROOT('root')
		)
    END;

    ELSE IF (@TypeMethod = 'GetIncidenceByServicesDelivery')
    BEGIN
        PRINT 'PRUEBA 7';
		SET @jsonResult =
		(
			SELECT ROW_NUMBER() OVER (ORDER BY IdIncidenceType) - 1 AS [@Row],
					CONVERT(NVARCHAR, IdIncidenceType) AS Id,
					ISNULL(NameIncidence, 'N/A') AS Name,
					ISNULL(DescriptionIncidence, 'N/A') AS Description,									   
					IIF(COALESCE(EvidenceRequirement,0) = 1, '1','0')  AS EvidenceRequirement,
					ISNULL(CourierInstructions, 'N/A') AS CourierInstructions								   
			FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
			WHERE RowStatus = 1
					AND ServiceType = 'DELIVERY'
			FOR XML PATH('Row'), ROOT('root')
		)
    END;

    ELSE IF (@TypeMethod = 'GetIncidenceByPiece')
    BEGIN
		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY IdIncidenceType) - 1 AS [@Row],
				   CONVERT(NVARCHAR, IdIncidenceType) AS Id,
				   ISNULL(   CASE
								 WHEN IdIncidenceType = 16 THEN
									 CONVERT(NVARCHAR(10), 500)
								 WHEN IdIncidenceType = 17 THEN
									 CONVERT(NVARCHAR(10), 404)
								 WHEN IdIncidenceType = 18 THEN
									 CONVERT(NVARCHAR(10), 406)
								 WHEN IdIncidenceType = 19 THEN
									 CONVERT(NVARCHAR(10), 409)
								 ELSE
									 CONVERT(NVARCHAR(10), 0)
							 END,
							 'N/A'
						 ) AS Code,
				   ISNULL(NameIncidence, 'N/A') AS Name,
				   ISNULL(DescriptionIncidence, 'N/A') AS Description
			FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH (NOLOCK)
			WHERE RowStatus = 1
				  AND ServiceType = 'PIECE'
			FOR XML PATH('Row'), ROOT('root')
		 )
    END;

    ELSE IF (@TypeMethod = 'GetDefaultCharges')
    BEGIN
        PRINT 'PRUEBA 9';
		SET @jsonResult =
		(
			SELECT ROW_NUMBER() OVER (ORDER BY IdToCharge) - 1 AS [@Row],
				   ch.Name AS Code,
				   ch.Description AS [Description],
				   CONVERT(VARCHAR, ch.Value) AS Rate
			FROM dbo.CatToCharge ch WITH (NOLOCK)
			WHERE (
					  @Others = '-1'
					  OR -- -1 significa todos
					  ch.Name = @Others
				  ) -- codigo de tarifa
				  AND ch.RowStatus = 1 -- solo registros activos

			FOR XML PATH('Row'), ROOT('root')
		)
    END;

    ELSE IF (@TypeMethod = 'GetConfigParams')
    BEGIN
        PRINT 'PRUEBA 10';
		SET @jsonResult =
		(
			SELECT ROW_NUMBER() OVER (ORDER BY ConfigParamsId) - 1 AS [@Row],
				   CONVERT(NVARCHAR, ConfigParamsId) AS Id,
				   ISNULL(Name, 'N/A') AS [Name],
				   ISNULL(Description, 'N/A') AS [Description],
				   ISNULL(Value, 'N/A') AS [Value]
			FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
			WHERE Status = 1
			FOR XML PATH('Row'), ROOT('root')
		)
    END;
    ELSE IF (@TypeMethod = 'GetExpressCenters')
    BEGIN
        PRINT 'PRUEBA 11';
		SET @jsonResult =
		(
			SELECT  ROW_NUMBER() OVER (ORDER BY VPC.IdVisitPointClient) - 1 AS [@Row],
					DescriptionOfClient AS [Name], 
					ISNULL(ContactName, '') AS ContactName, 
					ISNULL(Phone, '') AS Phone,
					ISNULL(Email, '') AS Email,
					ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '') AS IdTownship, 
					ISNULL(TWS.TownshipDescription, '') AS TownshipName,
					ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '') AS IdProvince, 
					ISNULL(PRV.ProvinceDescription, '') AS ProvinceName, 
					ISNULL(VPC.Address, '') AS Address, 
					ISNULL(TWS.HeaderCode, '') AS HeaderCode,
					CONCAT(STL.Settlement,', ',TWS.TownshipName,', ',prv.ProvinceName) AS SettlementDescription,
					ISNULL(CONVERT(NVARCHAR, STL.IdSettlement), '') AS IdSettlement,
					ISNULL(CONVERT(NVARCHAR, VPC.CodeOfReference), '') AS CodeOfReference
			FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.Settlement STL WITH(NOLOCK)
					ON VPC.IdSettlement = STL.IdSettlement 
				INNER JOIN DeliveryBackOffice.dbo.Township TWS WITH(NOLOCK)
					ON TWS.IdTownship = STL.IdTownship
				INNER JOIN DeliveryBackOffice.dbo.Province PRV WITH(NOLOCK)
					ON PRV.IdProvince = TWS.IdProvince
			WHERE IdKindOfVPClient = 1
			AND VPC.StatusClient = 1
			AND STL.SettlementSatus = 1
			AND TWS.TownshipStatus = 1
			AND PRV.ProvinceStatus = 1
			FOR XML PATH('Row'), ROOT('root')
		)
    END;
    ELSE IF (@TypeMethod = 'GetDeliveryOptions')
    BEGIN
		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY IdDeliveryOption) - 1 AS [@Row],
				   CONVERT(NVARCHAR, IdDeliveryOption) AS Id,
				   ISNULL(Name, 'N/A') AS [Name], 
				   ISNULL(Description, 'N/A') AS [Description]
			FROM DeliveryBackOffice.dbo.CatDeliveryOptions WITH(NOLOCK)
			WHERE RowStatus = 1
			FOR XML PATH('Row'), ROOT('root')
		 )
    END;
    ELSE IF (@TypeMethod = 'GetCorporateCustomers')
    BEGIN
	
		DECLARE @ActiveSalesPackageId INT = ( SELECT TOP 1 CSPS.IdCatSalesPackageStatus FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH(NOLOCK) WHERE CSPS.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI )

		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY Id) - 1 AS [@Row],
				   Id,
				   [Name],
				   Phone,
				   Email,
				   CodeOfReference,
				   [Description],
				   [Address],
				   Province,
				   Township,
				   HeaderCode,
				   HasMembership,
				   HasRate,
				   HasCredit,
				   (
					   SELECT EntityName,
							  TaxId,
							  TaxAddress,
							  TaxEmail
					   FOR XML PATH('Billing'), TYPE
				   ),
				   (
					   SELECT IdBank,
							  BankDescription,
							  Acronym,
							  NameAccount,
							  TypeAccount,
							  NumberAcc
					   FOR XML PATH('Cod'), TYPE
				   )
			FROM
			(
				SELECT DISTINCT
					CONVERT(NVARCHAR, ISNULL(IdCustomer, 0)) AS Id,
					REPLACE(ISNULL(cu.[Name], 'N/A'), '"', '') AS [Name],
					ISNULL([CustomerPhone], '') AS Phone,
					ISNULL([ContactEmail], '') AS Email,
					CONVERT(NVARCHAR, ISNULL(vpc.[CodeOfReference], '')) AS CodeOfReference,
					ISNULL(REPLACE(vpc.[DescriptionOfClient], '"', ''), '') AS [Description],
					ISNULL(REPLACE(vpc.[Address], '"', ''), '') AS [Address],
					ISNULL(pr.ProvinceName, '') AS Province,
					ISNULL(TWS.TownshipName, '') AS Township,
					ISNULL(TWS.HeaderCode, '') AS HeaderCode,
					CONVERT(NVARCHAR,
							ISNULL(   (CASE
										   WHEN mmbrshp.IdMembership IS NOT NULL THEN
											   1
										   ELSE
											   0
									   END
									  ),
									  0
								  )
						   ) AS HasMembership,
					CONVERT(NVARCHAR, ISNULL(rc.[RbcRowStatus], '')) AS HasRate,
					CONVERT(NVARCHAR, ISNULL(IIF(ISNULL(ccp.ConditionOfPayment, 'Contado') = 'Contado', '0', '1'), '')) AS HasCredit,
					ISNULL(Cu.[InvoiceName], '') AS EntityName,
					ISNULL(Cu.[TaxIdentificationNumber], '') AS TaxId,
					REPLACE(ISNULL(Cu.[FiscalAddress], ''), '"', '') AS TaxAddress,
					REPLACE(ISNULL(Cu.[InvoiceEmail], ''), CHAR(31), '') AS TaxEmail,
					CONVERT(NVARCHAR, ISNULL([CODAccountBankID], '')) AS IdBank,
					CONVERT(NVARCHAR, ISNULL(dbk.[Name], '')) AS BankDescription,
					CONVERT(NVARCHAR, ISNULL(dbk.[Acronym], '')) AS Acronym,
					ISNULL([CODAccountName], '') AS NameAccount,
					CONVERT(NVARCHAR, ISNULL(cba.[BankAccountType], '')) AS TypeAccount,
					ISNULL([CODAccountNumber], '') AS NumberAcc
				FROM DeliveryBackOffice.dbo.Customer cu WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbk WITH (NOLOCK)
						ON cu.CODAccountBankID = dbk.Id_bank
						   AND dbk.Id_country = 'GT'
						   AND dbk.Id_status = 1
					LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType cba WITH (NOLOCK)
						ON cu.CODAccountTypeID = cba.IdBankAccountType
						   AND cba.RowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc WITH (NOLOCK)
						ON cu.IdCustomer = rc.RbcIdCustomer
						   AND rc.RbcRowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment ccp WITH (NOLOCK)
						ON ccp.IdConditionOfPayment = cu.ConditionOfPaymentID
					INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
						ON vpc.CustomerID = cu.IdCustomer
					LEFT JOIN DeliveryBackOffice.dbo.Settlement STL WITH (NOLOCK)
						ON vpc.IdSettlement = STL.IdSettlement
					LEFT JOIN DeliveryBackOffice.dbo.Township TWS WITH (NOLOCK)
						ON TWS.IdTownship = STL.IdTownship
					LEFT JOIN DeliveryBackOffice.dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = TWS.IdProvince
					LEFT JOIN DeliveryBackOffice.dbo.Membership mmbrshp WITH (NOLOCK)
						ON cu.IdCustomer = mmbrshp.CustomerId
						   AND mmbrshp.RowStatus = 1
						   AND mmbrshp.ExpirationDate >= GETDATE()
						   AND mmbrshp.CatMembershipStatusId IN ( @ActiveSalesPackageId )
				WHERE IdCustomerType = 1
					  AND vpc.StatusClient = 1
					  AND cu.RowSatus = 1
					  AND (
							  cu.IdCustomer = IIF(ISNUMERIC(@Others) = 1, @Others, 0)
							  OR cu.Name LIKE CONCAT('%', @Others, '%')
							  OR vpc.DescriptionOfClient LIKE CONCAT('%', @Others, '%')
						  )
					  --AND cu.TaxIdentificationNumber != '29715164'
					  /*AND ConditionOfPaymentID !=
							(
								SELECT IdConditionOfPayment
								FROM CatConditionOfPayment ccp
								WHERE ccp.ConditionOfPayment = 'CONTADO'
							)*/
					  AND RowSatus = 1
					  AND STL.SettlementSatus = 1
					  AND TWS.TownshipStatus = 1
					  AND pr.ProvinceStatus = 1
			) [Data]
			FOR XML PATH('Row'), ROOT('root')
		 )

    END;
    ELSE IF (@TypeMethod = 'GetCorporateArticles')
    BEGIN
		 SET @jsonResult =
		 (
        	SELECT ROW_NUMBER() OVER (ORDER BY [AbcId]) - 1 AS [@Row],
				   ISNULL(cd.[AbcId], 0) AS Id,
				   ISNULL(cd.[Code], '') AS Code,
				   ISNULL(CONCAT(cd.[Code], '  -  ', cd.[TarName], '-', cd.[ArtName]), '') AS Description,
				   CONVERT(NVARCHAR, ISNULL(cd.[Height], 30)) AS Height,
				   CONVERT(NVARCHAR, ISNULL(cd.[Width], 30)) AS Width,
				   CONVERT(NVARCHAR, ISNULL(cd.[Length], 30)) AS [Length]
			FROM
			(
				SELECT DISTINCT
					ac.Code,
					ac.AbcId,
					ta.TarName,
					ca.ArtName,
					ac.Height,
					ac.Width,
					ac.Length
				FROM DeliveryBackOffice.dbo.RatebyCustomer rc WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.RateData rd WITH (NOLOCK)
						ON rd.RateId = rc.RbcIdRate
					INNER JOIN DeliveryBackOffice.dbo.ArticleByCustomer ac WITH (NOLOCK)
						ON ac.AbcId = rd.ArticleId
					LEFT JOIN DeliveryBackOffice.dbo.CatArticle ca WITH (NOLOCK)
						ON ca.ArtId = ac.AbcIdArticle
					LEFT JOIN DeliveryBackOffice.dbo.CatTypeArticle ta WITH (NOLOCK)
						ON ta.TarId = ca.ArtIdTypeArticle
						   AND ta.TarRowStatus = 'TRUE'
						   AND ca.ArtRowStatus = 'TRUE'
				WHERE rc.RbcIdCustomer = 1
					  AND rc.RbcRowStatus = 'true'
			) cd
			ORDER BY cd.AbcId
			FOR XML PATH('Row'), ROOT('root')
		 )
    END;
    ELSE IF (@TypeMethod = 'GetTypeIncidenceExpress')
    BEGIN
        
        PRINT 'PRUEBA 15';
		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY C.IdIncidenceType) - 1 AS [@Row],
					CONVERT(VARCHAR, ISNULL(c.IdIncidenceType, '')) AS Id,
					ISNULL(c.NameIncidence, '') AS Name
			FROM DeliveryBackOffice.dbo.CatTypeIncidence c WITH(NOLOCK)
			WHERE
				c.RowStatus = 1 AND
				c.ServiceType = 'DELIVERY'
			ORDER BY c.OrderId
			FOR XML PATH('Row'), ROOT('root')
         )
    END;

    --CatIncidenceTransfer
    ELSE IF (@TypeMethod = 'GetIncidenceTransfer')
    BEGIN
		 SET @jsonResult =
		 (
			SELECT ROW_NUMBER() OVER (ORDER BY IdCatIncidenceTransfer) - 1 AS [@Row],
				   CONVERT(NVARCHAR, IdCatIncidenceTransfer) AS Id,
				   ISNULL(IncidenceName, 'N/A') AS Description 
			FROM DeliveryBackOffice.dbo.CatIncidenceTransfer WITH(NOLOCK)
			WHERE RowStatus = 1
			FOR XML PATH('Row'), ROOT('root')
		 )
	END;

	ELSE IF (@TypeMethod = 'GetTypeVehicle')
    BEGIN
		 SET @jsonResult =
		(
			SELECT ROW_NUMBER() OVER (ORDER BY IdTypeVehicle) - 1 AS [@Row],
				   CONVERT(NVARCHAR, IdTypeVehicle) AS Id, 
				   ISNULL(Name, '') AS [Name], 
				   ISNULL(Description, '') AS [Description]
			FROM CatTypeVehicle
			WHERE RowStatus = 1
				AND Name IN ('Camión','Panel','Motocicleta')
			FOR XML PATH('Row'), ROOT('root')
		)
	END

	ELSE IF (@TypeMethod = 'GetPaymentMethod')
    BEGIN
		SET @jsonResult =
		(
			SELECT ROW_NUMBER() OVER (ORDER BY cpv.IdCustomerPaymentValue) - 1 AS [@Row],
				   CONVERT(NVARCHAR, cpv.IdCustomerPaymentValue) AS Id,
				   cpv.DisplayText AS DisplayText,
				   IIF(cpv.IsDefault = 1, 'true', 'false') AS IsDefault
			FROM CustomerPaymentValue cpv
			WHERE (cpv.AccountId = @IdAccount
					  OR (
							 cpv.AccountId IS NULL
							 AND cpv.CustomerId =
							 (
								 SELECT IdCustomer FROM Account WHERE AccIdAccount = @IdAccount
							 )
						 )
				  )
				  AND cpv.RowStatus = 1
			FOR XML PATH('Row'), ROOT('root')
		)
    END

	ELSE IF (@TypeMethod = 'GetTypeArticle')
    BEGIN
		 SET @jsonResult =
			(
				SELECT ROW_NUMBER() OVER (ORDER BY cta.TarId) - 1 AS [@Row],
					   CONVERT(NVARCHAR, cta.TarId) AS ArticleTypeId,
					   CONVERT(NVARCHAR, cta.TarName) AS ArticleType
				FROM CatTypeArticle cta
				WHERE cta.TarRowStatus = 1
				FOR XML PATH('Row'), ROOT('root')
			)
    END
	
	/*ELSE IF (@TypeMethod = 'MundialPromo')
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"CandidateId":"' + CONVERT(NVARCHAR, WCPC.IdWorldCupPromoCandidate) + '",'
									   + '"CandidateName":"' + CONVERT(NVARCHAR, WCPC.WorldCupCandidateName) + '",' + '}'
                                FROM [DeliveryBackOffice].[dbo].[WorldCupPromoCandidate] WCPC WITH(NOLOCK)
								WHERE WCPC.RowStatus = 1
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END*/
	
	ELSE IF (@TypeMethod = 'ActiveMembership')
    BEGIN
		DECLARE @ProductExist INT = 0;

			SET @ProductExist = (
								(SELECT TOP 1 COUNT(IdMembership)
                                FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK)   
                                WHERE AccountId = @IdAccount
								     AND RowStatus = 1
                                     AND CONVERT(NVARCHAR(10), ExpirationDate, 20) >= CONVERT(NVARCHAR(10), GETDATE(), 20))
								
								+
									 
								(SELECT TOP 1 COUNT(IdSubscription)
                                FROM [DeliveryBackOffice].[dbo].[Subscription] WITH (NOLOCK)   
                                WHERE AccountId = @IdAccount
								     AND RowStatus = 1
                                     AND CONVERT(NVARCHAR(10), ExpirationDate, 20) >= CONVERT(NVARCHAR(10), GETDATE(), 20)
                                     AND SubscriptionMaxServiceFixedValue >	ActualServiceCount 
                                     )
                                     
                                +
									 
								(SELECT TOP 1 COUNT(IdSubscription)
                                FROM [DeliveryBackOffice].[dbo].[Subscription] S WITH (NOLOCK)  
								   INNER JOIN [DeliveryBackOffice].[dbo].[CatSubscription] SC WITH (NOLOCK)
								   ON S.CatSubscriptionId = SC.IdCatSubscription
                                WHERE AccountId = @IdAccount
								     AND S.RowStatus = 1
                                     AND CONVERT(NVARCHAR(10), ExpirationDate, 20) >= CONVERT(NVARCHAR(10), GETDATE(), 20)
                                     AND SC.SubscriptionDescription ='Plan de descuentos'
                                     )
                                     
                                     )
		SET @jsonResult	= (
			SELECT TOP 1 CAST((CASE
							WHEN @ProductExist > 0 THEN
								1
							ELSE
								0
						END
						) AS NVARCHAR) AS ActiveMembership
			FOR XML PATH('Membership'), ROOT('root')
			)
    END

    SELECT '<?xml version="1.0" encoding="UTF-8" ?>' + @jsonResult AS FormatJson;

END;
