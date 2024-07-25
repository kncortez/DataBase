-- =============================================
-- Modified:    <Daniel, Ramirez>
-- Create date: <2024-07-24>
-- Description: <Se ajusto la informacion de salida para que obtenga la moneda correcta>
-- =============================================
-- Modified:    <Daniel, Ramirez>
-- Create date: <2024-07-24>
-- Description: <Se retiro el parametro de pais, y se toma el pais desde la guia>
-- =============================================
CREATE PROCEDURE [dbo].[sps_getReprintGuie]
    @Guide_Number INT = 137916,
    @Serie_Number VARCHAR(2) = 'FD'
as
begin
    DECLARE @CountryThatConsults VARCHAR(2) = 'GT'

	declare @FranchiseVisitPointTypeId int = 
	(
		select 
			top (1) 
				[KOVPC].[IdKindOfVPClient] 
		from
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  with(nolock) 
		where
			[KOVPC].[KindOfVPName] = 'Concesionario'  --collate Latin1_General_CI_AI 
	)
	declare @ExpressVisitPointTypeId int = 
	(
		select 
			top (1) 
				[KOVPC].[IdKindOfVPClient] 
		from
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  with(nolock) 
		where
			[KOVPC].[KindOfVPName] = 'Express Center'  --collate Latin1_General_CI_AI 
	)
	declare @IndividualWebSys int =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web'  --COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ExpressWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-ExpressCenter'  --COLLATE Latin1_General_CI_AI 
	)
	DECLARE @CorporateWebSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Hermes Web-Corporativo'  --COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ParserSys INT =
	(
		SELECT 
			TOP 1
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Parser'  --COLLATE Latin1_General_CI_AI 
	)
	DECLARE @GuidePriority INT = 0;
    DECLARE @jsonOutput VARCHAR(MAX) = '',
            @parcels NVARCHAR(MAX) = N'',
            /*pieces*/
            @i INT = 0,
            @identity INT = 1,
            @arpieces VARCHAR(MAX) = '',
            @calcurrency VARCHAR(50) = '',
            @TotalWeight DECIMAL(12, 2),
            @TotalValue DECIMAL(12, 2);
    DECLARE @TMPPICES TABLE
    (
        it INT IDENTITY(1, 1),
        myrow INT
    );
    DECLARE @j INT = 0,
            @integrationCost VARCHAR(MAX) = '',
            @identityCost INT;
   DECLARE @StatusPackage INT = (SELECT IdCatSalesPackageStatus FROM CatSalesPackageStatus WHERE SalesPackageStatusName = 'Activa')

    SELECT 
		@i = COUNT(1),
		@TotalWeight = ISNULL(SUM(PieceWeight), 0),
		@TotalValue = ISNULL(SUM(Amount), 0)
    FROM 
		DeliveryBackOffice.[dbo].[DeliveryOrderPiece] WITH(NOLOCK)
    WHERE 
		GuideNumber = @Guide_Number
		AND
		GuideSerie = @Serie_Number;

    INSERT INTO @TMPPICES
    (
        myrow
    )
    SELECT GuidePiece
    FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece] WITH(NOLOCK)
    WHERE GuideNumber = @Guide_Number;

    SET @CountryThatConsults = (
                                SELECT TOP 1 SenderCountryId
                                  FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                                 WHERE Guide_Number = @Guide_Number
                                   AND Guide_Serie = @Serie_Number
                               );

	DECLARE @EXCKindOfVPC INT =
	(
		SELECT 
			[KOVPC].[IdKindOfVPClient] 
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center'  --COLLATE Latin1_General_CI_AI 
		AND ISNULL(IdCountry,'GT')=@CountryThatConsults
	);

    DECLARE @DaysToExpiration INT =
            (
                SELECT ISNULL(CAST(conf.Value AS INT), 45) DaysToExpiration
                FROM DeliveryBackOffice.dbo.ConfigParams conf WITH(NOLOCK)
                WHERE conf.Name = 'DaysToExpiration'
                      AND Status = 1
            );

    DECLARE @idCust BIGINT =
            (
                SELECT IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                WHERE Guide_Number = @Guide_Number
            );
    DECLARE @customerType INT =
            (
                SELECT IdCustomerType
                FROM DeliveryBackOffice.dbo.Customer WITH (NOLOCK)
                WHERE IdCustomer = @idCust
            );
    DECLARE @SalesChannel BIGINT =
            (
                SELECT SalePipeLineId
                FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
                WHERE Guide_Number = @Guide_Number
            );
    DECLARE @Impersonate VARCHAR(20) = CASE
                                           WHEN @SalesChannel = 3
                                                AND
                                                (
                                                    @customerType = 1
                                                    OR @customerType = 3
                                                ) THEN
                                               'TRUE'
                                           ELSE
                                               'FALSE'
                                       END;
    DECLARE @ExpressName VARCHAR(50) = '';

	DECLARE @IDCatBusinessB2B INT = (SELECT IdBusinessSegment FROM DBO.CatBusinessSegment WHERE BusinessSegmentName='B2B'AND ISNULL(IdCountry,'GT')=@CountryThatConsults);

    IF (@Impersonate = 'TRUE')
    BEGIN
        SET @ExpressName =
        (
            SELECT IIF(vpc.CodeOfReference=0,'',DescriptionOfClient)
            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = do.OriginSenderId
            WHERE Guide_Number = @Guide_Number
        );
    END;
    ELSE
    BEGIN
        IF (@SalesChannel = 3 OR @SalesChannel = 4)
        BEGIN
            SET @ExpressName =
            (
                SELECT DescriptionOfClient
                FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                        ON vpc.CodeOfReference = do.Sender_ID
                WHERE Guide_Number = @Guide_Number
            );
        END;
    END;

    WHILE @i > 0
    BEGIN
        SELECT @arpieces
            = @arpieces + '{"length":' + CONVERT(VARCHAR, ISNULL(PieceLength, 0)) + ',' + +'"width":'
              + CONVERT(VARCHAR, ISNULL(PieceWidth, 0)) + ',' + +'"height":' + CONVERT(VARCHAR, ISNULL(PieceHeight, 0))
              + ',' + +'"weight":' + CONVERT(VARCHAR, ISNULL(PieceWeight, 0)) + ',' + +'"amount":'
              + CONVERT(VARCHAR, ISNULL(Amount, 0)) + ', ' + '"currency":"' + COALESCE(Currency, '') + '",'
			  +'"ParcelCode":"'+ COALESCE(ParcelCode,'')+'",'+
              + +'"fragil":' + CASE
                                   WHEN fragile = 1 THEN
                                       'true'
                                   ELSE
                                       'false'
                               END + ',' + +'"description":"' + COALESCE(Detail, '') + '"' + '},',
               @calcurrency = COALESCE(Currency, '')
        FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece] WITH (NOLOCK)
        WHERE GuideNumber = @Guide_Number
              AND GuidePiece =
              (
                  SELECT myrow FROM @TMPPICES WHERE it = @identity
              );
        SET @identity = @identity + 1;
        SET @i = @i - 1;
    END;

    IF (@arpieces IS NOT NULL AND LEN(@arpieces) > 0)
    BEGIN
        SET @arpieces = LEFT(@arpieces, LEN(@arpieces) - 1);
    END;
    /*select @arpieces as cicloresult*/
    /*end pieces*/

    /*start integration cost*/

    SELECT @j = COUNT(1)
    FROM DeliveryBackOffice.[dbo].[Cost] ct WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bdp WITH (NOLOCK)
            ON bdp.IdCost = ct.IdCost
    WHERE ProductNumber = CONCAT(@Serie_Number, @Guide_Number);

    SELECT TOP 1
           @identityCost = bdp.IdBreakdownOfPayment
    FROM DeliveryBackOffice.[dbo].[Cost] ct WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bdp WITH (NOLOCK)
            ON bdp.IdCost = ct.IdCost
    WHERE ProductNumber = CONCAT(@Serie_Number, @Guide_Number);

    WHILE @j > 0
    BEGIN
        SELECT @integrationCost
            = @integrationCost + '{"Currency":"' + @calcurrency + '",' + +'"Description":"'
              + CONVERT(VARCHAR, ISNULL(Description, 0)) + '",' + +'"Price":"' + CONVERT(VARCHAR, ISNULL(Amount, 0))
              + '"' + '},'
        FROM DeliveryBackOffice.[dbo].[Cost] ct WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bdp WITH (NOLOCK)
                ON bdp.IdCost = ct.IdCost
        WHERE ProductNumber = CONCAT(@Serie_Number, @Guide_Number)
              AND IdBreakdownOfPayment = @identityCost;
        SET @identityCost = @identityCost + 1;
        SET @j = @j - 1;
    END;

    IF (@integrationCost IS NOT NULL AND LEN(@integrationCost) > 0)
    BEGIN
        SET @integrationCost = LEFT(@integrationCost, LEN(@integrationCost) - 1);
    END;

	SET @GuidePriority = (SELECT COUNT (do.Guide_Number) FROM DeliveryOrder do
		INNER JOIN Membership mb
		ON do.IdCustomer = mb.CustomerId
		WHERE do.Guide_Number = @Guide_Number
		AND mb.CatMembershipStatusId = 3
		AND mb.ExpirationDate >= GETDATE()
		AND mb.RowStatus = 1)


		/* Agregar bandera para indicar que fue creado con suscripcion de monto fijo */
			DECLARE @PaymentAllowsCollect INT = (
			               	SELECT Top 1 COUNT(
										 Case 
											  When s.CatTypeSubscriptionId = 2 Then 1
											  When s.CatTypeSubscriptionId = 1 Then 0
											  When s.CatTypeSubscriptionId IS NULL Then 0 
											  ELSE 0 End)
							FROM dbo.MembershipSubscriptionLog MSL WITH (NoLock)
							INNER JOIN dbo.Subscription s WITH (NoLock)
							ON MSL.SubscriptionId = S.IdSubscription
							Where LogGuideNumber = @Guide_Number
			
			
			)

		--------------------------------------------------------------------------------

    /*end integration cost*/

    SET @jsonOutput =
    (
        SELECT ''
               + STUFF(
                          (
                              SELECT DISTINCT TOP 1 --Price
                                     ',{"DateOfSale":"' + CONVERT(VARCHAR, ISNULL(dev.Preparation_Date, GETDATE()), 121)
                                     + '",' + '"ContentDescription":"'
                                     + CONVERT(VARCHAR, ISNULL(dev.Package_Description, '')) + '",' + '"IdCountry":"'
									 --SE AGREGA EL ID DEL PAIS DESTINO Y SI TIENE INCIDENCIAS AL PAIS ORIGEN, CRISTIAN SUAZO
                                     + CASE WHEN dev.IsLastMileReturn=0   
											THEN CONVERT(VARCHAR, COALESCE(dev.ReceiverCountryId, 'GT')) 
											ELSE CONVERT(VARCHAR, COALESCE(dev.SenderCountryId, 'GT'))
									   END+ '",' + '"CountPieces":'
									 --FIN CAMBIO
                                     + CONVERT(VARCHAR, ISNULL(dev.Pieces_Dry + dev.Pieces_Cold, 0)) + ','
                                     + '"Collected":' + CASE
                                                            WHEN dev.IsCollect = 1 THEN
                                                                'true'
                                                            ELSE
                                                                'false'
                                                        END + ',' +
                                  /*valor del felte para imprimir en la guia*/
                                  '"Price":"' + COALESCE(CONVERT(VARCHAR, dev.PriceShippment), '0.00') + '",' +
								  '"PaymentAllowsCollect":"'  + COALESCE(CONVERT(VARCHAR, @PaymentAllowsCollect), '0') + '",' +
                                  /*valor collect*/
                                  '"IdCustomer":'
                                     + COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0')
                                     + ',' + 
									 
									 (
									 CASE WHEN dev.IsLastMileReturn=1 THEN
										'"to_address":'
										ELSE
										'"from_address":'
										END
									 )
									 +' {' + '"HeaderCodeTownship":"'
                                     + CONVERT(VARCHAR, COALESCE(tws.HeaderCode, '')) + '",' +
                                  -- Cambios para flujos de impersonar, creacion de Guias y Devoluciones
                                  '"name":"' + IIF(ISNULL([dev].[IsLastMileReturn], 0) = 1 AND [vp].[IdKindOfVPClient] = @EXCKindOfVPC, REPLACE(dbo.fnt_String_Escape(ISNULL([vp].[DescriptionOfClient], ''), 'json'), '"','') + ' - ' , '') +
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           (CASE
                                                                                WHEN @Impersonate = 'TRUE' THEN
                                                                                    --IMPERSONADO
                                                                                    CASE
                                                                                        WHEN (dev.IsReturn = 1) THEN
                                                                                            --SI DEVOLUCION
                                                                                            CASE
                                                                                                WHEN (@customerType = 1) THEN
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
                                                                                                WHEN (@customerType = 1) THEN
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
                                              ) + '",' + '"phone":"'
                                     + REPLACE(CONVERT(VARCHAR, COALESCE(dev.Sender_Phone, '')), '"', ' ') + '",'
                                     + '"email":"' + CONVERT(VARCHAR, COALESCE(rgu.UsrEmail, '')) + '",' + '"address1":"'
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           CONVERT(
                                                                                      VARCHAR(200),
                                                                                      COALESCE(dev.Sender_Address, '')
                                                                                  ),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  '\"'
                                              ) + '",' + '"address2":"'
                                     + REPLACE(dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json'), '"', ' ')
                                     + '",' + '"city":"' + COALESCE(ctm.Abbreviation, '') + '",' + '"IdMerchant":'
                                     + COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0')
                                     + ',' +
									 + '"ReceiverIdSettlement":0'
                                      + ', ' +
                                  -- Cambios para flujos de impersonar, creacion de Guias y Devoluciones
                                  '"contact":"'
                                     + REPLACE(
										dbo.fnt_String_Escape(
																(CASE
																	WHEN dev.[IsLastMileReturn] = 1 THEN ''
																	WHEN @Impersonate = 'TRUE' THEN
																		--IMPERSONADO
																		CASE
																			WHEN (dev.IsReturn = 1) THEN
																				--SI DEVOLUCION
																				CASE
																					WHEN (@customerType = 1) THEN
																						--CORPORATIVO
																						COALESCE(@ExpressName, '')
																					ELSE
																						--INDIVIDUAL
																						COALESCE(@ExpressName, '')
																				END
																			ELSE
																				-- NO DEVOLUCION
																				CASE
																					WHEN (@customerType = 1) THEN
																						--CORPORATIVO
																						COALESCE(dev.Sender_FirstName, '')
																					ELSE
																						--INDIVIDUAL
																						COALESCE(@ExpressName, '')
																				END
																		END
																	ELSE
																		--NO IMPERSONADO
																		CONVERT(VARCHAR, COALESCE(dev.Sender_FirstName, '')) + ' '
																		+ CONVERT(VARCHAR, COALESCE(dev.Sender_LastName, ''))
																END)
											                ,'json')
									   ,'"'
									   ,' ') + '"' + '},' +
									   
									 (
									 CASE WHEN dev.IsLastMileReturn=1 THEN
										'"from_address":'
										ELSE
										'"to_address":'
										END
									 )									   
									   
									   +'{' + '"HeaderCodeTownship":"'
                                     + CONVERT(VARCHAR, COALESCE(tws2.HeaderCode, '')) + '",' + '"name":"'
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           COALESCE(dev.Receiver_FirstName, '') + ' '
                                                                           + COALESCE(dev.Receiver_LastName, ''),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  ' '
                                              ) + '",' + '"phone":"' + REPLACE(COALESCE(dev.Receiver_Phone, ''), '"', ' ')
                                     + '",' + '"email":"' + REPLACE(COALESCE(dev.Receiver_Email, ''), '"', ' ') + '",'
                                     + '"address1":"'
                                     + REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Address, ''), 'json'), '"', '\"')
                                     + '",' + '"address2":"'
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           COALESCE(
                                                                                       LOWER(dev.IndicationsToSendDestination),
                                                                                       ''
                                                                                   ),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  '\"'
                                              ) + '",' + '"city":"' + '' + '",' 
											  
											  +'"IdMerchant":'
                                     + COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0') + ','

											  + '"ReceiverIdSettlement":'
                                     + CONVERT(VARCHAR, ISNULL(dev.ReceiverIdSettlement, 0)) + ', ' + '"contact":"'
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           COALESCE(dev.Receiver_Alternant_FullName, ''),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  '\"'
                                              ) + '"' + '},' + '"parcels": [' + COALESCE(@arpieces, '') + ' ] , '
                                     + '"TotalWeight":' + CONVERT(VARCHAR, @TotalWeight) + ', ' + '"TotalValue":'
                                     + CONVERT(VARCHAR, @TotalValue) + ',' + '"Currency":"' + @calcurrency + '",'
                                     + '"ProductInsuranceAmount":'
                                     + CONVERT(VARCHAR, CAST(ISNULL(dev.InsuranceAmount, 0) AS MONEY)) + ','
                                     + '"InsuranceCurrency":"' + CONVERT(VARCHAR, @calcurrency) + '",'
                                     + '"CodeOfReference":' + CONVERT(VARCHAR, COALESCE(dev.Sender_ID, 0)) + ',' +
									 + '"CodeOfReferenceDestiny":' + CONVERT(VARCHAR, COALESCE(dev.Receiver_ID, 0)) + ',' +
                                     + '"IdInternalOrderRef":"' 
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                        CONVERT(VARCHAR, COALESCE(dev.Ticket_Number, '')) ,
                                                                        'json'
                                                                       ),
                                                  '"',
                                                  '\"'
                                              ) 
                                     + '",'
									 +'"IdInternalOrderRef2":"'
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                        CONVERT(VARCHAR, COALESCE([dev].[Order_Number], '')) ,
                                                                        'json'
                                                                       ),
                                                  '"',
                                                  '\"'
                                              ) 
                                     + '",'
									 + '"Service_Ref1":"' 
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           COALESCE(
                                                                                       LOWER(dev.IndicationsToSendDestination),
                                                                                       ''
                                                                                   ),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  '\"'
                                              ) 
                                     + '",'
                                     + '"Username":"'
                                     + dbo.fnt_String_Escape(CONVERT(VARCHAR, COALESCE(dev.OrderUserCreated, '')), 'json')
                                     + '",' + '"ExpirationDate":"'
                                     + CONVERT(
                                                  VARCHAR,
                                                  COALESCE(DATEADD(DAY, @DaysToExpiration, dev.DateCreated), ''),
                                                  103
                                              ) + '",' + '"Route":"",'
                                     + '"TypeService":"' + dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json')
                                     + '",' + '"Service_Payment":"' + COALESCE(CPT.TimePlaName, '') + '",' +
                                  /*nueva seccion del si esta asegurado o no*/
                                  '"IsInsuarance":' + (CASE
                                                           WHEN dev.IsInsuarance = 1 THEN
                                                               'true'
                                                           ELSE
                                                               'false'
                                                       END
                                                      ) + ',' +
                                  /**/
                                  '"IsReturn":' + (CASE
                                                       WHEN dev.IsReturn = 1 THEN
                                                           'true'
                                                       ELSE
                                                           'false'
                                                   END
                                                  ) + ',' + '"VisitPointByClientPortfolioId":'
                                     + CONVERT(   VARCHAR,
                                                  (CASE
                                                       WHEN ISNULL(dev.VisitpointClientPortfolioId, 0) > 0 THEN
                                                           dev.VisitpointClientPortfolioId
                                                       ELSE
                                                           0
                                                   END
                                                  )
                                              ) + ',' +
                                  /*Campos descripcion de entrega*/
                                  '"idDeliveryOption":' + CONVERT(NVARCHAR, COALESCE(cdo.IdDeliveryOption, 0)) + ','
                                     + '"descriptionDelivery":"'
                                     + REPLACE(dbo.fnt_String_Escape(COALESCE(cdo.[Name], ''), 'json'), '"', ' ') + '",'
                                     + '"Impersonate":"' + @Impersonate + '",' + '"SaleChannel":'
                                     + CONVERT(NVARCHAR, COALESCE(@SalesChannel, 0)) + ',' +
                                  /**/
                                  '"COD":  {' + '"CashOnDelivery": ' + (CASE
                                                                            WHEN dev.Collect_OnDelivery > 0 THEN
                                                                                'true'
                                                                            ELSE
                                                                                'false'
                                                                        END
                                                                       ) + ',' + '"CreditNumber":"'
                                     + CONVERT(VARCHAR, ISNULL(dev.Order_Number, 0)) + '",' + '"AmmountCashOnDelivery": '
                                     + COALESCE(CONVERT(VARCHAR, dev.Collect_OnDelivery), '0') + ','
                                     + '"CashOnDeliveryCurrency":"' + 
                                        CASE 
                                            WHEN dev.SenderCountryId = 'GT' THEN 'GTQ'
                                            WHEN dev.SenderCountryId = 'HN' THEN 'HNL'
                                            ELSE 'HNL'
                                        END  
                                     + '",'
                                     + '"BankAccountName":"AccountName",' /*,*/ + '"BankId":"'
                                     + COALESCE(CONVERT(VARCHAR, dcba.DCBA_Bank_Id), '') + '",' + '"BankAccountType":"'
                                     + COALESCE(CONVERT(VARCHAR, dcba.DCBA_BankAccountType), '') + '",'
                                     + '"BankAccountId":"' + COALESCE(CONVERT(VARCHAR, dcba.DCBA_Num_account), '') + '",'
                                     + '"Identification":"' + COALESCE(CONVERT(VARCHAR, dcba.DCBA_Identification), '')
                                     + '"' + ' },' + '"Integration": [' + COALESCE(@integrationCost, '') + ' ], ' 
									  + '"Priority": "' + 
										COALESCE(
											(CASE 
												WHEN ISNULL([dev].[IsLastMileReturn], 0) = 1 THEN 'D'
												WHEN MMBSHP.IdMembership IS NOT NULL THEN 'F'
												WHEN ctm.BusinessSegmentID = @IDCatBusinessB2B THEN 'B' 
												ELSE 'E'
											END)
										, '') + '",' 
									 + '"QRLink": "' + COALESCE(CONCAT('https://forzadelivery.com/rastreo/',Guide_Serie,Guide_Number), '') + '",' 
									 + '"UseMembership": ' + CONVERT(VARCHAR, CAST(ISNULL((CASE WHEN [MSL].[IdMembershipSubscriptionLog] IS NOT NULL THEN 1 ELSE 0 END), 0) AS BIT)) + ',' 
									 + '"AllowsCollect": ' + CONVERT(VARCHAR, IIF(CSBT.CatTypeSubscriptionId = 2, 0,1)) + ','  
									 + '"CategoryProductId": ' + CONVERT(VARCHAR, IIF([MSL].[MembershipId] IS NOT NULL, CMSL.CatProductCategoryId,IIF(CSBT.CatProductCategoryId IS NOT NULL,CSBT.CatProductCategoryId, 0) )) + ',' 
									 + '"ProductId": ' + CONVERT(VARCHAR, IIF([MSL].[MembershipId] IS NOT NULL,[MSL].[MembershipId], IIF(MSL.SubscriptionId IS NOT NULL,MSL.SubscriptionId, 0))) + ','  
									 + '"Pieces_Dry":' +  COALESCE(CONVERT(VARCHAR,dev.Pieces_Dry),'') + ','
									 + '"Pieces_Cold": ' + COALESCE(CONVERT(VARCHAR, [dev].[Pieces_Cold]), '') + ',' 
									 + '"DeliveryETA": "' + COALESCE
																(
																	FORMAT([dev].[DeliveryETA], 'ddMM')
																	, ''
																) + '",' 
									 + '"WayToPayDescription": "' + COALESCE
																		(
																			(
																				CASE
																					WHEN ISNULL([dev].[IsCollect], 0) = 1 THEN 'COLLECT'
																					WHEN [DOPD].[TimePlaId] = 1 THEN 'PREPAGO'
																					WHEN [DOPD].[TimePlaId] = 2 THEN 'PICKUP'
																					WHEN [DOPD].[TimePlaId] = 3 THEN 'COLLECT'
																					WHEN [DOPD].[TimePlaId] = 4 THEN 'CRÉDITO'
																					ELSE 'CRÉDITO'
																				END
																			)
																			, ''
																		) + '",' 
									 + '"GuideOrigin": "' + COALESCE
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
																) + '",' 
									 + '"Icon": "' + (CASE
															WHEN 
																(dev.IsCollect <> 1 AND dev.Collect_OnDelivery>0 )
																or ctm.Abbreviation IN ('IGSS','RENAP')

															THEN
															   'D'
														   ELSE
															   ''
													   END
													  ) + '"'
									 + '} }'
                                     + ''
                              FROM DeliveryBackOffice.dbo.DeliveryOrder dev WITH (NOLOCK)
                                  INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
                                      ON vp.CodeOfReference = dev.Sender_ID
								  LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpori  WITH(NOLOCK) 
									  ON [vpori].[CodeOfReference] = [dev].[OriginSenderId]
                                  LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
                                      ON ctm.IdCustomer = dev.IdCustomer
                                  LEFT JOIN DeliveryBackOffice.dbo.Account acc WITH (NOLOCK)
                                      ON acc.IdCustomer = ctm.IdCustomer
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
                                  LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage cov WITH (NOLOCK)
                                      ON cov.HeaderCode = tws2.HeaderCode
                                  LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH (NOLOCK)
                                      ON DOPD.GuideNumber = dev.Guide_Number
                                  LEFT JOIN DeliveryBackOffice.dbo.CatPaymentTime CPT WITH (NOLOCK)
                                      ON DOPD.TimePlaId = CPT.TimePlaId
                                         AND cov.RowStatus = 1
								  LEFT JOIN DeliveryBackOffice.dbo.Membership MMBSHP WITH(NOLOCK)
									    ON MMBSHP.CustomerId = ctm.IdCustomer
										AND MMBSHP.CatMembershipStatusId = @StatusPackage
										AND MMBSHP.ExpirationDate >= GETDATE()
										AND MMBSHP.RowStatus = 1
								  LEFT JOIN [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL  WITH(NOLOCK) 
									  ON [MSL].[LogGuideSerie] = [dev].[Guide_Serie] 
									  AND [MSL].[LogGuideNumber] = [dev].[Guide_Number]
									  AND [MSL].[RowStatus] = 1
								  LEFT JOIN [DeliveryBackOffice].[dbo].[CatMembership] CMSL  WITH(NOLOCK) 
									  ON MMBSHP.CatMembershipId = CMSL.IdCatMembership
									  AND CMSL.RowStatus = 1
								  LEFT JOIN [DeliveryBackOffice].[dbo].[Subscription] SBT  WITH(NOLOCK) 
									  ON MSL.SubscriptionId = SBT.IdSubscription
									  AND SBT.RowStatus = 1
								  LEFT JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CSBT  WITH(NOLOCK) 
								      ON SBT.CatSubscriptionId = CSBT.IdCatSubscription
									  AND CSBT.RowStatus = 1
                              WHERE dev.Guide_Number = @Guide_Number
                              FOR XML PATH(''), TYPE
                          ).value('.', 'varchar(max)'),
                          1,
                          1,
                          ''
                      ) + ''
    );

    PRINT @jsonOutput;

    SELECT @jsonOutput FormatJson;


END; 
