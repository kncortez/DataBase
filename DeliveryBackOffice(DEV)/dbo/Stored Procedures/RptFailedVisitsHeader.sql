-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-02-17>
-- Description:	<SP para encabezado de reporte visitas fallidas>
-- =============================================
CREATE PROCEDURE [dbo].[RptFailedVisitsHeader]
@DateOf DateTime,
@DateTo DateTime,
@IdHub int,
@IdCourier int = null
AS
BEGIN
       
	   DECLARE @IdIncidenceInRoute NVARCHAR(100) = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Incidencia en ruta')
	   DECLARE @IdDeliveryFail     NVARCHAR(100) = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Intento de entrega fallida')
	   DECLARE @Hub                NVARCHAR(100) = (select HubName from [dbo].[HubLogistics]      Where IdHubLogistic=@IdHub)
	 
	  
	
	SET NOCOUNT ON;
	 
	 if (@IdCourier IS NOT NULL or @IdCourier != '')
	 Begin

	   DECLARE @CourierName        NVARCHAR(100) = (select First_Name +' '+ Last_Name From [dbo].[SenderReceiver] Where  ID = @IdCourier)

		 Select       
				Convert(varchar(10), GETDATE(),103)   GenerationDate,
				Convert(varchar(10), @DateOf,  103)   DateOf,
				Convert(varchar(10), @DateTo,  103)   DateTo,
				IIF(@IdCourier IS NOT NULL,   @Hub + '-'+ @CourierName,@Hub) Hub ,
				SUM(IIF(CI.StatusOrderId = @IdDeliveryFail, 1,0))     TotalVisit,
				SUM(IIF(CI.StatusOrderId = @IdIncidenceInRoute,1,0))  TotalIncidence,
				SUM(IIF(CI.StatusOrderId in(@IdDeliveryFail, @IdIncidenceInRoute),1,0)) TotalVisitandIncidence
		From [dbo].[ConfirmationOfIncidence] CI   WITH(NOLOCK)
				INNER JOIN [dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
				 ON CI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
				INNER JOIN [dbo].[SenderReceiver]    SR    WITH(NOLOCK)
				 ON DA.ID_Courier = SR.ID
				LEFT JOIN [dbo].[CatTypeIncidence] CTI     WITH(NOLOCK)
				 ON CTI.IdIncidenceType = ID_Incident
				LEFT JOIN [dbo].[StatusOrder] SO          WITH(NOLOCK)
				 ON  CI.StatusOrderId = SO.StatusOrderId
		 Where CI.StatusOrderId in(@IdIncidenceInRoute,@IdDeliveryFail) 
					  And SR.HubLogisticId = @IdHub 
					  And CI.DateCreated Between @DateOf And @DateTo
					  And DA.ID_Courier = @IdCourier
       End
		ELSE
		   Begin

		   Select       
					Convert(varchar(10), GETDATE(),103)   GenerationDate,
					Convert(varchar(10), @DateOf,  103)   DateOf,
					Convert(varchar(10), @DateTo,  103)   DateTo,
					IIF(@IdCourier IS NOT NULL,   @Hub + '-'+ @CourierName,@Hub) Hub ,
					SUM(IIF(CI.StatusOrderId = @IdDeliveryFail, 1,0))     TotalVisit,
					SUM(IIF(CI.StatusOrderId = @IdIncidenceInRoute,1,0))  TotalIncidence,
					SUM(IIF(CI.StatusOrderId in(@IdDeliveryFail, @IdIncidenceInRoute),1,0)) TotalVisitandIncidence
			From [dbo].[ConfirmationOfIncidence] CI   WITH(NOLOCK)
					INNER JOIN [dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
					 ON CI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
					INNER JOIN [dbo].[SenderReceiver]    SR    WITH(NOLOCK)
					 ON DA.ID_Courier = SR.ID
					LEFT JOIN [dbo].[CatTypeIncidence] CTI     WITH(NOLOCK)
					 ON CTI.IdIncidenceType = ID_Incident
					LEFT JOIN [dbo].[StatusOrder] SO          WITH(NOLOCK)
					 ON  CI.StatusOrderId = SO.StatusOrderId
			 Where CI.StatusOrderId in(@IdIncidenceInRoute,@IdDeliveryFail) 
						  And SR.HubLogisticId = @IdHub 
						  And CI.DateCreated Between @DateOf 
						  And @DateTo
					  

		   End
	
    
END