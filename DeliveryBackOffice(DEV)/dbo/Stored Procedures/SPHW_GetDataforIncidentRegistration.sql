
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-09-25>
-- Description:	<Description, Obtener data de una guía con incidencia>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-07-19>
-- Description:	<validar si un agente está operando una incidencia Ref. FDAPI-2283>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-07-23>
-- Description:	<Se agrega un nuevo campo en la respuesta para regresar el comentario que ingreso el piloto Ref. FDAPI-2296>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetDataforIncidentRegistration]
 @GuideSerie NVARCHAR(2) = 'FD',
 @GuideNumber INT,
 @UserId INT,
 @UserName NVARCHAR(100) = ''

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ConfirmationOfIncidenceId INT
	DECLARE @TakenUserId INT
	DECLARE @TakenUserName VARCHAR(100)
	DECLARE @TakenDate DATETIME
	DECLARE @isConfirmed INT
	DECLARE @Message VARCHAR(100) = 'FREE'

	SELECT @TakenUserId = coi.TakenIncidenceUserId
		,@TakenUserName = coi.TakenIncidenceUserName
		,@TakenDate = coi.TakenIncidenceDateAndTime
		,@ConfirmationOfIncidenceId = da.ConfirmationOfIncidenceId
		,@isConfirmed = coi.IsConfirmed
	FROM [dbo].[ConfirmationOfIncidence] coi WITH (NOLOCK)
		INNER JOIN [dbo].[DeliveryAttempt] da WITH (NOLOCK) ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
	WHERE da.Guide_Number = @GuideNumber
		AND da.Guide_Serie = @GuideSerie
		AND coi.TakenIncidenceDateAndTime IS NOT NULL
		AND coi.TakenIncidenceDateAndTime > DATEADD(MINUTE, -10, GETDATE())

	IF ((@TakenUserId IS NOT NULL AND @TakenUserId != @UserId) AND @isConfirmed = 0)
	BEGIN
		SET @Message = 'TAKEN'
	END;

	SELECT @Message AS Message,  ISNULL(@TakenUserName,@UserName) AS TakenByUserName

	IF (@Message = 'FREE')
	BEGIN

		SELECT 
			@isConfirmed = coi.IsConfirmed,
			@ConfirmationOfIncidenceId = da.ConfirmationOfIncidenceId
		FROM [dbo].[ConfirmationOfIncidence] coi
			INNER JOIN [dbo].[DeliveryAttempt] da ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
		WHERE da.Guide_Number = @GuideNumber
			AND da.Guide_Serie = @GuideSerie

		IF (@isConfirmed = 0)
		BEGIN
			-- Actualizar el registro con el usuario que solicito
			UPDATE [dbo].[ConfirmationOfIncidence] SET TakenIncidenceUserId = @UserId, TakenIncidenceUserName = @UserName,  TakenIncidenceDateAndTime = GETDATE() 
			WHERE IdConfirmationOfIncidence = @ConfirmationOfIncidenceId
		END;

		DECLARE @Terminal INT =
		(
				SELECT Top 1 [SO].[CatCheckpointTypeId]
			FROM [dbo].[DeliveryOrder] [DO] WITH (NOLOCK)
				INNER JOIN [dbo].[StatusOrder] [SO] WITH (NOLOCK)
					ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
			WHERE [SO].[RowStatus] = 1
					AND [DO].[Guide_Serie] = @GuideSerie and [DO].[Guide_Number]  =  @GuideNumber
		);

		SELECT TOP 1 
			   ISNULL(DO.Sender_FirstName +' '+ DO.Sender_LastName,'') AS Sender,
			   SO.OrderDescription AS [Status],
			   DO.Sender_Phone,
			   ISNULL(DO.Receiver_FirstName,'') +' '+ISNULL(DO.Receiver_LastName,'') AS Receiver,
			   DO.Receiver_Phone,
			  ( CASE 
					 WHEN DO.IdDeliveryOption = 3 THEN VPC.DescriptionOfClient 
						ELSE
						DO.Receiver_Address 
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
						 WHEN cfi.IsDenied = 0 THEN
							 'Rechazada'
						 ELSE
							 'Aprobada'
					 END
					)
					 END
					) [StatusOfIncident],
					ISNULL(DO.IdDeliveryOption,1) AS IdDeliveryOption,
					cfi.ActionObservation AS TrackingObservations,
					cfi.LiquidatorRemarks AS LiquidationObservations,
					@Terminal  AS 'boolResult',
					CASE 
						WHEN @Terminal = 3 THEN 'Guía en estado terminal,no es posible confirmar incidencia.'
						ELSE 'Incidencia confirmada Exitosamente.'
				   END
				   AS 'DescriptionResult',
				cfi.CommentOnIncident 
		FROM [dbo].[DeliveryOrder] DO WITH (NOLOCK)
			LEFT JOIN  [dbo].[DeliveryProof] DP WITH (NOLOCK)
				ON DO.Guide_Serie = DP.Guide_Serie AND DO.Guide_Number = DP.Guide_Number 
			OUTER APPLY(
			SELECT TOP 1 DA.* FROM [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH(NOLOCK)
					ON DOD.Guide_Serie = DA.Guide_Serie
					AND DOD.Guide_Number = DA.Guide_Number
					AND DA.ID = DOD.DeliveryAttemptId
					AND DOD.StatusOrderId = 45 --Incidencia en ruta
					AND DOD.RowStatus = 1
				WHERE DO.Guide_Serie = DA.Guide_Serie AND DO.Guide_Number = DA.Guide_Number
				ORDER BY DOD.DateCreatedInSystem DESC
			)DA		
			INNER JOIN [dbo].[StatusOrder] SO WITH (NOLOCK)
				ON DO.StatusOrderId = SO.StatusOrderId
		   LEFT JOIN [dbo].[DeliveryOrderAttemptData] ATD WITH (NOLOCK)
				ON DA.Guide_Serie = ATD.GuideSerie AND DA.Guide_Number = ATD.GuideNumber
		  LEFT JOIN [dbo].[CatTypeIncidence] cti WITH (NOLOCK)
					ON cti.IdIncidenceType = DA.ID_Incident
		 LEFT JOIN [dbo].[CatIncidenceClasification] CIS WITH (NOLOCK)
			   ON CTI.IncidenceClasificationId = CIS.IdCatIncidenceClasification
		LEFT JOIN [dbo].[VisitPointClient] VPC WITH (NOLOCK)
			  ON DO.Receiver_ID = VPC.CodeOfReference
	   LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
			 ON cfi.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
		Where  DO.Guide_Serie = @GuideSerie  And DO.Guide_Number = @GuideNumber


		SELECT  TOP 1
			   IIF(DOD.SystemOrigin != 2,DP.Path_Incident,'') AS Path_Incident	     
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH(NOLOCK)				   
			LEFT JOIN  [dbo].[DeliveryProof] DP WITH (NOLOCK)
				ON DOD.Guide_Serie = DP.Guide_Serie 
				AND DOD.Guide_Number = DP.Guide_Number
			LEFT JOIN  [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
				ON DOD.Guide_Serie = DA.Guide_Serie 
				AND DOD.Guide_Number = DA.Guide_Number
				AND DOD.DeliveryAttemptId = DA.ID		
				AND DA.ID_Proof = DP.ID		 			
		WHERE		
		DOD.Guide_Serie = @GuideSerie  
		AND DOD.Guide_Number = @GuideNumber
		AND DOD.StatusOrderId = 45 
		AND DOD.RowStatus = 1
		ORDER BY DP.Date_Photo DESC
	END;
END;

