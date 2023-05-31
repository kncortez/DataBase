-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <2022-10-27>
-- Description:	<Genera los datos necesarios para poder realizar una reimpresión de guía>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-12-20>
-- Description:	<Agregar Campos de Piezas Frías y piezas Secas>
-- =============================================
CREATE  PROCEDURE [dbo].[sps_getReprintMultipleGuides]
	-- Add the parameters for the stored procedure here
	@GUIDESLIST TblGUides READONLY
AS
BEGIN

	DECLARE @FranchiseVisitPointTypeId INT = 
	(
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Concesionario'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ExpressVisitPointTypeId INT = 
	(
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @IndividualWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ExpressWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-ExpressCenter'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @CorporateWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-Corporativo'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ParserSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Parser'  COLLATE Latin1_General_CI_AI 
	)
    DECLARE @TMPPICES TABLE
    (        
        GuideSerie nvarchar(2),
		GuideNumber int,
		[TotalWeight] DECIMAL(12, 2),
		[TotalValue] DECIMAL(12, 2)
    );

	INSERT INTO @TMPPICES
	(
		GuideSerie,
		GuideNumber,
		[TotalWeight],
		[TotalValue]
	)
	SELECT 
		GL.Guide_Serie,
		GL.Guide_Number,
		ISNULL(SUM(PieceWeight), 0),
		ISNULL(SUM(Amount), 0)
    FROM 
		DeliveryBackOffice.[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
		INNER JOIN @GUIDESLIST GL ON
			DOP.GuideNumber=GL.Guide_Number
			AND DOP.GuideSerie=GL.Guide_Serie
	GROUP BY 
		GL.Guide_Serie,
		GL.Guide_Number


    DECLARE @DaysToExpiration INT =
            (
                SELECT ISNULL(CAST(conf.Value AS INT), 45) DaysToExpiration
                FROM DeliveryBackOffice.dbo.ConfigParams conf WITH(NOLOCK)
                WHERE conf.Name = 'DaysToExpiration'
                      AND Status = 1
            );

    


	DECLARE @IDCatBusinessB2B INT = (SELECT IdBusinessSegment FROM DBO.CatBusinessSegment WHERE BusinessSegmentName='B2B');



	SELECT 
		CONVERT(VARCHAR, ISNULL(PieceLength, 0)) 'length',
		CONVERT(VARCHAR, ISNULL(PieceWidth, 0)) 'width',
		CONVERT(VARCHAR, ISNULL(PieceHeight, 0)) 'height',
		CONVERT(VARCHAR, ISNULL(PieceWeight, 0)) 'weight',
		CONVERT(VARCHAR, ISNULL(Amount, 0)) 'amount' ,
		COALESCE(Currency, '') 'currency',
		COALESCE(ParcelCode,'') 'ParcelCode',
		CASE
            WHEN fragile = 1 THEN
                'true'
            ELSE
                'false'
        END 'fragil',
		COALESCE(Detail, '') 'description',
		dop.NoPiece 'NoPiece',
		dop.GuideSerie 'GuideSerie',
		dop.GuideNumber 'GuideNumber'
    FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
    INNER JOIN @GUIDESLIST GL
	ON GL.Guide_Serie= DOP.GuideSerie
		AND GL.Guide_Number=DOP.GuideNumber

 	



	SELECT 
		--TOP 1
		GL.Guide_Serie 'GuideSerie',
		GL.Guide_Number 'GuideNumber',
		'GTQ' 'Currency',
			CONVERT(VARCHAR, ISNULL(Description, 0)) 'Description',
			CONVERT(VARCHAR, ISNULL(Amount, 0)) 'Price'              
    FROM DeliveryBackOffice.[dbo].[Cost] ct WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bdp WITH (NOLOCK)
            ON bdp.IdCost = ct.IdCost
		INNER JOIN @GUIDESLIST GL
		ON ProductNumber=CONCAT(GL.Guide_Serie, GL.Guide_Number)
		
	



	

    /*end integration cost*/



                          
                              SELECT DISTINCT 
									TP.GuideSerie 'GuideSerie',
									TP.GuideNumber 'GuideNumber',
									CONVERT(VARCHAR, ISNULL(dev.Preparation_Date, GETDATE()), 121)		'DateOfSale',
									CONVERT(VARCHAR, ISNULL(dev.Package_Description, ''))				'ContentDescription',
									CONVERT(VARCHAR, COALESCE(p.IdCountry, ''))							'IdCountry',
									CONVERT(VARCHAR, ISNULL(dev.Pieces_Dry + dev.Pieces_Cold, 0))		'CountPieces',
									CONVERT(VARCHAR, COALESCE([dev].[Ticket_Number], '0'))							'Ticket_Number',
									CONVERT(VARCHAR, ISNULL(dev.[Order_Number], 0))		'Order_Number',
									(CASE
                                        WHEN dev.IsCollect = 1 THEN
                                            'true'
                                        ELSE
                                            'false'
                                    END)																'Collected',
									 COALESCE(CONVERT(VARCHAR, dev.PriceShippment), '0.00')				'Price',
									 COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0') 'IdCustomer',
									 (CASE WHEN DEV.IsLastMileReturn <>1 THEN CONVERT(VARCHAR, COALESCE(tws.HeaderCode, AlterOrigin.HeaderCode, '')) ELSE CONVERT(VARCHAR, COALESCE(tws2.HeaderCode, AlterDestiny.HeaderCode, '')) END ) 'HeaderCodeTownship_FA',
									 (CASE WHEN DEV.IsLastMileReturn<>1 THEN NAME_FA.NAME_FA ELSE NAME_TA.NAME_TA END)	'name_FA',
									 (CASE WHEN DEV.IsLastMileReturn <>1 THEN  CONVERT(VARCHAR, COALESCE(rgu.UsrEmail, '')) ELSE REPLACE(COALESCE(dev.Receiver_Email, ''), '"', ' ') END)'email_FA',
									 (CASE WHEN DEV.IsLastMileReturn <>1 THEN  REPLACE(CONVERT(VARCHAR, COALESCE(dev.Sender_Phone, '')), '"', ' ') ELSE REPLACE(COALESCE(dev.Receiver_Phone, ''), '"', ' ') END )'phone_FA',
									  (CASE WHEN DEV.IsLastMileReturn <>1 THEN   ADDRES1_FA.ADDRES1_FA	ELSE REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Address, ''), 'json'), '"', ' ') END) 'address1_FA',
									(CASE WHEN DEV.IsLastMileReturn <>1 THEN
										REPLACE(dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json'), '"', ' ')
										ELSE
										REPLACE(dbo.fnt_String_Escape(COALESCE(LOWER(dev.IndicationsToSendDestination),''),'json'),'"',' ') 
									END) 'address2_FA',
									(CASE WHEN DEV.IsLastMileReturn <>1 THEN COALESCE(ctm.Abbreviation, '') ELSE '' END) 'city_FA',
									COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0') 'IdMerchant_FA',
									 CONTACT_FA.CONTACT_FA 'contact_FA',
								(CASE WHEN DEV.IsLastMileReturn <>1 THEN CONVERT(VARCHAR, COALESCE(tws2.HeaderCode, AlterDestiny.HeaderCode, '')) ELSE CONVERT(VARCHAR, COALESCE(tws.HeaderCode, AlterOrigin.HeaderCode,''))  END )'HeaderCodeTownship_TA',
								CONCAT(IIF(
									ISNULL([dev].[IsLastMileReturn], 0) = 1
									AND ISNULL([AUX2].[ExpressName], '') <> '',
									REPLACE(
										[dbo].[fnt_String_Escape]
										(
											[AUX2].[ExpressName],
											'json'
										),
										'"',
										''
									) + ' - ',
								'') , (CASE WHEN DEV.IsLastMileReturn<>1 THEN NAME_TA.NAME_TA  ELSE  NAME_FA.NAME_FA END)) 'name_TA',
								(CASE WHEN DEV.IsLastMileReturn <>1 THEN  REPLACE(COALESCE(dev.Receiver_Email, ''), '"', ' ')  ELSE CONVERT(VARCHAR, COALESCE(rgu.UsrEmail, '')) END) 'email_TA',
								(CASE WHEN DEV.IsLastMileReturn <>1 THEN  REPLACE(COALESCE(dev.Receiver_Phone, ''), '"', ' ') ELSE  REPLACE(CONVERT(VARCHAR, COALESCE(dev.Sender_Phone, '')), '"', ' ') END ) 'phone_TA',								
								(CASE WHEN DEV.IsLastMileReturn <>1 THEN   REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Address, ''), 'json'), '"', ' ') ELSE ADDRES1_FA.ADDRES1_FA	END) 'address1_TA',
								
								(CASE WHEN DEV.IsLastMileReturn <>1 THEN
									REPLACE(dbo.fnt_String_Escape(COALESCE(LOWER(dev.IndicationsToSendDestination),''),'json'),'"',' ') 										
									ELSE
									REPLACE(dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json'), '"', ' ')
								END) 'address2_TA',
								(CASE WHEN DEV.IsLastMileReturn <>1 THEN '' ELSE COALESCE(ctm.Abbreviation, '') END) 'city_TA',
								(CASE WHEN DEV.IsLastMileReturn <>1 THEN CONVERT(VARCHAR, ISNULL(dev.ReceiverIdSettlement, 0)) ELSE 0 END)'ReceiverIdSettlement_TA',

								(
									CASE WHEN DEV.IsLastMileReturn <>1 THEN 
										REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Alternant_FullName, ''),'json'),'"',' ')
									ELSE 
										CONTACT_FA.CONTACT_FA
									END
								)
								'contact_TA',


								--PARCELS
								--+ '"' + '},' + '"parcels": [' + COALESCE(@arpieces, '') + ' ] , '
								CONVERT(VARCHAR, TP.TotalWeight) 'TotalWeight',
								CONVERT(VARCHAR, TP.TotalValue) 'TotalValue',
								'GTQ' 'Currency',
                                 CONVERT(VARCHAR, CAST(ISNULL(dev.InsuranceAmount, 0) AS MONEY)) 'ProductInsuranceAmount',
								 CONVERT(VARCHAR, 'GT') 'InsuranceCurrency',
								 CONVERT(VARCHAR, COALESCE(dev.Sender_ID, 0)) 'CodeOfReference',
								 CONVERT(VARCHAR, COALESCE(dev.Receiver_ID, 0)) 'CodeOfReferenceDestiny',
								 CONVERT(VARCHAR, COALESCE(dev.Sender_Internal_Code, '')) 'IdInternalOrderRef',
								 ISNULL(dev.IndicationsToSendDestination, '') 'Service_Ref1',
								 dbo.fnt_String_Escape(CONVERT(VARCHAR, COALESCE(dev.OrderUserCreated, '')), 'json') 'Username',
								 CONVERT(
                                                  VARCHAR,
                                                  COALESCE(DATEADD(DAY, @DaysToExpiration, dev.DateCreated), ''),
                                                  103
								) 'ExpirationDate',
								'' 'Route',
								dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json') 'TypeService',
								COALESCE(CPT.TimePlaName, '') 'Service_Payment',
								(CASE
                                    WHEN dev.IsInsuarance = 1 THEN
                                        'true'
                                    ELSE
                                        'false'
                                END
                                )'IsInsurance',
								(CASE
                                    WHEN dev.IsReturn = 1 THEN
                                        'true'
                                    ELSE
                                        'false'
                                END
                                )'IsReturn',
								CONVERT(   VARCHAR,
                                    (CASE
                                        WHEN ISNULL(dev.VisitpointClientPortfolioId, 0) > 0 THEN
                                            dev.VisitpointClientPortfolioId
                                        ELSE
                                            0
                                    END
                                    )
                                )'VisitPointByClientPortfolioId',
								CONVERT(NVARCHAR, COALESCE(cdo.IdDeliveryOption, 0)) 'idDeliveryOption',
								REPLACE(dbo.fnt_String_Escape(COALESCE(cdo.[Name], ''), 'json'), '"', ' ') 'descriptionDelivery',
								AUX.Impersonate 'Impersonate',
								CONVERT(NVARCHAR, COALESCE(dev.SalePipeLineId, 0)) 'SaleChannel',
								(CASE
                                    WHEN dev.Collect_OnDelivery > 0 THEN
                                        'true'
                                    ELSE
                                        'false'
                                END
                                )'COD_CashOnDelivery',
								CONVERT(VARCHAR, ISNULL(dev.Order_Number, 0)) 'COD_CreditNumber',
								COALESCE(CONVERT(VARCHAR, dev.Collect_OnDelivery), '0') 'COD_AmmountCashOnDelivery',
								'GTQ' 'COD_CashOnDeliveryCurrency',
								'AccountName' 'COD_BankAccountName',
								COALESCE(CONVERT(VARCHAR, dcba.DCBA_Bank_Id), '') 'COD_BankId',
								COALESCE(CONVERT(VARCHAR, dcba.DCBA_BankAccountType), '') 'COD_BankAccountType',
								COALESCE(CONVERT(VARCHAR, dcba.DCBA_Num_account), '') 'COD_BankAccountId',
								COALESCE(CONVERT(VARCHAR, dcba.DCBA_Identification), '') 'COD_Identification',


								--COALESCE(@integrationCost, '') 'Integration',
                                COALESCE(IIF(ISNULL([dev].[IsLastMileReturn],0) = 1,'D',IIF(ctm.BusinessSegmentID = @IDCatBusinessB2B,'B','E')), '') 'Priority',
								COALESCE(CONCAT('https://qa.forzadelivery.com/rastreo/',Guide_Serie,Guide_Number), '') 'QRLink',
								COALESCE(CONVERT(VARCHAR,dev.Pieces_Dry),'') 'Pieces_Dry' ,
                                COALESCE(CONVERT(VARCHAR,dev.Pieces_Cold),'')  'Pieces_Cold',
								(CASE
									WHEN 
										(dev.IsCollect <> 1 AND dev.Collect_OnDelivery>0 )
										or ctm.Abbreviation IN ('IGSS','RENAP')

									THEN
										'D'
									ELSE
										''
								END
								)'Icon',
								-- ADICIONES TSE
								COALESCE
								(
									(
										CASE
											WHEN [TSEGuide].[TSECodeRoute] IS NOT NULL THEN UPPER([TSEGuide].[TSECodeRoute])
											ELSE FORMAT([dev].[DeliveryETA], 'ddMM')
										END
									)
									, ''
								) [DeliveryETA],
								COALESCE
								(
									(
										CASE
											WHEN [TSEGuide].[TSEClusterAbbreviation] IS NOT NULL THEN UPPER([TSEGuide].[TSEClusterAbbreviation])
											ELSE ''
										END
									)
									, ''
								) [DestinyHub],
								-- FIN ADICIONES
								COALESCE
								(
									(
										CASE
											WHEN [DOPD].[TimePlaId] = 1 THEN 'PREPAGO'
											WHEN [DOPD].[TimePlaId] = 2 THEN 'PICKUP'
											WHEN [DOPD].[TimePlaId] = 3 THEN 'COLLECT'
											WHEN [DOPD].[TimePlaId] = 4 THEN 'CRÉDITO'
											ELSE 'CRÉDITO'
										END
									)
									, ''
								) [WayToPayDescription],
								COALESCE
								(
									(
										CASE
											WHEN [vp].[IdKindOfVPClient] = @FranchiseVisitPointTypeId THEN 'CNC'
											WHEN [vp].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN 'EXC'
											WHEN [vpori].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN 'EXC'
											WHEN [dev].[CatSystemId] = @IndividualWebSys THEN 'WEB'
											WHEN [dev].[CatSystemId] = @ExpressWebSys THEN 'EXC'
											WHEN [dev].[CatSystemId] = @CorporateWebSys THEN 'COR'
											WHEN [dev].[CatSystemId] = @ParserSys THEN 'PAR'
											WHEN [dev].[CatSystemId] IS NULL THEN 'API'
											ELSE 'API'
										END
									)
									, ''
								) [GuideOrigin]
                              FROM DeliveryBackOffice.dbo.DeliveryOrder dev WITH (NOLOCK)
                                  INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
                                      ON vp.CodeOfReference = dev.Sender_ID
								  LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpori  WITH(NOLOCK) 
									  ON [vpori].[CodeOfReference] = [dev].[OriginSenderId]
                                  LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
                                      ON ctm.IdCustomer = dev.IdCustomer
                                  OUTER APPLY(
									SELECT  TOP 1 acc1.AccIdAccount FROM  DeliveryBackOffice.dbo.Account acc1 WITH (NOLOCK)
                                      WHERE acc1.IdCustomer = ctm.IdCustomer
								  )acc
                                  LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rbu WITH (NOLOCK)
                                      ON rbu.RuaIdAccount = acc.AccIdAccount
                                  LEFT JOIN DeliveryBackOffice.dbo.RegisterUser rgu WITH (NOLOCK)
                                      ON rgu.UsrIdUser = rbu.RuaIdUser
                                  LEFT JOIN DeliveryBackOffice.dbo.Person prs WITH (NOLOCK)
                                      ON prs.PerIdPerson = rgu.UsrIdPerson
                                  LEFT JOIN DeliveryBackOffice.dbo.Township tws WITH (NOLOCK)
                                      ON tws.IdTownship = dev.SenderIdTownship
                                  LEFT JOIN DeliveryBackOffice.dbo.Township tws2 WITH (NOLOCK)
                                      ON tws2.IdTownship = dev.ReceiverIdTownship
                                  LEFT JOIN DeliveryBackOffice.dbo.Province p WITH (NOLOCK)
                                      ON p.IdProvince = tws.IdProvince
                                  LEFT JOIN DeliveryBackOffice.dbo.Province p2 WITH (NOLOCK)
                                      ON p2.IdProvince = tws2.IdProvince
                                  LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba WITH (NOLOCK)
                                      ON dcba.DCBA_Id = dev.DCBA_ID
                                  LEFT JOIN DeliveryBackOffice.dbo.CatDeliveryOptions cdo WITH (NOLOCK)
                                      ON dev.IdDeliveryOption = cdo.IdDeliveryOption
								  OUTER APPLY (
									SELECT 
										TOP (1) 
											[HL].[HubAbbreviation] 
									FROM 
										[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSCDesAux  WITH(NOLOCK) 
										INNER JOIN
											[DeliveryBackOffice].[dbo].[HubLogistics] HL  WITH(NOLOCK) 
											ON
												[DSCDesAux].[Hub] = [HL].[HubAbbreviation]
									WHERE
										[DSCDesAux].[HeaderCode] = [tws2].[HeaderCode]
									ORDER BY
										[DSCDesAux].[Hub] DESC
								  ) DestinyCov
                                  OUTER APPLY(
										SELECT TOP 1 
											cov2.RouteCode,
											cov2.RowStatus
										FROM DeliveryBackOffice.dbo.DumpServiceCoverage cov2 WITH (NOLOCK)
																			  WHERE  cov2.HeaderCode = tws2.HeaderCode
								  )cov
                                  LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH (NOLOCK)
                                      ON DOPD.GuideNumber = dev.Guide_Number
                                  LEFT JOIN DeliveryBackOffice.dbo.CatPaymentTime CPT WITH (NOLOCK)
                                      ON DOPD.TimePlaId = CPT.TimePlaId
                                         AND cov.RowStatus = 1
								  OUTER APPLY(
									SELECT CASE
                                           WHEN DEV.SalePipeLineId = 3
                                                AND
                                                (
                                                    CTM.IdCustomerType = 1
                                                    OR CTM.IdCustomerType = 3
                                                ) THEN
                                               'TRUE'
                                           ELSE
                                               'FALSE'
                                       END 'Impersonate'
								  )AUX
								  OUTER APPLY(
    
									SELECT CASE
												WHEN AUX.Impersonate='TRUE' THEN
													IIF(vpc.CodeOfReference=0,'',vpc.DescriptionOfClient)
												WHEN (dev.SalePipeLineId = 3 or  dev.SalePipeLineId = 4) THEN
													IIF(vpc2.CodeOfReference=0,'',vpc2.DescriptionOfClient)
												ELSE
													''
												END 'ExpressName'
									FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
										LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
											ON vpc.CodeOfReference = do.OriginSenderId
										LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc2 WITH (NOLOCK)
											ON vpc2.CodeOfReference = do.OriginSenderId
									WHERE Guide_Number = dev.Guide_Number and Guide_Serie=dev.Guide_Serie	
								
								  )AUX2
								  OUTER APPLY(
									 SELECT TOP 1 REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           (CASE
                                                                                WHEN AUX.Impersonate = 'TRUE' THEN
                                                                                    --IMPERSONADO
                                                                                    CASE
                                                                                        WHEN (dev.IsReturn = 1) THEN
                                                                                            --SI DEVOLUCION
                                                                                            CASE
                                                                                                WHEN (ctm.IdCustomerType = 1) THEN
                                                                                                    --CORPORATIVO
                                                                                                    COALESCE(
                                                                                                                dev.Sender_FirstName,
                                                                                                                ''
                                                                                                            )
                                                                                                ELSE
                                                                                                    --INDIVIDUAL
                                                                                                    COALESCE(
                                                                                                                dev.Sender_FirstName,
                                                                                                                ''
                                                                                                            )
                                                                                            END
                                                                                        ELSE
                                                                                            -- NO DEVOLUCION
                                                                                            CASE
                                                                                                WHEN (ctm.IdCustomerType = 1) THEN
                                                                                                    --CORPORATIVO
                                                                                                    COALESCE(
                                                                                                                vp.DescriptionOfClient,
                                                                                                                ''
                                                                                                            )
                                                                                                ELSE
                                                                                                    --INDIVIDUAL
                                                                                                    COALESCE(
                                                                                                                dev.Sender_FirstName,
                                                                                                                ''
                                                                                                            )
                                                                                            END
                                                                                    END
                                                                                ELSE
                                                                                    --NO IMPERSONADO
                                                                                    CONVERT(
                                                                                               VARCHAR,
                                                                                               COALESCE(
                                                                                                           dev.Sender_FirstName,
                                                                                                           ''
                                                                                                       )
                                                                                           ) + ' '
                                                                                    + CONVERT(
                                                                                                 VARCHAR,
                                                                                                 COALESCE(
                                                                                                             dev.Sender_LastName,
                                                                                                             ''
                                                                                                         )
                                                                                             )
                                                                            END
                                                                           ),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  ' '
                                              )NAME_FA								  
								) NAME_FA
								OUTER APPLY (
									SELECT REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           COALESCE(dev.Receiver_FirstName, '') + ' '
                                                                           + COALESCE(dev.Receiver_LastName, ''),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  ' '
									)NAME_TA								
								)NAME_TA

								OUTER APPLY (
									SELECT REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           CONVERT(
                                                                                      VARCHAR(200),
                                                                                      COALESCE(dev.Sender_Address, '')
                                                                                  ),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  ' '
                                              )	ADDRES1_FA							
								)ADDRES1_FA
								OUTER APPLY (
									SELECT (CASE
											WHEN [dev].[IsLastMileReturn] = 1 THEN ''
                                            WHEN AUX.Impersonate = 'TRUE' THEN
                                                --IMPERSONADO
                                                CASE
                                                    WHEN (dev.IsReturn = 1) THEN
                                                        --SI DEVOLUCION
                                                        CASE
                                                            WHEN (ctm.IdCustomerType = 1) THEN
                                                                --CORPORATIVO
                                                                COALESCE(AUX2.ExpressName, '')
                                                            ELSE
                                                                --INDIVIDUAL
                                                                COALESCE(AUX2.ExpressName, '')
                                                        END
                                                    ELSE
                                                        -- NO DEVOLUCION
                                                        CASE
                                                            WHEN (ctm.IdCustomerType = 1) THEN
                                                                --CORPORATIVO
                                                                COALESCE(dev.Sender_FirstName, '')
                                                            ELSE
                                                                --INDIVIDUAL
                                                                COALESCE(AUX2.ExpressName, '')
                                                        END
                                                END
                                            ELSE
                                                --NO IMPERSONADO
                                                CONVERT(VARCHAR, COALESCE(dev.Sender_FirstName, '')) + ' '
                                                + CONVERT(VARCHAR, COALESCE(dev.Sender_LastName, ''))
                                        END
                                       )CONTACT_FA								
								)CONTACT_FA
								  INNER JOIN @TMPPICES TP ON 
									TP.GuideSerie=DEV.Guide_Serie
									AND  TP.GuideNumber=DEV.Guide_Number
								OUTER APPLY (
									SELECT 
										TOP (1) 
											[Twn].[HeaderCode] 
									FROM 
										[DeliveryBackOffice].[dbo].[Province] Prv  WITH(NOLOCK) 
										INNER JOIN
											[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
											ON
												[Twn].[IdProvince] = [Prv].[IdProvince]
												AND
												[Twn].[HeaderCode] = CONCAT([Prv].[LocalCode],'01')
									WHERE
										[dev].[Sender_Department] = [Prv].[ProvinceName]  COLLATE Latin1_General_CI_AI 
								) AlterOrigin
								OUTER APPLY (
									SELECT 
										TOP (1) 
											[Twn].[HeaderCode] 
									FROM 
										[DeliveryBackOffice].[dbo].[Province] Prv  WITH(NOLOCK) 
										INNER JOIN
											[DeliveryBackOffice].[dbo].[Township] Twn  WITH(NOLOCK) 
											ON
												[Twn].[IdProvince] = [Prv].[IdProvince]
												AND
												[Twn].[HeaderCode] = CONCAT([Prv].[LocalCode],'01')
									WHERE
										[dev].[Receiver_Department] = [Prv].[ProvinceName]  COLLATE Latin1_General_CI_AI 
								) AlterDestiny
								-- ADICIONES TSE
								OUTER APPLY (
									SELECT 
										TOP (1) 
											CR.[CodeRoute] [TSECodeRoute],
											[CRC].[ClusterAbbreviation] [TSEClusterAbbreviation]
									FROM 
										[DeliveryBackOffice].[dbo].[TSERoutePreparationDetail] TSERPD  WITH(NOLOCK) 
										INNER JOIN
											[DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TSERPH  WITH(NOLOCK) 
											ON
												[TSERPD].[TSERoutePreparationHeaderID] = [TSERPH].[IDTSERoutePreparationHeader]
												AND
												[TSERPH].[RowStatus] = 1
										INNER JOIN
											[DeliveryBackOffice].[dbo].[CatRouteCluster] CRC  WITH(NOLOCK) 
											ON
												[CRC].[IdCatRouteCluster] = [TSERPH].[IdCatRouteCluster]
										INNER JOIN
											[DeliveryBackOffice].[dbo].[CatRoute] CR  WITH(NOLOCK) 
											ON
												[TSERPH].[IdCatRoute] = [CR].[IdRoute]
									WHERE
										[TSERPD].[GuideSerie] = [dev].[Guide_Serie]
										AND
										[TSERPD].[GuideNumber] = [dev].[Guide_Number]
										AND
										[TSERPD].[RowStatus] = 1
								) [TSEGuide]
							  -- FIN ADICIONES
								  
                              --WHERE dev.Guide_Number = @Guide_Number



  
	


END