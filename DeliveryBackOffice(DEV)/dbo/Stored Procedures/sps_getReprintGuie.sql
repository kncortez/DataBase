
CREATE PROCEDURE [dbo].[sps_getReprintGuie]
    @Guide_Number INT = 137916,
    @Serie_Number VARCHAR(2) = 'FD'
AS
BEGIN
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

    SELECT @i = COUNT(1)
    FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece]
    WHERE GuideNumber = @Guide_Number;


    SELECT @TotalWeight = ISNULL(SUM(PieceWeight), 0)
    FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece]
    WHERE GuideNumber = @Guide_Number;


    SELECT @TotalValue = ISNULL(SUM(Amount), 0)
    FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece]
    WHERE GuideNumber = @Guide_Number;


    INSERT INTO @TMPPICES
    (
        myrow
    )
    SELECT GuidePiece
    FROM DeliveryBackOffice.[dbo].[DeliveryOrderPiece]
    WHERE GuideNumber = @Guide_Number;

    DECLARE @DaysToExpiration INT =
            (
                SELECT ISNULL(CAST(conf.Value AS INT), 45) DaysToExpiration
                FROM DeliveryBackOffice.dbo.ConfigParams conf
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

    IF (@Impersonate = 'TRUE')
    BEGIN
        SET @ExpressName =
        (
            SELECT DescriptionOfClient
            FROM DeliveryOrder do WITH (NOLOCK)
                JOIN VisitPointClient vpc WITH (NOLOCK)
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
                FROM DeliveryOrder do WITH (NOLOCK)
                    JOIN VisitPointClient vpc WITH (NOLOCK)
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
            = @integrationCost + '{"Currency":"' + 'GTQ' + '",' + +'"Description":"'
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
                                     + CONVERT(VARCHAR, COALESCE(p.IdCountry, '')) + '",' + '"CountPieces":'
                                     + CONVERT(VARCHAR, ISNULL(dev.Pieces_Dry + dev.Pieces_Cold, 0)) + ','
                                     + '"Collected":' + CASE
                                                            WHEN dev.IsCollect = 1 THEN
                                                                'true'
                                                            ELSE
                                                                'false'
                                                        END + ',' +
                                  /*valor del felte para imprimir en la guia*/
                                  '"Price":"' + COALESCE(CONVERT(VARCHAR, dev.PriceShippment), '0.00') + '",' +
                                  /*valor collect*/
                                  '"IdCustomer":'
                                     + COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0')
                                     + ',' + '"from_address": {' + '"HeaderCodeTownship":"'
                                     + CONVERT(VARCHAR, COALESCE(tws.HeaderCode, '')) + '",' +
                                  -- Cambios para flujos de impersonar, creacion de Guias y Devoluciones
                                  '"name":"'
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
                                                  ' '
                                              ) + '",' + '"address2":"'
                                     + REPLACE(dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json'), '"', ' ')
                                     + '",' + '"city":"' + COALESCE(ctm.Abbreviation, '') + '",' + '"IdMerchant":'
                                     + COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0')
                                     + ',' +
                                  -- Cambios para flujos de impersonar, creacion de Guias y Devoluciones
                                  '"contact":"'
                                     + (CASE
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
                                        END
                                       ) + '"' + '},' + '"to_address": {' + '"HeaderCodeTownship":"'
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
                                     + REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Address, ''), 'json'), '"', ' ')
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
                                                  ' '
                                              ) + '",' + '"city":"' + '' + '",' + '"ReceiverIdSettlement":'
                                     + CONVERT(VARCHAR, ISNULL(dev.ReceiverIdSettlement, 0)) + ', ' + '"contact":"'
                                     + REPLACE(
                                                  dbo.fnt_String_Escape(
                                                                           COALESCE(dev.Receiver_Alternant_FullName, ''),
                                                                           'json'
                                                                       ),
                                                  '"',
                                                  ' '
                                              ) + '"' + '},' + '"parcels": [' + COALESCE(@arpieces, '') + ' ] , '
                                     + '"TotalWeight":' + CONVERT(VARCHAR, @TotalWeight) + ', ' + '"TotalValue":'
                                     + CONVERT(VARCHAR, @TotalValue) + ',' + '"Currency":"' + 'GTQ' + '",'
                                     + '"ProductInsuranceAmount":'
                                     + CONVERT(VARCHAR, CAST(ISNULL(dev.InsuranceAmount, 0) AS MONEY)) + ','
                                     + '"InsuranceCurrency":"' + CONVERT(VARCHAR, @calcurrency) + '",'
                                     + '"CodeOfReference":' + CONVERT(VARCHAR, COALESCE(dev.Sender_ID, 0)) + ','
                                     + '"IdInternalOrderRef":"' + CONVERT(VARCHAR, COALESCE(dev.Sender_Internal_Code, ''))
                                     + '",'
                                     +
                                  -- '"Username":"' + dbo.fnt_String_Escape(Convert(varchar,coalesce( dev.Sender_Mail,'')),'json')+'",'+
                                  '"Username":"'
                                     + dbo.fnt_String_Escape(CONVERT(VARCHAR, COALESCE(dev.OrderUserCreated, '')), 'json')
                                     + '",' + '"ExpirationDate":"'
                                     + CONVERT(
                                                  VARCHAR,
                                                  COALESCE(DATEADD(DAY, @DaysToExpiration, dev.DateCreated), ''),
                                                  103
                                              ) + '",' + '"Route":"' + COALESCE(cov.RouteCode, '') + '",'
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
                                     + '"CashOnDeliveryCurrency":"' + 'GTQ' + '",'
                                     + '"BankAccountName":"AccountName",' /*,*/ + '"BankId":"'
                                     + COALESCE(CONVERT(VARCHAR, dcba.DCBA_Bank_Id), '') + '",' + '"BankAccountType":"'
                                     + COALESCE(CONVERT(VARCHAR, dcba.DCBA_BankAccountType), '') + '",'
                                     + '"BankAccountId":"' + COALESCE(CONVERT(VARCHAR, dcba.DCBA_Num_account), '') + '",'
                                     + '"Identification":"' + COALESCE(CONVERT(VARCHAR, dcba.DCBA_Identification), '')
                                     + '"' + ' },' + '"Integration": [' + COALESCE(@integrationCost, '') + ' ] ' + '} }'
                                     + ''
                              FROM DeliveryBackOffice.dbo.DeliveryOrder dev WITH (NOLOCK)
                                  JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH (NOLOCK)
                                      ON vp.CodeOfReference = dev.Sender_ID
                                  LEFT JOIN DeliveryBackOffice.dbo.Customer ctm WITH (NOLOCK)
                                      ON ctm.IdCustomer = dev.IdCustomer
                                  LEFT JOIN DeliveryBackOffice.dbo.Account acc WITH (NOLOCK)
                                      ON acc.IdCustomer = ctm.IdCustomer
                                  --and acc.AccIdAccount = 1 
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
                                  LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD
                                      ON DOPD.GuideNumber = dev.Guide_Number
                                  LEFT JOIN DeliveryBackOffice.dbo.CatPaymentTime CPT
                                      ON DOPD.TimePlaId = CPT.TimePlaId
                                         AND cov.RowStatus = 1
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
