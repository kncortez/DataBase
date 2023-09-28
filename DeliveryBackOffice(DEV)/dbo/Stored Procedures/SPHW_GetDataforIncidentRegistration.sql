
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
	       SO.OrderDescription AS [Status],
		   DO.Sender_Phone,
		   ISNULL(DO.Receiver_FirstName,'') +' '+ISNULL(DO.Receiver_LastName,'') AS Receiver,
		   DO.Receiver_Phone,
		  ( CASE 
		       WHEN DO.IdDeliveryOption = 1 THEN DO.Receiver_Address ELSE
			   VPC.DescriptionOfClient
			   END 
			   
			        ) Receiver_Address,
		   DO.Receiver_Id,
		   DO.Receiver_Department,
		   DO.Receiver_Town, 
	       DA.Latitude, 
		   DA.Longitude,
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
		ISNULL(CIS.IncidenceTypeName, 'N/A') [TypeOfIncident],
		 (CASE
                     WHEN cfi.IsConfirmed IS NULL THEN
                         NULL
                     WHEN cfi.IsConfirmed = 0 THEN
                         'Pendiente'
                     ELSE
                (CASE
                     WHEN cfi.IsValid = 1 THEN
                         'Real'
                     ELSE
                         'Falsa'
                 END
                )
                 END
                ) [StatusOfIncident],
				DO.IdDeliveryOption,
				'' AS TrackingObservations,
				'' AS LiquidationObservations
	From [dbo].[DeliveryOrder] DO WITH (NOLOCK)
	    INNER JOIN  [dbo].[DeliveryProof] DP WITH (NOLOCK)
			ON DO.Guide_Serie = DP.Guide_Serie AND DO.Guide_Number = DP.Guide_Number 
	    INNER JOIN  [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
			ON DP.Guide_Serie = DA.Guide_Serie AND DP.Guide_Number = DA.Guide_Number
		INNER JOIN [dbo].[StatusOrder] SO WITH (NOLOCK)
		    ON DO.StatusOrderId = SO.StatusOrderId
	   INNER JOIN [dbo].[DeliveryOrderAttemptData] ATD WITH (NOLOCK)
	        ON DA.Guide_Serie = ATD.GuideSerie AND DA.Guide_Number = ATD.GuideNumber
	  LEFT JOIN [dbo].[CatTypeIncidence] cti WITH (NOLOCK)
                ON cti.IdIncidenceType = DA.ID_Incident
	 LEFT JOIN [dbo].[CatIncidenceClasification] CIS WITH (NOLOCK)
		   ON CTI.IncidenceClasificationId = CIS.IdCatIncidenceClasification
	LEFT JOIN [dbo].[VisitPointClient] VPC WITH (NOLOCK)
	      ON DO.Receiver_ID = VPC.CodeOfReference
   LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
         ON cfi.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
	Where  DO.Guide_Number = @GuideNumber  And DO.Guide_Number = @GuideNumber


	Select  TOP 1
	       DP.Path_Incident
	From [dbo].[DeliveryOrder] DO WITH (NOLOCK)
	    INNER JOIN  [dbo].[DeliveryProof] DP WITH (NOLOCK)
			ON DO.Guide_Serie = DP.Guide_Serie AND DO.Guide_Number = DP.Guide_Number 
	    INNER JOIN  [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
			ON DP.Guide_Serie = DA.Guide_Serie AND DP.Guide_Number = DA.Guide_Number
	Where  DO.Guide_Number = @GuideNumber  And DO.Guide_Number = @GuideNumber
	       

	
END
GO


