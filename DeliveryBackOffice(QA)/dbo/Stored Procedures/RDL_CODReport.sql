-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <2021-08-29>
-- Description:	<Reporte completo de COD>
-- =============================================
--EXEC [RDL_CODReport] @StartDate = '2022-02-01',@EndDate='2022-02-24'
CREATE PROCEDURE [dbo].[RDL_CODReport]
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
	IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL DROP TABLE #TransactionFAC1;

    CREATE TABLE #TransactionFAC1
    (
        GuideSerie NVARCHAR(2) NOT NULL,
        OrderNumber BIGINT NOT NULL,
        IdTransaction BIGINT NULL,
        CardNumber NVARCHAR(50) NULL,
        Currency INT NULL,
        Ammount DECIMAL(18, 2) NULL,
        [Signature] NVARCHAR(100) NULL,
        ReasonDescription NVARCHAR(100) NULL
    );

    CREATE NONCLUSTERED INDEX tempTransactionFAC1
    ON #TransactionFAC1 (
                            GuideSerie,
                            OrderNumber
                        );

    --IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL
    --DROP TABLE #TransactionFAC1;
    --Transacciones bancarias
    INSERT INTO #TransactionFAC1
    SELECT GuideSerie,
           OrderNumber,
           IdTransaction,
           CardNumber,
           Currency,
           Ammount,
           Signature,
           ReasonDescription
    --INTO #TransactionFAC1
    FROM
    (
        SELECT 'FD' GuideSerie,
               SUBSTRING(OrderNumber, 3, LEN(OrderNumber)) OrderNumber,
               cbc.IdTransaction,
               cbc.CardNumber,
               cbc.Currency,
               cbc.Ammount,
               cbc.Signature,
               cbc.ReasonDescription
        FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer cbc WITH (NOLOCK)
        WHERE SUBSTRING(OrderNumber, 0, 3) = 'FD'
              AND cbc.ReasonCode = 1
        UNION
        SELECT DOP.GuideSerie,
               DOP.GuideNumber,
               CBC.IdTransaction,
               CBC.CardNumber,
               CBC.Currency,
               CBC.Ammount,
               CBC.Signature,
               CBC.ReasonDescription
        FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer CBC WITH (NOLOCK)
            JOIN DeliveryBackOffice.dbo.SchedulePickup SCP WITH (NOLOCK)
                JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                    ON DOP.IdHeaderRecolection = SCP.SchedulePickupId
                ON CBC.OrderNumber = SCP.TransaccionFAC
        WHERE SUBSTRING(CBC.OrderNumber, 0, 3) = 'HR'
              AND CBC.ReasonCode = 1
    ) CBC;

	
	
    SELECT 
	DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía'
	,
	STO.OrderDescription 'Último estado'
	,
           IIF(KVP.IdKindOfVPClient = 3,
               'Concesionario',
               IIF(ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 2,
                   KVP.KindOfVPName,
                   IIF(ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 3,
                       'Portal Web',
                       IIF(ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 1,
                           IIF(DOR.IdCustomer IS NULL,
                               'Parser',
                               IIF(
                                  (
                                      SELECT COUNT(1)
                                      FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
                                      WHERE ec.IdCustomer = DOR.IdCustomer
                                  ) > 0,
                                  'API',
                                  'Parser')),
                           'Parser')))) 'Origen de guía',
		   (
				CASE
					WHEN ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 2 AND KVP.IdKindOfVPClient <> 3 THEN VPC.DescriptionOfClient
					ELSE NULL
				END
		   ) 'Tienda',
		   CTOB.TypeOfBusinessName 'Canal de negocio',
           DOR.PriceShippment 'Monto envío',
           IIF(INH.inv_cli_nit IS NULL,
               'NO', 'SI') 'Facturado',
		   IIF(INH.IsManualInvoice IS NULL,'Factura Hermes',IIF(INH.IsManualInvoice = 1,'Factura manual','Factura Hermes')) 'Tipo de factura',

           IIF(CTS.SysIdSystem = 1, --Hermes Web
               IIF(CTT.IdCustomerType = 2,
                   KVP.KindOfVPName, --Necesito diferenciar entre individual y express center
                   IIF(CTT.IdCustomerType = 3, 'Portal Web', '')),
               CTS.SysNameSystem) 'Plataforma facturó',
           INH.inv_amount 'Monto factura',
           IIF(CTS.SysIdSystem = 1, --Hermes Web
               IIF(CTT.IdCustomerType = 2,
                   TypeInOut.tio_pk_name, --Express Center 
                   IIF(CTT.IdCustomerType = 3, CTO.tio_pk_name, '' --Individual tome de costdetail
                   )),
               IIF(CTS.SysIdSystem = 3, TypeInOut.tio_pk_name, IIF(CTS.SysIdSystem = 5, TypeInOut.tio_pk_name, ''))) 'Método de pago',
           IIF(
               CTS.SysIdSystem <> 3
               AND CTT.IdCustomerType = 2
               AND INH.inv_descriptionFEL IS NOT NULL,
               'En Recepcion del paquete', --Redistribuidor
               IIF(
                   CTS.SysIdSystem <> 3
                   AND CTT.IdCustomerType = 3
                   AND INH.inv_descriptionFEL IS NOT NULL,
                   'En la creación de la guía', --Individual    
                   IIF(
                       CTS.SysIdSystem = 3
                       AND DOR.IsCollect = 0
                       AND INH.inv_descriptionFEL IS NOT NULL,
                       'En la recolección del paquete', --Courierapp
                       IIF(
                           CTS.SysIdSystem = 3
                           AND DOR.IsCollect = 1
                           AND INH.inv_descriptionFEL IS NOT NULL,
                           'En la entrega del paquete',
                           '' --Courierapp	  
                       )))) 'Momento de cobro',
           --(
           --    SELECT TOP 1
           --           COALESCE(SER.First_Name, '') + ' ' + COALESCE(SER.Last_Name, '')
           --    FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
           --        JOIN DeliveryBackOffice.dbo.LogTokenPOD LTP WITH (NOLOCK)
           --            ON LTP.LogTokenPOD = DOD.UserCreated
           --        JOIN DeliveryBackOffice.dbo.SenderReceiver SER WITH (NOLOCK)
           --            ON SER.ID = LTP.IdCourierman
           --    WHERE DOD.StatusOrderId = 2 --Recolectado		
           --          AND DOD.Guide_Serie = DOR.Guide_Serie
           --          AND DOD.Guide_Number = DOR.Guide_Number
           --    ORDER BY DOD.DateCreated DESC
           --) 'Courierman recolección',
           --(
           --    SELECT TOP 1
           --           COALESCE(SER.First_Name, '') + ' ' + COALESCE(SER.Last_Name, '')
           --    FROM DeliveryBackOffice.dbo.DeliveryAttempt DAT WITH (NOLOCK)
           --        JOIN DeliveryBackOffice.dbo.SenderReceiver SER WITH (NOLOCK)
           --            ON SER.ID = DAT.ID_Courier
           --    WHERE DAT.Guide_Serie = DOR.Guide_Serie
           --          AND DAT.Guide_Number = DOR.Guide_Number
           --    ORDER BY DAT.Date_Created DESC
           --) 'Courierman entrega',
           INH.inv_cli_nit 'Nit',
           INH.inv_cli_name 'Facturado a nombre de 1',
		   
           COALESCE(
           (
               SELECT TOP 1
                      'SI'
               FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
               WHERE DOD.Guide_Serie = DOR.Guide_Serie
                     AND DOD.Guide_Number = DOR.Guide_Number
                     AND DOD.StatusOrderId IN ( 5, 22 ) --Entregado, Entregado en Express Center
           ),
           'NO'
                   ) 'Confirmación entrega',
           COALESCE(
           (
               SELECT TOP 1

                   ---
                      (
                          SELECT TOP 1
                                 IIF(tbl1.MaxDeliveryDate IS NULL, 'SI', 'NO')
                          FROM
                          (
                              SELECT MAX(DOD.DateCreated) MaxDeliveryDate,
                                     DOD.Guide_Number
                              FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
                              WHERE DOD.Guide_Serie = DOR.Guide_Serie
                                    AND DOD.Guide_Number = DOR.Guide_Number
                                    AND DOD.StatusOrderId IN ( 5, 22 ) --traer la última entrega
                              GROUP BY DOD.Guide_Number
                          --y sobre esa fecha buscar si hay un retornado a forza
                          ) tbl1
                              JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD3
                                  ON DOD3.Guide_Number = tbl1.Guide_Number
                                     AND DOD3.StatusOrderId = 8 --retornado a forza
                                     AND DOD3.DateCreatedInSystem > tbl1.MaxDeliveryDate
                      )
               FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
               WHERE DOD.Guide_Serie = DOR.Guide_Serie
                     AND DOD.Guide_Number = DOR.Guide_Number
                     AND DOD.StatusOrderId IN ( 5, 22 ) --Entregado
           ),
           COALESCE(
           (
               SELECT TOP 1
                      'SI'
               FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
               WHERE DOD.Guide_Serie = DOR.Guide_Serie
                     AND DOD.Guide_Number = DOR.Guide_Number
                     AND DOD.StatusOrderId IN ( 5, 22 ) --Entregado, Entregado en EXC
           ),
           'NO'
                   )
                   ) 'Confirmación liquidación',
           IIF(
              (
                  SELECT TOP 1
                         DOS.Guides_Received_COD
                  FROM DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
                      JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS WITH (NOLOCK)
                          ON DSD.ID_DeliveryOrderBySettlement = DOS.ID
                  WHERE DOR.Guide_Number = DOR.Guide_Number
                        AND DOR.Guide_Serie = DOR.Guide_Serie
              ) = 1,
              'SI',
              'NO') 'Confirmación liquidación COD',
           BatchCODId 'Confirmación Lote COD',
           DOP.Deposit_Number '# Referencia Banco',
           HB.HUB 'Hub destino',
           DOR.Receiver_Department 'Departamento Destino',
           DOR.Receiver_Town 'Municipio Destino',
           COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '') 'Destinatario',
           DOR.Collect_OnDelivery 'Monto COD',
           INH.inv_numberFEL 'No. factura',
           INH.inv_SAPDocEntry 'Confirmación carga SAP',
           '' 'Cardcode Cliente',
           '' 'Cardcode Proveedor',
           DOR.Sender_ID 'Id remitente',
           COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '') 'Remitente',
           DOR.Sender_Mail 'Correo remitente',
           DCBA.DCBA_Num_account '# Cuenta Bancaria',
           DCBA.DCBA_BankAccountType 'Tipo de cuenta',
           DBA.Name 'Banco',
           DCBA.DCBA_Nom_account 'Nombre de cuenta',
           (
               SELECT MAX(DOD4.DateCreated)
               FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
               WHERE DOD4.Guide_Serie = DOR.Guide_Serie
                     AND DOD4.Guide_Number = DOR.Guide_Number
                     AND DOD4.StatusOrderId IN ( 5, 22 )
           ) 'Fecha de entrega',
           (
               SELECT MAX(DOS2.Date_Received_COD)
               FROM DeliveryBackOffice.dbo.DeliverySettlementDetail DSD2 WITH (NOLOCK)
                   JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS2 WITH (NOLOCK)
                       ON DOS2.ID = DSD2.ID_DeliveryOrderBySettlement
               WHERE DSD2.Guide_Serie = DOR.Guide_Serie
                     AND DSD2.Guide_Number = DOR.Guide_Number
           ) 'Fecha de liquidación COD',
           (
               SELECT MAX(DOP.DateCreated)
               FROM DeliveryBackOffice.dbo.DeliveryOrderPaid DOP WITH (NOLOCK)
               WHERE DOP.Guide_Serie = DOR.Guide_Serie
                     AND DOP.Guide_Number = DOR.Guide_Number
                     AND DOP.IdStatus = 1
           ) 'Fecha de pago',
           COALESCE(DOR.Pieces_Dry, 0) + COALESCE(DOR.Pieces_Cold, 0) 'Piezas',
           (IIF(
               (
                   SELECT SUM(   IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
                                     COALESCE(DOP.MassWeight, 1),      --las que no tienen poner 1 libra
                                     COALESCE(DOP.volumetricWeight, 1) --las que no tienen poner 1 libra
                                 )
                             )
                   FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
                   WHERE DOP.GuideSerie = DOR.Guide_Serie
                         AND DOP.GuideNumber = DOR.Guide_Number
               ) IS NOT NULL,
            (
                SELECT SUM(   IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
                                  COALESCE(DOP.MassWeight, 1),      --las que no tienen poner 1 libra
                                  COALESCE(DOP.volumetricWeight, 1) --las que no tienen poner 1 libra
                              )
                          )
                FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
                WHERE DOP.GuideSerie = DOR.Guide_Serie
                      AND DOP.GuideNumber = DOR.Guide_Number
            ),
               COALESCE(DOR.Pieces_Cold, 0) + COALESCE(DOR.Pieces_Dry, 0))
           ) 'Peso total',
           BDC.Commission '% Comisión',
           BDC.Amount 'Monto depositado',
           FAC.IdTransaction 'Id Transacción FAC',
           FAC.ReasonDescription 'Respuesta FAC',
           IIF(DOR.TypeService = 'EXP', 'NDD', ISNULL(DOR.TypeService, 'NDD')) 'Tipo de servicio',
           INH.inv_cli_name 'Facturado a nombre de',
           CTM.SAPCardCode 'Código SAP',
           '' 'Código de Agencia de entrega',
           '' 'Código de Agencia que recibe',
           (
               SELECT STUFF(
                               (
                                   SELECT ISNULL(dps.Detail, 'Caja,')
                                   FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
                                   WHERE dps.GuideSerie = DOR.Guide_Serie
                                         AND dps.GuideNumber = DOR.Guide_Number
                                   --	where us.UsrEmail = @UserName and us.UsrRowStatus = 1 
                                   FOR XML PATH(''), TYPE
                               ).value('.', 'varchar(max)'),
                               1,
                               0,
                               ''
                           )
           ) 'Descripcion del bien transportado',
           
		   --ISNULL(rah.WeightLimit, 0) 'Peso Base',
		   (
		    SELECT TOP 1 ISNULL(TBL.WeightLimit, 0) from
		     (
			 SELECT rah.WeightLimit,RbcCodeOfReference,RbcIdCustomer FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
			 LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
			 ON rah.RheId = rac.RbcIdRate
			 --WHERE rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer)
			 WHERE 
			  (
			  rac.RbcCodeOfReference = VPC.CodeOfReference
			   OR (rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL)			   
			  )
			    AND rac.RbcRowStatus = 1
			 )TBL
				ORDER BY TBL.RbcCodeOfReference desc
				
		   ) 'Peso Base',
           0 'Peso a Facturar',
           --ISNULL(rah.AdditionalWeightRate, 0) 'Tarifa del excedente por libra',
		   (
		    SELECT TOP 1 ISNULL(TBL.AdditionalWeightRate, 0) from
		     (
			 SELECT rah.AdditionalWeightRate,RbcCodeOfReference,RbcIdCustomer FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
			 LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
			 ON rah.RheId = rac.RbcIdRate
			 --WHERE rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer)
			 WHERE 
			  (
			  rac.RbcCodeOfReference = VPC.CodeOfReference
			   OR (rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL)			   
			  )
			    AND rac.RbcRowStatus = 1
			 )TBL
				ORDER BY TBL.RbcCodeOfReference desc
				
		   ) 'Tarifa del excedente por libra',
           0 'Cobro por peso',
           ISNULL(DOR.PriceShippment, 0) 'Tarifa del servicio',
           --dbo.fn_get_segment(DOR.Guide_Serie, DOR.Guide_Number) 'Tipo de tarifa aplicada',
		   DOR.Segment 'Tipo de tarifa aplicada',
           ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',
           'SI' 'Entregado',
           --IIF(DOR.StatusOrderId IN ( 5, 22, 25, 24 ), 'SI', 'NO') 'Entregado',
           DOR.DateCreated 'Fecha de solicitud del servicio',
           IIF(DOR.IsCollect = 1, 'SI', 'NO') 'Collect',
           ISNULL(CTM.Name, CTV.Name) 'Cliente'
		   ,IIF( 
				RTRIM(ISNULL(CTM.TaxIdentificationNumber,'')) <> ''
				,CTM.TaxIdentificationNumber,
				IIF( 
					RTRIM(ISNULL(CTV.TaxIdentificationNumber,'')) <> ''
					,CTV.TaxIdentificationNumber
					,NULL
				)
			) 'NIT Cliente'
		   ,INH.inv_certificationFEL 'Certificación FEL'
		   ,IIF(ISNULL(CTM.ExcludePriceShippingCOD,CTV.ExcludePriceShippingCOD) =1,'SI','NO') 'Exclusión de envio'
		  ,IIF(ISNULL(CTM.ExcludeCommissionCOD,CTV.ExcludeCommissionCOD) =1,'SI','NO') 'Exclusión de comisión'
		  -- INTO ##TempInvoiceReportProdBNHL
		   
    FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
        LEFT JOIN
        (
            SELECT MIN(IND.dti_fk_header) dti_fk_header,
                   IND.dti_fk_orderSerie dti_fk_orderSerie,
                   IND.dti_fk_orderNumber dti_fk_orderNumber,
				   --MAX(INH.inv_date) inv_date,
                   MIN(INH.systemOperation) systemOperation,
                   MIN(INH.inv_pk_id) inv_pk_id,
                   MIN(INH.inv_cli_nit) inv_cli_nit,
                   MIN(INH.inv_amount) inv_amount,
                   MIN(INH.inv_descriptionFEL) inv_descriptionFEL,
                   MIN(INH.inv_cli_name) inv_cli_name,
                   MIN(INH.inv_numberFEL) inv_numberFEL,
                   MIN(INH.inv_SAPDocEntry) inv_SAPDocEntry
				   ,MIN(inh.inv_certificationFEL) inv_certificationFEL
				   ,MAX(IIF(inh.IsManualInvoice IS NULL,0,IIF(INH.IsManualInvoice=1,1,0))) IsManualInvoice
            FROM DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK) --22TEBNHL
                JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
                    ON IND.dti_fk_header = INH.inv_pk_id
                       AND INH.inv_certificationFEL IS NOT NULL
                       AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
                       AND INH.inv_creditNote IS NULL
                       AND INH.inv_motiveCreditNote IS NULL
            GROUP BY IND.dti_fk_orderSerie,
                     IND.dti_fk_orderNumber
        ) INH
            ON INH.dti_fk_orderSerie = DOR.Guide_Serie
               AND INH.dti_fk_orderNumber = DOR.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.CatSystem CTS --22TEBNHL
            ON CTS.SysIdSystem = INH.systemOperation
        LEFT JOIN DeliveryBackOffice.dbo.InOutOfMoneyDetail InOut --22TEBNHL
            ON InOut.io_invoice = INH.inv_pk_id
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney TypeInOut
            ON TypeInOut.tio_pk_id = InOut.io_type
        LEFT JOIN
        (
            SELECT ProductNumber,
                   CST.IdProduct,
                   MIN(CST.IdCost) IdCost
            FROM DeliveryBackOffice.dbo.Cost CST WITH (NOLOCK) --REGISTROS REPETIDOS
            GROUP BY ProductNumber,
                     IdProduct
        ) CST
            ON CST.IdProduct = 1 --Pendiente cuando el pago se hizo en recolecciones 
               AND CST.ProductNumber = DOR.Guide_Serie + CAST(DOR.Guide_Number AS CHAR)
        LEFT JOIN
        (
            SELECT CSD.IdCost,
                   MIN(CSD.IdTypeOfMoney) IdTypeOfMoney,
                   MIN(CSD.IdCostDetail) IdCostDetail
            FROM DeliveryBackOffice.dbo.CostDetail CSD WITH (NOLOCK) --25TEBNHL
            GROUP BY CSD.IdCost
        ) CSD
            ON CST.IdCost = CSD.IdCost
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney CTO
            ON CTO.tio_pk_id = CSD.IdTypeOfMoney
        LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
            ON VPC.CodeOfReference = DOR.Sender_ID
        LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient KVP
            ON KVP.IdKindOfVPClient = VPC.IdKindOfVPClient
        LEFT JOIN DeliveryBackOffice.dbo.Customer CTM
            ON CTM.IdCustomer = DOR.IdCustomer
        LEFT JOIN DeliveryBackOffice.dbo.Customer CTV
            ON CTV.IdCustomer = VPC.CustomerID
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeOfBusiness] CTOB
			ON ISNULL(CTV.TypeOfBusinessID, CTM.TypeOfBusinessID) = CTOB.IdTypeOfBusiness
        LEFT JOIN DeliveryBackOffice.dbo.CustomerType CTT
            ON CTT.IdCustomerType = CTM.IdCustomerType --45STEBNHL
        LEFT JOIN #TransactionFAC1 FAC
            ON FAC.GuideSerie = DOR.Guide_Serie
               AND FAC.OrderNumber = DOR.Guide_Number
        LEFT JOIN
        (
            SELECT BDT.BatchCODId,
                   BDT.GuideSerie,
                   BDT.GuideNumber,
                   BDT.Commission,
                   BDT.Amount
            FROM DeliveryBackOffice.dbo.BatchDetailCOD BDT WITH (NOLOCK)
            WHERE BDT.CatConceptCODId = 2
        ) BDC
            ON BDC.GuideSerie = DOR.Guide_Serie
               AND BDC.GuideNumber = DOR.Guide_Number
        LEFT JOIN
        (
            SELECT DPA.Guide_Serie,
                   DPA.Guide_Number,
                   MIN(DPA.Deposit_Number) Deposit_Number
            FROM DeliveryBackOffice.dbo.DeliveryOrderPaid DPA WITH (NOLOCK)
            WHERE DPA.IdStatus = 1
            GROUP BY DPA.Guide_Serie,
                     DPA.Guide_Number
        ) DOP
            ON DOP.Guide_Serie = DOR.Guide_Serie
               AND DOP.Guide_Number = DOR.Guide_Number
        LEFT JOIN dbo.Township TONW WITH (NOLOCK)
            ON TONW.IdTownship = DOR.ReceiverIdTownship
        LEFT JOIN dbo.Township TWN WITH (NOLOCK)
            ON TWN.TownshipName = DOR.Receiver_Town ----26TEBNHL
        LEFT JOIN
        (
            SELECT CV.HeaderCode,
                   MAX(CV.Hub) HUB
            FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
            GROUP BY CV.HeaderCode
        ) HB
            ON HB.HeaderCode = ISNULL(TONW.HeaderCode, TWN.HeaderCode)
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount DCBA WITH (NOLOCK)
            ON DCBA.DCBA_Id = DOR.DCBA_ID
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank DBA WITH (NOLOCK)
            ON DBA.Id_bank = DCBA.DCBA_Bank_Id
               AND DBA.Id_country = 'GT'
               AND DBA.Id_status = 1
		LEFT JOIN DeliveryBackOffice.dbo.StatusOrder STO ON STO.StatusOrderId = DOR.StatusOrderId
        --LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)
        --    ON rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer)
        --       AND rac.RbcRowStatus = 1
        --LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
        --    ON rah.RheId = rac.RbcIdRate
    WHERE EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
        WHERE DOD.Guide_Serie = DOR.Guide_Serie
              AND DOD.Guide_Number = DOR.Guide_Number
              AND DOD.StatusOrderId = 11
              AND CAST(DOD.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
              AND CAST(DOD.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
    )
	--AND DOR.StatusOrderId <> 7 --NO MOSTRAR ANULADOS
	/*AND
	INH.inv_date >= @StartDate
	AND
	INH.inv_date <= @EndDate
	AND
	INH.IsManualInvoice = 1; */

	IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL DROP TABLE #TransactionFAC1;
END;
