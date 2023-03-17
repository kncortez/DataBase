-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2023-02-16>
-- Description:	<Sp detalle de visitas fallidas>
-- =============================================
CREATE PROCEDURE [dbo].[RptFailedVisitsDetail] 
@DateOf DateTime,
@DateTo DateTime,
@IdHub nvarchar(5),
@IdCourier nvarchar(5) = null
AS
BEGIN
	
	SET NOCOUNT ON;
	 DECLARE @IdDeliveryFail     int = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Intento de entrega fallida')
	 DECLARE @IdIncidenceInRoute int = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Incidencia en ruta')

	 Select
	             Distinct
			     ROW_NUMBER() OVER (ORDER BY CI.DateCreated) [NumberRow],
				  DA.Guide_Serie+CONVERT(nvarchar,DA.Guide_Number) AS Guide,
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
			From [dbo].[DeliveryOrder] DO WITH(NOLOCK)
		        Inner JOIN
				[dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
				ON DO.Guide_Serie = DA.Guide_Serie AND  DO.Guide_Number = DA.Guide_Number 
				INNER JOIN 
		        [dbo].[ConfirmationOfIncidence] CI   WITH(NOLOCK)
				 ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence  
				INNER JOIN [dbo].[SenderReceiver]    SR    WITH(NOLOCK)
				 ON DA.ID_Courier = SR.ID
				LEFT JOIN [dbo].[CatTypeIncidence] CTI     WITH(NOLOCK)
				 ON CTI.IdIncidenceType = ID_Incident
				LEFT JOIN [dbo].[StatusOrder] SO          WITH(NOLOCK)
				 ON  CI.StatusOrderId = SO.StatusOrderId
		 Where CI.StatusOrderId in(@IdIncidenceInRoute) 
					  And   SR.HubLogisticId = Convert(int,@IdHub)  
					  And CI.DateCreated Between @DateOf +' 00:00:00' And @DateTo + ' 23:59:59'
					  And (@IdCourier IS NULL OR  DA.ID_Courier = Convert(int, @IdCourier))
		
	
	

END
