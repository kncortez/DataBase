USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetCollectGuides]    Script Date: 12/02/2021 14:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recotizacion>
-- =============================================


CREATE PROCEDURE [dbo].[SetFinishPickUp]
	-- Add the parameters for the stored procedure here
	@InGuides   NVARCHAR(400) = 'FD22221,FD22361,FD22223,FD22359,FD22226',
	@IdPickup int = 2,
	@TypeofInOutMoneyId int = 1
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

		-- insertar en tabla temporal posbibles mensajes de respuesta
			IF OBJECT_ID('tempdb.dbo.#UpdatePayNow', 'U') IS NOT NULL DROP TABLE #UpdatePayNow;
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
			select * INTO #responsemessage from (SELECT  200 AS IdResult
					,'Estado  cambiado correctamente' AS Message
					,'OK' as Id 
			union
			SELECT  500 AS IdResult
					,'Error faltal intente de nuevo mas tarde' AS Message
					,'Transac' as Id 
		 )  as errror
	BEGIN TRANSACTION
		BEGIN TRY

			IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;

			select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
				into #listGuides
				from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

			---declare @IdCustomer int = (select IdCustomer from Account where AccIdAccount = @IdAccount)



	--------------------------------inserta en una tabla temporal, los campos requeridos para insertar en DeliveryPaymentDetail las guias no generadas en el portal--------------------------------------
			SELECT 
			
			[Guide_Number] ,
			[PriceShippment],
			[Guide_Serie],
			[recolect]

		INTO #UpdatePayNow
		FROM  (select   ord.Guide_Number  , ord.Guide_Serie, ord.PriceShippment , (15.00) as recolect from DeliveryOrder ord 
																inner join #listGuides ls on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
																where ord.StatusOrderId in (15,1)) as Table1
		
		----------------------------------------------Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal ----------------------------------

	insert into dbo.DeliveryOrderPaymentDetail
	(  [GuideNumber]
      ,[GuideSerie]
      ,[PayTypeId]
      ,[TypeofInOutMoneyId]
      ,[TimePlaId]
      ,[amount]
	  ,[PaymentRecollections]
	  ,[PaymentNow]
	  ,[PaymentDelivery]
	  ,[StartDate]
	  ,[EndDate]
	  ,[ShipmentCompleted]
	  ,[RecollectionCompleted]
	  ,[PaidGuide]
      ,[TokenCreated]
      ,[DateCreated]
      ,[TokenUpdated]
      ,[DateUpdated]
	  ,[TransaccionFAC]
	  ,[IdHeaderRecolection]
	  )
	  select ls.Guide_Number 
	,ls.Guide_Serie
	,1
	,@TypeofInOutMoneyId
	,3
	,null
	,ls.PriceShippment
	,0.00
	,0.00
	,null
	,null
	,null
	,null
	,null
	,'SYSTEMSYS'
	,getdate()
	,null
	,0.00
	,0.00
	,ls.recolect
	  from #UpdatePayNow ls
	  -------------------------- Drop la tabla temporal -------------------------------------------------------------------

	DROP TABLE #UpdatePayNow

	---------------------------------Obtner los datos a actualizar del encabezado del lote de guias -------------------------------------

		declare @SenderId int  = (select top 1 Sender_ID  from #listGuides ls
							join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						where ord.Guide_Number in (select ItemNumber from #listGuides ))

		declare @SenderName varchar (50)  = (select top 1  concat(Sender_FirstName, Sender_LastName) as SenderName  from #listGuides ls
							join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						where ord.Guide_Number in (select ItemNumber from #listGuides ))

		declare @Sender_Phone varchar (20)  = (select top 1  Sender_Phone from #listGuides ls
							join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						where ord.Guide_Number in (select ItemNumber from #listGuides ))


		declare @IdHublogistic int  = (select top 1  thb.IdHublogistic from #listGuides ls
							join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						where ord.Guide_Number in (select ItemNumber from #listGuides ))


		declare @AmountPickup decimal (18,2)  = (select (sum (dop.PaymentRecollections) + sum (dop.RecolectPayment)) as AmountPickup from #listGuides ls
							join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						where ord.Guide_Number in (select ItemNumber from #listGuides ))

	   declare @Sender_Address varchar (200)  = (select top 1  Sender_Address from #listGuides ls
							join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						where ord.Guide_Number in (select ItemNumber from #listGuides ))


-----------------------------------------------------Actualiza los datos obtenidos anteriormente para la tabla SchedulePickup-----------------------------------------------------------

		update dbo.SchedulePickup  set  SenderId = @SenderId, SenderName = @SenderName, SenderPhone = @Sender_Phone , IdHubLogistics = @IdHublogistic, AddressPickup = @Sender_Address, AmountPickup = @AmountPickup
		where SchedulePickupId = @IdPickup

---------------------------------------------------------Agrupa el lote de guias a una sola transaccion ------------------------------------------------------------------------------

		update DeliveryOrderPaymentDetail  set  IdHeaderRecolection = @idPickup
		from DeliveryOrderPaymentDetail dop
		inner join DeliveryOrder ord on (ord.Guide_Number = dop.GuideNumber and ord.Guide_Serie = dop.GuideSerie)
		where GuideNumber in( select ItemNumber from #listGuides) and ord.StatusOrderId in (15,1) and (dop.IdHeaderRecolection = @idPickup or dop.IdHeaderRecolection is null)

		------------------------------------------------- Actualiza su StatusId a 2 = Recoleccion todas las guias del lote -------------------------------------

		update DeliveryOrder set StatusOrderId = 2
		from DeliveryOrder
		where Guide_Number in (select ItemNumber from #listGuides) and Guide_Serie in (select ItemSerie from #listGuides)

		---------------------------------------------- Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia --------------------

		update DeliveryOrderPiece set IsPickuup = 1
		from DeliveryOrderPiece
		where GuideNumber in (select ItemNumber from #listGuides) and GuideSerie = (select ItemSerie from #listGuides)

				
			DECLARE @jsonResult1 NVARCHAR(MAX) 



			set @jsonResult1 = (SELECT STUFF(( 
			select
			 ',{"Messege":"' + CONVERT(varchar,cast( coalesce('Cambios realizados exitosamente' ,'N/A')as money),1)  + --'",' +
							+ '"}'

	
			FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )
									print 'ingresa2'
										print @jsonResult

		-- retornar resultado en formato json
	If @jsonResult1 is null 

	begin

		set @jsonResult1 =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se encontraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		select ('[' + @jsonResult1 +  ']') jsonResult1


			
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
				+ '"Message":"' + Message + '"}' from #responsemessage where Id ='OK'
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			select ERROR_MESSAGE()
				-- retornar mensaje de error
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' +  convert(varchar,IdResult)    +',' 
				+ '"Message":"' + convert( nvarchar(max),ERROR_MESSAGE()) + '"}' from #responsemessage where Id ='Invalid'
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)
		END CATCH;
		IF @@TRANCOUNT > 0 BEGIN
			COMMIT TRANSACTION;
			--- succesfull
		END
		
		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END



