-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2023-02-16>
-- Description:	<Sp detalle de visitas fallidas>
-- =============================================
CREATE PROCEDURE [dbo].[RptFailedVisitsDitail] 
@DateOf DateTime,
@DateTo DateTime,
@IdHub nvarchar,
@IdCourier nvarchar = null
AS
BEGIN
	
	SET NOCOUNT ON;
	 DECLARE @IdDeliveryFail     NVARCHAR(100) = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Intento de entrega fallida')
	 DECLARE @IdIncidenceInRoute NVARCHAR(100) = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Incidencia en ruta')

	If (@IdCourier Is Not Null)
	Begin
			Select ROW_NUMBER() OVER (ORDER BY CI.DateCreated) [NumberRow],
				  Guide_Serie+CONVERT(nvarchar,DA.Guide_Number) AS Guide,
				  SR.First_Name +' '+ SR.Last_Name Courierman,
				  CTI.NameIncidence,
				  SO.OrderDescription,
				 CONVERT(varchar(10), DA.Date_Created, 103) +' '+ Convert(varchar(10), DA.Date_Created,108) [DateAndHour],
				  CASE 
					  WHEN CI.IsValid = 1 THEN     'Si'
					  ELSE 'No' End IsValid, 
				  CASE 
					  WHEN CI.IsConfirmed = 1 THEN 'Si'
					  Else 'No' End  IsConfirmed,
				  CI.ActionObservation,
				  CASE 
				      WHEN CI.CourierContempt = 1  THEN 'Desacato'
				      WHEN (CI.StatusOrderId = @IdIncidenceInRoute and CI.IsValid=0) THEN 'Visita Falsa'
				  ELSE 'Incidencia Sospechosa' end TypeIncidence
			From [dbo].[ConfirmationOfIncidence] CI   WITH(NOLOCK)
			INNER JOIN [dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
			 ON CI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
			INNER JOIN [dbo].[SenderReceiver]    SR    WITH(NOLOCK)
			 ON DA.ID_Courier = SR.ID
			LEFT JOIN [dbo].[CatTypeIncidence] CTI     WITH(NOLOCK)
			 ON CTI.IdIncidenceType = ID_Incident
			LEFT JOIN [dbo].[StatusOrder] SO          WITH(NOLOCK)
			 ON  CI.StatusOrderId = SO.StatusOrderId
			Where CI.StatusOrderId in(@IdIncidenceInRoute) 
			      And DA.ID_Courier = Convert(int,@IdCourier)
				  And SR.HubLogisticId =Convert(int, @IdHub) 
				  And CI.DateCreated Between @DateOf and @DateTo
			
		
		End
	Else
	Begin

	Select 
	             ROW_NUMBER() OVER (ORDER BY CI.DateCreated) [NumberRow],
				  Guide_Serie+CONVERT(nvarchar,DA.Guide_Number) AS Guide,
				  SR.First_Name +' '+ SR.Last_Name Courierman,
				  CTI.NameIncidence,
				  SO.OrderDescription,
				 CONVERT(varchar(10), DA.Date_Created, 103) +' '+ Convert(varchar(10), DA.Date_Created,108) [DateAndHour],
				  CASE 
					  WHEN CI.IsValid = 1 THEN     'Si'
					  ELSE 'No' End IsValid, 
				  CASE 
					  WHEN CI.IsConfirmed = 1 THEN 'Si'
					  Else 'No' End  IsConfirmed,
				  CI.ActionObservation,
				  CASE 
				      WHEN CI.CourierContempt = 1  THEN 'Desacato'
				      WHEN (CI.StatusOrderId = @IdIncidenceInRoute and CI.IsValid=0) THEN 'Visita Falsa'
				  ELSE 'Incidencia Sospechosa' end TypeIncidence
			From [dbo].[ConfirmationOfIncidence] CI   WITH(NOLOCK)
			INNER JOIN [dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
			 ON CI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
			INNER JOIN [dbo].[SenderReceiver]    SR    WITH(NOLOCK)
			 ON DA.ID_Courier = SR.ID
			LEFT JOIN [dbo].[CatTypeIncidence] CTI     WITH(NOLOCK)
			 ON CTI.IdIncidenceType = ID_Incident
			LEFT JOIN [dbo].[StatusOrder] SO          WITH(NOLOCK)
			 ON  CI.StatusOrderId = SO.StatusOrderId
			Where CI.StatusOrderId in(@IdIncidenceInRoute) And SR.HubLogisticId = Convert(int, @IdHub) And 
			      CI.DateCreated Between @DateOf and @DateTo
				

	End

END