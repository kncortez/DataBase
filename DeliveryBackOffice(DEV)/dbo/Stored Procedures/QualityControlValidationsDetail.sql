============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-11-16>
-- Description:	<Description,Detalle de historial de valdiaciones de incdiencias>
-- =============================================
Create PROCEDURE [QualityControlValidationsDetail] 
 @StartDate DATE,
 @EndDate DATE
AS
BEGIN

  
	
	SET NOCOUNT ON;

	WITH RankedGuides AS (
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
	    DO.PriceShippment,
		ISNULL(DO.Collect_OnDelivery,0) Collect_OnDelivery,
	    COI.LiquidatorRemarks,
		CASE WHEN COI.IsConfirmed = 0 And COI.IsDenied = 0 And DOD.StatusOrderId = 45 AND DOD.StatusOrderId NOT IN (50)
		        THEN 'Pendiente' 
			WHEN (COI.IsConfirmed = 1 Or COI.IsDenied = 1) And DOD.StatusOrderId = 50 
		        THEN 'Procesada' 
			ELSE 'N/A' END Resolucion,
			SR.First_Name+' '+SR.Last_Name Piloto,
			SR.Phone,
			COI.ActionObservation,
			COI.dateCreated,
			RU.UsrNickName,
        ROW_NUMBER() OVER (PARTITION BY DA.Guide_Number ORDER BY CASE WHEN DOD.StatusOrderId = 50 THEN 0 ELSE 1 END, DOD.StatusOrderId) AS RowNum
    FROM
        DeliveryOrder DO WITH (NOLOCK)
        INNER JOIN DeliveryOrderDetail DOD WITH (NOLOCK) ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number
        INNER JOIN DeliveryAttempt DA WITH (NOLOCK) ON DOD.Guide_Number = DA.Guide_Number
        INNER JOIN ConfirmationOfIncidence COI WITH (NOLOCK) ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        INNER JOIN StatusOrder SO WITH (NOLOCK) ON DOD.StatusOrderId = SO.StatusOrderId
        INNER JOIN CatTypeIncidence CI WITH (NOLOCK) ON DA.ID_Incident = CI.IdIncidenceType
		INNER JOIN  DeliveryBackOffice.dbo.TownshipByHubLogistic tbl WITH (NOLOCK) ON tbl.IdTownship = DO.ReceiverIdTownship
		INNER JOIN  DeliveryBackOffice.dbo.HubLogistics hl WITH (NOLOCK) ON tbl.IdHublogistic = hl.IdHublogistic
		LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK) ON DA.ID_Courier= SR.ID
		LEFT JOIN [dbo].[TokenLog] TL WITH (NOLOCK)
                        ON DOD.UserCreated = TL.TknTokenCreated
                    LEFT JOIN [dbo].[RegisterUser] RU WITH (NOLOCK)
                        ON TL.TknIdUser = RU.UsrIdUser
    WHERE
        DOD.StatusOrderId IN (45, 50)
        AND CONVERT(DATE, DA.Date_Created) BETWEEN @StartDate AND @EndDate
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
	Resolucion,
	Piloto,
	Phone,
	ActionObservation,
	CONVERT(varchar,dateCreated,110) dateCreated,
	UsrNickName
FROM
    RankedGuides
WHERE
    RowNum = 1;
   
END
GO









