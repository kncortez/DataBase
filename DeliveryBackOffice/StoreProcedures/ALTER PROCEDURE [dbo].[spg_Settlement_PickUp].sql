USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_Settlement_PickUp]    Script Date: 12/05/2021 09:00:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gómez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todas las Pickups asociadas a una ruta >
-- =============================================
ALTER PROCEDURE [dbo].[spg_Settlement_PickUp]
@Route varchar (100) = 'GUA001'
AS
BEGIN
	
	declare @tiempo date = (select CAST(GETDATE() as date))
	
	DECLARE @Guides TABLE (
		Guide_Serie NVARCHAR(2),
		Guide_Number INT,
		Serie_Manifest NVARCHAR(2),
		Numero_Manifest INT,
		Sender_FirstName NVARCHAR (100),
		Sender_LastName NVARCHAR (100),
		piece int,
		IdRoute int,
		ID int
	)

	insert into @Guides
	select  DISTINCT
		ord.Guide_Serie, 
		ord.Guide_Number, 
		ord.Manifest_Serie, 
		ord.Manifest_Number, 
		ord.Sender_FirstName, 
		ord.Sender_LastName, 
		Count(ordp.NoPiece) piece, 
		ra.IdRouteAssigment , 
		sr.ID	
	from DeliveryOrder ord
		--left join DeliveryOrderDetail ordd on (ord.Guide_Number = ordd.Guide_Number and ord.Guide_Serie = ordd.Guide_Serie)
		left join DeliveryOrderPiece ordp on (ord.Guide_Number = ordp.GuideNumber and ord.Guide_Serie = ordp.GuideSerie)
		left join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
		left join SchedulePickup sp on (sp.SchedulePickupId = dop.IdHeaderRecolection)
		left join ServiceManagement sm on (sm.IdSchedulePickup = sp.SchedulePickupId)
		inner join RouteAssigment ra on (ra.IdRouteAssigment = sm.IdPuRouteAssigment)
		inner join CatRoute cr on (cr.IdRoute = ra.IdRoute)
		inner join SenderReceiver sr on (sr.ID = ra.IdCurrierMan)
	where cr.CodeRoute = @Route and (ordp.StatusOrderId not in (11,10,7,5)or ordp.StatusOrderId is null)  and ord.StatusOrderId not in (11,10,7,5) and cast(sm.DateCreated as date) = @tiempo
	--where cr.CodeRoute = @Route and (ordp.StatusOrderId not in (11,10,7,5)or ordp.StatusOrderId is null)  and ord.StatusOrderId not in (11,10,7,5) and ordp.IsPickup = 1  and cast(sm.DateCreated as date) = @tiempo
	group by   ord.Guide_Serie, ord.Guide_Number, ord.Manifest_Serie, ord.Manifest_Number, ord.Sender_FirstName, ord.Sender_LastName, ra.IdRouteAssigment, sr.ID
	--and es.ServiceStatusId = 3
	

	/* TABLE 0 */
	select convert(int,ordp.NoPiece) PIECE,  
		CONCAT(ord.Guide_Serie,ord.Guide_Number, '-', NoPiece) GUIA,
		sp.SchedulePickupId  PickUp,  
		sp.DateCreated DATERECOLECT,  
		concat(ord.Sender_FirstName, 
		ord.Sender_LastName) REMITENTE, 
		CONCAT(ord.Manifest_Serie,'-', ord.Manifest_Number) MANIFIESTO,
		concat(sr.First_Name, ' ',sr.Last_Name) NAMECOURIER, 
		sm.IdServiceManagement
 	from DeliveryOrder ord
		--left join DeliveryOrderDetail ordd on (ord.Guide_Number = ordd.Guide_Number and ord.Guide_Serie = ordd.Guide_Serie)
		left join DeliveryOrderPiece ordp on (ord.Guide_Number = ordp.GuideNumber and ord.Guide_Serie = ordp.GuideSerie)
		left join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
		left join SchedulePickup sp on (sp.SchedulePickupId = dop.IdHeaderRecolection)
		left join ServiceManagement sm on (sm.IdSchedulePickup = sp.SchedulePickupId)
		inner join RouteAssigment ra on (ra.IdRouteAssigment = sm.IdPuRouteAssigment)
		inner join CatRoute cr on (cr.IdRoute = ra.IdRoute)
		inner join SenderReceiver sr on (sr.ID = ra.IdCurrierMan)
		--inner join  EventService es on (es.ServiceManagementId = sm.IdServiceManagement )
	where cr.CodeRoute = @Route and (ordp.StatusOrderId not in (11,10,7,5)or ordp.StatusOrderId is null) and cast(sm.DateCreated as date) = @tiempo ---and es.ServiceStatusId = 3 and ord.StatusOrderId not in (11,10,7,5)  --
	--where cr.CodeRoute = @Route and (ordp.StatusOrderId not in (11,10,7,5)or ordp.StatusOrderId is null) and cast(sm.DateCreated as date) = @tiempo and ordp.IsPickup = 1 ---and es.ServiceStatusId = 3 and ord.StatusOrderId not in (11,10,7,5)  --

	/* TABLE 1 */
	select COUNT(Guide_Number) NUMEROGUIA from @Guides
	
	/* TABLE 2 */
	select concat(Serie_Manifest,'-', Numero_Manifest) MANIFIESTO, 
		CONCAT(Sender_FirstName, Sender_LastName) REMITENTE, 
		piece PIECE
	from @Guides

	/* TABLE 3 */
	select rta.IdRouteAssigment as IdRoute
	from DeliveryBackOffice.dbo.ServiceManagement svm
	left join DeliveryBackOffice.dbo.RouteAssigment rta on svm.IdPuRouteAssigment = rta.IdRouteAssigment
	left join DeliveryBackOffice.dbo.CatRoute ctr on ctr.IdRoute = rta.IdRoute
	left join SenderReceiver sr on sr.ID = rta.IdCurrierMan
	where ctr.CodeRoute = @Route and cast(svm.DateCreated as date) = @tiempo


	/* TABLE 4 */
	select sr.ID, 
		concat(sr.First_Name, ' ',sr.Last_Name) NAMECOURIER, 
		CAST(rta.DateOfRoute as Date) as DATERECOLECT
	from DeliveryBackOffice.dbo.ServiceManagement svm
	left join DeliveryBackOffice.dbo.RouteAssigment rta on svm.IdPuRouteAssigment = rta.IdRouteAssigment
	left join DeliveryBackOffice.dbo.CatRoute ctr on ctr.IdRoute = rta.IdRoute
	left join SenderReceiver sr on sr.ID = rta.IdCurrierMan
	where ctr.CodeRoute = @Route and cast(svm.DateCreated as date) = @tiempo

	/*	TABLE 5 
		Selecciona todas las guías liquidadas de una ruta en la fecha actual.
	*/
	select  1 as StatusCode, 
		CONCAT(tbb.GuideSerie,tbb.GuideNumber,'-', tbb.GuidePiece) Guía, 
		1 as SubStatusCode
 	from DeliveryBackOffice.dbo.TransactionalBackbone tbb
		inner join DeliveryBackOffice.dbo.CatRoute cr on (cr.IdRoute = tbb.RouteId)
	where cr.CodeRoute = @Route and cast(tbb.DateCreated as date) = @tiempo and tbb.RowStatus = 1

	/* TABLE 6 */
	select  top 1 sbp.Id IdManifest
	from ServiceManagement sm
		inner join RouteAssigment ra on (ra.IdRouteAssigment = sm.IdPuRouteAssigment)
		inner join CatRoute cr on (cr.IdRoute = ra.IdRoute)
		inner join SettlementByPickup sbp on (sbp.RouteAssigmentId = ra.IdRouteAssigment and sbp.IdCourier = ra.IdCurrierMan and  CAST(sbp.DatePrinted as date) = @tiempo)
		--inner join  EventService es on (es.ServiceManagementId = sm.IdServiceManagement )
	where cr.CodeRoute = @Route and cast(sm.DateCreated as date) = @tiempo ---and es.ServiceStatusId = 3 and ord.StatusOrderId not in (11,10,7,5)  --
	--where cr.CodeRoute = @Route and (ordp.StatusOrderId  in (11,2,16)or ordp.StatusOrderId is null) and cast(sm.DateCreated as date) = @tiempo and ordp.IsPickup = 1
	order by 1 desc



END


