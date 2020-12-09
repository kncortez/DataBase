USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GenerateDynamicJSON]    Script Date: 12/9/2020 8:08:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec dbo.GenerateDynamicJSON @Parameter3 = '1'
--DROP PROCEDURE dbo.GenerateDynamicJSON 
ALTER PROCEDURE [dbo].[GenerateDynamicJSON]
(
  @OperationName varchar(200) = 'GetServicesByDate'
 ,@Parameter1 varchar(200) = '2020-11-12'
 ,@Parameter2 varchar(200) = '2020-11-20'
 ,@Parameter3 varchar(200) = '-1'
)
AS
BEGIN

CREATE TABLE #GuidesDelivered  (        
       Guide_Serie varchar(2),
	   Guide_Number int,
	   DateCreated datetime
	  )

 
--Guías entregadas
INSERT INTO #GuidesDelivered
SELECT distinct
Det.Guide_Serie,
Det.Guide_Number,
Det.DateCreated
FROM DeliveryBackOffice.DBO.DeliveryOrderDetail Det
join DeliveryBackOffice.dbo.DeliveryOrder serv on Det.Guide_Serie = serv.Guide_Serie
and Det.Guide_Number = serv.Guide_Number
LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] SettDet
on serv.Guide_Serie = SettDet.Guide_Serie
and serv.Guide_Number = SettDet.Guide_Number
and SettDet.Guide_Delivered = 1
and SettDet.Guide_Discharged = 1
JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   SettDet.ID_DeliveryOrderBySettlement = Head.ID
where Det.StatusOrderId = 5
and CONVERT(DATE, Head.Route_Received) 
   BETWEEN  CONVERT(DATE, @Parameter1) AND CONVERT(DATE, @Parameter2) --Filtrar por fecha de liquidación		
AND serv.StatusOrderId <> 7 --No esté anulada la guía
AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
AND serv.Dispatched_Date is not null --La guía debe haber sido despachada


DECLARE @jsonOutput NVARCHAR(MAX)
DECLARE @jsonOutputTotal NVARCHAR(MAX)

if (@OperationName = 'GetServicesByDate')
BEGIN

--Mostrar detalles
---
--Tabla para recorrido de Clientes
DECLARE @Customers AS TABLE (
        primary_key INT IDENTITY(1,1) NOT NULL, --Usado para while
        IdCustomer INT 
	  )

--Tabla para recibir json por clientes para el detalle
DECLARE @CustomersDetail AS TABLE (        
        IdCustomer INT,
		jsonDetail varchar(max) 
	  )

--Llenar tabla con clientes
INSERT INTO @Customers
SELECT distinct
			vpclient.CustomerID IdCustomer
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient
			ON serv.Sender_ID = vpclient.CodeOfReference		
		JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det
		on serv.Guide_Serie = Det.Guide_Serie
		and serv.Guide_Number = Det.Guide_Number
		and Det.Guide_Delivered = 1
		and Det.Guide_Discharged = 1
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   Det.ID_DeliveryOrderBySettlement = Head.ID		   
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PaidHead
			on PaidHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PaidHead.IdStatus = 1
		WHERE 
		(
		 @Parameter3 = '-1'
		 or (
		     @Parameter3 = 1 and CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
			)
		 or (
			 @Parameter3 = 2 and CONVERT(DATE, PaidHead.Manifest_Date) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
		    )
		)		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0	
		AND 
		 (@Parameter3 = '-1' 
		 or (@Parameter3 = 1 and paidguide.Guide_Number IS NULL) --solo cobrado
		 or (@Parameter3 = 2 and paidguide.Guide_Number IS NOT NULL) --pagado
		 )
GROUP BY CustomerID 

DECLARE @CustomerItem INT = 0
DECLARE @item_counter INT
DECLARE @loop_counter INT	 
SET @item_counter = 1

SET @loop_counter = ISNULL((SELECT COUNT(*) FROM @Customers),0) 
	  -- Hacer el conteo de registros de nuestra tabla

	  WHILE @loop_counter > 0 AND @item_counter <= @loop_counter
	  BEGIN
	    
		SELECT 
		 @CustomerItem = IdCustomer		
		FROM @Customers
		WHERE primary_key = @item_counter
		DECLARE @jsonDetOutput NVARCHAR(MAX)
		/*
		SET @jsonDetOutput = 
   (		
		SELECT  		
			UPPER(serv.Receiver_FirstName) + ' '+ UPPER(serv.Receiver_LastName) ReceiverName,
			Deliv.DateCreated DateDelivery,
			COALESCE(PHead.Manifest_Date,null) DatePayment,
			Serv.Manifest_Serie ManifestSerie,
			Serv.Manifest_Number ManifestNumber,
			Serv.Guide_Serie GuideSerie,
			Serv.Guide_Number GuideNumber,
			Settlement_Collect_OnDelivery CollectOnDelivery,
			case WHEN paidguide.Deposit_Number IS NOT NULL THEN 2 
			     WHEN Settlement_Collect_OnDelivery IS NOT NULL THEN 1
				 ELSE 3 END StatusId,
			case WHEN paidguide.Deposit_Number IS NOT NULL THEN 'Pagado' 
			     WHEN Settlement_Collect_OnDelivery IS NOT NULL THEN 'Liquidado'
				 ELSE 'N/A' END StatusDescription,
			PHead.Manifest_Date PayManifest_Date,
			PHead.Manifest_Serie PayManifest_Serie,
			PHead.Manifest_Number PayManifest_Number
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
			ON serv.Sender_ID = vpclient.CodeOfReference		
		JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det
		on serv.Guide_Serie = Det.Guide_Serie
		and serv.Guide_Number = Det.Guide_Number
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   Det.ID_DeliveryOrderBySettlement = Head.ID
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'	   
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PHead 
			on PHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PHead.IdStatus = 1
		LEFT JOIN #GuidesDelivered Deliv
		   on Deliv.Guide_Serie = Serv.Guide_Serie 
		   and Deliv.Guide_Number = Serv.Guide_Number		   
		JOIN DeliveryBackOffice.dbo.Customer Ctm on Ctm.IdCustomer = vpclient.CustomerID
		WHERE 
		(
		 @Parameter3 = '-1'
		 or (
		     @Parameter3 = 1 and CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
			)
		 or (
			 @Parameter3 = 2 and CONVERT(DATE, PHead.Manifest_Date) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
		    )
		)		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Ctm.IdCustomer = @CustomerItem
		AND 
		 (@Parameter3 = '-1' 
		 or (@Parameter3 = 1 and paidguide.Guide_Number IS NULL) --solo cobrado
		 or (@Parameter3 = 2 and paidguide.Guide_Number IS NOT NULL) --pagado
		 )
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)
    */
	set @jsonDetOutput =
	(
	SELECT '['+ STUFF(
	   (		
		SELECT distinct 		
			',{"ReceiverName":"' + UPPER(COALESCE(serv.Receiver_FirstName,'')) + ' '+ UPPER(COALESCE(serv.Receiver_LastName,'')) + '",'+
			'"DateDelivery":"'   + CASE WHEN Deliv.DateCreated IS NULL THEN '' ELSE CONVERT(VARCHAR,Deliv.DateCreated,126) END  + '",'+
			'"DatePayment":"'    + CASE WHEN PHead.Manifest_Date IS NULL THEN '' ELSE CONVERT(VARCHAR,PHead.Manifest_Date,126) END  + '",'+
			'"ManifestSerie":"'  + Serv.Manifest_Serie + '",'+
			'"ManifestNumber":'  + CONVERT(VARCHAR,Serv.Manifest_Number) + ','+
			'"GuideSerie":"'     + Serv.Guide_Serie + '",'+
			'"GuideNumber":'     + CONVERT(VARCHAR,Serv.Guide_Number) + ','+
			'"CollectOnDelivery":' + CONVERT(VARCHAR,COALESCE(Settlement_Collect_OnDelivery,'0')) + ','+
			'"StatusId":' + CONVERT(VARCHAR,case WHEN paidguide.Deposit_Number IS NOT NULL THEN 2 
			     WHEN Settlement_Collect_OnDelivery IS NOT NULL THEN 1
				 ELSE 3 END) + ','+
			'"StatusDescription":"' + CONVERT(VARCHAR,case WHEN paidguide.Deposit_Number IS NOT NULL THEN 'Pagado' 
			     WHEN Settlement_Collect_OnDelivery IS NOT NULL THEN 'Liquidado'
				 ELSE 'N/A' END) + '",'+
			'"PayManifest_Date":"' + CASE WHEN PHead.Manifest_Date IS NULL THEN '' ELSE CONVERT(VARCHAR,PHead.Manifest_Date,126) END + '",'+
			'"PayManifest_Serie":"' + CONVERT(VARCHAR,COALESCE(PHead.Manifest_Serie,'')) + '",'+
			
			'"PayManifest_Number":' + CONVERT(VARCHAR,COALESCE(PHead.Manifest_Number,'')) + '}'
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
			ON serv.Sender_ID = vpclient.CodeOfReference		
		JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det
		on serv.Guide_Serie = Det.Guide_Serie
		and serv.Guide_Number = Det.Guide_Number
		and Det.Guide_Delivered = 1
		and Det.Guide_Discharged = 1
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   Det.ID_DeliveryOrderBySettlement = Head.ID
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'	   
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PHead 
			on PHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PHead.IdStatus = 1
		LEFT JOIN #GuidesDelivered Deliv
		   on Deliv.Guide_Serie = Serv.Guide_Serie 
		   and Deliv.Guide_Number = Serv.Guide_Number		   
		JOIN DeliveryBackOffice.dbo.Customer Ctm on Ctm.IdCustomer = vpclient.CustomerID
		WHERE 
		(
		 @Parameter3 = '-1'
		 or (
		     @Parameter3 = 1 and CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
			)
		 or (
			 @Parameter3 = 2 and CONVERT(DATE, PHead.Manifest_Date) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
		    )
		)		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Ctm.IdCustomer = @CustomerItem
		AND 
		 (@Parameter3 = '-1' 
		 or (@Parameter3 = 1 and paidguide.Guide_Number IS NULL) --solo cobrado
		 or (@Parameter3 = 2 and paidguide.Guide_Number IS NOT NULL) --pagado
		 )
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		FOR XML PATH(''), TYPE
	)
	.value('.', 'varchar(max)'),1,1,''
              ) + ']'
	)
	

	--select @jsonDetOutput --temporal

	INSERT INTO @CustomersDetail
	values (@CustomerItem,@jsonDetOutput)


		SET @item_counter= @item_counter + 1

	  END

---

--Mostrar clientes y sus detalles
/*  SET @jsonOutput = 
  (


SELECT  
			Ctm.IdCustomer,			
			Ctm.Name Name,
			0 FeeRate,
			sum(serv.Collect_OnDelivery) TotalServicesByCollect,
			sum(CASE WHEN Settlement_Collect_OnDelivery > 0 THEN Collect_OnDelivery ELSE 0 END) TotalServicesCharged, --LIQUIDADO 				
			sum(CASE WHEN paidGuide.Deposit_Number IS NOT NULL THEN Settlement_Collect_OnDelivery ELSE 0 END) TotalServicesPaid,
			SUM(CASE WHEN Serv.Guide_Number IS NOT NULL THEN 1 ELSE 0 END) TotalNumberOfGuidesDelivered
			,
			JSON_QUERY
			(
			'[' + CustomDet.jsonDetail + ']' 
			) 
			GuideDetail
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
			ON serv.Sender_ID = vpclient.CodeOfReference		
		JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det
		on serv.Guide_Serie = Det.Guide_Serie
		and serv.Guide_Number = Det.Guide_Number
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   Det.ID_DeliveryOrderBySettlement = Head.ID
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'	 
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PaidHead
			on PaidHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PaidHead.IdStatus = 1
		LEFT JOIN #GuidesDelivered Deliv
		   on Deliv.Guide_Serie = Serv.Guide_Serie 
		   and Deliv.Guide_Number = Serv.Guide_Number
		
		LEFT JOIN @CustomersDetail CustomDet on vpclient.CustomerID = CustomDet.IdCustomer
		JOIN DeliveryBackOffice.dbo.Customer Ctm on Ctm.IdCustomer = vpclient.CustomerID
		
		WHERE
		(
		 @Parameter3 = '-1'
		 or (
		     @Parameter3 = 1 and CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
			)
		 or (
			 @Parameter3 = 2 and CONVERT(DATE, PaidHead.Manifest_Date) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
		    )
		)		
		   --Filtrar por fecha de liquidación		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		AND 
		 (@Parameter3 = '-1' 
		 or (@Parameter3 = 1 and paidguide.Guide_Number IS NULL) --solo cobrado
		 or (@Parameter3 = 2 and paidguide.Guide_Number IS NOT NULL) --pagado
		 )
		GROUP BY Ctm.IdCustomer,Ctm.Name,serv.Sender_FirstName,CustomDet.jsonDetail
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  )*/

    SET @jsonOutput = 
  (

SELECT '['+ STUFF((
SELECT  distinct
			',{"IdCustomer":' +  CONVERT(varchar,Ctm.IdCustomer) + ','+			
			'"Name":"' + Ctm.Name  + '",'+
			'"FeeRate":0' + ','+
			'"TotalServicesByCollect":' + CONVERT(VARCHAR,sum(serv.Collect_OnDelivery))  + ','+
			'"TotalServicesCharged":' + CONVERT(VARCHAR,sum(CASE WHEN Settlement_Collect_OnDelivery > 0 THEN Collect_OnDelivery ELSE 0 END)) + ','+ 				
			'"TotalServicesPaid":' + CONVERT(VARCHAR,sum(CASE WHEN paidGuide.Deposit_Number IS NOT NULL THEN Settlement_Collect_OnDelivery ELSE 0 END)) + ','+
			'"TotalNumberOfGuidesDelivered":' + CONVERT(VARCHAR,SUM(CASE WHEN Serv.Guide_Number IS NOT NULL THEN 1 ELSE 0 END)) + ','
			,
			'"GuideDetail":' +
			--JSON_QUERY
			--(
			--'[' + 
			CustomDet.jsonDetail 
			--+ ']' 
			+ '}'
			--) 
			
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpclient WITH (NOLOCK)
			ON serv.Sender_ID = vpclient.CodeOfReference		
		JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det
		on serv.Guide_Serie = Det.Guide_Serie
		and serv.Guide_Number = Det.Guide_Number
		and Det.Guide_Delivered = 1
		and Det.Guide_Discharged = 1
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   Det.ID_DeliveryOrderBySettlement = Head.ID
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'	 
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PaidHead
			on PaidHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PaidHead.IdStatus = 1
		LEFT JOIN #GuidesDelivered Deliv
		   on Deliv.Guide_Serie = Serv.Guide_Serie 
		   and Deliv.Guide_Number = Serv.Guide_Number
		
		LEFT JOIN @CustomersDetail CustomDet on vpclient.CustomerID = CustomDet.IdCustomer
		JOIN DeliveryBackOffice.dbo.Customer Ctm on Ctm.IdCustomer = vpclient.CustomerID
		
		WHERE
		(
		 @Parameter3 = '-1'
		 or (
		     @Parameter3 = 1 and CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
			)
		 or (
			 @Parameter3 = 2 and CONVERT(DATE, PaidHead.Manifest_Date) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
		    )
		)		
		   --Filtrar por fecha de liquidación		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		AND 
		 (@Parameter3 = '-1' 
		 or (@Parameter3 = 1 and paidguide.Guide_Number IS NULL) --solo cobrado
		 or (@Parameter3 = 2 and paidguide.Guide_Number IS NOT NULL) --pagado
		 )
		GROUP BY Ctm.IdCustomer,Ctm.Name
		--,serv.Sender_FirstName
		,CustomDet.jsonDetail
		FOR XML PATH(''), TYPE
   ).value('.', 'varchar(max)'),1,1,''
              ) + ']'

  )

  

  --Grand Total
  /*
    SET @jsonOutputTotal = 
  (

SELECT  
			sum(CASE WHEN Settlement_Collect_OnDelivery > 0 THEN Collect_OnDelivery ELSE 0 END) TotalServicesCharged, 
			sum(CASE WHEN paidGuide.Deposit_Number IS NOT NULL THEN Settlement_Collect_OnDelivery ELSE 0 END) TotalServicesPaid,			
			sum(CASE WHEN Serv.Guide_Number IS NOT NULL THEN 1 ELSE 0 END) TotalNumberOfGuidesDelivered
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)				
		JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det
		on serv.Guide_Serie = Det.Guide_Serie
		and serv.Guide_Number = Det.Guide_Number
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   Det.ID_DeliveryOrderBySettlement = Head.ID
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'	 
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PaidHead
			on PaidHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PaidHead.IdStatus = 1			
		LEFT JOIN #GuidesDelivered Deliv
		   on Deliv.Guide_Serie = Serv.Guide_Serie 
		   and Deliv.Guide_Number = Serv.Guide_Number		
		WHERE
		(
		 @Parameter3 = '-1'
		 or (
		     @Parameter3 = 1 and CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
			)
		 or (
			 @Parameter3 = 2 and CONVERT(DATE, PaidHead.Manifest_Date) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
		    )
		)		
		   --Filtrar por fecha de liquidación		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		AND 
		 (@Parameter3 = '-1' 
		 or (@Parameter3 = 1 and paidguide.Guide_Number IS NULL) --solo cobrado
		 or (@Parameter3 = 2 and paidguide.Guide_Number IS NOT NULL) --pagado
		 )
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  )*/



  select 
  --'[' + 
  @jsonOutput 
  --+ ']' 
  FormatJson
  
SET @jsonOutputTotal = 
  (
  
SELECT  '['+ 
STUFF((

		SELECT distinct
			',{"TotalServicesCharged":' + 
			 CONVERT(
			  VARCHAR(MAX),
			   sum(CASE WHEN Settlement_Collect_OnDelivery > 0 THEN Collect_OnDelivery ELSE 0 END)
			        ) 
					+ ','+ 			
			'"TotalServicesPaid":' + 
			 CONVERT(VARCHAR,
			 sum(CASE WHEN paidGuide.Deposit_Number IS NOT NULL THEN Settlement_Collect_OnDelivery 
			    ELSE 0 END)) + ','+			
			'"TotalNumberOfGuidesDelivered":' + 
			 CONVERT(VARCHAR,
			 sum(CASE WHEN Serv.Guide_Number IS NOT NULL THEN 1 ELSE 0 END)) + '}'			 
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)				
		JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det
		on serv.Guide_Serie = Det.Guide_Serie
		and serv.Guide_Number = Det.Guide_Number
		and Det.Guide_Delivered = 1
		and Det.Guide_Discharged = 1
		JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] Head
        on   Det.ID_DeliveryOrderBySettlement = Head.ID and Det.Guide_Delivered = 1
		LEFT JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'	 
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PaidHead
			on PaidHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PaidHead.IdStatus = 1			
		LEFT JOIN #GuidesDelivered Deliv
		   on Deliv.Guide_Serie = Serv.Guide_Serie 
		   and Deliv.Guide_Number = Serv.Guide_Number		
		WHERE
		(
		 @Parameter3 = '-1'
		 or (
		     @Parameter3 = 1 and CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
			)
		 or (
			 @Parameter3 = 2 and CONVERT(DATE, PaidHead.Manifest_Date) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)
		    )
		)		
		   --Filtrar por fecha de liquidación		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		AND 
		 (@Parameter3 = '-1' 
		 or (@Parameter3 = 1 and paidguide.Guide_Number IS NULL) --solo cobrado
		 or (@Parameter3 = 2 and paidguide.Guide_Number IS NOT NULL) --pagado
		 
		 )
		 FOR XML PATH(''), TYPE
		 ).value('.', 'varchar(max)'),1,1,''
              ) 
			  + ']'
		)
			  
  DROP TABLE #GuidesDelivered
  
  select 
  --'[' + 
  @jsonOutputTotal 
  --+ ']' 
  FormatJson
 END
END
