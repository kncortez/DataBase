-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2022-10-06>
-- Description:	<Reporte completo>
-- =============================================
CREATE PROCEDURE [dbo].[RDL_New_ReportFacturation]
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
	DECLARE @DATE1 INT;
	DECLARE @DATE2 INT;

	SET @DATE1 = (SELECT (DATEPART(MONTH,@StartDate)))
	SET @DATE2 = (SELECT (DATEPART(MONTH,@EndDate)))
					
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

	
	
								SELECT
								STO.OrderDescription 'Último estado',--SI
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
													   'Parser')))) 'Origen de guía',--SI
									   ISNULL(CTM.Name, CTV.Name) 'Cliente',--SI
									   CTM.SAPCardCode 'Código SAP', --SI
									   COALESCE(DOR.Sender_FirstName, '') + ' ' + COALESCE(DOR.Sender_LastName, '') 'Remitente', --SI
									   COALESCE(DOR.Receiver_FirstName, '') + ' ' + COALESCE(DOR.Receiver_LastName, '') 'Destinatario', --SI
									   DOR.Receiver_Department 'Departamento Destino',--SI
									   DOR.Receiver_Town 'Municipio Destino', --SI
									   DOR.DateCreated 'Fecha de solicitud del servicio', --SI
									   (
										   SELECT MAX(DOD4.DateCreated)
										   FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD4 WITH (NOLOCK)
										   WHERE DOD4.Guide_Serie = DOR.Guide_Serie
												 AND DOD4.Guide_Number = DOR.Guide_Number
												 AND DOD4.StatusOrderId IN ( 5, 22 )
									   ) 'Fecha de entrega', --SI
									   ISNULL(DOR.Manifest_Number, 0) 'No. de Manifiesto',--SI
									   DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) 'Guía', --SI
									   'SI' 'Entregado',--SI
									   DOR.Segment 'Tipo de tarifa aplicada',--SI
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
									   ) 'Descripcion del bien transportado',--SI
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
									   ) 'Peso total',--SI

		   								   (
										SELECT TOP 1 ISNULL(TBL.AdditionalWeightRate, 0) FROM
										 (
										 SELECT rah.AdditionalWeightRate,RbcCodeOfReference,RbcIdCustomer FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
										 LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
										 ON rah.RheId = rac.RbcIdRate
										 WHERE 
										  (
										  rac.RbcCodeOfReference = VPC.CodeOfReference
										   OR (rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL)			   
										  )
											AND rac.RbcRowStatus = 1
										 )TBL
											ORDER BY TBL.RbcCodeOfReference DESC
				
									   ) 'Tarifa del excedente por libra',--SI
           
									   (
										SELECT TOP 1 ISNULL(TBL.WeightLimit, 0) FROM
										 (
										 SELECT rah.WeightLimit,RbcCodeOfReference,RbcIdCustomer FROM DeliveryBackOffice.dbo.RatebyCustomer rac WITH (NOLOCK)            
										 LEFT JOIN DeliveryBackOffice.dbo.RateHeader rah WITH (NOLOCK)
										 ON rah.RheId = rac.RbcIdRate
										 WHERE 
										  (
										  rac.RbcCodeOfReference = VPC.CodeOfReference
										   OR (rac.RbcIdCustomer = ISNULL(CTM.IdCustomer, CTV.IdCustomer) AND rac.RbcCodeOfReference IS NULL)			   
										  )
											AND rac.RbcRowStatus = 1
										 )TBL
											ORDER BY TBL.RbcCodeOfReference DESC
				
									   ) 'Peso Base',
									   0 'Peso a Facturar',
									   --AQUI VA NUEVA COLUMNA
										 IIF(DORPD.TimePlaId= 4,
										   'Envío Crédito',
										   IIF(
											   DORPD.TimePlaId = 1
											   AND PRC.GuideNumberDestination IS NOT NULL,
											   'Envío con descuento',
											   IIF(
												   DORPD.TimePlaId = 1
												   AND PRC.GuideNumberDestination IS NULL,
												   'Envío Contado',
												   IIF(
													   DORPD.TimePlaId = 3,
													   'Collect',
													   IIF(
													   DORPD.TimePlaId = 2,
													   'Envío con cobro en recoleccíon',
													   ''	  
														)
												   )
												   ))) 'Credito/Collect',
		   
		   								(SELECT TOP 1 CSA.SaleAdvisorCode FROM DeliveryBackOffice.dbo.CatSaleAdvisor CSA WITH(NOLOCK)
										 WHERE IIF(C.SaleAdvisorID IS NULL,CTM2.SaleAdvisorID,C.SaleAdvisorID)  = CSA.IdSaleAdvisor
										)SaleAdvisorCode,
											(SELECT TOP 1BusinessSegmentName FROM DeliveryBackOffice.dbo.CatBusinessSegment CBS WITH (NOLOCK)
									WHERE CBS.IdBusinessSegment = IIF(c.BusinessSegmentID IS NULL,CTM2.BusinessSegmentID,c.BusinessSegmentID)) BusinessSegmentName,

									COALESCE(
									(SELECT TOP 1 CSC.Description FROM DeliveryBackOffice.dbo.CatSalesChannel CSC WITH (NOLOCK)
									LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC2 WITH(NOLOCK) ON VPC2.CustomerID = CTM.IdCustomer
									WHERE CSC.IdSalesChannel = IIF(VPC.SaleChannelId IS NULL,VPC2.SaleChannelId,VPC.SaleChannelId)),'Portal Web')KindOfVPName,
									(SELECT TOP 1 CommercialSegmentName FROM dbo.CatCommercialSegment CCS  WITH (NOLOCK) WHERE CCS.IdCommercialSegment = ISNULL(C.CommercialSegmentID,CTM2.CommercialSegmentID)
									)CommercialSegmentName

		   
								FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
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
									LEFT JOIN DeliveryOrderPaymentDetail DORPD
										ON DOR.Guide_Serie = DORPD.GuideSerie
										   AND DOR.Guide_Number = DORPD.GuideNumber
									LEFT JOIN PromoCoupon PRC
										ON DOR.Guide_Serie = PRC.GuideSerieDestination
										   AND DOR.Guide_Number = PRC.GuideNumberDestination
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
									LEFT JOIN DeliveryBackOffice.dbo.Customer CTM2 WITH(NOLOCK)
									ON DOR.IdCustomer = CTM2.IdCustomer
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
										AND BDT.RowStatus = 1 -- 03OctCRAS
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
										INNER JOIN dbo.Province prd ON prd.IdProvince = TWN.IdProvince  AND prd.IdCountry  = DOR.ReceiverCountryId --03OctCRAS
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
									LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] c WITH (NOLOCK)--cano
									ON c.IdCustomer = vpc.CustomerID
								WHERE EXISTS
								(
									SELECT 1
									FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK) --18TEBNHL
									WHERE DOR.StatusOrderId <> 7
										  AND DOR.StatusOrderId <> 15
										  AND CAST(DOR.DateCreated AS DATE) >= CAST(@StartDate AS DATE)
										  AND CAST(DOR.DateCreated AS DATE) <= CAST(@EndDate AS DATE)
										  AND @DATE1 = @DATE2
								)

								IF OBJECT_ID('tempdb.dbo.#TransactionFAC1', 'U') IS NOT NULL DROP TABLE #TransactionFAC1;
                    
  --        END
		--ELSE
		--  BEGIN
		--		SELECT '¡Meses no coinciden!. Solo puede consultar datos de un mismo mes.' AS 'MessageDescription'
		--  END
END;