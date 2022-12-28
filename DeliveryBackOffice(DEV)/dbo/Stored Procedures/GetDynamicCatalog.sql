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
            SELECT STUFF(
                            (
                                SELECT
                                    /*
		',{"IdError":' + '500' + ',' +
	    '"DescriptionError":"' + 'Token inválido'  + '"' +	  	  
	    '}'
		*/
                                    ',{"Id":"' + CONVERT(VARCHAR, ModIdModule) + '",' + '"Description":"'
                                    + CONVERT(VARCHAR, ModName) + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatModule WITH(NOLOCK)
                                WHERE ModVisible = 1
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;


    ELSE IF (@TypeMethod = 'GetTypePayment')
    BEGIN


        BEGIN

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"Id":"' + CONVERT(NVARCHAR, TimePlaId) + '",' + '"Name":"' + TimePlaName
                                           + '",' + '"Description":"' + TimePlaDescription + '"' + '}'
                                    FROM DeliveryBackOffice.dbo.CatPaymentTime WITH(NOLOCK)
                                    WHERE TimePlaStatus = 1
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;

    END;

    ELSE IF (@TypeMethod = 'GetTypePiece')
    BEGIN

        DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
		DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);
		DECLARE @NewAutoSalesMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' COLLATE Latin1_General_CI_AI);


        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT
										',{"Id":"' + CONVERT(NVARCHAR, ISNULL(cd.[AbcId], 0)) + '",'
										+ '"Code":"' + ISNULL(cd.[Code], '') + '",'
										+ '"Description":"' + (
											CASE
												WHEN cd.IsMainPackage IS NOT NULL AND cd.IsMainPackage = 1 THEN cd.ArtName
												ELSE ISNULL(CONCAT(cd.[Code], '  -  ', cd.[TarName], '-', cd.[ArtName]), '')
											END
										) + '",'
										+ '"Height":' + CONVERT(NVARCHAR, ISNULL(cd.[Height], 30)) + ','
										+ '"Width":' + CONVERT(NVARCHAR, ISNULL(cd.[Width], 30)) + ','
										+ '"Length":' + CONVERT(NVARCHAR, ISNULL(cd.[Length], 30)) + ','
										+ '"Weight":' + CONVERT(NVARCHAR, ISNULL(cd.MassWeight, 1)) + ''
										+ IIF(cd.IsMainPackage IS NOT NULL,CONCAT(',"IsMainPackage":',IIF(cd.IsMainPackage = 1,'true','false')),'')
										+ '}'
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
										FROM dbo.CatArticle art
										INNER JOIN dbo.ArticleByCustomer abc
											ON abc.AbcIdArticle = art.ArtId
										LEFT JOIN CatTypeArticle ta
											ON ta.TarId = art.ArtIdTypeArticle
										INNER JOIN RateData ra
											ON ra.ArticleId = abc.AbcId
										INNER JOIN RatebyCustomer rbc
											ON rbc.RbcIdRate = ra.RateId
										INNER JOIN Account ac
											ON ac.IdCustomer = rbc.RbcIdCustomer
										WHERE ac.AccIdAccount = @IdAccount
										AND art.ArtRowStatus = 'TRUE'
										AND abc.AbcRowStatus = 'TRUE'
										AND ra.RowStatus = 'TRUE'
										AND rbc.RbcRowStatus = 'TRUE'
										AND ac.AccRowStatus = 'TRUE') cd
									ORDER BY cd.AbcId
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    ELSE IF (@TypeMethod = 'GetTypeIncidence')
    BEGIN

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdIncidenceType) + '",' + '"Name":"'
                                       + ISNULL(NameIncidence, 'N/A') + '",' + '"Description":"'
                                       + ISNULL(DescriptionIncidence, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
                                WHERE RowStatus = 1
                                      AND ServiceType = 'PICKUP'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    ELSE IF (@TypeMethod = 'GetIncidenceByServicesReturn')
    BEGIN
        PRINT 'PRUEBA 6';
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdIncidenceType) + '",' + '"Name":"'
                                       + ISNULL(NameIncidence, 'N/A') + '",' + '"Description":"'
                                       + ISNULL(DescriptionIncidence, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
                                WHERE RowStatus = 1
                                      AND ServiceType = 'RETURN'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    ELSE IF (@TypeMethod = 'GetIncidenceByServicesDelivery')
    BEGIN
        PRINT 'PRUEBA 7';
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdIncidenceType) + '",' + '"Name":"'
                                       + ISNULL(NameIncidence, 'N/A') + '",' + '"Description":"'
                                       + ISNULL(DescriptionIncidence, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
                                WHERE RowStatus = 1
                                      AND ServiceType = 'DELIVERY'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    ELSE IF (@TypeMethod = 'GetIncidenceByPiece')
    BEGIN

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdIncidenceType) + '",' + '"Code":"'
                                       + ISNULL(   CASE
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
                                               ) + '",' + '"Name":"' + ISNULL(NameIncidence, 'N/A') + '",'
                                       + '"Description":"' + ISNULL(DescriptionIncidence, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence WITH(NOLOCK)
                                WHERE RowStatus = 1
                                      AND ServiceType = 'PIECE'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    ELSE IF (@TypeMethod = 'GetDefaultCharges')
    BEGIN
        PRINT 'PRUEBA 9';
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Code":"' + ch.Name + '",' + '"Description":"' + ch.Description + '",'
                                       + '"Rate":"' + CONVERT(VARCHAR, ch.Value) + +'"}'
                                FROM dbo.CatToCharge ch WITH(NOLOCK)
                                WHERE (
                                          @Others = '-1'
                                          OR -- -1 significa todos
                                          ch.Name = @Others
                                      ) -- codigo de tarifa
                                      AND ch.RowStatus = 1 -- solo registros activos

                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    ELSE IF (@TypeMethod = 'GetConfigParams')
    BEGIN
        PRINT 'PRUEBA 10';
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, ConfigParamsId) + '",' + '"Name":"'
                                       + ISNULL(Name, 'N/A') + '",' + '"Description":"' + ISNULL(Description, 'N/A')
                                       + '",' + '"Value":"' + ISNULL(Value, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
                                WHERE Status = 1
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    ELSE IF (@TypeMethod = 'GetExpressCenters')
    BEGIN
        PRINT 'PRUEBA 11';
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Name":"' + DescriptionOfClient + '",' + '"ContactName":"'
                                       + ISNULL(ContactName, '') + '",' + '"Phone":"' + ISNULL(Phone, '') + '",'
                                       + '"Email":"' + ISNULL(Email, '') + '",' + '"IdTownship":"'
                                       + ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '') + '",' + '"TownshipName":"'
                                       + ISNULL(TWS.TownshipDescription, '') + '",' + '"IdProvince":"'
                                       + ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '') + '",' + '"ProvinceName":"'
                                       + ISNULL(PRV.ProvinceDescription, '') + '",' + '"Address":"'
                                       + ISNULL(VPC.Address, '') + '",' + '"HeaderCode":"' + ISNULL(TWS.HeaderCode, '') + '",'
                                       + '"SettlementDescription":"'+ ISNULL( STL.Settlement, '') + '",'
									   + '"IdSettlement":"'+ ISNULL(CONVERT(NVARCHAR, STL.IdSettlement), '') + '",'
									   + '"CodeOfReference":"'+ ISNULL(CONVERT(NVARCHAR, VPC.CodeOfReference), '') + '"'
                                       + '}'
                                FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
                                    INNER JOIN DeliveryBackOffice.dbo.Settlement STL WITH(NOLOCK)
                                        ON VPC.IdSettlement = STL.IdSettlement 
                                    INNER JOIN DeliveryBackOffice.dbo.Township TWS WITH(NOLOCK)
                                        ON TWS.IdTownship = STL.IdTownship
                                    INNER JOIN DeliveryBackOffice.dbo.Province PRV WITH(NOLOCK)
                                        ON PRV.IdProvince = TWS.IdProvince
                                WHERE IdKindOfVPClient = 1
								AND VPC.StatusClient = 1
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    ELSE IF (@TypeMethod = 'GetDeliveryOptions')
    BEGIN

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdDeliveryOption) + '",' + '"Name":"'
                                       + ISNULL(Name, 'N/A') + '",' + '"Description":"' + ISNULL(Description, 'N/A')
                                       + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatDeliveryOptions WITH(NOLOCK)
                                WHERE RowStatus = 1
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    ELSE IF (@TypeMethod = 'GetCorporateCustomers')
    BEGIN

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT DISTINCT ',{"Id":"' + CONVERT(NVARCHAR, ISNULL(IdCustomer, 0)) + '",' + '"Name":"'
                                       + REPLACE(ISNULL(cu.[Name], 'N/A'), '"', '') + '",' + '"Phone":"'
                                       + ISNULL([CustomerPhone], '') + '",' + '"Email":"' + ISNULL([ContactEmail], '')
                                       + '",' + '"CodeOfReference":"'
                                       + CONVERT(NVARCHAR, ISNULL(vpc.[CodeOfReference], '')) + '",'
                                       + '"Description":"' + ISNULL(REPLACE(vpc.[DescriptionOfClient], '"', ''), '')
                                       + '",' + '"Address":"' + ISNULL(REPLACE(vpc.[Address], '"', ''), '') + '",'
                                       + '"Province":"' + ISNULL(pr.ProvinceName, '') + '",' + '"Township":"'
                                       + ISNULL(TWS.TownshipName, '') + '",' + '"HeaderCode":"'
                                       + ISNULL(TWS.HeaderCode, '') + '",' + '"HasRate":"'
                                       + CONVERT(NVARCHAR, ISNULL(rc.[RbcRowStatus], '')) + '",' + '"HasCredit":"'
                                       + CONVERT(
                                                    NVARCHAR,
                                                    ISNULL(
                                                              IIF(ISNULL(ccp.ConditionOfPayment, 'Contado') = 'Contado',
                                                                  '0',
                                                                  '1'),
                                                              ''
                                                          )
                                                ) + '",' + '"Billing":' + '[{' + '"EntityName":"'
                                       + REPLACE(ISNULL([InvoiceName], ''), '"', '') + '",' + '"TaxId":"'
                                       + ISNULL([TaxIdentificationNumber], '') + '",' + '"TaxAddress":"'
                                       + REPLACE(ISNULL([FiscalAddress], ''), '"', '') + '",' + '"TaxEmail":"'
                                       + REPLACE(ISNULL([InvoiceEmail], ''), CHAR(31), '') + '"' + '}]' + ','
                                       + '"Cod":' + '[{' + '"IdBank":"'
                                       + CONVERT(NVARCHAR, ISNULL([CODAccountBankID], '')) + '",'
                                       + '"BankDescription":"'
                                       + REPLACE(CONVERT(NVARCHAR, ISNULL(dbk.[Name], '')), '"', '') + '",'
                                       + '"Acronym":"' + REPLACE(CONVERT(NVARCHAR, ISNULL(dbk.[Acronym], '')), '"', '')
                                       + '",' + '"NameAccount":"' + REPLACE(ISNULL([CODAccountName], ''), '"', '')
                                       + '",' + '"TypeAccount":"'
                                       + CONVERT(NVARCHAR, ISNULL(cba.[BankAccountType], '')) + '",' + '"NumberAcc":"'
                                       + ISNULL([CODAccountNumber], '') + '"' + '}]' + '}'
                                FROM DeliveryBackOffice.dbo.Customer cu WITH(NOLOCK)
                                    LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbk WITH(NOLOCK)
                                        ON cu.CODAccountBankID = dbk.Id_bank
                                           AND dbk.Id_country = 'GT'
                                           AND dbk.Id_status = 1
                                    LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType cba WITH(NOLOCK)
                                        ON cu.CODAccountTypeID = cba.IdBankAccountType
                                           AND cba.RowStatus = 1
                                    LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc WITH(NOLOCK)
                                        ON cu.IdCustomer = rc.RbcIdCustomer
                                           AND rc.RbcRowStatus = 1
                                    LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment ccp WITH(NOLOCK)
                                        ON ccp.IdConditionOfPayment = cu.ConditionOfPaymentID
                                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
                                        ON vpc.CustomerID = cu.IdCustomer
                                           AND vpc.StatusClient = 1
                                    LEFT JOIN DeliveryBackOffice.dbo.Settlement STL WITH(NOLOCK)
                                        ON vpc.IdSettlement = STL.IdSettlement
                                    LEFT JOIN DeliveryBackOffice.dbo.Township TWS WITH(NOLOCK)
                                        ON TWS.IdTownship = STL.IdTownship 
                                    LEFT JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK)
                                        ON pr.IdProvince = TWS.IdProvince
                                WHERE IdCustomerType = 1
                                      AND cu.RowSatus = 1
									   
									  AND
											  ( cu.IdCustomer = IIF(ISNUMERIC(@Others) =1,@Others,0)											    
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
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    ELSE IF (@TypeMethod = 'GetCorporateArticles')
    BEGIN

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, ISNULL(cd.[AbcId], 0)) + '",' + '"Code":"'
                                       + ISNULL(cd.[Code], '') + '",' + '"Description":"'
                                       + ISNULL(CONCAT(cd.[Code], '  -  ', cd.[TarName], '-', cd.[ArtName]), '') + '",'
                                       + '"Height":' + CONVERT(NVARCHAR, ISNULL(cd.[Height], 30)) + ',' + '"Width":'
                                       + CONVERT(NVARCHAR, ISNULL(cd.[Width], 30)) + ',' + '"Length":'
                                       + CONVERT(NVARCHAR, ISNULL(cd.[Length], 30)) + '' + '}'
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
                                    FROM DeliveryBackOffice.dbo.RatebyCustomer rc WITH(NOLOCK)
                                        LEFT JOIN DeliveryBackOffice.dbo.RateData rd WITH(NOLOCK)
                                            ON rd.RateId = rc.RbcIdRate
                                        INNER JOIN DeliveryBackOffice.dbo.ArticleByCustomer ac WITH(NOLOCK)
                                            ON ac.AbcId = rd.ArticleId
                                        LEFT JOIN DeliveryBackOffice.dbo.CatArticle ca WITH(NOLOCK)
                                            ON ca.ArtId = ac.AbcIdArticle
                                        LEFT JOIN DeliveryBackOffice.dbo.CatTypeArticle ta WITH(NOLOCK)
                                            ON ta.TarId = ca.ArtIdTypeArticle
                                               AND ta.TarRowStatus = 'TRUE'
                                               AND ca.ArtRowStatus = 'TRUE'
                                    WHERE rc.RbcIdCustomer = @IdAccount
                                          AND rc.RbcRowStatus = 'true'
                                ) cd
                                ORDER BY cd.AbcId
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    ELSE IF (@TypeMethod = 'GetTypeIncidenceExpress')
    BEGIN
        PRINT 'PRUEBA 15';
        SET @jsonResult
            = ISNULL(
              (
                  SELECT STUFF(
                                  (
                                      SELECT ',{' + '"Id":"' + CONVERT(VARCHAR, ISNULL(c.IdIncidenceType, '')) + '",'
                                             + '"Name":"' + ISNULL(c.NameIncidence, '') + '"' + '}'
                                      FROM DeliveryBackOffice.dbo.CatTypeIncidence c WITH(NOLOCK)
                                      WHERE @Others = c.ServiceType
                                            AND c.RowStatus = 1
                                      ORDER BY c.OrderId
                                      FOR XML PATH(''), TYPE
                                  ).value('.', 'varchar(max)'),
                                  1,
                                  1,
                                  ''
                              )
              ),
              ''
                    );
    END;

    --CatIncidenceTransfer
    ELSE IF (@TypeMethod = 'GetIncidenceTransfer')
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdCatIncidenceTransfer) + '",'
                                       + '"Description":"' + ISNULL(IncidenceName, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatIncidenceTransfer WITH(NOLOCK)
                                WHERE RowStatus = 1
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

	ELSE IF (@TypeMethod = 'GetTypeVehicle')
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdTypeVehicle) + '",'
                                       + '"Name":"' + ISNULL(Name, '') + '",' 
									   + '"Description":"' + ISNULL(Description, '') + '",' + '}'
                                FROM CatTypeVehicle
                                WHERE RowStatus = 1
									AND Name IN ('Camión','Panel','Motocicleta')
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END



    SELECT '[' + @jsonResult + ']' FormatJson;

END;
