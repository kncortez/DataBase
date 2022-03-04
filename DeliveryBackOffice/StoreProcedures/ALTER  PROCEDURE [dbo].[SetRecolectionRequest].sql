USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetRecolectionRequest]    Script Date: 4/03/2022 09:13:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recoleccion de guias, su funcion es insertar y actualizar informacion de las tablas DeliveryOrder, DeliveryOrderPaymentDetail y SchedulePickup >
-- =============================================
ALTER PROCEDURE [dbo].[SetRecolectionRequest]
	@TblDeliveryOrdersList AS [TblDeliveryOrdersList2] READONLY,
	@Iscollected bit = true,
	@status int = 15,
	@ShipmentCompleted bit = true,
	@IdStatus as int = 15,
	@Token as nvarchar(100),
	@IdAccount as int = null,
	@InstructionsCurrier as nvarchar (300) = null,
	@PartDimensions as int  = 1,
	@Regularpiezer  as int  =  1,
	@StartDate as datetime = null,
	@EndDate as datetime  = null,
	@WeightEstimated as decimal (18,2) = null,
	@BigPackages as bit = false ,
	@ValidateFilter as int = 0,
	@RecollectionLatitude as decimal(18,15) = 0,
	@RecollectionLongitude as decimal(18,15) = 0,
	@DeliveryLatitude as decimal(18,15) = 0,
	@DeliveryLongitude as decimal(18,15) = 0,
	@IdUser INT = 0
AS
BEGIN
if(@ValidateFilter = 1 )
	begin 
	BEGIN TRANSACTION
	BEGIN TRY

	DECLARE @jsonResult2 NVARCHAR(MAX) 

		update dbo.DeliveryOrder 
		set PriceShippment = t.PriceShippment, StatusOrderId = @IdStatus, IsCollect = t.IsCollect
	from dbo.DeliveryOrder ord
	inner join @TblDeliveryOrdersList t on t.Guide_Number = ord.Guide_Number and t.Guide_Serie = ord.Guide_Serie

	-- insertar checkpoint de generado.	
	--insert into dbo.DeliveryOrderDetail
	--( [Guide_Serie]
	--,[Guide_Number]
 --     ,[StatusOrderId]
 --     ,[UserCreated]
 --     ,[DateCreated]
 --     ,[DateCreatedInSystem]
 --     ,[Observations]
 --     ,[Temperature_Celsius])
	--select Guide_Serie
	--,Guide_Number
	--,@IdStatus
	--,@Token
	--,GETDATE()
	--,null
	--,null
	--,null
	--from @TblDeliveryOrdersList

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
	  select Guide_Number 
	,Guide_Serie
	,IdTypePayment
	,IdWayToPayment
	,IdTimePayment
	,AmmountToPay
	,tdop.PaymentRecollections
	,tdop.PaymentNow
	,tdop.PaymentDelivery
	,null
	,null
	,tdop.ShipmentCompleted
	,tdop.RecollectionCompleted
	,tdop.PaidGuide
	,@Token
	,getdate()
	,null
	,null
	,null
	,null
	  from @TblDeliveryOrdersList tdop
	  END TRY
	
	BEGIN CATCH
			 DECLARE @jsonOutput NVARCHAR(MAX) 
			    SET @jsonOutput =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
					',{"Status":"' + ERROR_MESSAGE() + '"}'
	
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput +  ']') jsonOutput 
					ROLLBACK TRANSACTION
			
				END CATCH;
			
				IF @@TRANCOUNT > 0
		BEGIN
					COMMIT TRANSACTION;
			
			 DECLARE @jsonOutput1 NVARCHAR(MAX) 
			    SET @jsonOutput1 =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
			  ',{"Status":"Cambios realizados exitosamente"}'
			  
			
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput1 +  ']') jsonOutput1
				END

		end 
		
if(@ValidateFilter = 2)
begin 

	-- MODIFICACIÓN 04/03/2022
	-- Variable que indicará si ya existe una transacción
	DECLARE @ValidateTransaction INT = (SELECT DopId FROM dbo.DeliveryOrderPaymentTransaction do
									INNER JOIN @TblDeliveryOrdersList tpo
									ON do.GuideNumber = tpo.Guide_Number
										AND do.GuideSerie = tpo.Guide_Serie
										AND do.TypeServiceId = tpo.IdTypeService)

	IF (@ValidateTransaction IS NULL)
	BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		/*fecha inicio cambio 18/02/2020*/
		update dbo.DeliveryOrder 
		set PriceShippment = t.PriceShippment, StatusOrderId = @IdStatus, IsCollect = t.IsCollect
		from dbo.DeliveryOrder ord
		inner join @TblDeliveryOrdersList t on t.Guide_Number = ord.Guide_Number and t.Guide_Serie = ord.Guide_Serie
		/*fecha fin 18/02/2020*/	
		update  dbo.DeliveryOrderPaymentDetail 
		set ShipmentCompleted  = t.ShipmentCompleted , PayTypeId = t.IdTypePayment
		, TypeofInOutMoneyId = t.IdWayToPayment, TimePlaId = t.IdTimePayment
		from dbo.DeliveryOrderPaymentDetail pay
			 inner join @TblDeliveryOrdersList t 
			 on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 


		IF (@IdAccount != 0)
		BEGIN

			DECLARE @VistitPointUser INT = (SELECT CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient VPC
										JOIN VisitPointByUser VPU
											ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
												AND VPU.RowStatus = 1
										JOIN RegisterUser ru
											ON VPU.RegisterUserID = ru.UsrIdUser
												AND ru.UsrRowStatus = 1
												JOIN [dbo].[RolByUserByAccount] rua
										ON rua.RuaIdUser = ru.UsrIdUser
										WHERE rua.RuaIdAccount = @IdAccount)

			insert into dbo.DeliveryOrderPaymentTransaction
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
			  ,[TypeServiceId]
			  ,[AccountId]
			  ,[CODAmountProcess]
			  ,[Fel]
			  ,[VisitPoint]
			  )
			select Guide_Number 
			,Guide_Serie
			,IdTypePayment
			,IdWayToPayment
			,IdTimePayment
			,tdop.PriceShippment
			,tdop.PaymentRecollections
			,tdop.PaymentNow
			,tdop.PaymentDelivery
			,null
			,null
			,tdop.ShipmentCompleted
			,tdop.RecollectionCompleted
			,tdop.PaidGuide
			,@Token
			,getdate()
			,null
			,null
			,null
			,null
			,tdop.IdTypeService
			,IIF(@IdAccount=0,null, @IdAccount)
			,tdop.CODAmountProccess
			,null
			,IIF(@VistitPointUser=0,null, @VistitPointUser)
			 from @TblDeliveryOrdersList tdop
			 where tdop.PriceShippment != 0 or tdop.CODAmountProccess != 0
		END
	END TRY
	
	BEGIN CATCH
		DECLARE @jsonOutput2 NVARCHAR(MAX) ;
		SET @jsonOutput2 =  
		( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
					',{"Status":"' + ERROR_MESSAGE() + '"}'
	
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			             ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput2 +  ']') jsonOutput2 
					ROLLBACK TRANSACTION
			
	END CATCH;
			
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
			
		DECLARE @jsonOutput3 NVARCHAR(MAX) 
		SET @jsonOutput3 =  
		( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
			  ',{"Status":"Cambios actualizados exitosamente"}'
			  
			
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput3 +  ']') jsonOutput3
	END
	END
	-- FIN MODIFICACIÓN
end 

if(@ValidateFilter = 3 )
		begin 
			BEGIN TRANSACTION
	BEGIN TRY
		
		IF OBJECT_ID('tempdb.dbo.#Sender', 'U') IS NOT NULL DROP TABLE #Sender;

		

		SELECT 
			[Sender_ID] ,
			[SenderName],
			[Sender_Phone],
			[Hub],
			AmountPickup,
			AddressPickup,
			Number,
			Serie

		INTO #Sender
		FROM (select top 1 Sender_ID ,  concat(Sender_FirstName, Sender_LastName) 
		as SenderName, ord.Guide_Number as Number , ord.Guide_Serie 
		as Serie , Sender_Phone ,thb.IdHublogistic as Hub, 
		(sum (dop.PaymentRecollections) + sum (dop.RecolectPayment)) 
		as AmountPickup , Sender_Address as AddressPickup 
		from DeliveryOrder ord
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						inner join @TblDeliveryOrdersList t   on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
						where ord.Guide_Number in (t.Guide_Number)
						group by Sender_ID ,  Sender_Phone,ord.Guide_Number, ord.Guide_Serie  ,thb.IdHublogistic,  Sender_Address, Sender_FirstName, Sender_LastName) as table1



		--declare @SenderId int  = (select top 1 Sender_ID  from DeliveryOrder ord
		--				inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
		--				inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
		--				 inner join @TblDeliveryOrdersList t  on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
		--				where ord.Guide_Number in (t.Guide_Number))

		--declare @SenderName varchar (50)  = (select top 1  concat(Sender_FirstName, Sender_LastName) as SenderName  from DeliveryOrder ord
		--				inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
		--				inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
		--				 inner join @TblDeliveryOrdersList t   on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
		--				where ord.Guide_Number in (t.Guide_Number))

		--declare @Sender_Phone varchar (20)  = (select top 1  Sender_Phone from DeliveryOrder ord
		--				inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
		--				inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
		--				 inner join @TblDeliveryOrdersList t   on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
		--				where ord.Guide_Number in (t.Guide_Number))


		--declare @IdHublogistic int  = (select top 1  thb.IdHublogistic from DeliveryOrder ord
		--				inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
		--				inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
		--				 inner join @TblDeliveryOrdersList t   on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
		--				where ord.Guide_Number in (t.Guide_Number))


		--declare @AmountPickup decimal (18,2)  = (select top 1  (sum (dop.PaymentRecollections) + sum (dop.RecolectPayment)) as AmountPickup from DeliveryOrder ord
		--				inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
		--				inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
		--				 inner join @TblDeliveryOrdersList t  on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
		--				where ord.Guide_Number in (t.Guide_Number))

			--declare @Sender_Address varchar (200)  = (select top 1  Sender_Address from DeliveryOrder ord
			--			inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
			--			inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
			--			 inner join @TblDeliveryOrdersList t  on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
			--			where ord.Guide_Number in (t.Guide_Number))



			  insert into dbo.SchedulePickup(AccountId, 
			  StartDate ,
			   EndDate,
			   EstimatedWeight,
			   IsLargePackage,
			   QuantityRegularPackages,
			   QuantityOverDimensionedPackage, 
			   SpecialInstructions, 
			   RowStatus,
			   TokenCreated, 
			   DateCreated, 
			   TokenUpdated,
			   DateUpdated, 
			   SenderId,
			   SenderName, 
			   SenderPhone, 
			   IdHubLogistics, 
			   AmountPickup, 
			   IdSourcePlataform, 
			   AddressPickup)
			  select 
			  @IdAccount
			  ,@StartDate
			  ,@EndDate
			  ,@WeightEstimated
			  ,@BigPackages
			  ,@Regularpiezer
			  ,@PartDimensions
			  ,@InstructionsCurrier
			  ,1
			  ,@Token
			  ,GETDATE()
			  ,null
			  ,null
			  ,sd.Sender_ID
			  ,sd.SenderName
			  ,sd.Sender_Phone
			  ,sd.Hub
			  ,null
			  ,null
			  ,sd.AddressPickup
			  from #Sender sd

			  declare @transaction int = Scope_Identity()
			  

			 

			 update dbo.DeliveryOrderPaymentDetail set IdHeaderRecolection = @transaction, StartDate = @StartDate, EndDate = @EndDate
			 from dbo.DeliveryOrderPaymentDetail pay
			 inner join @TblDeliveryOrdersList t on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 
	
		DROP TABLE #Sender
			 
			 	  END TRY
	
	BEGIN CATCH
			 DECLARE @jsonOutput4 NVARCHAR(MAX) 
			    SET @jsonOutput4 =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
					',{"Status":"' + ERROR_MESSAGE() + '"}'
	
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput4 +  ']') jsonOutput4 
					ROLLBACK TRANSACTION
			
				END CATCH;
			
				IF @@TRANCOUNT > 0
		BEGIN
					COMMIT TRANSACTION;
			
			 DECLARE @jsonOutput5 NVARCHAR(MAX) 
			    SET @jsonOutput5 =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
			  ',{"Status":"Agrupación realizada exitosamente"}'
			  
			
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput5 +  ']') jsonOutput5
			END

	end 

	if(@ValidateFilter = 4)
	begin 
	BEGIN TRANSACTION
	BEGIN TRY
	
		update  dbo.DeliveryOrderPaymentDetail 
		set ShipmentCompleted  = t.ShipmentCompleted , RecollectionCompleted = t.RecollectionCompleted
		, PaidGuide = t.PaidGuide
		from dbo.DeliveryOrderPaymentDetail pay
			 inner join @TblDeliveryOrdersList t 
			 on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 

			--update dbo.DeliveryOrder 
			--set  StatusOrderId = @IdStatus   
			--from dbo.DeliveryOrder ord
			--inner join @TblDeliveryOrdersList t on t.Guide_Number = ord.Guide_Number and t.Guide_Serie = ord.Guide_Serie


			--		---	 insertar checkpoint de generado.	
			--insert into dbo.DeliveryOrderDetail
			--( [Guide_Serie]
			--,[Guide_Number]
			--  ,[StatusOrderId]
			--  ,[UserCreated]
			--  ,[DateCreated]
			--  ,[DateCreatedInSystem]
			--  ,[Observations]
			--  ,[Temperature_Celsius])
			--select Guide_Serie
			--,Guide_Number
			--,@IdStatus
			--,@Token
			--,GETDATE()
			--,null
			--,null
			--,null
			--from @TblDeliveryOrdersList



		END TRY
	
	BEGIN CATCH
			 DECLARE @jsonOutput6 NVARCHAR(MAX) 
			    SET @jsonOutput =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
					',{"Status":"' + ERROR_MESSAGE() + '"}'
	
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput2 +  ']') jsonOutput2 
					ROLLBACK TRANSACTION
			
				END CATCH;
			
				IF @@TRANCOUNT > 0
		BEGIN
					COMMIT TRANSACTION;
			
			 DECLARE @jsonOutput7 NVARCHAR(MAX) 
			    SET @jsonOutput7 =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
			  ',{"Status":"Cambios actualizados exitosamente"}'
			  
			
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput5 +  ']') jsonOutput5
				END

	end 

	if(@ValidateFilter = 5)
	begin 
	BEGIN TRANSACTION
	BEGIN TRY

	DECLARE @jsonResult NVARCHAR(MAX) 

	update dbo.DeliveryOrder 
		set StatusOrderId = @IdStatus, IsCollect = t.IsCollect
	from dbo.DeliveryOrder ord
	inner join @TblDeliveryOrdersList t on t.Guide_Number = ord.Guide_Number and t.Guide_Serie = ord.Guide_Serie

	DECLARE @IdAcc INT = @IdAccount;
	IF (@IdUser != 0)
	begin
		SET @IdAcc = (
						select AccIdAccount from dbo.InternalUser IU
						JOIN RegisterUser RU ON RU.UsrIdUser = IU.RegisterUserID
						JOIN RolByUserByAccount RB  ON RB.RuaIdUser = RU.UsrIdUser
						JOIN Account ACC ON RB.RuaIdAccount = ACC.AccIdAccount
						where IdUser = @IdUser
		)
	end

	insert into dbo.DeliveryOrderPaymentTransaction
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
	  ,[TypeServiceId]
	  ,[AccountId]
	  ,[CODAmountProcess]
	  )
	  select Guide_Number 
	,Guide_Serie
	,IdTypePayment
	,IdWayToPayment
	,IdTimePayment
	,tdop.PriceShippment
	,tdop.PaymentRecollections
	,tdop.PaymentNow
	,tdop.PaymentDelivery
	,null
	,null
	,tdop.ShipmentCompleted
	,tdop.RecollectionCompleted
	,tdop.PaidGuide
	,@Token
	,getdate()
	,null
	,null
	,null
	,null
	,tdop.IdTypeService
	,@IdAcc
	,tdop.CODAmountProccess
	  from @TblDeliveryOrdersList tdop
	where tdop.PriceShippment != 0 or tdop.CODAmountProccess != 0

	  END TRY
	
	BEGIN CATCH
			 DECLARE @jsonOut NVARCHAR(MAX) 
			    SET @jsonOut =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
					',{"Status":"' + ERROR_MESSAGE() + '"}'
	
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOut +  ']') jsonOut
					ROLLBACK TRANSACTION
			
				END CATCH;
			
				IF @@TRANCOUNT > 0
		BEGIN
					COMMIT TRANSACTION;
			
			 DECLARE @jsonOut1 NVARCHAR(MAX) 
			    SET @jsonOut1 =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
			  ',{"Status":"Cambios realizados exitosamente"}'
			  
			
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOut1 +  ']') jsonOut1
				END

		end 
END
