
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-09-25>
-- Description:	<Description, Obtener data de una guía con incidencia>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetDataforIncidentRegistration]
 @GuideSerie NVARCHAR(2) = 'FD',
 @GuideNumber INT	
AS
BEGIN
	
	SET NOCOUNT ON;


	Select TOP 1 
	       ISNULL(DO.Sender_FirstName +' '+ DO.Sender_LastName,'') AS Sender,
	       SO.OrderDescription,
		   DO.Sender_Phone,
		   ISNULL(DO.Receiver_FirstName +' '+DO.Receiver_LastName,'') AS Receiver,
		   DO.Receiver_Phone,
		   DO.Receiver_Address,
		   DO.Receiver_Department,
		   DO.Receiver_Town,
	       DP.Path_Incident, 
	       DA.Latitude, 
		   DA.Longitude,
		   DO.StatusOrderId,
		    (CASE
                 WHEN CTI.NameIncidence IS NULL THEN
                     NULL
                 ELSE
                     CONCAT(
                               CONVERT(NVARCHAR(4), ATD.GuideDeliveryAttemptCount + 1),
                               '/',
                               CONVERT(NVARCHAR(4), ATD.GuideDeliveryMaxAttemptCount)
                           )
             END
            ) [Attempts],
			CTI.NameIncidence,
			DA.Date_Created,
			CTI.IdIncidenceType,
		ISNULL(CIS.IncidenceTypeName, 'N/A') [TypeOfIncident]
	From [dbo].[DeliveryOrder] DO 
	    INNER JOIN  [dbo].[DeliveryProof] DP
			ON DO.Guide_Serie = DP.Guide_Serie AND DO.Guide_Number = DP.Guide_Number 
	    INNER JOIN  [dbo].[DeliveryAttempt] DA
			ON DP.Guide_Serie = DA.Guide_Serie AND DP.Guide_Number = DA.Guide_Number
		INNER JOIN [dbo].[StatusOrder] SO 
		    ON DO.StatusOrderId = SO.StatusOrderId
	   INNER JOIN [dbo].[DeliveryOrderAttemptData] ATD
	        ON DA.Guide_Serie = ATD.GuideSerie AND DA.Guide_Number = ATD.GuideNumber
	  LEFT JOIN [dbo].[CatTypeIncidence] cti WITH (NOLOCK)
                ON cti.IdIncidenceType = DA.ID_Incident
	 LEFT JOIN [dbo].[CatIncidenceClasification] CIS
		   ON CTI.IncidenceClasificationId = CIS.IdCatIncidenceClasification
	Where  DO.Guide_Number = @GuideNumber  And DO.Guide_Number = @GuideNumber
	       

	
END
GO


