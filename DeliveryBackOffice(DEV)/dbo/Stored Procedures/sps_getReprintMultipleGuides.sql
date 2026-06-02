/* =================================================
   SP:        sps_getReprintMultipleGuides
   Propósito: Se Crea SP para generar los datos necesarios para poder realizar una reimpresión de guía
   Autor:     Alberto Ixchop
   Historia:  ---
   Fecha:     2022-10-27

=== CHANGELOG ============================

2022-12-20 | Historia/épica: ---         | Autor: Edelman Vásquez | Agregar Campos de Piezas Frías y piezas Secas
2024-10-23 | Historia/épica: ---         | Autor: Edelman Vásquez | Integración nuevo formato 4X4
2025-04-21 | Historia/épica: ---         | Autor: Oscar Rodriguez | Se agrego validacion para manejo de codigo de ruta asociado a poblado de origen en devolucion
2026-04-08 | Historia/épica: FDAPI-6026  | Autor: Mario Herrarte  | Se valida el estado Retenido para el campo priority
2026-06-01 | Historia/épica: FDAPI-6153  | Autor: Brandon Pedroza | Se agrega validacion para obtener datos de bodega de devolucion

=========================================== */
CREATE  PROCEDURE [dbo].[sps_getReprintMultipleGuides]
	@GUIDESLIST TblGUides READONLY,
	@CountryThatConsults VARCHAR(2)= 'GT'
AS
BEGIN

    DECLARE @FranchiseVisitPointTypeId INT =
            (
                SELECT TOP (1)
                       [KOVPC].[IdKindOfVPClient]
                FROM [DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC WITH (NOLOCK)
                WHERE
                    [KOVPC].[KindOfVPName] = 'Concesionario' 
                    AND IdCountry = @CountryThatConsults
            );
    DECLARE @ExpressVisitPointTypeId INT =
            (
                SELECT TOP (1)
                       [KOVPC].[IdKindOfVPClient]
                FROM [DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC WITH (NOLOCK)
                WHERE
                    [KOVPC].[KindOfVPName] = 'Express Center'  
                    AND IdCountry = @CountryThatConsults
            );
    DECLARE @IndividualWebSys INT =
            (
                SELECT TOP 1
                       [CS].[SysIdSystem]
                FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH (NOLOCK)
                WHERE
                    --[CS].[SysNameSystem] = 'Hermes Web'   
                    [CS].[SysNameSystem] = 'Hermes Web' 
            );
    DECLARE @ExpressWebSys INT =
            (
                SELECT TOP 1
                       [CS].[SysIdSystem]
                FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH (NOLOCK)
                WHERE
                    --[CS].[SysNameSystem] = 'Hermes Web-ExpressCenter'   
                    [CS].[SysNameSystem] = 'Hermes Web-ExpressCenter'  
            );
    DECLARE @CorporateWebSys INT =
            (
                SELECT TOP 1
                       [CS].[SysIdSystem]
                FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH (NOLOCK)
                WHERE
                    --[CS].[SysNameSystem] = 'Hermes Web-Corporativo'   
                    [CS].[SysNameSystem] = 'Hermes Web-Corporativo'  
            );
    DECLARE @ParserSys INT =
            (
                SELECT TOP 1
                       [CS].[SysIdSystem]
                FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH (NOLOCK)
                WHERE
                    --[CS].[SysNameSystem] = 'Parser'   
                    [CS].[SysNameSystem] = 'Parser'  
            );
    DECLARE @TMPPICES TABLE
    (
        GuideSerie NVARCHAR(2)
      , GuideNumber INT
      , [TotalWeight] DECIMAL(12, 2)
      , [TotalValue] DECIMAL(12, 2)
    );

    INSERT INTO @TMPPICES
    (
        GuideSerie
      , GuideNumber
      , [TotalWeight]
      , [TotalValue]
    )
    SELECT GL.Guide_Serie
         , GL.Guide_Number
         , ISNULL(SUM(PieceWeight), 0)
         , ISNULL(SUM(Amount), 0)
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
        INNER JOIN @GUIDESLIST                         GL
            ON DOP.GuideSerie = GL.Guide_Serie
            AND DOP.GuideNumber = GL.Guide_Number
    GROUP BY GL.Guide_Serie
           , GL.Guide_Number;


    DECLARE @DaysToExpiration INT =
            (
                SELECT ISNULL(CAST(conf.Value AS INT), 45) DaysToExpiration
                FROM [DeliveryBackOffice].[dbo].[ConfigParams] conf WITH (NOLOCK)
                WHERE conf.Name = 'DaysToExpiration'
                      AND Status = 1
            );




    DECLARE @IDCatBusinessB2B INT =
            (
                SELECT IdBusinessSegment
                FROM [DeliveryBackOffice].[dbo].[CatBusinessSegment]
                WHERE BusinessSegmentName = 'B2B'
                      AND IdCountry = @CountryThatConsults
            );



    SELECT CONVERT(VARCHAR, ISNULL(PieceLength, 0)) 'length'
         , CONVERT(VARCHAR, ISNULL(PieceWidth, 0))  'width'
         , CONVERT(VARCHAR, ISNULL(PieceHeight, 0)) 'height'
         , CONVERT(VARCHAR, ISNULL(PieceWeight, 0)) 'weight'
         , CONVERT(VARCHAR, ISNULL(Amount, 0))      'amount'
         , COALESCE(Currency, '')                   'currency'
         , COALESCE(ParcelCode, '')                 'ParcelCode'
         , CASE
               WHEN fragile = 1 THEN
                   'true'
               ELSE
                   'false'
           END                                      'fragil'
         , COALESCE(Detail, '')                     'description'
         , dop.NoPiece                              'NoPiece'
         , dop.GuideSerie                           'GuideSerie'
         , dop.GuideNumber                          'GuideNumber'
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH (NOLOCK)
        INNER JOIN @GUIDESLIST                         GL
            ON GL.Guide_Serie = dop.GuideSerie
               AND GL.Guide_Number = dop.GuideNumber;

    SELECT --TOP 1
        GL.Guide_Serie                           'GuideSerie'
      , GL.Guide_Number                          'GuideNumber'
      , cc.CodeISO                               AS 'Currency'
      , CONVERT(VARCHAR, ISNULL(Description, 0)) 'Description'
      , CONVERT(VARCHAR, ISNULL(Amount, 0))      'Price'
    FROM [DeliveryBackOffice].[dbo].[Cost]                    ct WITH (NOLOCK)
        LEFT JOIN [DeliveryBackOffice].[dbo].BreakdownOfPayment bdp WITH (NOLOCK)
            ON bdp.IdCost = ct.IdCost
        LEFT JOIN [DeliveryBackOffice].[dbo].CatCurrencyCOD     cc WITH (NOLOCK)
            ON cc.IdCatCurrencyCOD = ct.ShippingCurrency
        INNER JOIN @GUIDESLIST                              GL
            ON ct.GuideSerie = GL.Guide_Serie
               AND ct.GuideNumber = GL.Guide_Number;

    /*end integration cost*/

    SELECT DISTINCT
           TP.GuideSerie                                                                            'GuideSerie'
         , TP.GuideNumber                                                                           'GuideNumber'
         , CONVERT(VARCHAR, ISNULL(dev.Preparation_Date, GETDATE()), 121)                           'DateOfSale'
         , CONVERT(VARCHAR, ISNULL(dev.Package_Description, ''))                                    'ContentDescription'
         --SE AGREGA EL ID DEL PAIS DESTINO Y SI TIENE INCIDENCIAS AL PAIS ORIGEN, CRISTIAN SUAZO
         , CASE
               WHEN dev.IsLastMileReturn = 0 THEN
                   CONVERT(VARCHAR, COALESCE(dev.ReceiverCountryId, 'GT'))
               ELSE
                   CONVERT(VARCHAR, COALESCE(dev.SenderCountryId, 'GT'))
           END                                                                                      'IdCountry'
         --FIN CAMBIO
         , CONVERT(VARCHAR, ISNULL(dev.Pieces_Dry + dev.Pieces_Cold, 0))                            'CountPieces'
         , CONVERT(VARCHAR, COALESCE([dev].[Ticket_Number], '0'))                                   'Ticket_Number'
         , CONVERT(VARCHAR, ISNULL(dev.[Order_Number], 0))                                          'Order_Number'
         , (CASE
                WHEN dev.IsCollect = 1 THEN
                    'true'
                ELSE
                    'false'
            END
           )                                                                                        'Collected'
         , COALESCE(CONVERT(VARCHAR, dev.PriceShippment), '0.00')                                   'Price'
         , COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0')         'IdCustomer'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    CONVERT(VARCHAR, COALESCE(tws.HeaderCode, AlterOrigin.HeaderCode, ''))
                ELSE
                    CONVERT(VARCHAR, COALESCE(tws2.HeaderCode, AlterDestiny.HeaderCode, ''))
            END
           )                                                                                        'HeaderCodeTownship_FA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    NAME_FA.NAME_FA
                ELSE
                    NAME_TA.NAME_TA
            END
           )                                                                                        'name_FA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    CONVERT(VARCHAR, COALESCE(rgu.UsrEmail, ''))
                ELSE
                    REPLACE(COALESCE(dev.Receiver_Email, ''), '"', ' ')
            END
           )                                                                                        'email_FA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    REPLACE(CONVERT(VARCHAR, COALESCE(dev.Sender_Phone, '')), '"', ' ')
                ELSE
                    REPLACE(COALESCE(dev.Receiver_Phone, ''), '"', ' ')
            END
           )                                                                                        'phone_FA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    ADDRES1_FA.ADDRES1_FA
                ELSE
                    REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Address, ''), 'json'), '"', ' ')
            END
           )                                                                                        'address1_FA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    REPLACE(dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json'), '"', ' ')
                ELSE
                    REPLACE(dbo.fnt_String_Escape(COALESCE(LOWER(dev.IndicationsToSendDestination), ''), 'json'), '"', ' ')
            END
           )                                                                                        'address2_FA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    COALESCE(ctm.Abbreviation, '')
                ELSE
                    ''
            END
           )                                                                                        'city_FA'
         , COALESCE(CONVERT(VARCHAR, ctm.IdCustomer), CONVERT(VARCHAR, vp.CustomerID), '0')         'IdMerchant_FA'
         , CONTACT_FA.CONTACT_FA                                                                    'contact_FA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    CONVERT(VARCHAR, COALESCE(tws2.HeaderCode, AlterDestiny.HeaderCode, ''))
                ELSE
                    CONVERT(VARCHAR, COALESCE(BODEGA.SenderHeaderCode, AlterOrigin.HeaderCode, ''))
            END
           )                                                                                        'HeaderCodeTownship_TA'
         , CONCAT(
                     IIF(
                         ISNULL([dev].[IsLastMileReturn], 0) = 1
                         AND ISNULL([AUX2].[ExpressName], '') <> ''
                       , REPLACE([dbo].[fnt_String_Escape]([AUX2].[ExpressName], 'json'), '"', '') + ' - '
                       , '')
                   , (CASE
                          WHEN dev.IsLastMileReturn <> 1 THEN
                              NAME_TA.NAME_TA
                          ELSE
                              NAME_FA.NAME_FA
                      END
                     )
                 )                                                                                  'name_TA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    REPLACE(COALESCE(dev.Receiver_Email, ''), '"', ' ')
                ELSE
                    CONVERT(VARCHAR, COALESCE(rgu.UsrEmail, ''))
            END
           )                                                                                        'email_TA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    REPLACE(COALESCE(dev.Receiver_Phone, ''), '"', ' ')
                ELSE
                    REPLACE(CONVERT(VARCHAR, COALESCE(BODEGA.SenderPhone, '')), '"', ' ')
            END
           )                                                                                        'phone_TA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Address, ''), 'json'), '"', ' ')
                ELSE
                    ADDRES1_FA.ADDRES1_FA
            END
           )                                                                                        'address1_TA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    REPLACE(dbo.fnt_String_Escape(COALESCE(LOWER(dev.IndicationsToSendDestination), ''), 'json'), '"', ' ')
                ELSE
                    REPLACE(dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json'), '"', ' ')
            END
           )                                                                                        'address2_TA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    ''
                ELSE
                    COALESCE(ctm.Abbreviation, '')
            END
           )                                                                                        'city_TA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    CONVERT(VARCHAR, ISNULL(dev.ReceiverIdSettlement, 0))
                ELSE
                    0
            END
           )                                                                                        'ReceiverIdSettlement_TA'
         , (CASE
                WHEN dev.IsLastMileReturn <> 1 THEN
                    REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Alternant_FullName, ''), 'json'), '"', ' ')
                ELSE
                    CONTACT_FA.CONTACT_FA
            END
           )                                                                                        'contact_TA'

         --PARCELS
         --+ '"' + '},' + '"parcels": [' + COALESCE(@arpieces, '') + ' ] , '
         , CONVERT(VARCHAR, TP.TotalWeight)                                                         'TotalWeight'
         , CONVERT(VARCHAR, TP.TotalValue)                                                          'TotalValue'
         , ISNULL(ccy.CodeISO, 'GTQ')                                                               'Currency'
         , CONVERT(VARCHAR, CAST(ISNULL(dev.InsuranceAmount, 0) AS MONEY))                          'ProductInsuranceAmount'
         , CONVERT(VARCHAR, @CountryThatConsults)                                                   'InsuranceCurrency'
         , CONVERT(VARCHAR, COALESCE(dev.Sender_ID, 0))                                             'CodeOfReference'
         , CONVERT(VARCHAR, COALESCE(dev.Receiver_ID, 0))                                           'CodeOfReferenceDestiny'
         , CONVERT(VARCHAR, COALESCE(dev.Sender_Internal_Code, ''))                                 'IdInternalOrderRef'
         , ISNULL(dev.IndicationsToSendDestination, '')                                             'Service_Ref1'
         , dbo.fnt_String_Escape(CONVERT(VARCHAR, COALESCE(dev.OrderUserCreated, '')), 'json')      'Username'
         , CONVERT(VARCHAR, COALESCE(DATEADD(DAY, @DaysToExpiration, dev.DateCreated), ''), 103)    'ExpirationDate'
         , ''                                                                                       'Route'
         , dbo.fnt_String_Escape(COALESCE(dev.TypeService, 'EXP'), 'json')                          'TypeService'
         , COALESCE(CPT.TimePlaName, '')                                                            'Service_Payment'
         , (CASE
                WHEN dev.IsInsuarance = 1 THEN
                    'true'
                ELSE
                    'false'
            END
           )                                                                                        'IsInsurance'
         , (CASE
                WHEN dev.IsReturn = 1 THEN
                    'true'
                ELSE
                    'false'
            END
           )                                                                                        'IsReturn'
         , CONVERT(   VARCHAR
                    , (CASE
                           WHEN ISNULL(dev.VisitpointClientPortfolioId, 0) > 0 THEN
                               dev.VisitpointClientPortfolioId
                           ELSE
                               0
                       END
                      )
                  )                                                                                 'VisitPointByClientPortfolioId'
         , CONVERT(NVARCHAR, COALESCE(cdo.IdDeliveryOption, 0))                                     'idDeliveryOption'
         , REPLACE(dbo.fnt_String_Escape(COALESCE(cdo.[Name], ''), 'json'), '"', ' ')               'descriptionDelivery'
         , AUX.Impersonate                                                                          'Impersonate'
         , CONVERT(NVARCHAR, COALESCE(dev.SalePipeLineId, 0))                                       'SaleChannel'
         , (CASE
                WHEN dev.Collect_OnDelivery > 0 THEN
                    'true'
                ELSE
                    'false'
            END
           )                                                                                        'COD_CashOnDelivery'
         , CONVERT(VARCHAR, ISNULL(dev.Order_Number, 0))                                            'COD_CreditNumber'
         , COALESCE(CONVERT(VARCHAR, dev.Collect_OnDelivery), '0')                                  'COD_AmmountCashOnDelivery'
         , ISNULL(ccy.CodeISO, 'GTQ')                                                               'COD_CashOnDeliveryCurrency'
         , 'AccountName'                                                                            'COD_BankAccountName'
         , COALESCE(CONVERT(VARCHAR, dcba.DCBA_Bank_Id), '')                                        'COD_BankId'
         , COALESCE(CONVERT(VARCHAR, dcba.DCBA_BankAccountType), '')                                'COD_BankAccountType'
         , COALESCE(CONVERT(VARCHAR, dcba.DCBA_Num_account), '')                                    'COD_BankAccountId'
         , COALESCE(CONVERT(VARCHAR, dcba.DCBA_Identification), '')                                 'COD_Identification'
         --COALESCE(@integrationCost, '') 'Integration',
         , COALESCE(
                       IIF(ISNULL([dev].[IsLastMileReturn], 0) = 1
                        , IIF([dev].[StatusOrderId] = 28, 'R', 'D') 
                        , IIF(ctm.BusinessSegmentID = @IDCatBusinessB2B, 'B', 'E'))
                     , ''
                   )                                                                                'Priority'
         , COALESCE(CONCAT('https://qa.forzadelivery.com/rastreo/', Guide_Serie, Guide_Number), '') 'QRLink'
         , COALESCE(CONVERT(VARCHAR, dev.Pieces_Dry), '')                                           'Pieces_Dry'
         , COALESCE(CONVERT(VARCHAR, dev.Pieces_Cold), '')                                          'Pieces_Cold'
         , (CASE
                WHEN (
                         dev.IsCollect <> 1
                         AND dev.Collect_OnDelivery > 0
                     )
                     OR ctm.Abbreviation IN ( 'IGSS', 'RENAP' ) THEN
                    'D'
                ELSE
                    ''
            END
           )                                                                                        'Icon'
         -- ADICIONES TSE
         , COALESCE(   (CASE
                            WHEN [TSEGuide].[TSECodeRoute] IS NOT NULL THEN
                                UPPER([TSEGuide].[TSECodeRoute])
                            ELSE
                                FORMAT([dev].[DeliveryETA], 'ddMM')
                        END
                       )
                     , ''
                   )                                                                                [DeliveryETA]
         , COALESCE(   (CASE
                            WHEN [TSEGuide].[TSEClusterAbbreviation] IS NOT NULL THEN
                                UPPER([TSEGuide].[TSEClusterAbbreviation])
                            ELSE
                                ''
                        END
                       )
                     , ''
                   )                                                                                [DestinyHub]
         -- FIN ADICIONES
         , COALESCE(   (CASE
                            WHEN ISNULL([dev].[IsCollect], 0) = 1 THEN
                                'COLLECT'
                            WHEN [DOPD].[TimePlaId] = 1 THEN
                                'PREPAGO'
                            WHEN [DOPD].[TimePlaId] = 2 THEN
                                'PICKUP'
                            WHEN [DOPD].[TimePlaId] = 3 THEN
                                'COLLECT'
                            WHEN [DOPD].[TimePlaId] = 4 THEN
                                'CRÉDITO'
                            ELSE
                                'CRÉDITO'
                        END
                       )
                     , ''
                   )                                                                                [WayToPayDescription]
         , COALESCE(   (CASE
                            WHEN [vp].[IdKindOfVPClient] = @FranchiseVisitPointTypeId THEN
                                'CNC'
                            WHEN [vp].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN
                                'EXC'
                            WHEN [vpori].[IdKindOfVPClient] = @ExpressVisitPointTypeId THEN
                                'EXC'
                            WHEN [dev].[CatSystemId] = @IndividualWebSys THEN
                                'WEB'
                            WHEN [dev].[CatSystemId] = @ExpressWebSys THEN
                                'EXC'
                            WHEN [dev].[CatSystemId] = @CorporateWebSys THEN
                                'COR'
                            WHEN [dev].[CatSystemId] = @ParserSys THEN
                                'PAR'
                            WHEN [dev].[CatSystemId] IS NULL THEN
                                'API'
                            ELSE
                                'API'
                        END
                       )
                     , ''
                   )                                                                                [GuideOrigin]
         , dev.ReceiverCountryId
         , IIF(dev.InsuranceAmount > 800 AND dev.IsInsuarance = 1, 1, 0)                            'IsInsured'
         , CASE
               WHEN DOP.PiecePhysicalWeight > 0 THEN
                   IIF(DOP.PiecePhysicalWeight >= DOP.PieceWeight
                     , CAST(ROUND(DOP.PiecePhysicalWeight, 0) AS INT)
                     , CAST(ROUND(DOP.PieceWeight, 0) AS INT))
               ELSE
                   CAST(ROUND(RH.AdditionalWeightRate, 0) AS INT)
           END                                                                                      'WeightLB'
         , CAST(ROUND(RH.WeightLimit, 0) AS INT)                                                    AS 'WeightOf'
         , (CASE
                WHEN ISNULL(dev.IsLastMileReturn, 0) = 1 THEN
                    ISNULL(BODEGA.SenderRouteCode, '')
                ELSE
                    ISNULL(DSC.RouteCode, '')
            END
           )                                                                                        AS 'Route_Code'
         , ISNULL(DPF.dpf_SAPcardCode, '')                                                          AS 'CardCode'
         , dev.IndicationsToSendDestination
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]                   dev WITH (NOLOCK)
        LEFT JOIN [DeliveryBackOffice].[dbo].[Cost]                   cst WITH (NOLOCK)
            ON cst.GuideSerie = dev.Guide_Serie
               AND cst.GuideNumber = dev.Guide_Number
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]         ccy WITH (NOLOCK)
            ON cst.ShippingCurrency = ccy.IdCatCurrencyCOD
        INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]      vp WITH (NOLOCK)
            ON vp.CodeOfReference = dev.Sender_ID
        LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpori WITH (NOLOCK)
            ON [vpori].[CodeOfReference] = [dev].[OriginSenderId]
        LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]               ctm WITH (NOLOCK)
            ON ctm.IdCustomer = dev.IdCustomer
        OUTER APPLY
    (
        SELECT TOP 1
               acc1.AccIdAccount
        FROM [DeliveryBackOffice].[dbo].[Account] acc1 WITH (NOLOCK)
        WHERE acc1.IdCustomer = ctm.IdCustomer
    )                                                           acc
        LEFT JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount]          rbu WITH (NOLOCK)
            ON rbu.RuaIdAccount = acc.AccIdAccount
        LEFT JOIN [DeliveryBackOffice].[dbo].[RegisterUser]                rgu WITH (NOLOCK)
            ON rgu.UsrIdUser = rbu.RuaIdUser
        LEFT JOIN [DeliveryBackOffice].[dbo].[Person]                      prs WITH (NOLOCK)
            ON prs.PerIdPerson = rgu.UsrIdPerson
        LEFT JOIN [DeliveryBackOffice].[dbo].[Township]                    tws WITH (NOLOCK)
            ON tws.IdTownship = dev.SenderIdTownship
        LEFT JOIN [DeliveryBackOffice].[dbo].[Township]                    tws2 WITH (NOLOCK)
            ON tws2.IdTownship = dev.ReceiverIdTownship
        LEFT JOIN [DeliveryBackOffice].[dbo].[Province]                    p WITH (NOLOCK)
            ON p.IdProvince = tws.IdProvince
        LEFT JOIN [DeliveryBackOffice].[dbo].[Province]                    p2 WITH (NOLOCK)
            ON p2.IdProvince = tws2.IdProvince
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] dcba WITH (NOLOCK)
            ON dcba.DCBA_Id = dev.DCBA_ID
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatDeliveryOptions]          cdo WITH (NOLOCK)
            ON dev.IdDeliveryOption = cdo.IdDeliveryOption
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]                         DOP WITH (NOLOCK)
            ON DOP.GuideSerie = dev.Guide_Serie
               AND DOP.GuideNumber = dev.Guide_Number
        LEFT JOIN [DeliveryBackOffice].[dbo].[del_ParametrosFactura]                      DPF WITH (NOLOCK)
            ON dev.[OriginSenderId] = DPF.dpf_VpCodeOfReference
        LEFT JOIN [DeliveryBackOffice].[dbo].[DumpServiceCoverage]                                DSC WITH (NOLOCK)
            ON DSC.IdSettlement = dev.ReceiverIdSettlement
        LEFT JOIN [DeliveryBackOffice].[dbo].[DumpServiceCoverage]                                DSC2 WITH (NOLOCK)
            ON DSC2.IdSettlement = dev.SenderIdSettlement
       OUTER APPLY
       (
       SELECT TOP 1 * FROM [DeliveryBackOffice].[dbo].[RatebyCustomer]                                 RC WITH (NOLOCK)
            WHERE dev.IdCustomer = RC.RbcIdCustomer
               AND RbcRowStatus = 1
               AND
               (
                   dev.Sender_ID = RC.RbcCodeOfReference
                   OR RC.RbcCodeOfReference IS NULL
               )
       )RC
        LEFT JOIN dbo.RateHeader                                     RH WITH (NOLOCK)
            ON RC.RbcIdRate = RH.RheId
        OUTER APPLY
    (
        SELECT TOP (1)
               [HL].[HubAbbreviation]
        FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]    DSCDesAux WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH (NOLOCK)
                ON [DSCDesAux].[Hub] = [HL].[HubAbbreviation]
        WHERE [DSCDesAux].[HeaderCode] = [tws2].[HeaderCode]
        ORDER BY [DSCDesAux].[Hub] DESC
    )                                                                DestinyCov
        OUTER APPLY
    (
        SELECT TOP 1
               cov2.RouteCode
             , cov2.RowStatus
        FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage] cov2 WITH (NOLOCK)
        WHERE cov2.HeaderCode = tws2.HeaderCode
    ) cov
        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
            ON DOPD.GuideSerie = dev.Guide_Serie
               AND DOPD.GuideNumber = dev.Guide_Number
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatPaymentTime]             CPT WITH (NOLOCK)
            ON DOPD.TimePlaId = CPT.TimePlaId
               AND cov.RowStatus = 1
        OUTER APPLY
    (
        SELECT CASE
                   WHEN dev.SalePipeLineId = 3
                        AND
                        (
                            ctm.IdCustomerType = 1
                            OR ctm.IdCustomerType = 3
                        ) THEN
                       'TRUE'
                   ELSE
                       'FALSE'
               END 'Impersonate'
    )                                                               AUX
        OUTER APPLY
    (
        SELECT CASE
                   WHEN AUX.Impersonate = 'TRUE' THEN
                       IIF(vpc.CodeOfReference = 0, '', vpc.DescriptionOfClient)
                   WHEN
                   (
                       dev.SalePipeLineId = 3
                       OR dev.SalePipeLineId = 4
                   ) THEN
                       IIF(vpc2.CodeOfReference = 0, '', vpc2.DescriptionOfClient)
                   ELSE
                       ''
               END 'ExpressName'
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]             do WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = do.OriginSenderId
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc2 WITH (NOLOCK)
                ON vpc2.CodeOfReference = do.OriginSenderId
        WHERE Guide_Serie = dev.Guide_Serie
              AND Guide_Number = dev.Guide_Number 
    ) AUX2
    OUTER APPLY(
    SELECT 
             ISNULL(bod.Address, dev.Sender_Address)                 SenderAddress
            ,ISNULL(bod.DescriptionOfClient, dev.Sender_FirstName)  SenderFirstName
            ,ISNULL(bod.DescriptionCC, dev.Sender_LastName)         SenderLastName
            ,ISNULL(bod.Phone, dev.Sender_Phone)                    SenderPhone
            ,ISNULL(twbod.HeaderCode, tw.HeaderCode)                SenderHeaderCode
            ,ISNULL(dscBod.RouteCode, dsc.RouteCode)                SenderRouteCode
    --FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH (NOLOCK)
    FROM [DeliveryBackOffice].[dbo].[VisitPointClient]  vpc WITH (NOLOCK)
        --ON dev.Sender_ID = vpc.CodeOfReference
    INNER JOIN [DeliveryBackOffice].[dbo].[Township] tw WITH (NOLOCK)
        ON dev.SenderIdTownship = tw.IdTownship
    INNER JOIN [DeliveryBackOffice].[dbo].[DumpServiceCoverage] dsc WITH(NOLOCK)
        ON dsc.IdSettlement = dev.SenderIdSettlement
    LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]  bod WITH (NOLOCK)
        ON dev.IdCustomer = bod.CustomerID
        AND bod.isReturnWarehouse = 1
        AND dev.IsLastMileReturn = 1
    LEFT JOIN [DeliveryBackOffice].[dbo].[Township] twbod WITH (NOLOCK)
        ON twbod.IdTownship =  bod.IdTownship
    LEFT JOIN [DeliveryBackOffice].[dbo].[DumpServiceCoverage] dscBod WITH (NOLOCK)
        ON dscBod.IdSettlement = bod.IdSettlement
		WHERE vpc.CodeOfReference = dev.Sender_ID
	) [BODEGA]
        OUTER APPLY
    (
        SELECT TOP 1
               REPLACE(
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
                                                                            COALESCE(BODEGA.SenderFirstName, '')
                                                                        ELSE
                                                                            --INDIVIDUAL
                                                                            COALESCE(dev.Sender_FirstName, '')
                                                                    END
                                                                ELSE
                                                                    -- NO DEVOLUCION
                                                                    CASE
                                                                        WHEN (ctm.IdCustomerType = 1) THEN
                                                                            --CORPORATIVO
                                                                            COALESCE(vp.DescriptionOfClient, '')
                                                                        ELSE
                                                                            --INDIVIDUAL
                                                                            COALESCE(dev.Sender_FirstName, '')
                                                                    END
                                                            END
                                                        ELSE
                                                            --NO IMPERSONADO
                                                            CONVERT(VARCHAR, COALESCE(BODEGA.SenderFirstName, '')) + ' '
                                                            + CONVERT(VARCHAR, COALESCE(BODEGA.SenderLastName, ''))
                                                    END
                                                   )
                                                 , 'json'
                                               )
                        , '"'
                        , ' '
                      ) NAME_FA
    ) NAME_FA
        OUTER APPLY
    (
        SELECT REPLACE(
                          dbo.fnt_String_Escape(
                                                   COALESCE(dev.Receiver_FirstName, '') + ' '
                                                   + COALESCE(dev.Receiver_LastName, '')
                                                 , 'json'
                                               )
                        , '"'
                        , ' '
                      ) NAME_TA
    ) NAME_TA
        OUTER APPLY
    (
        SELECT REPLACE(dbo.fnt_String_Escape(CONVERT(VARCHAR(200), COALESCE(BODEGA.SenderAddress, '')), 'json'), '"', ' ') ADDRES1_FA
    ) ADDRES1_FA
        OUTER APPLY
    (
        SELECT (CASE
                    WHEN [dev].[IsLastMileReturn] = 1 THEN
                        ''
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
               ) CONTACT_FA
    ) CONTACT_FA
        INNER JOIN @TMPPICES TP
            ON TP.GuideSerie = dev.Guide_Serie
               AND TP.GuideNumber = dev.Guide_Number
        OUTER APPLY
    (
        SELECT TOP (1)
               [Twn].[HeaderCode]
        FROM [DeliveryBackOffice].[dbo].[Province]           Prv WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[Township] Twn WITH (NOLOCK)
                ON [Twn].[IdProvince] = [Prv].[IdProvince]
        WHERE
            --[dev].[Sender_Department] = [Prv].[ProvinceName]   
            [dev].[Sender_Department] = [Prv].[ProvinceName]  
            AND [Twn].[HeaderCode] = CONCAT([Prv].[LocalCode], '01')
    )                        AlterOrigin
        OUTER APPLY
    (
        SELECT TOP (1)
               [Twn].[HeaderCode]
        FROM [DeliveryBackOffice].[dbo].[Province]           Prv WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[Township] Twn WITH (NOLOCK)
                ON [Twn].[IdProvince] = [Prv].[IdProvince]
        WHERE
            --[dev].[Receiver_Department] = [Prv].[ProvinceName]   
            [dev].[Receiver_Department] = [Prv].[ProvinceName]  
            AND [Twn].[HeaderCode] = CONCAT([Prv].[LocalCode], '01')
    ) AlterDestiny
        -- ADICIONES TSE
        OUTER APPLY
    (
        SELECT TOP (1)
               CR.[CodeRoute]              [TSECodeRoute]
             , [CRC].[ClusterAbbreviation] [TSEClusterAbbreviation]
        FROM [DeliveryBackOffice].[dbo].[TSERoutePreparationDetail]           TSERPD WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[TSERoutePreparationHeader] TSERPH WITH (NOLOCK)
                ON [TSERPD].[TSERoutePreparationHeaderID] = [TSERPH].[IDTSERoutePreparationHeader]
                   AND [TSERPH].[RowStatus] = 1
            INNER JOIN [DeliveryBackOffice].[dbo].[CatRouteCluster]           CRC WITH (NOLOCK)
                ON [CRC].[IdCatRouteCluster] = [TSERPH].[IdCatRouteCluster]
            INNER JOIN [DeliveryBackOffice].[dbo].[CatRoute]                  CR WITH (NOLOCK)
                ON [TSERPH].[IdCatRoute] = [CR].[IdRoute]
        WHERE [TSERPD].[GuideSerie] = [dev].[Guide_Serie]
              AND [TSERPD].[GuideNumber] = [dev].[Guide_Number]
              AND [TSERPD].[RowStatus] = 1
              AND [TSERPH].[RowStatus] = 1
    ) [TSEGuide];
-- FIN ADICIONES
END;