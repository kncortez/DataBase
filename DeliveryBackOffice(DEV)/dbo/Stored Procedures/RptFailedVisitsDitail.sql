-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2023-02-16>
-- Description:	<Sp detalle de visitas fallidas>
-- =============================================
CREATE PROCEDURE [dbo].[RptFailedVisitsDitail] 
@DateOf DateTime,
@DateTo DateTime,
@IdHub int,
@IdCourier int = null
AS
BEGIN
	
	SET NOCOUNT ON;

	If (@IdCourier Is Not Null)
	Begin
			Select ROW_NUMBER() OVER (ORDER BY CI.DateCreated) [NumberRow],
				  Guide_Serie+CONVERT(nvarchar,DA.Guide_Number) AS Guide,
				  SR.First_Name +' '+ SR.Last_Name Courierman,
				  CTI.NameIncidence,
				  SO.OrderDescription,
				  Convert(varchar(10), DA.Date_Created,108) [Hour],
				  CONVERT(varchar(10), DA.Date_Created, 103) [Date],
				  CASE 
					  WHEN CI.IsValid = 1 THEN     'Si'
					  ELSE 'No' End IsValid, 
				  CASE 
					  WHEN CI.IsConfirmed = 1 THEN 'Si'
					  Else 'No' End  IsConfirmed
			From [dbo].[ConfirmationOfIncidence] CI   WITH(NOLOCK)
			INNER JOIN [dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
			 ON CI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
			INNER JOIN [dbo].[SenderReceiver]    SR    WITH(NOLOCK)
			 ON DA.ID_Courier = SR.ID
			LEFT JOIN [dbo].[CatTypeIncidence] CTI     WITH(NOLOCK)
			 ON CTI.IdIncidenceType = ID_Incident
			LEFT JOIN [dbo].[StatusOrder] SO          WITH(NOLOCK)
			 ON  CI.StatusOrderId = SO.StatusOrderId
			Where CI.StatusOrderId in(12,32) 
			      And DA.ID_Courier = @IdCourier
				  And SR.HubLogisticId = @IdHub 
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
				 CONVERT(varchar(10), DA.Date_Created, 108) [Hour],
				 CONVERT(varchar(10), DA.Date_Created, 103) [Date],
				  CASE 
					  WHEN CI.IsValid = 1 THEN     'Si'
					  ELSE 'No' End IsValid, 
				  CASE 
					  WHEN CI.IsConfirmed = 1 THEN 'Si'
					  Else 'No' End  IsConfirmed,
					  DA.ID_Courier
			From [dbo].[ConfirmationOfIncidence] CI   WITH(NOLOCK)
			INNER JOIN [dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
			 ON CI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId
			INNER JOIN [dbo].[SenderReceiver]    SR    WITH(NOLOCK)
			 ON DA.ID_Courier = SR.ID
			LEFT JOIN [dbo].[CatTypeIncidence] CTI     WITH(NOLOCK)
			 ON CTI.IdIncidenceType = ID_Incident
			LEFT JOIN [dbo].[StatusOrder] SO          WITH(NOLOCK)
			 ON  CI.StatusOrderId = SO.StatusOrderId
			Where CI.StatusOrderId in(12,32) And SR.HubLogisticId = @IdHub And 
			      CI.DateCreated Between @DateOf and @DateTo
				

	End

END