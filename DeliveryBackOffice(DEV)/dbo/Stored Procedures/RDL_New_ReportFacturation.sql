-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2022-10-06>
-- Description:	<Reporte completo>
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-07-21>
-- Description:	<Filtro agregado por país.>
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2025-08-26>
-- Description:	<Se agregan nuevos filtros y refactorizacion de SP>
-- =============================================
CREATE PROCEDURE [dbo].[RDL_New_ReportFacturation]
    @StartDate DATETIME,
    @EndDate DATETIME,
	@IdCountry NVARCHAR(3) = NULL,
	@Corporative BIT = 0,
	@Status BIT = 0,
	@Exclusive BIT = 1,
	@Origins NVARCHAR(MAX) = ''
AS
BEGIN
	DECLARE @DATE1 INT;
	DECLARE @DATE2 INT;

	SET @DATE1 = (SELECT (DATEPART(MONTH,@StartDate)))
	SET @DATE2 = (SELECT (DATEPART(MONTH,@EndDate)))
					
	IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL 
		DROP TABLE #TransactionFAC1;

	IF OBJECT_ID('tempdb.dbo.#Report', 'U') IS NOT NULL 
			DROP TABLE #Report;

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

	CREATE TABLE #Report
	(
		Ultimo_estado NVARCHAR(MAX),
		Origen_de_guia NVARCHAR(MAX),
		Cliente NVARCHAR(MAX),
		Codigo_SAP NVARCHAR(MAX),
		Remitente NVARCHAR(MAX),
		Destinatario NVARCHAR(MAX),
		Departamento_Destino NVARCHAR(MAX),
		Municipio_Destino NVARCHAR(MAX),
		Fecha_solicitud_servicio DATETIME,
		Fecha_entrega DATETIME,
		No_Manifiesto INT,
		Guia NVARCHAR(MAX),
		Entregado NVARCHAR(100),
		Tipo_tarifa_aplicada NVARCHAR(MAX),
		Descripcion_bien NVARCHAR(MAX),
		Piezas INT,
		Tarifa_servicio DECIMAL(18,2),
		Monto_envio DECIMAL(18,2),
		Monto_COD DECIMAL(18,2),
		Correo_remitente NVARCHAR(MAX),
		Nombre_cuenta NVARCHAR(MAX),
		Tipo_servicio NVARCHAR(MAX),
		Collect NVARCHAR(MAX),
		NIT_Cliente NVARCHAR(MAX),
		Certificacion_FEL NVARCHAR(MAX),
		Exclusion_envio NVARCHAR(MAX),
		Codigo_socio_negocios NVARCHAR(MAX),
		Peso_total DECIMAL(18,2),
		Tarifa_excedente_libra DECIMAL(18,2),
		Peso_Base DECIMAL(18,2),
		Peso_a_Facturar DECIMAL(18,2),
		Credito_Collect NVARCHAR(MAX),
		SaleAdvisorCode NVARCHAR(MAX),
		BusinessSegmentName NVARCHAR(MAX),
		KindOfVPName NVARCHAR(MAX),
		CommercialSegmentName NVARCHAR(MAX)
	);

	--==============================================================================================
	--========================== INSERTAR DATOS A TABLA TEMP =======================================
	--==============================================================================================

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

	--==============================================================================================
	--==================================== CONSULTAS PRINCIPALES ======================================
	--==============================================================================================
	IF @IdCountry IS NOT NULL
	BEGIN
		IF @Corporative IS NOT NULL AND @Status IS NOT NULL
		BEGIN
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

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND ISNULL(DOR.SenderCountryId,'GT') = @IdCountry
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId != 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));
		END
		ELSE IF @Corporative IS NOT NULL AND @Exclusive IS NOT NULL
		BEGIN
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

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)


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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND ISNULL(DOR.SenderCountryId,'GT') = @IdCountry
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId = 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE IF @Corporative IS NOT NULL
		BEGIN

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

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND ISNULL(DOR.SenderCountryId,'GT') = @IdCountry
			AND  COALESCE(INH.inv_certificationFEL, '') = ''

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE IF @Status IS NOT NULL
		BEGIN
	
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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)


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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName		   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND ISNULL(DOR.SenderCountryId,'GT') = @IdCountry
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId != 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE IF @Exclusive IS NOT NULL
		BEGIN
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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)


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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName
		   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND ISNULL(DOR.SenderCountryId,'GT') = @IdCountry
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId = 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE IF @Origins != ''
		BEGIN
		
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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)


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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName
		   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND ISNULL(DOR.SenderCountryId,'GT') = @IdCountry

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE
		BEGIN
		PRINT 'SIN FILTROS PAIS NO NULL'
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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND ISNULL(DOR.SenderCountryId,'GT') = @IdCountry
		END
	END
	ELSE IF @IdCountry IS NULL
	BEGIN
		IF @Corporative IS NOT NULL AND @Status IS NOT NULL
		BEGIN
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

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId != 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));
		END
		ELSE IF @Corporative IS NOT NULL AND @Exclusive IS NOT NULL
		BEGIN
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

			
			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId = 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));
		END
		ELSE IF @Corporative IS NULL AND @Status IS NULL AND @Exclusive IS NULL AND @Origins != ''
		BEGIN 
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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE IF @Corporative IS NOT NULL
		BEGIN

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

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND  COALESCE(INH.inv_certificationFEL, '') = ''

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE IF @Status IS NOT NULL
		BEGIN
	
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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

			
			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName		   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId != 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));


		END
		ELSE IF @Exclusive IS NOT NULL
		BEGIN
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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName
		   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId = 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));
		END
		ELSE IF @Origins != ''
		BEGIN

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
					AND INH.inv_descriptionFEL = 'PROCESO REALIZADO'
					AND INH.inv_creditNote IS NULL
					AND INH.inv_motiveCreditNote IS NULL
				GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
			)

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)


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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI, --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName
		   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));

		END
		ELSE IF @Corporative IS NOT NULL AND @Status IS NOT NULL
		BEGIN
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

			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId != 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));
		END
		ELSE IF @Corporative IS NOT NULL AND @Exclusive IS NOT NULL
		BEGIN
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

			
			INSERT INTO #Report
			(
				Ultimo_estado,
				Origen_de_guia,
				Cliente,
				Codigo_SAP,
				Remitente,
				Destinatario,
				Departamento_Destino,
				Municipio_Destino,
				Fecha_solicitud_servicio,
				Fecha_entrega,
				No_Manifiesto,
				Guia,
				Entregado,
				Tipo_tarifa_aplicada,
				Descripcion_bien,
				Piezas,
				Tarifa_servicio,
				Monto_envio,
				Monto_COD,
				Correo_remitente,
				Nombre_cuenta,
				Tipo_servicio,
				Collect,
				NIT_Cliente,
				Certificacion_FEL,
				Exclusion_envio,
				Codigo_socio_negocios,
				Peso_total,
				Tarifa_excedente_libra,
				Peso_Base,
				Peso_a_Facturar,
				Credito_Collect,
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName
			)

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
					dbo.fn_CleanText(COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '')) 'Remitente', --SI
					dbo.fn_CleanText(COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '')) 'Destinatario', --SI
					DOR.Receiver_Department 'Departamento Destino',--SI
					DOR.Receiver_Town 'Municipio Destino', --SI
					DOR.DateCreated 'Fecha de solicitud del servicio', --SI
					FECHAS.FechaEntrega AS 'Fecha de entrega', --SI
					ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
					DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
					'SI' 'Entregado',--SI
					DOR.Segment 'Tipo de tarifa aplicada',--SI
					DPS.DescripcionBien AS 'Descripcion del bien transportado',--SI
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
					CS.CommercialSegmentName	   
			FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
				-- FECHA DE ENTREGA
				OUTER APPLY (
					SELECT MAX(DOD4.DateCreated) AS FechaEntrega

					FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
					WHERE DOD4.Guide_Serie = DOR.Guide_Serie
					  AND DOD4.Guide_Number = DOR.Guide_Number
					  AND DOD4.StatusOrderId IN (5, 22)
				) FECHAS
				-- DESCRIPCIÓN DEL BIEN
				OUTER APPLY (
					SELECT STRING_AGG(ISNULL(dps.Detail, 'Caja'), ', ') AS DescripcionBien
					FROM dbo.DeliveryOrderPiece dps WITH (NOLOCK)
					WHERE dps.GuideSerie = DOR.Guide_Serie
					  AND dps.GuideNumber = DOR.Guide_Number
				) DPS
				-- PESO TOTAL
				OUTER APPLY (
					SELECT SUM(IIF(COALESCE(DOP.MassWeight, 0) > COALESCE(DOP.volumetricWeight, 1),
								   COALESCE(DOP.MassWeight, 1),
								   COALESCE(DOP.volumetricWeight, 1))) AS PesoTotal
					FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
					WHERE DOP.GuideSerie = DOR.Guide_Serie
					  AND DOP.GuideNumber = DOR.Guide_Number
				) Weights

				LEFT JOIN FacturasSinFEL INH
					 ON INH.dti_fk_orderSerie = DOR.Guide_Serie
						AND INH.dti_fk_orderNumber = DOR.Guide_Number
				LEFT JOIN DeliveryOrderPaymentDetail DORPD WITH (NOLOCK)
					ON DOR.Guide_Serie = DORPD.GuideSerie
						AND DOR.Guide_Number = DORPD.GuideNumber
				LEFT JOIN PromoCoupon PRC WITH (NOLOCK)
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
				OUTER APPLY (
					SELECT CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END AS IsEcommerce
					FROM DeliveryBackOffice.dbo.Ecommerce ec WITH (NOLOCK)
					WHERE ec.IdCustomer = DOR.IdCustomer
				) EC
				-- TARIFAS Y PESO BASE
				OUTER APPLY (
					SELECT TOP 1
						COALESCE(rah.AdditionalWeightRate, 0) AS TarifaExcedente,
						COALESCE(rah.WeightLimit, 0) AS PesoBase
					FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
					LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
						ON rah.RheId = rac.RbcIdRate
					WHERE 
						(rac.RbcCodeOfReference = VPC.CodeOfReference
						OR (rac.RbcIdCustomer = COALESCE(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL))
						AND rac.RbcRowStatus = 1
					ORDER BY rac.RbcCodeOfReference DESC
				) RATE
				OUTER APPLY (
					SELECT TOP 1 CSA.SaleAdvisorCode
					FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
					WHERE CSA.IdSaleAdvisor = COALESCE(CTM2.SaleAdvisorID, C.SaleAdvisorID)
				) SA

				OUTER APPLY (
					SELECT TOP 1 CBS.BusinessSegmentName
					FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
					WHERE CBS.IdBusinessSegment = COALESCE(CTM2.BusinessSegmentID, C.BusinessSegmentID)
				) BS

				OUTER APPLY (
					SELECT TOP 1 CSC.Description
					FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) 
						ON VPC2.CustomerID = CTM.IdCustomer
					WHERE CSC.IdSalesChannel = COALESCE(VPC2.SaleChannelId, VPC.SaleChannelId)
				) SC

				OUTER APPLY (
					SELECT TOP 1 CCS.CommercialSegmentName
					FROM dbo.CatCommercialSegment CCS WITH (NOLOCK)
					WHERE CCS.IdCommercialSegment = COALESCE(C.CommercialSegmentID, CTM2.CommercialSegmentID)
				) CS
			WHERE EXISTS
			(
				SELECT TOP(1) 1
				FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
				WHERE DOR.StatusOrderId <> 7
						AND DOR.StatusOrderId <> 15
						AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
						AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
						AND @DATE1 = @DATE2
			)
			AND  COALESCE(INH.inv_certificationFEL, '') = ''
			AND STO.StatusOrderId = 1

			SELECT 
				Ultimo_estado AS 'Último estado',
				Origen_de_guia AS 'Origen de guía',
				Cliente,
				Codigo_SAP AS 'Código SAP',
				Remitente,
				Destinatario,
				Departamento_Destino AS 'Departamento Destino',
				Municipio_Destino AS 'Municipio Destino',
				Fecha_solicitud_servicio AS 'Fecha de solicitud del servicio',
				Fecha_entrega AS 'Fecha de entrega',
				No_Manifiesto AS 'No. de Manifiesto',
				Guia AS 'Guía',
				Entregado,
				Tipo_tarifa_aplicada AS 'Tipo de tarifa aplicada',
				Descripcion_bien AS 'Descripcion del bien transportado',
				Piezas,
				Tarifa_servicio AS 'Tarifa del servicio',
				Monto_envio AS 'Monto envío',
				Monto_COD AS 'Monto COD',
				Correo_remitente AS 'Correo remitente',
				Nombre_cuenta AS 'Nombre de cuenta',
				Tipo_servicio AS 'Tipo de servicio',
				Collect,
				NIT_Cliente AS 'NIT Cliente',
				Certificacion_FEL AS 'Certificación FEL',
				Exclusion_envio AS 'Exclusión de envio',
				Codigo_socio_negocios AS 'Código socio de negocios',
				Peso_total AS 'Peso total',
				Tarifa_excedente_libra AS 'Tarifa del excedente por libra',
				Peso_Base AS 'Peso Base',
				Peso_a_Facturar AS 'Peso a Facturar',
				Credito_Collect AS 'Credito/Collect',
				SaleAdvisorCode,
				BusinessSegmentName,
				KindOfVPName,
				CommercialSegmentName 
			FROM #Report RP
			WHERE RP.Origen_de_guia IN (SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(@Origins,','));
		END
	END
		IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL 
			DROP TABLE #TransactionFAC1;

		IF OBJECT_ID('tempdb.dbo.#Report', 'U') IS NOT NULL 
			DROP TABLE #Report;
           
END;