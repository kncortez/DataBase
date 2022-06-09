--exec dbo.GenerateDynamicJSON @Parameter1 ='2020-11-01',@Parameter2='2020-12-09', @Parameter3 = '2'
--DROP PROCEDURE dbo.GenerateDynamicJSON
CREATE PROCEDURE [dbo].[GenerateDynamicJSON_bidcar]
(
  @OperationName varchar(200) = 'GetServicesByDate'
 ,@Parameter1 varchar(200) = '2020-11-12'
 ,@Parameter2 varchar(200) = '2020-11-20'
 ,@Parameter3 varchar(200) = '1' --1 Liquidado, 2 pagado
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
SELECT
Det.Guide_Serie,
Det.Guide_Number,
MAX(Det.DateCreated)
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
group by Det.Guide_Serie,Det.Guide_Number

DECLARE @jsonOutput VARCHAR(MAX)
DECLARE @jsonOutputTotal VARCHAR(MAX)


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
if (@Parameter3 =1)
BEGIN
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
  		WHERE 
  		  CONVERT(DATE, Head.Route_Received)   --Fecha de liquidación
  		  BETWEEN  CONVERT(DATE, @Parameter1) 
  		  AND CONVERT(DATE, @Parameter2)  		  				
  		AND serv.StatusOrderId <> 7 --No esté anulada la guía
  		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0	  		 
  GROUP BY CustomerID 
END
ELSE
BEGIN
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
		JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
			on paidguide.Guide_Serie = serv.Guide_Serie
			and paidguide.Guide_Number = serv.Guide_Number
			and paidguide.Deposit_Number = serv.Deposit_Number
			and paidguide.IdStatus = 'TRUE'
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaidHeader PaidHead
			on PaidHead.IdDeliveryOrderPaid = paidguide.IdDeliveryOrderPaidHeader
			   and PaidHead.IdStatus = 1
		WHERE 
			 CONVERT(DATE, COALESCE(PaidHead.Manifest_Date,COALESCE(paidguide.DateUpdate,paidguide.DateCreated))) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)		   
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0	
		AND paidguide.Guide_Number IS NOT NULL --pagado		 
		GROUP BY CustomerID 
END


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

		if (@Parameter3 = 1)
		BEGIN
	      			set @jsonDetOutput =
	      (
	      SELECT '['+ STUFF(
	         (		
	      	SELECT distinct 		
	      		',{"ReceiverName":"' + UPPER(COALESCE(serv.Receiver_FirstName,'')) + ' '+ UPPER(COALESCE(serv.Receiver_LastName,'')) + '",'+
	      		'"DateDelivery":"'   + CASE WHEN Deliv.DateCreated IS NULL THEN '' ELSE CONVERT(VARCHAR,Deliv.DateCreated,126) END  + '",'+
	      		'"DatePayment":"'     + '",'+
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
	      		'"PayManifest_Date":"' + '",'+
	      		'"PayManifest_Serie":"' + '",'+
	      		'"SenderName":"' + COALESCE(vpclient.ContactName,'') + '",'+
	      		'"PayManifest_Number":"' + 'No aplica"' + '}'
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
	      	LEFT JOIN #GuidesDelivered Deliv
	      	   on Deliv.Guide_Serie = Serv.Guide_Serie 
	      	   and Deliv.Guide_Number = Serv.Guide_Number		   
	      	JOIN DeliveryBackOffice.dbo.Customer Ctm on Ctm.IdCustomer = vpclient.CustomerID
	          WHERE 	      	
	      	     CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
	      	     BETWEEN  CONVERT(DATE, @Parameter1) 
	      	     AND CONVERT(DATE, @Parameter2)	      		
	      	AND serv.StatusOrderId <> 7 --No esté anulada la guía
	      	AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
	      	AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
	      	AND Ctm.IdCustomer = @CustomerItem	      	
	      	AND Det.Guide_Discharged = 1 --Guía fue liquidada
			AND paidguide.Guide_Number IS NULL --Solo liquidado y no pagado
	      	FOR XML PATH(''), TYPE
	      )
	      .value('.', 'varchar(max)'),1,1,''
                    ) + ']'
	      )
		END
		ELSE
		BEGIN



		  		set @jsonDetOutput =
	      (
	      SELECT '['+ STUFF(
	         (		
	      	SELECT distinct 		
	      		',{"ReceiverName":"' + UPPER(COALESCE(serv.Receiver_FirstName,'')) + ' '+ UPPER(COALESCE(serv.Receiver_LastName,'')) + '",'+
	      		'"DateDelivery":"'   + CASE WHEN Deliv.DateCreated IS NULL THEN '' ELSE CONVERT(VARCHAR,Deliv.DateCreated,126) END  + '",'+
	      		'"DatePayment":"'    + CASE WHEN PHead.Manifest_Date IS NULL THEN '' ELSE CONVERT(VARCHAR,COALESCE(PHead.Manifest_Date,COALESCE(paidguide.DateUpdate,paidguide.DateCreated)),126) END  + '",'+
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
	      		'"PayManifest_Date":"' + CASE WHEN COALESCE(PHead.Manifest_Date,NULL) IS NULL THEN '' ELSE CONVERT(VARCHAR,COALESCE(PHead.Manifest_Date,''),126) END + '",'+
	      		'"PayManifest_Serie":"' + CONVERT(VARCHAR,COALESCE(PHead.Manifest_Serie,'')) + '",'+
	      		'"SenderName":"' + COALESCE(vpclient.ContactName,'') + '",'+				
	      		'"PayManifest_Number":' + CONVERT(VARCHAR,COALESCE(PHead.Manifest_Number,'')) 
				+ '}'								
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
	      	JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
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
	      		CONVERT(DATE, COALESCE(PHead.Manifest_Date,COALESCE(paidguide.DateUpdate,paidguide.DateCreated))) --Fecha de pago
	      	    BETWEEN  CONVERT(DATE, @Parameter1) 
	      	    AND CONVERT(DATE, @Parameter2)	     
	      	AND serv.StatusOrderId <> 7 --No esté anulada la guía
	      	AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
	      	AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
	      	AND Ctm.IdCustomer = @CustomerItem
	      	AND paidguide.Guide_Number IS NOT NULL --pagado	      	
	      	AND Det.Guide_Discharged = 1 --Guía fue liquidada
	      	FOR XML PATH(''), TYPE
	      )
	      .value('.', 'varchar(max)'),1,1,''
                    ) + ']'
	      )

		  if (@jsonDetOutput is null)
		  BEGIN
		   print 'No devuelve data'
		   print @CustomerItem
		   print @Parameter1
		   print @Parameter2
		   print @Parameter3
		  END

		END
	
	INSERT INTO @CustomersDetail
	values (@CustomerItem,@jsonDetOutput)

		SET @item_counter= @item_counter + 1
	  END

---

--Mostrar clientes y sus detalles
if (@Parameter3 = 1)
		BEGIN
	     
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
	     			'"TotalNumberOfGuidesDelivered":' + CONVERT(VARCHAR,SUM(CASE WHEN Serv.Guide_Number IS NOT NULL THEN 1 ELSE 0 END)) + ',',
	     			'"GuideDetail":' +	CustomDet.jsonDetail 			 
	     			+ '}'			 	     			
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
	     		LEFT JOIN #GuidesDelivered Deliv
	     		   on Deliv.Guide_Serie = Serv.Guide_Serie 
	     		   and Deliv.Guide_Number = Serv.Guide_Number	     		
	     		LEFT JOIN @CustomersDetail CustomDet on vpclient.CustomerID = CustomDet.IdCustomer
	     		JOIN DeliveryBackOffice.dbo.Customer Ctm on Ctm.IdCustomer = vpclient.CustomerID	     		
	     		WHERE
	     			CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
	     		     BETWEEN  CONVERT(DATE, @Parameter1) 
	     		     AND CONVERT(DATE, @Parameter2)	     				
	     		   --Filtrar por fecha de liquidación		
	     		AND serv.StatusOrderId <> 7 --No esté anulada la guía
	     		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
	     		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
	     		AND Det.Guide_Discharged = 1 --Guía fue liquidada
	     		AND paidguide.Guide_Number IS NULL --solo cobrado
	     		GROUP BY Ctm.IdCustomer,Ctm.Name	     		
	     		,CustomDet.jsonDetail
	     		FOR XML PATH(''), TYPE
	        ).value('.', 'varchar(max)'),1,1,''
	                   ) + ']'
	     
	       )
		END
ELSE
		BEGIN
		     
	     -- SET @jsonOutput = 
	      -- (
	
	     SELECT '['+ STUFF((
	     SELECT  distinct
	     			',{"IdCustomer":' +  CONVERT(varchar,Ctm.IdCustomer) + ','+			
	     			'"Name":"' + Ctm.Name  + '",'+
	     			'"FeeRate":0' + ','+
	     			'"TotalServicesByCollect":' + CONVERT(VARCHAR,sum(serv.Collect_OnDelivery))  + ','+
	     			'"TotalServicesCharged":' + CONVERT(VARCHAR,sum(CASE WHEN Settlement_Collect_OnDelivery > 0 THEN Collect_OnDelivery ELSE 0 END)) + ','+ 				
	     			'"TotalServicesPaid":' + CONVERT(VARCHAR,sum(CASE WHEN paidGuide.Deposit_Number IS NOT NULL THEN Settlement_Collect_OnDelivery ELSE 0 END)) + ','+
	     			'"TotalNumberOfGuidesDelivered":' + CONVERT(VARCHAR,SUM(CASE WHEN Serv.Guide_Number IS NOT NULL THEN 1 ELSE 0 END)) + ',',
	     			'"GuideDetail":' +	CustomDet.jsonDetail 			 
	     			+ '}'			 	     			
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
	     		JOIN DeliveryBackOffice.DBO.DeliveryOrderPaid paidguide
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
	     		 CONVERT(DATE, COALESCE(PaidHead.Manifest_Date,COALESCE(paidguide.DateUpdate,paidguide.DateCreated))) --Fecha de pago
	     		     BETWEEN  CONVERT(DATE, @Parameter1) 
	     		     AND CONVERT(DATE, @Parameter2)
	     		--Filtrar por fecha de liquidación		
	     		AND serv.StatusOrderId <> 7 --No esté anulada la guía
	     		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
	     		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
	     		AND Det.Guide_Discharged = 1 --Guía fue liquidada
	     		AND paidguide.Guide_Number IS NOT NULL --pagado	     		
	     		GROUP BY Ctm.IdCustomer,Ctm.Name
	     		--,serv.Sender_FirstName
	     		,CustomDet.jsonDetail
	     		FOR XML PATH(''), TYPE
	        ).value('.', 'varchar(max)'),1,1,''
	                   ) + ']'
	     
	       --)
		
		END
  --Grand Total 
  /*select 
  --'[' + 
  @jsonOutput 
  --+ ']' 
  FormatJson
  */
if (@Parameter3 = 1)
BEGIN
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
		LEFT JOIN #GuidesDelivered Deliv
		   on Deliv.Guide_Serie = Serv.Guide_Serie 
		   and Deliv.Guide_Number = Serv.Guide_Number		
		WHERE
		CONVERT(DATE, Head.Route_Received)  --Fecha de liquidación
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)			
		   --Filtrar por fecha de liquidación		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		AND paidguide.Guide_Number IS NULL --solo cobrado		
		 FOR XML PATH(''), TYPE
		 ).value('.', 'varchar(max)'),1,1,''
              ) 
			  + ']'
		)
END
ELSE
BEGIN
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
		CONVERT(DATE, COALESCE(PaidHead.Manifest_Date,COALESCE(paidguide.DateUpdate,paidguide.DateCreated))) --Fecha de pago
		     BETWEEN  CONVERT(DATE, @Parameter1) 
		     AND CONVERT(DATE, @Parameter2)				
		   --Filtrar por fecha de liquidación		
		AND serv.StatusOrderId <> 7 --No esté anulada la guía
		AND serv.Collect_OnDelivery > 0 --El collect sea mayor a 0
		AND serv.Dispatched_Date is not null --La guía debe haber sido despachada		
		AND Det.Guide_Discharged = 1 --Guía fue liquidada
		AND paidguide.Guide_Number IS NOT NULL --pagado
		 FOR XML PATH(''), TYPE
		 ).value('.', 'varchar(max)'),1,1,''
              ) 
			  + ']'
		)
END

			  
  DROP TABLE #GuidesDelivered
  
  select 
  --'[' + 
  @jsonOutputTotal 
  --+ ']' 
  FormatJson
 
END
