--============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-11-16>
-- Description:	<Description,Detalle de historial de valdiaciones de incdiencias>
-- =============================================
Create PROCEDURE [QualityControlValidationsDetail] 
 @StartDate DATE,
 @EndDate DATE
AS
BEGIN

    
	

 WITH CTE AS (
    SELECT
        DA.Guide_Serie + CONVERT(varchar, DA.Guide_Number) AS Guide,
        SO.OrderDescription,
        DO.Sender_FirstName,
        CONVERT(VARCHAR(8),DO.Sender_Phone) Sender_Phone,
        DO.Receiver_FirstName,
        DO.Receiver_Phone,
        DO.Receiver_Address,
        CI.DescriptionIncidence,
        hl.HubAbbreviation,
        DO.PriceShippment,
        ISNULL(DO.Collect_OnDelivery,0) Collect_OnDelivery,
        COI.LiquidatorRemarks,
        'Pendiente'  Resolucion,
        SR.First_Name+' '+SR.Last_Name Piloto,
        SR.Phone,
        COI.ActionObservation,
        COI.dateCreated,
        RU.UsrNickName,
        CIC.IncidenceTypeName,
        ROW_NUMBER() OVER (PARTITION BY DA.Guide_Number ORDER BY COI.dateCreated DESC) AS RowNum
    FROM ConfirmationOfIncidence COI WITH (NOLOCK) 
        INNER JOIN DeliveryAttempt DA WITH (NOLOCK)
		ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  AND COI.IsConfirmed = 0 And COI.IsDenied = 0  And COI.StatusOrderId=45
		INNER JOIN 
		DeliveryOrder DO WITH (NOLOCK)
		ON DA.Guide_Serie = DO.Guide_Serie AND DA.Guide_Number = DO.Guide_Number
		INNER JOIN 
        DeliveryOrderDetail DOD WITH (NOLOCK) ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number
        INNER JOIN StatusOrder SO WITH (NOLOCK) ON DOD.StatusOrderId = SO.StatusOrderId
        INNER JOIN CatTypeIncidence CI WITH (NOLOCK) ON DA.ID_Incident = CI.IdIncidenceType
        INNER JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbl WITH (NOLOCK) ON tbl.IdTownship = DO.ReceiverIdTownship
        INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl WITH (NOLOCK) ON tbl.IdHublogistic = hl.IdHublogistic
        LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK) ON DA.ID_Courier= SR.ID
        LEFT JOIN [dbo].[TokenLog] TL WITH (NOLOCK) ON CONVERT(VARCHAR(50),DOD.UserCreated) = TL.TknTokenCreated
        LEFT JOIN [dbo].[RegisterUser] RU WITH (NOLOCK) ON TL.TknIdUser = RU.UsrIdUser
        LEFT JOIN [DBO].[CatIncidenceClasification] CIC WITH (NOLOCK) ON CI.IncidenceClasificationId = CIC.IdCatIncidenceClasification
    WHERE
        CONVERT(DATE, COI.DateCreated) BETWEEN @StartDate AND @EndDate
)
SELECT
    Guide,
    OrderDescription,
    Sender_FirstName,
    Sender_Phone,
    Receiver_FirstName,
    Receiver_Phone,
    Receiver_Address,
    DescriptionIncidence,
    HubAbbreviation,
    PriceShippment,
    Collect_OnDelivery,
    LiquidatorRemarks,
    Resolucion,
    Piloto,
    Phone,
    ActionObservation,
    dateCreated,
    UsrNickName,
    IncidenceTypeName
FROM CTE
WHERE RowNum = 1

UNION

SELECT
    Guide,
    OrderDescription,
    Sender_FirstName,
    Sender_Phone,
    Receiver_FirstName,
    Receiver_Phone,
    Receiver_Address,
    DescriptionIncidence,
    HubAbbreviation,
    PriceShippment,
    Collect_OnDelivery,
    LiquidatorRemarks,
    'Procesada'
       Resolucion,
    Piloto,
    Phone,
    ActionObservation,
    dateCreated,
    UsrNickName,
    IncidenceTypeName
FROM (
    SELECT
        DA.Guide_Serie + CONVERT(varchar, DA.Guide_Number) AS Guide,
        SO.OrderDescription,
        DO.Sender_FirstName,
        CONVERT(VARCHAR(8),DO.Sender_Phone) Sender_Phone,
        DO.Receiver_FirstName,
        DO.Receiver_Phone,
        DO.Receiver_Address,
        CI.DescriptionIncidence,
        hl.HubAbbreviation,
        DO.PriceShippment,
        ISNULL(DO.Collect_OnDelivery,0) Collect_OnDelivery,
        COI.LiquidatorRemarks,
        COI.IsDenied,
        COI.IsConfirmed,
        SR.First_Name+' '+SR.Last_Name Piloto,
        SR.Phone,
        COI.ActionObservation,
        COI.dateCreated,
        RU.UsrNickName,
        CIC.IncidenceTypeName,
        ROW_NUMBER() OVER (PARTITION BY DA.Guide_Number ORDER BY COI.dateCreated DESC) AS RowNum
    FROM ConfirmationOfIncidence COI WITH (NOLOCK) 
        INNER JOIN DeliveryAttempt DA WITH (NOLOCK) ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence  AND COI.IsConfirmed = 1    AND COI.StatusOrderId=50
		INNER JOIN DeliveryOrder DO WITH (NOLOCK) ON DA.Guide_Serie = DO.Guide_Serie AND DA.Guide_Number = DO.Guide_Number
		INNER JOIN DeliveryOrderDetail DOD WITH (NOLOCK) ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number
        INNER JOIN StatusOrder SO WITH (NOLOCK) ON DOD.StatusOrderId = SO.StatusOrderId
        INNER JOIN CatTypeIncidence CI WITH (NOLOCK) ON DA.ID_Incident = CI.IdIncidenceType
        INNER JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbl WITH (NOLOCK) ON tbl.IdTownship = DO.ReceiverIdTownship
        INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl WITH (NOLOCK) ON tbl.IdHublogistic = hl.IdHublogistic
        LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK) ON DA.ID_Courier= SR.ID
        LEFT JOIN [dbo].[TokenLog] TL WITH (NOLOCK) ON CONVERT(VARCHAR(50),DOD.UserCreated) = TL.TknTokenCreated
        LEFT JOIN [dbo].[RegisterUser] RU WITH (NOLOCK) ON TL.TknIdUser = RU.UsrIdUser
        LEFT JOIN [DBO].[CatIncidenceClasification] CIC WITH (NOLOCK) ON CI.IncidenceClasificationId = CIC.IdCatIncidenceClasification
    WHERE
        CONVERT(DATE, COI.DateCreated) BETWEEN @StartDate AND @EndDate
) AS Subquery
WHERE RowNum = 1;

END

	
	  
	

 