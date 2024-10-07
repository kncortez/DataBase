-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-04-10>
-- Description:	<Reporte completo de COD>
-- =============================================

CREATE PROCEDURE [dbo].[spRS_CODReport]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
	@IdCountrySender NVARCHAR(2) = 'GT'

AS
BEGIN

	-- Variables globales
	-- Identificadores
	DECLARE @FranchiseKindVisitPoint INT = 
	(
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM 
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Concesionario'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ExpressCenterKindVisitPoint INT = 
	(
		SELECT 
			TOP (1) 
				[KOVPC].[IdKindOfVPClient] 
		FROM 
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ParserSystemId INT =
	(
		SELECT 
			TOP (1)
				[CS].[SysIdSystem] 
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = 'Parser'  COLLATE Latin1_General_CI_AI 
	)

	-- Manejo de fechas
	IF(@EndDate IS NULL)
	BEGIN

		SET @EndDate = DATEADD(DAY,-1,DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))

	END
	ELSE 
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@EndDate AS DATE) AS DATETIME)))

	END

	IF(@StartDate IS NULL)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,0,@EndDate) AS DATE) AS DATETIME)

	END
	ELSE
	BEGIN

		SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)

	END

	IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL 
		DROP TABLE #TransactionFAC1;
	IF OBJECT_ID('tempdb.dbo.#GuideWithArrival', 'U') IS NOT NULL 
		DROP TABLE #GuideWithArrival;

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

    INSERT INTO #TransactionFAC1
    SELECT GuideSerie,
           OrderNumber,
           IdTransaction,
           CardNumber,
           Currency,
           Ammount,
           Signature,
           ReasonDescription
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
              AND 
			  (cbc.ReasonCode = '1'
			  OR cbc.ReasonCode = '01'
			  )
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
            INNER JOIN DeliveryBackOffice.dbo.SchedulePickup SCP WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                    ON DOP.IdHeaderRecolection = SCP.SchedulePickupId
                ON CBC.OrderNumber = SCP.TransaccionFAC
        WHERE SUBSTRING(CBC.OrderNumber, 0, 3) = 'HR'
              AND 
			  (cbc.ReasonCode = '1'
			  OR cbc.ReasonCode = '01'
			  )
    ) CBC;

	CREATE TABLE #GuideWithArrival(
		GuideSerie NVARCHAR(2)
		,GuideNumber INT
	);

	CREATE NONCLUSTERED INDEX TMP_IDX_GuideWithArrival_Guide
	ON #GuideWithArrival ( [GuideSerie],
                            [GuideNumber] )

	INSERT INTO [#GuideWithArrival]
	(
	    [GuideSerie],
	    [GuideNumber]
	)
	SELECT 
		DISTINCT
			[DOD].[Guide_Serie]
			,[DOD].[Guide_Number]
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK) --18TEBNHL
    WHERE 
		[DOD].[StatusOrderId] = 11
		AND
		[DOD].[RowStatus] = 1
		AND
		[DOD].[DateCreated] BETWEEN @StartDate AND @EndDate
		
    SELECT 
		DISTINCT
			DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía'
			,STO.OrderDescription 'Último estado'
			,[DOR].[CatSystemId]
			,(
				CASE
					WHEN [DOR].[CatSystemId] IS NULL THEN 'API'
					WHEN 
					(
						SELECT 
							COUNT(1)
						FROM 
							DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
						WHERE 
							ec.IdCustomer = DOR.IdCustomer
					) > 0 THEN 'API'
					WHEN KVP.IdKindOfVPClient = @FranchiseKindVisitPoint THEN 'Concesionario'
					WHEN KVP.IdKindOfVPClient = @ExpressCenterKindVisitPoint THEN 'Express Center'
					WHEN KVPori.IdKindOfVPClient = @ExpressCenterKindVisitPoint THEN 'Express Center'
					WHEN [DOR].[CatSystemId] = @ParserSystemId THEN 'Parser'
					ELSE 'Portal Web'
				END
			) 'Origen de guía',
			(
			CASE
				-- Origen impersonado desde express center
				WHEN [VPCori].[IdVisitPointClient] IS NOT NULL AND VPCori.IdKindOfVPBusiness = @ExpressCenterKindVisitPoint THEN VPCori.DescriptionOfClient
				-- Origen directo en express center
				WHEN ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 2 AND KVP.IdKindOfVPClient <> @FranchiseKindVisitPoint THEN VPC.DescriptionOfClient
				ELSE NULL
			END
			) 'Tienda',
			CTOB.TypeOfBusinessName 'Canal de negocio',
			DOR.PriceShippment 'Monto envío',
			IIF
			(
				INH.inv_cli_nit IS NULL,
				'NO', 
				'SI'
			) 'Facturado',
			IIF
			(
				INH.IsManualInvoice IS NULL
				,'Factura Hermes'
				,IIF
				(
					INH.IsManualInvoice = 1
					,'Factura manual'
					,'Factura Hermes'
				)
			) 'Tipo de factura',
			IIF
			(
				CTS.SysIdSystem = 1, --Hermes Web
				IIF
				(
					CTT.IdCustomerType = 2,
					KVP.KindOfVPName, --Necesito diferenciar entre individual y express center
					IIF
					(
						CTT.IdCustomerType = 3
						, 'Portal Web'
						, ''
					)
				),
				CTS.SysNameSystem
			) 'Plataforma facturó',
			INH.inv_amount 'Monto factura',
			IIF
			(
				CTS.SysIdSystem = 1, --Hermes Web
				IIF
				(
					CTT.IdCustomerType = 2,
					TypeInOut.tio_pk_name, --Express Center 
					IIF
					(
						CTT.IdCustomerType = 3
						, CTO.tio_pk_name
						, '' --Individual tome de costdetail
					)
				),
				IIF
				(
					CTS.SysIdSystem = 3
					, TypeInOut.tio_pk_name
					, IIF
					(
						CTS.SysIdSystem = 5
						, TypeInOut.tio_pk_name
						, ''
					)
				)
			) 'Método de pago',
			IIF
			(
				CTS.SysIdSystem <> 3
				AND CTT.IdCustomerType = 2
				AND INH.inv_descriptionFEL IS NOT NULL,
				'En Recepcion del paquete', --Redistribuidor
				IIF
				(
					CTS.SysIdSystem <> 3
					AND CTT.IdCustomerType = 3
					AND INH.inv_descriptionFEL IS NOT NULL,
					'En la creación de la guía', --Individual    
					IIF
					(
						CTS.SysIdSystem = 3
						AND DOR.IsCollect = 0
						AND INH.inv_descriptionFEL IS NOT NULL,
						'En la recolección del paquete', --Courierapp
						IIF
						(
							CTS.SysIdSystem = 3
							AND DOR.IsCollect = 1
							AND INH.inv_descriptionFEL IS NOT NULL,
							'En la entrega del paquete',
							'' --Courierapp	  
						)
					)
				)	
			) 'Momento de cobro',
			INH.inv_cli_nit 'Nit',
			INH.inv_cli_name 'Facturado a nombre de 1',
			COALESCE
			(
				(
					SELECT 
						TOP 1
							'SI'
					FROM 
						DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
					WHERE 
						DOD.Guide_Serie = DOR.Guide_Serie
						AND 
						DOD.Guide_Number = DOR.Guide_Number
						AND 
						DOD.StatusOrderId IN ( 5, 22 ) --Entregado, Entregado en Express Center
					ORDER BY
						DOD.[DateCreated] DESC
				),
				'NO'
			) 'Confirmación entrega',
			COALESCE
			(
				(
					SELECT 
						TOP 1
							(
								SELECT 
									TOP 1
										IIF
										(
											tbl1.MaxDeliveryDate IS NULL
											, 'SI'
											, 'NO'
										)
								FROM
									(
										SELECT 
											MAX(DOD.DateCreated) MaxDeliveryDate,
											DOD.Guide_Number
										FROM 
											DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
										WHERE 
											DOD.Guide_Serie = DOR.Guide_Serie
											AND 
											DOD.Guide_Number = DOR.Guide_Number
											AND 
											DOD.StatusOrderId IN ( 5, 22 ) --traer la última entrega
										GROUP BY 
											DOD.Guide_Number
									--y sobre esa fecha buscar si hay un retornado a forza
									) tbl1
									INNER JOIN 
										DeliveryBackOffice.dbo.DeliveryOrderDetail DOD3 WITH(NOLOCK)
										ON 
											DOD3.Guide_Number = tbl1.Guide_Number
											AND 
											DOD3.StatusOrderId = 8 --retornado a forza
											AND 
											DOD3.DateCreatedInSystem > tbl1.MaxDeliveryDate
							)
					FROM 
						DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
					WHERE 
						DOD.Guide_Serie = DOR.Guide_Serie
						AND 
						DOD.Guide_Number = DOR.Guide_Number
						AND 
						DOD.StatusOrderId IN ( 5, 22 ) --Entregado
				),
				COALESCE
				(
					(
						SELECT 
							TOP 1
								'SI'
						FROM 
							DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
						WHERE 
							DOD.Guide_Serie = DOR.Guide_Serie
							AND 
							DOD.Guide_Number = DOR.Guide_Number
							AND 
							DOD.StatusOrderId IN ( 5, 22 ) --Entregado, Entregado en EXC
					),
					'NO'
				)
			) 'Confirmación liquidación',
			IIF
			(
				(
					SELECT 
						TOP 1
							DOS.Guides_Received_COD
					FROM 
						DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
						INNER JOIN 
							DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS WITH (NOLOCK)
							ON 
								DSD.ID_DeliveryOrderBySettlement = DOS.ID
					WHERE 
						DOR.Guide_Number = DOR.Guide_Number
						AND 
						DOR.Guide_Serie = DOR.Guide_Serie
				) = 1,
				'SI',
				'NO'
			) 'Confirmación liquidación COD',
			BatchCODId 'Confirmación Lote COD',
			DOP.Deposit_Number '# Referencia Banco',
           
			HBO.HUB 'Hub origen',
			DOR.Sender_Department 'Departamento Origen',
			DOR.Sender_Town 'Municipio Origen',

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
				SELECT 
					MAX(DOD4.DateCreated)
				FROM 
					DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
				WHERE 
					DOD4.Guide_Serie = DOR.Guide_Serie
					AND 
					DOD4.Guide_Number = DOR.Guide_Number
					AND 
					DOD4.StatusOrderId IN ( 5, 22 )
			) 'Fecha de entrega',
			(
				SELECT 
					MAX(DOS2.Date_Received_COD)
				FROM 
					DeliveryBackOffice.dbo.DeliverySettlementDetail DSD2 WITH (NOLOCK)
					INNER JOIN 
						DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS2 WITH (NOLOCK)
						ON 
							DOS2.ID = DSD2.ID_DeliveryOrderBySettlement
				WHERE 
					DSD2.Guide_Serie = DOR.Guide_Serie
					AND 
					DSD2.Guide_Number = DOR.Guide_Number
			) 'Fecha de liquidación COD',
			(
				SELECT
					MAX(DOP.DateCreated)
				FROM 
					DeliveryBackOffice.dbo.DeliveryOrderPaid DOP WITH (NOLOCK)
				WHERE 
					DOP.Guide_Serie = DOR.Guide_Serie
					AND 
					DOP.Guide_Number = DOR.Guide_Number
					AND 
					DOP.IdStatus = 1
			) 'Fecha de pago',
			COALESCE(DOR.Pieces_Dry, 0) + COALESCE(DOR.Pieces_Cold, 0) 'Piezas',
			(
				IIF
				(
					(
						SELECT 
							SUM
							(
								IIF
								(
									COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
									COALESCE(DOP.MassWeight, 1),      --las que no tienen poner 1 libra
									COALESCE(DOP.volumetricWeight, 1) --las que no tienen poner 1 libra
								)
							)
						FROM 
							DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
						WHERE 
							DOP.GuideSerie = DOR.Guide_Serie
							AND 
							DOP.GuideNumber = DOR.Guide_Number
					) IS NOT NULL,
					(
						SELECT 
						SUM
						(
							IIF
							(
								COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								COALESCE(DOP.MassWeight, 1),      --las que no tienen poner 1 libra
								COALESCE(DOP.volumetricWeight, 1) --las que no tienen poner 1 libra
							)
						)
						FROM 
							DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
						WHERE 
							DOP.GuideSerie = DOR.Guide_Serie
							AND 
							DOP.GuideNumber = DOR.Guide_Number
					),
					COALESCE(DOR.Pieces_Cold, 0) + COALESCE(DOR.Pieces_Dry, 0)
				)
			) 'Peso total',
			BDC.Commission '% Comisión',
			BDC.Amount 'Monto depositado',
			FAC.IdTransaction 'Id Transacción FAC',
			FAC.ReasonDescription 'Respuesta FAC',
			IIF
			(
				DOR.TypeService = 'EXP', 'STD', ISNULL(DOR.TypeService, 'STD')
			) 'Tipo de servicio',
			INH.inv_cli_name 'Facturado a nombre de',
			CTM.SAPCardCode 'Código SAP',
			'' 'Código de Agencia de entrega',
			'' 'Código de Agencia que recibe',
			(
				SELECT 
					STUFF
					(
						(
							SELECT 
								ISNULL(dps.Detail, 'Caja,')
							FROM 
								dbo.DeliveryOrderPiece dps WITH (NOLOCK)
							WHERE 
								dps.GuideSerie = DOR.Guide_Serie
								AND 
								dps.GuideNumber = DOR.Guide_Number
							FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),
						1,
						0,
						''
					)
			) 'Descripcion del bien transportado',
			(
				SELECT 
					TOP 1 
						ISNULL(TBL.WeightLimit, 0) 
				FROM
					(
						SELECT 
							rah.WeightLimit
							,RbcCodeOfReference
							,RbcIdCustomer 
						FROM 
							DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
							LEFT JOIN 
								DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
								ON 
									rah.RheId = rac.RbcIdRate
						WHERE 
						(
							rac.RbcCodeOfReference = VPC.CodeOfReference
							OR 
							(
								rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer) 
								AND 
								rac.RbcCodeOfReference IS NULL
							)			   
						)
						AND rac.RbcRowStatus = 1
					)TBL
				ORDER BY TBL.RbcCodeOfReference desc
			) 'Peso Base',
			0 'Peso a Facturar',
			(
				SELECT 
					TOP 1 
						ISNULL(TBL.AdditionalWeightRate, 0) 
				FROM
					(
						SELECT 
							rah.AdditionalWeightRate
							,RbcCodeOfReference
							,RbcIdCustomer 
						FROM 
							DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
							LEFT JOIN 
								DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
								ON 
									rah.RheId = rac.RbcIdRate
						WHERE 
						(
							rac.RbcCodeOfReference = VPC.CodeOfReference
							OR 
							(
								rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer) 
								AND 
								rac.RbcCodeOfReference IS NULL
							)
						)
						AND rac.RbcRowStatus = 1
					)TBL
				ORDER BY TBL.RbcCodeOfReference desc
			) 'Tarifa del excedente por libra',
			0 'Cobro por peso',
			ISNULL(DOR.PriceShippment, 0) 'Tarifa del servicio',
			DOR.Segment 'Tipo de tarifa aplicada',
			ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',
			'SI' 'Entregado',
			DOR.DateCreated 'Fecha de solicitud del servicio',
			IIF(DOR.IsCollect = 1, 'SI', 'NO') 'Collect',
			ISNULL(CTM.Name, CTV.Name) 'Cliente'
			,IIF
			( 
				RTRIM(ISNULL(CTM.TaxIdentificationNumber,'')) <> ''
				,CTM.TaxIdentificationNumber,
				IIF
				( 
					RTRIM(ISNULL(CTV.TaxIdentificationNumber,'')) <> ''
					,CTV.TaxIdentificationNumber
					,NULL
				)
			) 'NIT Cliente'
			,INH.inv_certificationFEL 'Certificación FEL'
			,IIF
			(
				ISNULL(CTM.ExcludePriceShippingCOD,CTV.ExcludePriceShippingCOD) =1
				,'SI'
				,'NO'
			) 'Exclusión de envio'
			,IIF
			(
				ISNULL(CTM.ExcludeCommissionCOD,CTV.ExcludeCommissionCOD) =1
				,'SI'
				,'NO'
			) 'Exclusión de comisión'
    FROM 
		DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
		INNER JOIN
			[#GuideWithArrival] GWA  WITH(NOLOCK) 
			ON
				[DOR].[Guide_Serie] = [GWA].[GuideSerie]
				AND
				[DOR].[Guide_Number] = [GWA].[GuideNumber]
        LEFT JOIN
        (
            SELECT MIN(IND.dti_fk_header) dti_fk_header,
                   IND.dti_fk_orderSerie dti_fk_orderSerie,
                   IND.dti_fk_orderNumber dti_fk_orderNumber,
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
                INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
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
        LEFT JOIN DeliveryBackOffice.dbo.CatSystem CTS  WITH(NOLOCK) 
            ON CTS.SysIdSystem = INH.systemOperation
        LEFT JOIN DeliveryBackOffice.dbo.InOutOfMoneyDetail InOut  WITH(NOLOCK) 
            ON InOut.io_invoice = INH.inv_pk_id
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney TypeInOut  WITH(NOLOCK) 
            ON TypeInOut.tio_pk_id = InOut.io_type
		LEFT JOIN DeliveryBackOffice.dbo.Cost CST WITH (NOLOCK)
			ON CST.GuideSerie = DOR.Guide_Serie AND CST.GuideNumber = DOR.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.CostDetail CSD WITH (NOLOCK)
			ON [CSD].[IdCost] = [CST].[IdCost]
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney CTO WITH (NOLOCK)
            ON CTO.tio_pk_id = CSD.IdTypeOfMoney
		LEFT JOIN DeliveryBackOffice.dbo.[VisitPointClient] VPCori  WITH(NOLOCK) 
			ON [VPCori].[CodeOfReference] = [DOR].[OriginSenderId]
			AND [VPCori].[CodeOfReference] <> 0
		LEFT JOIN [DeliveryBackOffice].[dbo].[KindOfVPClient] KVPori  WITH(NOLOCK) 
			ON [KVPori].[IdKindOfVPClient] = [VPCori].[IdKindOfVPClient]
        LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
            ON VPC.CodeOfReference = DOR.Sender_ID
        LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient KVP WITH (NOLOCK)
            ON KVP.IdKindOfVPClient = VPC.IdKindOfVPClient
        LEFT JOIN DeliveryBackOffice.dbo.Customer CTM WITH (NOLOCK)
            ON CTM.IdCustomer = DOR.IdCustomer
        LEFT JOIN DeliveryBackOffice.dbo.Customer CTV WITH (NOLOCK)
            ON CTV.IdCustomer = VPC.CustomerID
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeOfBusiness] CTOB WITH (NOLOCK)
			ON ISNULL(CTV.TypeOfBusinessID, CTM.TypeOfBusinessID) = CTOB.IdTypeOfBusiness
        LEFT JOIN DeliveryBackOffice.dbo.CustomerType CTT WITH (NOLOCK)
            ON CTT.IdCustomerType = CTM.IdCustomerType
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
            ON TWN.TownshipName = DOR.Receiver_Town
        LEFT JOIN
        (
            SELECT CV.HeaderCode,
                   MAX(CV.Hub) HUB
            FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
            GROUP BY CV.HeaderCode
        ) HB
            ON HB.HeaderCode = ISNULL(TONW.HeaderCode, TWN.HeaderCode)
		--Info origen
		LEFT JOIN dbo.Township TONWO WITH (NOLOCK)
            ON TONWO.IdTownship = DOR.SenderIdTownship AND TONWO.TownshipStatus = 1
		LEFT JOIN dbo.Township TWNO WITH (NOLOCK)
            ON TWNO.TownshipName = DOR.Sender_Town AND TWNO.TownshipStatus = 1
		LEFT JOIN
        (
            SELECT CV.HeaderCode,
                   MAX(CV.Hub) HUB
            FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
            GROUP BY CV.HeaderCode
        ) HBO
            ON HBO.HeaderCode = ISNULL(TONWO.HeaderCode, TWNO.HeaderCode)

		LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount DCBA WITH (NOLOCK)
            ON DCBA.DCBA_Id = DOR.DCBA_ID
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank DBA WITH (NOLOCK)
            ON DBA.Id_bank = DCBA.DCBA_Bank_Id
               AND DBA.Id_country = 'GT'
               AND DBA.Id_status = 1
		LEFT JOIN DeliveryBackOffice.dbo.StatusOrder STO ON STO.StatusOrderId = DOR.StatusOrderId
		WHERE ISNULL(DOR.SenderCountryId, 'GT') = @IdCountrySender

	IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL 
		DROP TABLE #TransactionFAC1;
	IF OBJECT_ID('tempdb.dbo.#GuideWithArrival', 'U') IS NOT NULL 
		DROP TABLE #GuideWithArrival;

END;