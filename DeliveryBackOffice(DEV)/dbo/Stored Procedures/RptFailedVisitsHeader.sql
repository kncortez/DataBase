-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-02-17>
-- Description:	<SP para encabezado de reporte visitas fallidas>
-- =============================================
CREATE PROCEDURE [dbo].[RptFailedVisitsHeader]
@DateOf DateTime,
@DateTo DateTime,
@IdHub nvarchar(5),
@IdCourier nvarchar(5) = null
AS
BEGIN
       
	   DECLARE @IdIncidenceInRoute int = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Incidencia en ruta')
	   DECLARE @IdDeliveryFail     int = (Select StatusOrderId From [dbo].[StatusOrder] WHERE OrderDescription='Intento de entrega fallida')
	   DECLARE @Hub                NVARCHAR(100) = (select HubName from [dbo].[HubLogistics]      Where IdHubLogistic= Convert(int, @IdHub))
	   DECLARE @CourierName        NVARCHAR(100) ='';
	   DECLARE @temp TABLE (
	                            
	                            Guide int,
								GenerationDate	Datetime,
								StatusOrderId int,
								IsValid bit,
								CourierContempt bit
	                      )
	
	SET NOCOUNT ON;
	 

	 IF (@IdCourier IS NOT NULL OR  @IdCourier <> '') 
	  SET  @CourierName  = (select First_Name +' '+ Last_Name From [dbo].[SenderReceiver] WITH(NOLOCK) Where  ID = Convert(int, @IdCourier))
	 
	 BEGIN TRY

	 INSERT INTO @temp
	   SELECT
		  Distinct
			    DA.Guide_Number,
			    GETDATE(),
				CI.StatusOrderId,
				CI.IsValid,
				CI.CourierContempt
		From   
				[dbo].[DeliveryAttempt]   DA   WITH(NOLOCK)
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
					  And  SR.HubLogisticId = Convert(int,@IdHub)  
					  And CI.DateCreated Between @DateOf +' 00:00:00' And @DateTo + ' 23:59:59'
					  And (@IdCourier IS NULL OR  DA.ID_Courier = Convert(int, @IdCourier))



	 Select       
		     
			    Convert(varchar(10), GETDATE(),103)   GenerationDate,
				Convert(varchar(10), @DateOf,  103)   DateOf,
				Convert(varchar(10), @DateTo,  103)   DateTo,
				IIF((@IdCourier IS NOT NULL OR @IdCourier <>'') ,@Hub + '-'+ @CourierName,@Hub) Hub ,
				SUM(IIF((CI.StatusOrderId = @IdIncidenceInRoute and CI.IsValid=0) , 1,0))  TotalVisit,
				SUM(IIF(CI.StatusOrderId = @IdIncidenceInRoute,1,0))  TotalIncidence,
				SUM(IIF(CI.CourierContempt=1,1,0)) TotalDesacato,
				SUM(IIF(CI.StatusOrderId in(@IdDeliveryFail, @IdIncidenceInRoute),1,0)) TotalVisitandIncidence
		From   @temp CI
								
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