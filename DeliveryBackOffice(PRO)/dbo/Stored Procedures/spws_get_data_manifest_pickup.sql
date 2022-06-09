

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-02-13>
-- Description:	<Devuelve datos para llenar manifiesto>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_data_manifest_pickup]
	-- Add the parameters for the stored procedure here
			@IdPickup as int = null


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRY  
	-- remitente
			select spk.SchedulePickupId, isnull(spk.SenderName,' ') Sender_Name, isnull(spk.SenderPhone,' ') Sender_Phone , 
			isnull(spk.AddressPickup,' ') Sender_Address,
			isnull(vpc.ContactName,' ') Sender_FirstName, isnull(vpc.Town,' ') Sender_Town, isnull(vpc.Department,' ') Sender_Department, 
			isnull(vpc.Email,' ') Sender_Email
		from dbo.SchedulePickup spk
			left join VisitPointClient vpc on vpc.CodeOfReference = spk.SenderId
		where spk.SchedulePickupId = @IdPickup
	--- destinatario
		select spk.SchedulePickupId, isnull(spk.SenderName,' ') Sender_Name, isnull(spk.SenderPhone,' ') Sender_Phone , 
			isnull(spk.AddressPickup,' ') Sender_Address,
			isnull(vpc.ContactName,' ') Sender_FirstName, isnull(vpc.Town,' ') Sender_Town, isnull(vpc.Department,' ') Sender_Department, 
			isnull(vpc.Email,' ') Sender_Email
		from dbo.SchedulePickup spk
			left join VisitPointClient vpc on vpc.CodeOfReference = spk.SenderId
		where spk.SchedulePickupId = @IdPickup
	-- transporte
		select isnull(rou.Description,' ') Route, isnull(veh.Plate,' ') Plate, isnull(veh.CodeName,' ') Vehicle,
		isnull(ras.DateOfRoute,GETDATE()) DateOfPickup, spk.SchedulePickupId IdPickup
		from dbo.SchedulePickup spk
			left join ServiceManagement smg on smg.IdSchedulePickup = spk.SchedulePickupId
			left join RouteAssigment ras on ras.IdRouteAssigment = smg.IdPuRouteAssigment
			left join CatRoute rou on rou.IdRoute = ras.IdRoute
			left join CatVehicle veh on veh.IdVehicle = ras.IdVehicle
		where spk.SchedulePickupId = @IdPickup
	-- detalle
		select  (isnull(spk.QuantityOverDimensionedPackage,0) + isnull(spk.QuantityRegularPackages,0)) Pieces_Dry , 0 Pieces_Cold, 
		(select count(*) from dbo.DeliveryOrderPaymentDetail dt where dt.IdHeaderRecolection =  spk.SchedulePickupId) GuideCount
		from dbo.SchedulePickup spk
		where spk.SchedulePickupId = @IdPickup


			
	END TRY  
	BEGIN CATCH  
		SELECT   Cast(ERROR_NUMBER() as nvarchar) AS ErrorNumber  
				,Cast(ERROR_SEVERITY() as nvarchar) AS ErrorSeverity  
				,Cast(ERROR_STATE() as nvarchar) AS ErrorState  
				,Cast(ERROR_PROCEDURE() as nvarchar) AS ErrorProcedure  
				,Cast(ERROR_LINE() as nvarchar) AS ErrorLine  
				,Cast(ERROR_MESSAGE() as nvarchar) AS ErrorMessage;
		
	END CATCH;   

END
