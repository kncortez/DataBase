


-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-12-08>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (COD)>
-- =============================================
-- =============================================
-- Author:		<Oscar, Rodriguez>
-- Modification date: <2024-06-19>
-- Description:	<Devuelve información para liquidación de COD filtrado por pais, y montos de moneda modificado para interpais, multimoneda y multipais>
-- =============================================
-- =============================================
-- Author:      <Edelman>
-- Create date: <2026-01-21>
-- Description: <Agregar parámetro Voucher y  tipo de pago>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_cod_guides]
		@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @IdManifest AS INT = 32181;
	SELECT do.Guide_Serie + ISNULL(CONVERT(NVARCHAR, do.Guide_Number), '') Guide_Code,
		   do.Pieces_Cold Pieces_Cold,
		   do.Pieces_Dry Pieces_Dry,
		   (CASE WHEN [do].[IsLastMileReturn] = 1 THEN IIF(cu.Name = 'FD EXPRESS CENTER', CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName), cu.Name) ELSE ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') END) Receiver_Fullname,
		   (CASE WHEN do.[IsLastMileReturn] = 1 THEN ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') ELSE IIF(cu.Name = 'FD EXPRESS CENTER', CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName), cu.Name) END) AS Client,
		   (CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Town] ELSE do.Receiver_Town END) Receiver_Town,
		   (CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Department] ELSE do.Receiver_Department END) Receiver_Departament,
		   CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) Preparation_Date,
		   CONVERT(VARCHAR, do.Shipping_Date, 103) Shipping_Date,
		   ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103), '') Max_Date,
		   (CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Phone] ELSE do.Receiver_Phone END) Receiver_Phone,
		   (
			   SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)
		   ) Rack_Position,
		   CAST(IIF(do.IsCollect = 'TRUE', IIF(do.IsLastMileReturn = 1, ISNULL(CASE WHEN ISNULL(cdp.IdConditionOfPayment, 1) > 1 THEN 0 ELSE do.PriceShippment END, 0), 
		   
		    --sino es una devolución que hago?
                        IIF(A1.ReasonCode = '00', 0, do.PriceShippment)
		   --do.PriceShippment
		   
		   ), 0) AS DECIMAL(18, 2)) Price,
		   CAST(ISNULL((CASE WHEN do.[IsLastMileReturn] = 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.Collect_OnDelivery / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.Collect_OnDelivery * c.codExchangeRate) * c.CODPaymentExchangeRate), do.Collect_OnDelivery) END), 0) AS DECIMAL(18, 2)) Collect_on_Delivery,
		   CAST(IIF(do.IsCollect = 'TRUE',
					(ISNULL((CASE WHEN do.[IsLastMileReturn] = 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.Collect_OnDelivery / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.Collect_OnDelivery * c.codExchangeRate) * c.CODPaymentExchangeRate), do.Collect_OnDelivery) END), 0) + IIF(do.IsLastMileReturn = 1, ISNULL(CASE WHEN ISNULL(cdp.IdConditionOfPayment, 1) > 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.PriceShippment / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.PriceShippment * c.codExchangeRate) * c.CODPaymentExchangeRate), do.PriceShippment) END, 0), 
					--do.PriceShippment
					 IIF(A1.ReasonCode = '00', 0, do.PriceShippment)
					)),
					ISNULL((CASE WHEN do.[IsLastMileReturn] = 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.Collect_OnDelivery / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.Collect_OnDelivery * c.codExchangeRate) * c.CODPaymentExchangeRate), do.Collect_OnDelivery) END), 0)) AS DECIMAL(18, 2)) Total,
		   do.Receiver_ID Receiver_ID,
		   REPLACE(REPLACE(REPLACE(dc.Symbol,'.',''),'(',''),')','') [Currency_Symbol],
		   cd.Voucher,
		   CASE 
		      WHEN cd.IdTypeOfMoney = 11 THEN 'Transferencia'
			  WHEN cd.IdTypeOfMoney = 1  THEN 'Efectivo'
			  WHEN cd.IdTypeOfMoney = 2  THEN 'Pago con Tarjeta'
			  WHEN cd.IdTypeOfMoney = 10 THEN 'Zigi'
	          ELSE 'Pago preautorizado'
		  END PaymentMethod
	FROM [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd WITH(NOLOCK)
			ON dsd.Guide_Serie = do.Guide_Serie
			   AND dsd.Guide_Number = do.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vp WITH(NOLOCK)
			ON do.Receiver_ID = vp.CodeOfReference
		LEFT JOIN [dbo].VisitPointClient vps WITH(NOLOCK)
			ON vps.CodeOfReference = do.Sender_ID
		LEFT JOIN [dbo].[Customer] cu WITH(NOLOCK)
			ON ISNULL(do.[IdCustomer], vps.CustomerID) = cu.[IdCustomer]
		LEFT JOIN dbo.CatConditionOfPayment cdp WITH (NOLOCK)
            ON cdp.IdConditionOfPayment = cu.ConditionOfPaymentID
               AND cdp.IdConditionOfPayment > 1
		LEFT JOIN dbo.Cost c WITH (NOLOCK)
            ON c.GuideSerie	= do.guide_Serie AND c.GuideNumber = do.guide_number
		LEFT JOIN dbo.CatCurrencyCOD dc WITH (NOLOCK)
            ON dc.IdCatCurrencyCOD = ISNULL(c.ShippingCurrency,1)
        LEFT JOIN dbo.CreditCardTransactionByCustomer A1 WITH (NOLOCK)
            ON A1.OrderNumber = do.Guide_Serie + CONVERT(VARCHAR, do.Guide_Number)
               AND A1.ReasonCode = '00'
		LEFT JOIN dbo.CostDetail cd WITH (NOLOCK)
            ON c.IdCost = cd.IdCost
	WHERE dsd.Guide_Settlement = 1 -- guía liquidada en bodega
		  AND dsd.Guide_Discharged = 1 -- guía liquidada en COD
		  AND
		  (
			  vp.IdKindOfVPClient <> 1
			  OR vp.IdKindOfVPClient IS NULL
		  )
		 AND dsd.Guide_Delivered =1
		 AND dsd.ID_DeliveryOrderBySettlement = @IdManifest
		 AND dsd.RowStatus = 1
	ORDER BY Receiver_Departament ASC,
			 Receiver_Town ASC,
			 Receiver_Zone ASC,
			 Receiver_Address ASC;
		--SELECT * FROM @temp
		--order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END