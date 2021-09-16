USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetDynamicCatalog]    Script Date: 8/16/2021 2:31:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetDynamicCatalog]
    @TypeMethod VARCHAR(100) = 'GetTypePayment',
    @IdAccount INT = 1,
    @Token VARCHAR(100) = '0BE2F8F3BD53652635746ACD069954B5',
    @GuideSerie VARCHAR(2) = 'FD',
    @GuideNumber VARCHAR(100) = '12345',
    @Others VARCHAR(500) = ''
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);
    IF (@Others NOT LIKE '%CourierApp%')
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.TokenLog
            WHERE TknRowStatus = 1
                  AND TknIdToken = @Token
                  AND CAST(TknDateCreated AS DATE) = CAST(GETDATE() AS DATE)
        )
        BEGIN
            PRINT 'token inválido';

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"IdError":' + '500' + ',' + '"DescriptionError":"' + 'Token inválido'
                                           + '"' + '}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
            SELECT '[' + @jsonResult + ']' FormatJson;

            RETURN;
        END;
    END;
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
                                FROM DeliveryBackOffice.dbo.CatModule
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
                                    FROM DeliveryBackOffice.dbo.CatPaymentTime
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
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, art.ArtId) + '",' +
                                    --    '"Name":"' +  replace(art.ArtName,'"',' ')  + '",' +	  	  
                                    '"Name":"' + REPLACE(art.ArtName, '"', ' ') + '"' + '}'
                                FROM dbo.CatArticle art
                                    LEFT JOIN dbo.ArticleByCustomer abc
                                        ON abc.AbcIdArticle = art.ArtId
                                WHERE art.ArtShowDefault = 1
                                      OR abc.AbcIdCustomer =
                                      (
                                          SELECT TOP 1
                                                 ac.IdCustomer
                                          FROM dbo.Account ac
                                          WHERE ac.AccIdAccount = @IdAccount
                                      )
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
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence
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

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdIncidenceType) + '",' + '"Name":"'
                                       + ISNULL(NameIncidence, 'N/A') + '",' + '"Description":"'
                                       + ISNULL(DescriptionIncidence, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence
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

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, IdIncidenceType) + '",' + '"Name":"'
                                       + ISNULL(NameIncidence, 'N/A') + '",' + '"Description":"'
                                       + ISNULL(DescriptionIncidence, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence
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
                                FROM DeliveryBackOffice.dbo.CatTypeIncidence
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

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Code":"' + ch.Name + '",' + '"Description":"' + ch.Description + '",'
                                       + '"Rate":"' + CONVERT(VARCHAR, ch.Value) + +'"}'
                                FROM dbo.CatToCharge ch
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

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, ConfigParamsId) + '",' + '"Name":"'
                                       + ISNULL(Name, 'N/A') + '",' + '"Description":"' + ISNULL(Description, 'N/A')
                                       + '",' + '"Value":"' + ISNULL(Value, 'N/A') + '"' + '}'
                                FROM DeliveryBackOffice.dbo.ConfigParams
                                WHERE Status = 1
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
                                FROM DeliveryBackOffice.dbo.CatDeliveryOptions
                                WHERE RowStatus = 1
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

        IF @Others = 'ClosureEXC'
        BEGIN

            IF (SELECT ISNULL(ROL.RolAdminInternal, 'FALSE')
                FROM dbo.RolByUserByAccount RUA
                    JOIN dbo.CatRol ROL
                        ON ROL.RolIdRol = RUA.RuaIdRol
                WHERE RuaIdAccount = @IdAccount
				AND rua.RuaRowStatus = 'TRUE'
				AND rol.RolIdSystem  = 1 --portal web
				) = 'TRUE'
            BEGIN
                PRINT 'Mostrar TODOS Exc';
				SET @jsonResult =  (
									SELECT STUFF(
									(SELECT 
									 ',{"Name":"' + A.Name + '",' + '"ContactName":"'
											+ ISNULL(A.ContactName, '') + '",' + '"Phone":"' + ISNULL(A.Phone, '') + '",'
											+ '"Email":"' + ISNULL(A.Email, '') + '",' + '"IdTownship":"'
											+ ISNULL(CONVERT(VARCHAR, A.IdTownship), '') + '",' + '"TownshipName":"'
											+ ISNULL(A.TownshipName, '') + '",' + '"IdProvince":"'
											+ ISNULL(CONVERT(VARCHAR, A.IdProvince), '') + '",' + '"ProvinceName":"'
											+ ISNULL(A.ProvinceName, '') + '",' + '"Address":"'
											+ ISNULL(A.Address, '') + '",' + '"HeaderCode":"'
											+ ISNULL(A.HeaderCode, '') + '",' + '"CodeOfReference":"'
											+ ISNULL(CONVERT(VARCHAR, A.CodeOfReference), '') + '"' + '}'

									FROM (
											SELECT 
													'TODOS' [Name] ,
													'' [ContactName],
													'' [Phone],
													'' [Email],
													'' [IdTownship],
													'' [TownshipName],
													'' [IdProvince],
													'' [ProvinceName],
													'' [Address],
													'' [HeaderCode] ,
													'-1' [CodeOfReference]
											UNION
											SELECT  DescriptionOfClient [Name] ,
													ISNULL(ContactName, '') [ContactName],
													ISNULL(Phone, '') [Phone],
													ISNULL(Email, '') [Email],
													ISNULL(CONVERT(VARCHAR, TWS.IdTownship), '') [IdTownship],
													ISNULL(TWS.TownshipDescription, '') [TownshipName],
													ISNULL(CONVERT(VARCHAR, PRV.IdProvince), '') [IdProvince],
													ISNULL(PRV.ProvinceDescription, '') [ProvinceName],
													ISNULL(VPC.Address, '') [Address],
													ISNULL(TWS.HeaderCode, '') [HeaderCode] ,
													ISNULL(CONVERT(VARCHAR, VPC.CodeOfReference), '') [CodeOfReference]
				
											FROM DeliveryBackOffice.dbo.VisitPointClient VPC
												JOIN DeliveryBackOffice.dbo.Settlement STL
													ON VPC.IdSettlement = STL.IdSettlement
												JOIN DeliveryBackOffice.dbo.Township TWS
													ON TWS.IdTownship = STL.IdTownship
												JOIN DeliveryBackOffice.dbo.Province PRV
													ON PRV.IdProvince = TWS.IdProvince
											WHERE IdKindOfVPClient = 1
											
									)A
									ORDER BY A.CodeOfReference ASC
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'), 1, 1, '' )
					);
            END
            ELSE
            BEGIN
                PRINT 'SOLO EL ID EXC DEL USUARIO';

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
                                           + ISNULL(VPC.Address, '') + '",' + '"HeaderCode":"'
                                           + ISNULL(TWS.HeaderCode, '') + '",' + '"CodeOfReference":"'
                                           + ISNULL(CONVERT(VARCHAR, VPC.CodeOfReference), '') + '"' + '}'
                                    FROM DeliveryBackOffice.dbo.VisitPointClient VPC
                                        JOIN DeliveryBackOffice.dbo.Settlement STL
                                            ON VPC.IdSettlement = STL.IdSettlement
                                        JOIN DeliveryBackOffice.dbo.Township TWS
                                            ON TWS.IdTownship = STL.IdTownship
                                        JOIN DeliveryBackOffice.dbo.Province PRV
                                            ON PRV.IdProvince = TWS.IdProvince
										JOIN dbo.VisitPointByUser vpu ON vpc.IdVisitPointClient = vpu.IdVisitPointClient
										JOIN dbo.RolByUserByAccount rua ON rua.RuaIdUser = vpu.RegisterUserID
										WHERE rua.RuaRowStatus = 'TRUE' --RegisterUserID = 66
										AND rua.RuaIdAccount = @IdAccount  --21 o 45
										AND  VPC.IdKindOfVPClient = 1
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
            END
        END;
        ELSE
        BEGIN
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
                                           + ISNULL(VPC.Address, '') + '",' + '"HeaderCode":"'
                                           + ISNULL(TWS.HeaderCode, '') + '",' + '"CodeOfReference":"'
                                           + ISNULL(CONVERT(VARCHAR, VPC.CodeOfReference), '') + '"' + '}'
                                    FROM DeliveryBackOffice.dbo.VisitPointClient VPC
                                        JOIN DeliveryBackOffice.dbo.Settlement STL
                                            ON VPC.IdSettlement = STL.IdSettlement
                                        JOIN DeliveryBackOffice.dbo.Township TWS
                                            ON TWS.IdTownship = STL.IdTownship
                                        JOIN DeliveryBackOffice.dbo.Province PRV
                                            ON PRV.IdProvince = TWS.IdProvince
                                    WHERE IdKindOfVPClient = 1
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;
    END;
    ELSE IF (@TypeMethod = 'GetCorporateCustomers')
    BEGIN

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Id":"' + CONVERT(NVARCHAR, ISNULL(IdCustomer, 0)) + '",' + '"Name":"'
								               + REPLACE(ISNULL(cu.[Name], 'N/A'), '"','')  + '",' +'"Phone":"'+ISNULL([CustomerPhone],'')+ '",'
								               +'"Email":"'+ISNULL([ContactEmail],'') + '",'
                               +'"CodeOfReference":"'+ CONVERT(NVARCHAR,ISNULL(vpc.[CodeOfReference],'')) + '",'
                               +'"Description":"'+ ISNULL(REPLACE(vpc.[DescriptionOfClient],'"',''),'') + '",'
								               +'"HasRate":"'+ CONVERT(NVARCHAR,ISNULL(rc.[RbcRowStatus],'')) + '",'
								               +'"HasCredit":"'+ CONVERT(NVARCHAR,ISNULL(IIF(ISNULL(ccp.ConditionOfPayment,'Contado')='Contado','0','1'),'')) +
								               '",' +'"Billing":'+'[{'
								               +'"EntityName":"'+ ISNULL([InvoiceName],'')+ '",'
								               +'"TaxId":"'+ ISNULL([TaxIdentificationNumber],'')+ '",'
								               +'"TaxAddress":"'+ ISNULL([FiscalAddress],'')+ '",'
								               +'"TaxEmail":"'+ ISNULL([InvoiceEmail],'')+ '"'
								               +'}]'+
								               ',' +'"Cod":'+'[{'
								               +'"IdBank":"'+ CONVERT(NVARCHAR,  ISNULL([CODAccountBankID],''))+ '",'
										                 +'"BankDescription":"'+ CONVERT(NVARCHAR,  ISNULL(dbk.[Name],''))+ '",'
								               +'"Acronym":"'+ CONVERT(NVARCHAR,  ISNULL(dbk.[Acronym],''))+ '",'
								               +'"NameAccount":"'+ ISNULL([CODAccountName],'')+ '",'
								               +'"TypeAccount":"'+ CONVERT(NVARCHAR, ISNULL(cba.[BankAccountType],''))+ '",'
								               +'"NumberAcc":"'+ ISNULL([CODAccountNumber],'')+ '"'
								               +'}]'+
								               '}'
                                              FROM DeliveryBackOffice.dbo.Customer cu
								              LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank dbk ON cu.CODAccountBankID = dbk.Id_bank 
								              AND dbk.Id_country = 'GT'
								              AND dbk.Id_status = 1
								              LEFT JOIN DeliveryBackOffice.dbo.CatBankAccountType cba ON cu.CODAccountTypeID = cba.IdBankAccountType
								              AND cba.RowStatus = 1
								              LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rc ON cu.IdCustomer = rc.RbcIdCustomer
								              AND rc.RbcRowStatus=1
								              LEFT JOIN DeliveryBackOffice.dbo.CatConditionOfPayment ccp ON ccp.IdConditionOfPayment = cu.ConditionOfPaymentID
                              JOIN DeliveryBackOffice.dbo.VisitPointClient vpc ON vpc.CustomerID = cu.IdCustomer AND vpc.StatusClient=1
								              WHERE IdCustomerType = 1
								              AND cu.RowSatus = 1
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
                                SELECT ',{"Id":"'+ CONVERT(NVARCHAR, ISNULL(cd.[AbcId], 0)) + '",'
								  +'"Code":"'+ ISNULL(cd.[code],'') + '",'
								  +'"Description":"'+ISNULL(CONCAT( cd.[Code],'  -  ', cd.[TarName],'-', cd.[ArtName]),'') + '"'
								  +'}' FROM (
								SELECT DISTINCT  ac.Code, ac.AbcId, ta.TarName, ca.ArtName
								  FROM DeliveryBackOffice.dbo.RatebyCustomer rc 
									LEFT JOIN DeliveryBackOffice.dbo.RateData rd ON rd.RateId = rc.RbcIdRate
									INNER JOIN DeliveryBackOffice.dbo.ArticleByCustomer ac ON ac.AbcId = rd.ArticleId
									LEFT JOIN DeliveryBackOffice.dbo.CatArticle ca ON ca.ArtId = ac.AbcIdArticle
		                            LEFT JOIN DeliveryBackOffice.dbo.CatTypeArticle ta ON ta.TarId =ca.ArtIdTypeArticle
				                    AND ta.TarRowStatus = 'TRUE'
				                    AND ca.ArtRowStatus = 'TRUE'
								WHERE  rc.RbcIdCustomer = @IdAccount AND rc.RbcRowStatus ='true'
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

    SELECT '[' + @jsonResult + ']' FormatJson;

END;
