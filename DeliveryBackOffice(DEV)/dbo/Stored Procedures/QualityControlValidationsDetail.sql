--============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-11-16>
-- Description:	<Description,Detalle de historial de valdiaciones de incdiencias>
-- =============================================
-- Author:	 <Brandon, Pedroza>
-- Modified: <2024-08-07>
-- Description:	<Se agrega el simbolo de moneda segun el pais de origen de la guia>
-- =============================================
CREATE PROCEDURE [dbo].[QualityControlValidationsDetail] 
 @StartDate DATE,
 @EndDate DATE
AS
BEGIN
set arithabort on;
	--Incidencias en ruta pendientes de operar
    SELECT 

        DA.Guide_Serie + CONVERT(varchar, DA.Guide_Number) AS Guide,
        SO.OrderDescription,
        DO.Sender_FirstName,
        DO.Sender_Phone,
        DO.Receiver_FirstName,
        DO.Receiver_Phone,
        DO.Receiver_Address,
        CI.DescriptionIncidence,
        hl.HubAbbreviation,
        CONCAT(cur.Symbol, DO.PriceShippment) PriceShippment,
        CONCAT(curCOD.Symbol, ISNULL(DO.Collect_OnDelivery,0)) Collect_OnDelivery,
        COI.LiquidatorRemarks,
        'Pendiente'  Resolucion,
        SR.First_Name+' '+SR.Last_Name Piloto,
        SR.Phone,
        COI.ActionObservation,
        COI.dateCreated,
        RU.UsrNickName,
        CIC.IncidenceTypeName		
    FROM ConfirmationOfIncidence COI WITH (NOLOCK) 
        INNER JOIN DeliveryAttempt DA WITH (NOLOCK)
		ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  
		INNER JOIN 
		DeliveryOrder DO WITH (NOLOCK)
		ON DA.Guide_Serie = DO.Guide_Serie AND DA.Guide_Number = DO.Guide_Number
		--INNER JOIN 
        --DeliveryOrderDetail DOD WITH (NOLOCK) ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number
        INNER JOIN [DeliveryBackOffice].[dbo].[Cost]								co WITH (NOLOCK)
			ON	DO.Guide_Number= co.GuideNumber 
				and DO.Guide_Serie = co.GuideSerie
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						cur WITH (NOLOCK)
			ON ISNULL(co.ShippingCurrency,1) = cur.IdCatCurrencyCOD 
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						curCOD WITH (NOLOCK)
			ON ISNULL(co.CodCurrency,IIF(DO.SenderCountryId='HN',4,1)) = curCOD.IdCatCurrencyCOD 
        OUTER APPLY
		(
		 SELECT TOP 1 DOD.UserCreated FROM  DeliveryOrderDetail DOD WITH (NOLOCK)
		 WHERE DOD.Guide_Serie = DO.Guide_Serie
		 AND DOD.Guide_Number = DO.Guide_Number
		 AND DOD.StatusOrderId = 45		 
		 ORDER BY DOD.DateCreatedInSystem DESC
		)DOD
		INNER JOIN StatusOrder SO WITH (NOLOCK) ON DO.StatusOrderId = SO.StatusOrderId
        INNER JOIN CatTypeIncidence CI WITH (NOLOCK) ON DA.ID_Incident = CI.IdIncidenceType
        --INNER JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbl WITH (NOLOCK) ON tbl.IdTownship = DO.ReceiverIdTownship
        OUTER APPLY
		(
		 SELECT hub.HubAbbreviation FROM  dbo.Township twn WITH (NOLOCK)                       
                    LEFT JOIN dbo.Township twc WITH (NOLOCK)
                        ON twc.TownshipName = DO.Receiver_Town
                    LEFT JOIN
                    (
                        SELECT CV.HeaderCode,
                               MAX(CV.Hub) HUB
                        FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
                        GROUP BY CV.HeaderCode
                    ) HB
                        ON HB.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
                    LEFT JOIN dbo.HubLogistics hub WITH (NOLOCK)
                        ON hub.HubAbbreviation = HB.HUB
		 WHERE twn.IdTownship = DO.ReceiverIdTownship
		) hl
		--INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl WITH (NOLOCK) ON tbl.IdHublogistic = hl.IdHublogistic
        LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK) ON DA.ID_Courier= SR.ID
        LEFT JOIN [dbo].[TokenLog] TL WITH (NOLOCK) ON CONVERT(VARCHAR(50),DOD.UserCreated) = TL.TknTokenCreated
        LEFT JOIN [dbo].[RegisterUser] RU WITH (NOLOCK) ON TL.TknIdUser = RU.UsrIdUser
        LEFT JOIN [DBO].[CatIncidenceClasification] CIC WITH (NOLOCK) ON CI.IncidenceClasificationId = CIC.IdCatIncidenceClasification
    WHERE
        CONVERT(DATE, COI.DateCreated) BETWEEN @StartDate AND @EndDate
      AND COI.IsConfirmed = 0 
      AND DA.Delivered = 0
      AND COI.StatusOrderId = 45
	UNION
	SELECT 

        DA.Guide_Serie + CONVERT(varchar, DA.Guide_Number) AS Guide,
        SO.OrderDescription,
        DO.Sender_FirstName,
        DO.Sender_Phone,
        DO.Receiver_FirstName,
        DO.Receiver_Phone,
        DO.Receiver_Address,
        CI.DescriptionIncidence,
        hl.HubAbbreviation,
        CONCAT(cur.Symbol, DO.PriceShippment) PriceShippment,
        CONCAT(curCOD.Symbol,ISNULL(DO.Collect_OnDelivery,0)) Collect_OnDelivery,
        COI.LiquidatorRemarks,
        IIF(ISNULL(COI.IsDenied,0) = 1,'Rechazada','Aprobada') Resolucion,
        SR.First_Name+' '+SR.Last_Name Piloto,
        SR.Phone,
        COI.ActionObservation,
        COI.dateCreated,
        RU.UsrNickName,
        CIC.IncidenceTypeName		
    FROM ConfirmationOfIncidence COI WITH (NOLOCK) 
        INNER JOIN DeliveryAttempt DA WITH (NOLOCK)
		ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  
		INNER JOIN 
		DeliveryOrder DO WITH (NOLOCK)
		ON DA.Guide_Serie = DO.Guide_Serie AND DA.Guide_Number = DO.Guide_Number
		--INNER JOIN 
        --DeliveryOrderDetail DOD WITH (NOLOCK) ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number
        INNER JOIN [DeliveryBackOffice].[dbo].[Cost]								co WITH (NOLOCK)
			ON	DO.Guide_Number= co.GuideNumber 
				and DO.Guide_Serie = co.GuideSerie
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						cur WITH (NOLOCK)
			ON ISNULL(co.ShippingCurrency,1) = cur.IdCatCurrencyCOD 
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						curCOD WITH (NOLOCK)
			ON ISNULL(co.CodCurrency,IIF(DO.SenderCountryId='HN',4,1)) = curCOD.IdCatCurrencyCOD 
        OUTER APPLY
		(
		 SELECT TOP 1 DOD.UserCreated FROM  DeliveryOrderDetail DOD WITH (NOLOCK)
		 WHERE DOD.Guide_Serie = DO.Guide_Serie
		 AND DOD.Guide_Number = DO.Guide_Number
		 AND DOD.StatusOrderId = 50		 
		 ORDER BY DOD.DateCreatedInSystem DESC
		)DOD
		INNER JOIN StatusOrder SO WITH (NOLOCK) ON DO.StatusOrderId = SO.StatusOrderId
        INNER JOIN CatTypeIncidence CI WITH (NOLOCK) ON DA.ID_Incident = CI.IdIncidenceType
        --INNER JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbl WITH (NOLOCK) ON tbl.IdTownship = DO.ReceiverIdTownship
        OUTER APPLY
		(
		 SELECT hub.HubAbbreviation FROM  dbo.Township twn WITH (NOLOCK)                       
                    LEFT JOIN dbo.Township twc WITH (NOLOCK)
                        ON twc.TownshipName = DO.Receiver_Town
                    LEFT JOIN
                    (
                        SELECT CV.HeaderCode,
                               MAX(CV.Hub) HUB
                        FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
                        GROUP BY CV.HeaderCode
                    ) HB
                        ON HB.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
                    LEFT JOIN dbo.HubLogistics hub WITH (NOLOCK)
                        ON hub.HubAbbreviation = HB.HUB
		 WHERE twn.IdTownship = DO.ReceiverIdTownship
		) hl
		--INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl WITH (NOLOCK) ON tbl.IdHublogistic = hl.IdHublogistic
        LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK) ON DA.ID_Courier= SR.ID
        LEFT JOIN [dbo].[TokenLog] TL WITH (NOLOCK) ON CONVERT(VARCHAR(50),DOD.UserCreated) = TL.TknTokenCreated
        LEFT JOIN [dbo].[RegisterUser] RU WITH (NOLOCK) ON TL.TknIdUser = RU.UsrIdUser
        LEFT JOIN [DBO].[CatIncidenceClasification] CIC WITH (NOLOCK) ON CI.IncidenceClasificationId = CIC.IdCatIncidenceClasification
    WHERE
        CONVERT(DATE, COI.DateCreated) BETWEEN @StartDate AND @EndDate
      AND COI.IsConfirmed = 1 
      AND DA.Delivered = 0
      AND COI.StatusOrderId=50
   
END

	
	  
	

 