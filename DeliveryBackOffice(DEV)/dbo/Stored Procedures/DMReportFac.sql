
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2025-10-07>
-- Description:	<Llena la tabla ReportFacturationFilter0 para el reporte de facturacion>
-- =============================================
CREATE PROCEDURE DMReportFac
	@IdCountry NVARCHAR(3) = 'GT'
AS
BEGIN

DECLARE 
    @StartDate DATE, 
    @EndDate DATE;

	SET @StartDate = DATEADD(MONTH, -3, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
	SET @EndDate = EOMONTH(GETDATE());

	DECLARE @DATE1 INT;
	DECLARE @DATE2 INT;

	SET @DATE1 = (SELECT (DATEPART(MONTH,@StartDate)))
	SET @DATE2 = (SELECT (DATEPART(MONTH,@EndDate)))

	CREATE TABLE #TransactionFAC1
	(
		GuideSerie			NVARCHAR(2)		NOT NULL,
		OrderNumber			BIGINT			NOT NULL,
		IdTransaction		BIGINT			NULL,
		CardNumber			NVARCHAR(50)	NULL,
		Currency			INT				NULL,
		Ammount				DECIMAL(18, 2)	NULL,
		[Signature]			NVARCHAR(100)	NULL,
		ReasonDescription	NVARCHAR(100)	NULL
	);

	CREATE NONCLUSTERED INDEX tempTransactionFAC1 
	ON #TransactionFAC1 ( GuideSerie, OrderNumber);

	INSERT INTO #TransactionFAC1
	SELECT 
		  GuideSerie
		, OrderNumber
		, IdTransaction
		, CardNumber
		, Currency
		, Ammount
		, Signature
		, ReasonDescription
	FROM
	(
		SELECT 
			  'FD' GuideSerie
			, SUBSTRING(OrderNumber, 3, LEN(OrderNumber)) OrderNumber
			, cbc.IdTransaction
			, cbc.CardNumber
			, cbc.Currency
			, cbc.Ammount
			, cbc.Signature
			, cbc.ReasonDescription
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer cbc WITH (NOLOCK)
		WHERE 
			SUBSTRING(OrderNumber, 0, 3) = 'FD'
			AND 
			(cbc.ReasonCode = '1' OR cbc.ReasonCode = '01')
		UNION
		SELECT 
			  DOP.GuideSerie
			, DOP.GuideNumber
			, CBC.IdTransaction
			, CBC.CardNumber
			, CBC.Currency
			, CBC.Ammount
			, CBC.Signature
			, CBC.ReasonDescription
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer			CBC WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.SchedulePickup				SCP WITH (NOLOCK)
				ON CBC.OrderNumber = SCP.TransaccionFAC
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail	DOP WITH (NOLOCK)
				ON DOP.IdHeaderRecolection = SCP.SchedulePickupId
		WHERE 
			SUBSTRING(CBC.OrderNumber, 0, 3) = 'HR'
			AND
			(cbc.ReasonCode = '1' OR cbc.ReasonCode = '01' )
	) CBC;

	BEGIN TRY
		BEGIN TRANSACTION

		IF (SELECT COUNT(*) FROM ReportFacturationFilter0) > 0
		BEGIN
			DELETE ReportFacturationFilter0
		END

		;WITH FacturasSinFEL AS (
				SELECT 
					IND.dti_fk_orderSerie,
					IND.dti_fk_orderNumber,
					MIN(IND.dti_fk_header) dti_fk_header,
					MIN(INH.systemOperation) systemOperation,
					MIN(INH.inv_pk_id) inv_pk_id,
					MIN(INH.inv_cli_nit) inv_cli_nit,
					MIN(INH.inv_amount) inv_amount,
					MIN(INH.inv_descriptionFEL) inv_descriptionFEL,
					MIN(INH.inv_cli_name) inv_cli_name,
					MIN(INH.inv_numberFEL) inv_numberFEL,
					MIN(INH.inv_SAPDocEntry) inv_SAPDocEntry,
					MIN(INH.inv_certificationFEL) inv_certificationFEL,
					MAX(CASE WHEN INH.IsManualInvoice = 1 THEN 1 ELSE 0 END) AS IsManualInvoice
				FROM DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
					ON IND.dti_fk_header = INH.inv_pk_id
				WHERE INH.inv_certificationFEL IS NOT NULL
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO' --  invoiceHeader.inv_status  NO TIENE ID DEFINIDO
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)


		INSERT INTO [dbo].[ReportFacturationFilter0]
			   ([Ultimo_estado]
			   ,[Origen_de_guia]
			   ,[Cliente]
			   ,[Codigo_SAP]
			   ,[Remitente]
			   ,[Destinatario]
			   ,[Departamento_Destino]
			   ,[Municipio_Destino]
			   ,[Fecha_solicitud_servicio]
			   ,[Fecha_entrega]
			   ,[No_Manifiesto]
			   ,[Guia]
			   ,[Entregado]
			   ,[Tipo_tarifa_aplicada]
			   ,[Descripcion_bien]
			   ,[Piezas]
			   ,[Tarifa_servicio]
			   ,[Monto_envio]
			   ,[Monto_COD]
			   ,[Correo_remitente]
			   ,[Nombre_cuenta]
			   ,[Tipo_servicio]
			   ,[Collect]
			   ,[NIT_Cliente]
			   ,[Certificacion_FEL]
			   ,[Exclusion_envio]
			   ,[Codigo_socio_negocios]
			   ,[Peso_total]
			   ,[Tarifa_excedente_libra]
			   ,[Peso_Base]
			   ,[Peso_a_Facturar]
			   ,[Credito_Collect]
			   ,[SaleAdvisorCode]
			   ,[BusinessSegmentName]
			   ,[KindOfVPName]
			   ,[CommercialSegmentName]
			   ,[IdCountry])


			SELECT
			STO.OrderDescription 'Último estado',--SI
					CASE 
						WHEN KVP.IdKindOfVPClient = 3 THEN 'Concesionario'
						WHEN ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 2 THEN KVP.KindOfVPName
						WHEN ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 3 THEN 'Portal Web'
						WHEN ISNULL(CTV.IdCustomerType, CTM.IdCustomerType) = 1 
							THEN CASE 
									WHEN DOR.IdCustomer IS NULL THEN 'Parser'
									WHEN EC.IsEcommerce = 1 THEN 'API'
									ELSE 'Parser'
								 END
						ELSE 'Parser'
						END AS 'Origen de guía',--SI
					ISNULL(CTM.Name, CTV.Name) 'Cliente',--SI
					CTM.SAPCardCode 'Código SAP', --SI
					DeliveryBackOffice.dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					DeliveryBackOffice.dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					COALESCE(DPS.DescripcionBien, 'caja') AS 'Descripcion del bien transportado',--SI
					COALESCE(DOR.Pieces_Dry, 0) + COALESCE(DOR.Pieces_Cold, 0) 'Piezas',--SI
					ISNULL(DOR.PriceShippment, 0) 'Tarifa del servicio', --SI
					DOR.PriceShippment 'Monto envío',--SI
					DOR.Collect_OnDelivery 'Monto COD',--SI
					DOR.Sender_Mail 'Correo remitente',--SI
					DCBA.DCBA_Nom_account 'Nombre de cuenta',--SI
					IIF(DOR.TypeService = 'EXP', 'NDD', ISNULL(DOR.TypeService, 'NDD')) 'Tipo de servicio',
					IIF(DOR.IsCollect = 1, 'SI', 'NO') 'Collect', --SI
						IIF( 
						RTRIM(ISNULL(CTM.TaxIdentificationNumber,'')) <> ''
						,CTM.TaxIdentificationNumber,
						IIF( 
							RTRIM(ISNULL(CTV.TaxIdentificationNumber,'')) <> ''
							,CTV.TaxIdentificationNumber
							,NULL
						)
					) 'NIT Cliente' --SI
					,INH.inv_certificationFEL 'Certificación FEL' --SI
					,IIF(ISNULL(CTM.ExcludePriceShippingCOD,CTV.ExcludePriceShippingCOD) =1,'SI','NO') 'Exclusión de envio',--SI
					CTM.SAPCardCode 'Código socio de negocios', --'Código SAP'
					ISNULL(Weights.PesoTotal, COALESCE(DOR.Pieces_Cold, 0) + COALESCE(DOR.Pieces_Dry, 0)) AS 'Peso total',--SI
					RATE.TarifaExcedente AS 'Tarifa del excedente por libra',--SI
				   RATE.PesoBase AS 'Peso Base',
					0 'Peso a Facturar',
					--AQUI VA NUEVA COLUMNA
					CASE 
						WHEN DORPD.TimePlaId = 4 THEN 'Envío Crédito'
						WHEN DORPD.TimePlaId = 1 AND PRC.GuideNumberDestination IS NOT NULL THEN 'Envío con descuento'
						WHEN DORPD.TimePlaId = 1 AND PRC.GuideNumberDestination IS NULL THEN 'Envío Contado'
						WHEN DORPD.TimePlaId = 3 THEN 'Collect'
						WHEN DORPD.TimePlaId = 2 THEN 'Envío con cobro en recolección'
						ELSE ''
					END AS 'Credito/Collect',
					SA.SaleAdvisorCode,
					BS.BusinessSegmentName,
					COALESCE(SC.Description, 'Portal Web') AS KindOfVPName,
					CS.CommercialSegmentName,
					DOR.SenderCountryId
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				LEFT JOIN (
					SELECT DOD4.Guide_Serie, DOD4.Guide_Number, MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.StatusOrderId IN (5, 22)
					GROUP BY DOD4.Guide_Serie, DOD4.Guide_Number
				) FECHAS
				ON FECHAS.Guide_Serie = DOR.Guide_Serie
					AND FECHAS.Guide_Number = DOR.Guide_Number
				-- DESCRIPCIÓN DEL BIEN
				LEFT JOIN (
					SELECT GuideSerie, GuideNumber,
							COALESCE(dps.Detail, 'Caja') AS DescripcionBien,
							ROW_NUMBER() OVER (PARTITION BY GuideSerie, GuideNumber ORDER BY Detail) AS rn
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dps WITH (NOLOCK)
				) DPS
				ON DPS.GuideSerie = DOR.Guide_Serie
				   AND DPS.GuideNumber = DOR.Guide_Number
				   AND DPS.rn = 1
				-- PESO TOTAL
				LEFT JOIN (
					SELECT DOP.GuideSerie, DOP.GuideNumber,
					SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					GROUP BY DOP.GuideSerie, DOP.GuideNumber
				) Weights
				ON Weights.GuideSerie = DOR.Guide_Serie
				 AND Weights.GuideNumber = DOR.Guide_Number

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.PromoCoupon PRC WITH (NOLOCK)
					ON DOR.Guide_Serie = PRC.GuideSerieDestination
						AND DOR.Guide_Number = PRC.GuideNumberDestination
				LEFT JOIN DeliveryBackOffice.dbo.CatSystem CTS WITH (NOLOCK) --22TEBNHL 
					ON CTS.SysIdSystem = INH.systemOperation
				LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
					ON VPC.CodeOfReference = DOR.Sender_ID
				LEFT JOIN DeliveryBackOffice.dbo.KindOfVPClient KVP WITH(NOLOCK)
					ON KVP.IdKindOfVPClient = VPC.IdKindOfVPClient
				LEFT JOIN DeliveryBackOffice.dbo.Customer CTM WITH(NOLOCK)
					ON CTM.IdCustomer = DOR.IdCustomer
				LEFT JOIN DeliveryBackOffice.dbo.Customer CTV WITH(NOLOCK)
					ON CTV.IdCustomer = VPC.CustomerID
				LEFT JOIN DeliveryBackOffice.dbo.Customer CTM2 WITH(NOLOCK)
					ON DOR.IdCustomer = CTM2.IdCustomer
				LEFT JOIN #TransactionFAC1 FAC 
					ON FAC.GuideSerie = DOR.Guide_Serie
						AND FAC.OrderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount DCBA WITH (NOLOCK)
					ON DCBA.DCBA_Id = DOR.DCBA_ID
				LEFT JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH(NOLOCK)
					ON STO.StatusOrderId = DOR.StatusOrderId
				LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] c WITH (NOLOCK)--cano
				ON c.IdCustomer = vpc.CustomerID
				LEFT JOIN (
					SELECT ec.IdCustomer,
					CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					GROUP BY ec.IdCustomer
				) EC
				ON DOR.IdCustomer = EC.IdCustomer
				-- TARIFAS Y PESO BASE
				LEFT JOIN (
					SELECT
						rac.RbcCodeOfReference,
						rac.RbcIdCustomer,
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						rac.RbcCodeOfReference IS NULL
						AND rac.RbcRowStatus = 1
				) RATE
				ON  RATE.RbcIdCustomer = ISNULL(ctm.IdCustomer, ctv.IdCustomer) --AND RATE.RbcCodeOfReference = ''
				LEFT JOIN (
					SELECT  CSA.IdSaleAdvisor,
								CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
				) SA
				ON SA.IdSaleAdvisor = COALESCE(CTM.SaleAdvisorID, C.SaleAdvisorID)
				LEFT JOIN (
					SELECT  CBS.IdBusinessSegment,
								CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
				) BS
				ON BS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				LEFT JOIN (
					SELECT CSC.IdSalesChannel,
								 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
				) SC
				ON SC.IdSalesChannel = VPC.SaleChannelId 
					AND VPC.CustomerID = CTM.IdCustomer
				LEFT JOIN (
					SELECT CCS.IdCommercialSegment,
								CCS.CommercialSegmentName
					FROM DeliveryBackOffice.dbo.CatCommercialSegment CCS WITH (NOLOCK)
				) CS
				ON CS.IdCommercialSegment = COALESCE(CTM.CommercialSegmentID,C.CommercialSegmentID)
			WHERE DOR.StatusOrderId <> 7
				AND DOR.StatusOrderId <> 15
				AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
				AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
				--AND @DATE1 = @DATE2
			

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION

			SELECT ERROR_MESSAGE(),
				   ERROR_LINE();
		END CATCH

END
