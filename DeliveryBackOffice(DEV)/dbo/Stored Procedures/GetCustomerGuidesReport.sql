
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-06-30>
-- Description:	< Reporte general de guías por rango de fechas >
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-07-22>
-- Description: <Se agregan los valores de moneda de pago y moneda de COD para el reporte en corporativo>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerGuidesReport]
    @AccountId INT
  , @DateStart DATETIME = NULL
  , @DateFinish DATETIME = NULL
AS
BEGIN

DECLARE @AccountIdParam INT =@AccountId
DECLARE @DateStartParam DATETIME = @DateStart
DECLARE @DateFinishParam DATETIME = @DateFinish

    -- Si alguna fecha esta vacia tomar mes actual
    IF (@DateStartParam IS NULL OR @DateFinishParam IS NULL)
    BEGIN

        SELECT @DateStartParam  = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)
             , @DateFinishParam = DATEADD(MILLISECOND, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0));

    END;

    -- Variables de control de flujo
    DECLARE @CustomerId INT = NULL;
    DECLARE @CustomerTypeId INT = NULL;
    DECLARE @VisitPointByAccount INT = NULL;

    -- Tabla de Hubs por Codigo de cabecera
    IF OBJECT_ID('tempdb.dbo.#HubsByHeaderCode', 'U') IS NOT NULL
        DROP TABLE #HubsByHeaderCode;

    SELECT DSC.HeaderCode
         , MAX(DSC.Hub) 'Hub'
    INTO #HubsByHeaderCode
    FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH (NOLOCK)
    WHERE DSC.RowStatus = 1
    GROUP BY DSC.HeaderCode;

    -- Obtener datos de usuario
    SELECT @CustomerId          = Cu.IdCustomer
         , @CustomerTypeId      = Cu.IdCustomerType
         , @VisitPointByAccount = VPC.CodeOfReference
    FROM [DeliveryBackOffice].[dbo].[Account]                     Acc WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[Customer]          Cu WITH (NOLOCK)
            ON Acc.IdCustomer = Cu.IdCustomer
        LEFT JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH (NOLOCK)
            ON RBUBA.RuaIdAccount = Acc.AccIdAccount
               AND RBUBA.RuaRowStatus = 1
        LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointByUser]   VPBU WITH (NOLOCK)
            ON RBUBA.RuaIdUser = VPBU.RegisterUserID
               AND VPBU.RowStatus = 1
        LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]   VPC WITH (NOLOCK)
            ON VPBU.IdVisitPointClient = VPC.IdVisitPointClient
               AND VPC.StatusClient = 1
    WHERE Acc.AccIdAccount = @AccountIdParam
          AND Acc.AccRowStatus = 1
          AND ISNULL(Cu.RowSatus, 1) = 1;

    IF (@CustomerTypeId = 3) -- INDIVIDUAL - cliente
    BEGIN

        SELECT LTRIM(RTRIM(IIF(VPC.DescriptionOfClient IS NULL
                               , ''
                               , CONCAT(VPC.CodeOfReference, ' - ', VPC.DescriptionOfClient))
                          )
                    )                                                             'Punto de origen'
             , LTRIM(RTRIM(CONCAT(DO.Sender_FirstName, ' ', DO.Sender_LastName))) 'Remitente'
             , CONCAT(DO.Manifest_Serie, DO.Manifest_Number)                      'Manifiesto'
             , CONCAT(DO.Guide_Serie, DO.Guide_Number)                            'Guía'
             , SO.OrderDescription                                                'Estado'
             , (ISNULL(DO.Pieces_Dry, 0) + ISNULL(DO.Pieces_Cold, 0))             'Piezas'
             , ISNULL(CPT.PayTypeName, '')                                        'Tipo de pago'
             , ISNULL(C2.Symbol, ISNULL(C1.Symbol, 'Q'))						  'Moneda de envio'
             , DO.PriceShippment                                                  'Monto de envío'
			 , ISNULL(C1.Symbol, ISNULL(C2.Symbol, 'Q'))						  'Moneda de CoD'
             , DO.Collect_OnDelivery                                              'Monto de CoD'
             , ISNULL(DO.Ticket_Number, '')                                       'Referencia'
             , DO.Sender_Department                                               'Departamento origen'
             , DO.Sender_Town                                                     'Municipio origen'
             , DO.DateCreated                                                     'Fecha de creación'
             , ISNULL((
                          SELECT TOP 1
                                 DODrec.DateCreated
                          FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DODrec WITH (NOLOCK)
                          WHERE DODrec.Guide_Serie = DO.Guide_Serie
                                AND DODrec.Guide_Number = DO.Guide_Number
                                AND DODrec.StatusOrderId IN ( 2, 21 )
                                AND DODrec.RowStatus = 1
                          ORDER BY DODrec.DateCreated DESC
                      )
                    , NULL
                     )                                                            'Fecha de recolección'
             , ISNULL(DSC.Hub, '')                                                'Hub destino'
             , DO.Receiver_Department                                             'Departamento destino'
             , DO.Receiver_Town                                                   'Municipio destino'
             , CONCAT(DO.Receiver_FirstName, '', DO.Receiver_LastName)            'Destinatario'
             , DO.Receiver_Phone                                                  'Teléfono destinatario'
             , DO.Receiver_Address                                                'Dirección destinatario'
             , ISNULL((
                          SELECT TOP 1
                                 DODdel.DateCreated
                          FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DODdel WITH (NOLOCK)
                          WHERE DODdel.Guide_Serie = DO.Guide_Serie
                                AND DODdel.Guide_Number = DO.Guide_Number
                                AND DODdel.StatusOrderId IN ( 5, 22 )
                                AND DODdel.RowStatus = 1
                          ORDER BY DODdel.DateCreated DESC
                      )
                    , NULL
                     )                                                            'Fecha de entrega'
             , ISNULL(DO.NameOfReceiver, '')                                      'Persona que recibe'
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]                       DO WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[Cost]						  C WITH (NOLOCK)
				ON DO.Guide_Serie = C.GuideSerie AND DO.Guide_Number = C.GuideNumber
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						  C1 WITH (NOLOCK)
				ON C.CodCurrency = C1.IdCatCurrencyCOD
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						  C2 WITH (NOLOCK)
				ON C.ShippingCurrency = C2.IdCatCurrencyCOD
            INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]               SO WITH (NOLOCK)
                ON DO.StatusOrderId = SO.StatusOrderId
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]           VPC WITH (NOLOCK)
                ON DO.Sender_ID = VPC.CodeOfReference
                   AND DO.Sender_ID != 0
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
                ON DOPD.GuideSerie = DO.Guide_Serie
                   AND DOPD.GuideNumber = DO.Guide_Number
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatPaymentType]             CPT WITH (NOLOCK)
                ON DOPD.PayTypeId = CPT.PayTypeId
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township]                   TwnId WITH (NOLOCK)
                ON DO.ReceiverIdTownship = TwnId.IdTownship
                OR (DO.ReceiverIdTownship IS NULL AND  DO.Receiver_Town = TwnId.TownshipName)
            LEFT JOIN #HubsByHeaderCode                                       DSC
                ON TwnId.HeaderCode = DSC.HeaderCode
        WHERE DO.DateCreated
              BETWEEN @DateStartParam AND @DateFinishParam
              AND DO.IdCustomer = @CustomerId
        ORDER BY DO.DateCreated DESC;

    END;
    ELSE IF (@CustomerTypeId = 2) -- Redistribuidores - express center - cliente + punto de visita
    BEGIN

        PRINT @VisitPointByAccount;
        PRINT @CustomerId;
        SELECT LTRIM(RTRIM(IIF(VPC.DescriptionOfClient IS NULL
                               , ''
                               , CONCAT(VPC.CodeOfReference, ' - ', VPC.DescriptionOfClient))
                          )
                    )                                                             'Punto de origen'
             , LTRIM(RTRIM(CONCAT(DO.Sender_FirstName, ' ', DO.Sender_LastName))) 'Remitente'
             , CONCAT(DO.Manifest_Serie, DO.Manifest_Number)                      'Manifiesto'
             , CONCAT(DO.Guide_Serie, DO.Guide_Number)                            'Guía'
             , SO.OrderDescription                                                'Estado'
             , (ISNULL(DO.Pieces_Dry, 0) + ISNULL(DO.Pieces_Cold, 0))             'Piezas'
             , ISNULL(CPT.PayTypeName, '')                                        'Tipo de pago'
             , ISNULL(C2.Symbol, ISNULL(C1.Symbol, 'Q'))						  'Moneda de envio'
             , DO.PriceShippment                                                  'Monto de envío'
			 , ISNULL(C1.Symbol, ISNULL(C2.Symbol, 'Q'))						  'Moneda de CoD'
             , DO.Collect_OnDelivery                                              'Monto de CoD'
             , ISNULL(DO.Ticket_Number, '')                                       'Referencia'
             , DO.Sender_Department                                               'Departamento origen'
             , DO.Sender_Town                                                     'Municipio origen'
             , DO.DateCreated                                                     'Fecha de creación'
             , ISNULL((
                          SELECT TOP 1
                                 DODrec.DateCreated
                          FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DODrec WITH (NOLOCK)
                          WHERE DODrec.Guide_Serie = DO.Guide_Serie
                                AND DODrec.Guide_Number = DO.Guide_Number
                                AND DODrec.StatusOrderId IN ( 2, 21 )
                                AND DODrec.RowStatus = 1
                          ORDER BY DODrec.DateCreated DESC
                      )
                    , NULL
                     )                                                            'Fecha de recolección'
             , ISNULL(DSC.Hub, '')                                                'Hub destino'
             , DO.Receiver_Department                                             'Departamento destino'
             , DO.Receiver_Town                                                   'Municipio destino'
             , CONCAT(DO.Receiver_FirstName, '', DO.Receiver_LastName)            'Destinatario'
             , DO.Receiver_Phone                                                  'Teléfono destinatario'
             , DO.Receiver_Address                                                'Dirección destinatario'
             , ISNULL((
                          SELECT TOP 1
                                 DODdel.DateCreated
                          FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DODdel WITH (NOLOCK)
                          WHERE DODdel.Guide_Serie = DO.Guide_Serie
                                AND DODdel.Guide_Number = DO.Guide_Number
                                AND DODdel.StatusOrderId IN ( 5, 22 )
                                AND DODdel.RowStatus = 1
                          ORDER BY DODdel.DateCreated DESC
                      )
                    , NULL
                     )                                                            'Fecha de entrega'
             , ISNULL(DO.NameOfReceiver, '')                                      'Persona que recibe'
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]                       DO WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]               SO WITH (NOLOCK)
                ON DO.StatusOrderId = SO.StatusOrderId
            LEFT JOIN [DeliveryBackOffice].[dbo].[Cost]						  C WITH (NOLOCK)
				ON DO.Guide_Serie = C.GuideSerie AND DO.Guide_Number = C.GuideNumber
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]			  C1 WITH (NOLOCK)
				ON C.CodCurrency = C1.IdCatCurrencyCOD
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]			  C2 WITH (NOLOCK)
				ON C.ShippingCurrency = C2.IdCatCurrencyCOD
           LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]           VPC WITH (NOLOCK)
                ON DO.Sender_ID = VPC.CodeOfReference
                   AND DO.Sender_ID != 0
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
                ON DOPD.GuideSerie = DO.Guide_Serie
                   AND DOPD.GuideNumber = DO.Guide_Number
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatPaymentType]             CPT WITH (NOLOCK)
                ON DOPD.PayTypeId = CPT.PayTypeId
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township]                   TwnId WITH (NOLOCK)
                ON DO.ReceiverIdTownship = TwnId.IdTownship
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township]                   TwnName WITH (NOLOCK)
                ON DO.Receiver_Town = TwnName.TownshipName 
            LEFT JOIN #HubsByHeaderCode                                       DSC
                ON ISNULL(TwnId.HeaderCode, TwnName.HeaderCode) = DSC.HeaderCode
        WHERE DO.DateCreated
              BETWEEN @DateStartParam AND @DateFinishParam
              --AND
              --DO.IdCustomer = @CustomerId
              AND
              (
                  DO.Sender_ID = @VisitPointByAccount
                  OR DO.OriginSenderId = @VisitPointByAccount
              )
        ORDER BY DO.DateCreated DESC;

    END;
    ELSE IF (@CustomerTypeId = 1) -- Corporativos - cliente + punto de visita
    BEGIN
        SELECT LTRIM(RTRIM(IIF(VPC.DescriptionOfClient IS NULL
                               , ''
                               , CONCAT(VPC.CodeOfReference, ' - ', VPC.DescriptionOfClient))
                          )
                    )                                                             'Punto de origen'
             , LTRIM(RTRIM(CONCAT(DO.Sender_FirstName, ' ', DO.Sender_LastName))) 'Remitente'
             , ISNULL((
                          SELECT TOP 1
                                 CONCAT(CM.ManifestSerie, CM.IdManifest)
                          FROM [DeliveryBackOffice].[dbo].[CorporateManifestDetail]     CMD WITH (NOLOCK)
                              INNER JOIN [DeliveryBackOffice].[dbo].[CorporateManifest] CM WITH (NOLOCK)
                                  ON CMD.ManifestId = CM.IdManifest
                          WHERE CMD.GuideSerie = DO.Guide_Serie
                                AND CMD.GuideNumber = DO.Guide_Number
                                AND CMD.RowStatus = 1
                          ORDER BY CMD.DateCreated DESC
                      )
                    , CONCAT(DO.Manifest_Serie, DO.Manifest_Number)
                     )                                                                     'Manifiesto'
             , CONCAT(DO.Guide_Serie, DO.Guide_Number)                                     'Guía'
             , SO.OrderDescription                                                         'Estado'
             , (ISNULL(DO.Pieces_Dry, 0) + ISNULL(DO.Pieces_Cold, 0))                      'Piezas'
             , ISNULL(CPT.PayTypeName, '')                                                 'Tipo de pago'
             , ISNULL(DeliveryBackOffice.dbo.CapitalizeFirstLetter(CCC.[name]) ,'Quetzal') 'Moneda de envío'
             , DO.PriceShippment                                                           'Monto de envío'
             , ISNULL(DeliveryBackOffice.dbo.CapitalizeFirstLetter(CCC.[name]),'Quetzal')  'Moneda de COD'
             , DO.Collect_OnDelivery                                                       'Monto de CoD'
             , ISNULL(DO.Ticket_Number, '')                                                'Referencia'
             , DO.Sender_Department                                                        'Departamento origen'
             , DO.Sender_Town                                                              'Municipio origen'
             , DO.DateCreated                                                              'Fecha de creación'
             , ISNULL((
                          SELECT TOP 1
                                 DODrec.DateCreated
                          FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DODrec WITH (NOLOCK)
                          WHERE DODrec.Guide_Serie = DO.Guide_Serie
                                AND DODrec.Guide_Number = DO.Guide_Number
                                AND DODrec.StatusOrderId IN ( 2, 21 )
                                AND DODrec.RowStatus = 1
                          ORDER BY DODrec.DateCreated DESC
                      )
                    , NULL
                     )                                                            'Fecha de recolección'
             , ISNULL(DSC.Hub, '')                                                'Hub destino'
             , DO.Receiver_Department                                             'Departamento destino'
             , DO.Receiver_Town                                                   'Municipio destino'
             , CONCAT(DO.Receiver_FirstName, '', DO.Receiver_LastName)            'Destinatario'
             , DO.Receiver_Phone                                                  'Teléfono destinatario'
             , DO.Receiver_Address                                                'Dirección destinatario'
             , ISNULL((
                          SELECT TOP 1
                                 DODdel.DateCreated
                          FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DODdel WITH (NOLOCK)
                          WHERE DODdel.Guide_Serie = DO.Guide_Serie
                                AND DODdel.Guide_Number = DO.Guide_Number
                                AND DODdel.StatusOrderId IN ( 5, 22 )
                                AND DODdel.RowStatus = 1
                          ORDER BY DODdel.DateCreated DESC
                      )
                    , NULL
                     )                                                            'Fecha de entrega'
             , ISNULL(DO.NameOfReceiver, '')                                      'Persona que recibe'
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]                       DO WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]               SO WITH (NOLOCK)
                ON DO.StatusOrderId = SO.StatusOrderId
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]           VPC WITH (NOLOCK)
                ON DO.Sender_ID = VPC.CodeOfReference
                   AND DO.Sender_ID != 0
                   AND VPC.StatusClient = 1
            LEFT JOIN [DeliveryBackOffice].[dbo].[Cost]                       C WITH (NOLOCK)
                   ON DO.Guide_Serie = C.GuideSerie 
                  AND DO.Guide_Number = C.GuideNumber
            LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD    CCC WITH(NOLOCK)
                ON CCC.IdCatCurrencyCOD = C.ShippingCurrency 
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
                ON DOPD.GuideSerie = DO.Guide_Serie
                   AND DOPD.GuideNumber = DO.Guide_Number
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatPaymentType]             CPT WITH (NOLOCK)
                ON DOPD.PayTypeId = CPT.PayTypeId
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township]                   TwnId WITH (NOLOCK)
                ON DO.ReceiverIdTownship = TwnId.IdTownship
                OR (DO.ReceiverIdTownship IS NULL AND DO.Receiver_Town = TwnId.TownshipName)
            LEFT JOIN #HubsByHeaderCode                                       DSC
                ON TwnId.HeaderCode = DSC.HeaderCode
        WHERE DO.DateCreated
              BETWEEN @DateStartParam AND @DateFinishParam
              AND DO.IdCustomer = @CustomerId
              AND
              (
                  @VisitPointByAccount IS NULL
                  OR DO.Sender_ID = @VisitPointByAccount
              )
        ORDER BY DO.DateCreated DESC;

    END;

    IF OBJECT_ID('tempdb.dbo.#HubsByHeaderCode', 'U') IS NOT NULL
        DROP TABLE #HubsByHeaderCode;
END;