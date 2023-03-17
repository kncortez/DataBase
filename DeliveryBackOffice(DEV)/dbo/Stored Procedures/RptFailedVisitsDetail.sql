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


	 	 DECLARE @temp TABLE (
								Guide	nvarchar(max),
								Courierman nvarchar(201),
								NameIncidence nvarchar(100),
								OrderDescriptions nvarchar(600),
								DateAndHour  Datetime,
								IsValid nvarchar(2),
								IsConfirmed nvarchar(2),
								ActionObservation nvarchar(600),
								TypeIncidence nvarchar(50)
	                      )


BEGIN TRY
	
	INSERT INTO @temp
	 Select
	              distinct
				  DA.Guide_Serie+CONVERT(nvarchar,DA.Guide_Number) AS Guide,
				  SR.First_Name +' '+ SR.Last_Name Courierman,
				  CTI.NameIncidence,
				  SO.OrderDescription,
				 DA.Date_Created [DateAndHour],
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
		
	
	

	 SELECT
	       ROW_NUMBER() OVER (ORDER BY Guide) [NumberRow],
		 Guide,
		Courierman,
		NameIncidence,
		OrderDescriptions,
		CONVERT(varchar(10), DateAndHour, 103) +' '+ Convert(varchar(10),DateAndHour,108) [DateAndHour],
		IsValid,
		IsConfirmed,
		ActionObservation,
		TypeIncidence 
	FROM @temp
	

END TRY
BEGIN CATCH

      
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];


END CATCH


END
