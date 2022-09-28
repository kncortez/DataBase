-- =============================================
-- Author:		<Alejandro Ródríguez>
-- Create date: <2021-02-06>
-- Description:	< Copia del SP SetRecolectionRequest para ser utilizado en por el SP SetFinishService >
-- =============================================
CREATE PROCEDURE [dbo].[SetServiceRecolect]
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
	DECLARE @Guide_Serie AS INT
	DECLARE @Guide_Number NVARCHAR(2)

		update dbo.DeliveryOrder 
		set PriceShippment = t.PriceShippment, StatusOrderId = @IdStatus, IsCollect = t.IsCollect
	from dbo.DeliveryOrder ord
	inner join @TblDeliveryOrdersList t on t.Guide_Number = ord.Guide_Number and t.Guide_Serie = ord.Guide_Serie

	SELECT 
	   @Guide_Serie = DOL.Guide_Serie
	  ,@Guide_Number = DOL.Guide_Number
	  FROM @TblDeliveryOrdersList DOL


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
	 select 
	  Guide_Number 
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
	
	-- MODIFICACIÓN 31/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
	BEGIN
        SAVE TRANSACTION Filter2;  
	END
    ELSE  
	BEGIN
        BEGIN TRANSACTION;  
	END
	-- FIN MODIFICACIÓN

	-- MODIFICACIÓN 04/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	-- Variable que indicará si ya existe una transacción con la guía actual
	DECLARE @ValidateTransaction INT = (SELECT DopId FROM dbo.DeliveryOrderPaymentTransaction do
									INNER JOIN @TblDeliveryOrdersList tpo
									ON do.GuideNumber = tpo.Guide_Number
										AND do.GuideSerie = tpo.Guide_Serie
										AND do.TypeServiceId = tpo.IdTypeService)

	IF (@ValidateTransaction IS NULL)
	BEGIN
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
		
		-- MODIFICACIÓN 31/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
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
			 
				SELECT ('[' + @jsonOutput3 +  ']') jsonOutput3
	
			IF @TranCounter = 0  
			BEGIN
				-- @TranCounter = 0 means no transaction was  
				-- started before the procedure was called.  
				-- The procedure must commit the transaction  
				-- it started.  
				COMMIT TRANSACTION;
			END

			--Valor para validar la transacción si es llamado por otro SP
			RETURN 1;

		END TRY
	
		BEGIN CATCH

			SELECT
				'ERROR' AS message
			   ,'FALSE' blnResult
			   ,CAST(500 AS VARCHAR(5)) StatusResult
			   ,CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber
			   ,CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity
			   ,CAST(ERROR_STATE() AS VARCHAR) AS ErrorState
			   ,CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure
			   ,CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine
			   ,CAST(ERROR_MESSAGE() AS VARCHAR(100)) AS ResultMessage;

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

			IF @TranCounter = 0  
			BEGIN
				-- Transaction started in procedure.  
				-- Roll back complete transaction.  
				ROLLBACK TRANSACTION;  
			END
			ELSE  
			BEGIN
				-- Transaction started before procedure  
				-- called, do not roll back modifications  
				-- made before the procedure was called.  
				IF XACT_STATE() <> -1  
				BEGIN
				-- If the transaction is still valid, just  
				-- roll back to the savepoint set at the  
				-- start of the stored procedure.  
					ROLLBACK TRANSACTION Filter2;  
				-- If the transaction is uncommitable,			
				END
			END

			--RAISERROR('Error en la transacción', 16, 1);
			
			--Valor para validar la transacción si es llamado por otro SP 
			RETURN 0
		END CATCH;

		-- FIN MODIFICACIÓN

	END
	ELSE
	BEGIN
		DECLARE @jsonOutM NVARCHAR(MAX) ;
			SET @jsonOutM =  
			( 
			 
				SELECT ''+ STUFF(( 
			
				SELECT 
						',{"Status":"La guía ya ha sido transaccionada"}'
	
				  FOR XML PATH(''), TYPE 
				  ) 
				  .value('.', 'varchar(max)'),1,1,'' 
							 ) + '' 
				  ) 
			 
					select ('[' + @jsonOutM +  ']') jsonOutM 
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
			table1.[SenderName],
			[Sender_Phone],
			[Hub],
			table1.AmountPickup,
			table1.AddressPickup,
			Number,
			Serie
			--,IIF(SM.IdServiceManagement IS NULL, SP.SchedulePickupId, IIF(SM.ServiceStatusId IN (select IdServiceStatus from dbo.CatServiceStatus WHERE Name IN ('Creado','Asignado a Ruta')), SP.SchedulePickupId, NULL)) SchedulePickupId
			,TEST.SchedulePickupId
			,TEST.AssigmentStatus
			,TEST.IdServiceManagement
		INTO #Sender
		FROM (select Sender_ID ,  concat(Sender_FirstName, Sender_LastName) 
		as SenderName, ord.Guide_Number as Number , ord.Guide_Serie 
		as Serie , Sender_Phone ,thb.IdHublogistic as Hub, 
		(sum (dop.PaymentRecollections) + sum (dop.RecolectPayment)) 
		as AmountPickup , Sender_Address as AddressPickup 
		from DeliveryOrder ord
						inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship) and StatusTownshipHub=1
						inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
						inner join @TblDeliveryOrdersList t   on (t.Guide_Number = dop.GuideNumber and t.Guide_Serie = dop.GuideSerie) 
						where ord.Guide_Number in (t.Guide_Number)
						group by Sender_ID ,  Sender_Phone,ord.Guide_Number, ord.Guide_Serie  ,thb.IdHublogistic,  Sender_Address, Sender_FirstName, Sender_LastName) as table1
			LEFT JOIN (
					--SELECT  SenderPhone,IdHubLogistics,AddressPickup,SenderName,SchedulePickupId,IdServiceManagement,ServiceStatusId FROM DBO.SchedulePickup SP				
					SELECT  SenderPhone,IdHubLogistics,AddressPickup,SenderName,SchedulePickupId,SP.AssigmentStatus,SM.IdServiceManagement FROM DBO.SchedulePickup SP				
					LEFT JOIN DBO.ServiceManagement SM ON SM.IdSchedulePickup=SP.SchedulePickupId
					--WHERE (SP.AssigmentStatus =0 OR (SM.RowStatus=1 AND SP.RowStatus=1 AND SP.AssigmentStatus=1 AND SM.ServiceStatusId IN(1,2)) ) --THIS LINE IS EQUIVALENT TO LINE BELOW
					WHERE NOT( (SP.AssigmentStatus <>0 AND SP.AssigmentStatus IS NOT NULL) AND NOT(SM.RowStatus=1 AND SP.RowStatus=1 AND SP.AssigmentStatus=1 AND SM.ServiceStatusId IN(1,2)) ) 
					AND (CONVERT(DATE,GETDATE()) >= CONVERT(DATE, SP.startDate))
					AND (CONVERT(DATE, SP.EndDate) >= CONVERT(DATE,GETDATE()))
			) TEST
			ON 
				TEST.SenderPhone=table1.Sender_Phone
				AND TEST.IdHubLogistics=table1.Hub
				AND TEST.AddressPickup=table1.AddressPickup
				AND TEST.SenderName=table1.SenderName

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
			  WHERE sd.SchedulePickupId IS NULL
			  group by sd.Sender_ID ,  sd.SenderName,sd.Sender_Phone,  sd.Hub,sd.AddressPickup

			  declare @transaction int = Scope_Identity()
			  

			 
			 --ACTUALIZANDO GUIAS SIN SCHEDULE PICKUP
			 update dbo.DeliveryOrderPaymentDetail set IdHeaderRecolection = @transaction, StartDate = @StartDate, EndDate = @EndDate,DateUpdated=GETDATE(), TokenUpdated=@Token
			 from dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
			 inner join @TblDeliveryOrdersList t on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 
			 LEFT join #Sender sd on sd.Serie=pay.GuideSerie and sd.Number=pay.GuideNumber 
			 WHERE sd.SchedulePickupId is null

			 --ACTUALIZANDO GUIAS CONSCHEDULEPICKUP
			 update dbo.DeliveryOrderPaymentDetail set IdHeaderRecolection = sd.SchedulePickupId, StartDate = @StartDate, EndDate = @EndDate,DateUpdated=GETDATE(), TokenUpdated=@Token
			 from dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
			 inner join @TblDeliveryOrdersList t on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 
			 LEFT join #Sender sd on sd.Serie=pay.GuideSerie and sd.Number=pay.GuideNumber
			 WHERE sd.SchedulePickupId is not null

			 --ACTUALIZANDO ESTADO DE LAS GUÍAS (A PROGRAMADO PARA RECOLECCIÓN)PARA LOS SERVICIOS QUE YA ESTAN ASIGNADOS
			-- DECLARE @IdStatusSh tinyint= (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription='Programado para recolección');
			-- UPDATE DBO.DeliveryOrder
			--	SET StatusOrderId=@IdStatusSh 
			--FROM DBO.DeliveryOrder DO WITH (NOLOCK)
			--INNER JOIN #Sender SD 
			--	ON  DO.Guide_Serie=SD.Serie AND DO.Guide_Number=SD.Number AND SD.AssigmentStatus=1

			-- UPDATE DBO.DeliveryOrderPiece
			--	SET StatusOrderId=@IdStatusSh 
			--FROM DBO.DeliveryOrderPiece DO WITH (NOLOCK)
			--INNER JOIN #Sender SD 
			--	ON  DO.GuideSerie=SD.Serie AND DO.GuideNumber=SD.Number AND SD.AssigmentStatus=1

			--ACTUALIZANDO MONTO DE SERVICIOS QUE YA ESTABAN ASIGNADOS A RUTA(SE SUMA EL NUEVO MONTO DE LA NUEVA GUÍA PROGRAMADO)
			DECLARE @TempPrice TABLE(	
			GuideSerie			NVARCHAR (25) NULL,
			GuideNumber			NVARCHAR (25) NULL,
			IsCollect			NVARCHAR (25) NULL,
			Price				DECIMAL (14,2) NULL,
			COD					DECIMAL (14,2) NULL,
			AmountPaid			DECIMAL (14,2) NULL,
			CODPaid				DECIMAL (14,2) NULL,
			CODIsPaid			DECIMAL (14,2) NULL,
			PaymentTime			INT NULL,
			TimeSequence		INT NULL,
			FelNumber			NVARCHAR (50) NULL,
			IsPaid				INT NULL,
			IsCustomer			INT NULL,
			ConditionPayment	NVARCHAR(200) NULL,
			HaveCredit			NVARCHAR (50) NULL,
			CollectCOD			NVARCHAR (50) NULL,
			ReturnRate			DECIMAL (14,2) NULL,
			AmountToPay			DECIMAL (14,2) NULL,
			CODAmount			DECIMAL (14,2) NULL,
			ReturnRates			DECIMAL (14,2) NULL
			)
			DECLARE @guides nvarchar (MAX) = ( SELECT
					STUFF((SELECT DISTINCT
							',' + CONCAT(Serie, Number)
						FROM #Sender
						GROUP BY Serie
								,Number
						FOR XML PATH (''))
					, 1, 1, ''));
			INSERT INTO @TempPrice (GuideSerie, GuideNumber, IsCollect, Price, COD, AmountPaid, CODPaid
			, CODIsPaid, PaymentTime, TimeSequence, FelNumber, IsPaid, IsCustomer
			, ConditionPayment, HaveCredit, CollectCOD, ReturnRate, AmountToPay, CODAmount, ReturnRates)
			EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @guides
													   ,@InTime = 2
													   ,@IsReturn = 'FALSE'
													   ,@CodeApp = 'SIFDCECOM300720201459'
													   ,@IdModule = 1
													   ,@Token = 'SYSTEM'
			UPDATE DBO.ServiceManagement
				SET Amount=SM.Amount+TP.AmountToPay
			FROM DBO.ServiceManagement SM 
				INNER JOIN  DBO.#Sender SD  ON SM.IdServiceManagement=SD.IdServiceManagement
				INNER JOIN @TempPrice TP ON TP.GuideSerie=SD.Serie AND TP.GuideNumber=SD.Number
			--@TempPrice TP ON  SD.Serie=

	
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



				
				--l momento de finalizar el proceso de devolución se debe realizar update en la tabla warehouse al campo Rack_Position, colocarlo como NULL
				  UPDATE  dbo.warehouse SET Rack_Position=NULL 
				  where Guide_Serie = @Guide_Serie AND 
                        Guide_Number = @Guide_Number




	end 

	if(@ValidateFilter = 5)
	begin 
		-- MODIFICACIÓN 31/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		DECLARE @TranCounter1 INT;  
		SET @TranCounter1 = @@TRANCOUNT;  
		IF @TranCounter1 > 0  
		BEGIN
			SAVE TRANSACTION Filter5;  
		END
		ELSE  
		BEGIN
			BEGIN TRANSACTION;  
		END
		-- FIN MODIFICACIÓN

		BEGIN TRY

			DECLARE @jsonResult NVARCHAR(MAX) 

			update dbo.DeliveryOrder 
				set StatusOrderId = @IdStatus, IsCollect = t.IsCollect
			from dbo.DeliveryOrder ord
			inner join @TblDeliveryOrdersList t on t.Guide_Number = ord.Guide_Number 
				and t.Guide_Serie = ord.Guide_Serie

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

			-- MODIFICACIÓN 07/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			DECLARE @VistitPointUser1 INT = (SELECT CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient VPC
											JOIN VisitPointByUser VPU
												ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
													AND VPU.RowStatus = 1
											JOIN RegisterUser ru
												ON VPU.RegisterUserID = ru.UsrIdUser
													AND ru.UsrRowStatus = 1
													JOIN [dbo].[RolByUserByAccount] rua
											ON rua.RuaIdUser = ru.UsrIdUser
											WHERE rua.RuaIdAccount = @IdAccount)
			-- FIN MODIFICACIÓN

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
				-- MODIFICACIÓN 07/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
				,[VisitPoint]
				-- FIN MODIFICACIÓN
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
				-- MODIFICACIÓN 07/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
				,IIF(@VistitPointUser1=0,null, @VistitPointUser1)
				-- FIN MODIFICACIÓN
			from @TblDeliveryOrdersList tdop
			where tdop.PriceShippment != 0 
				or tdop.CODAmountProccess != 0

		-- MODIFICACIÓN 31/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
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

			IF @TranCounter = 0  
			BEGIN
				-- @TranCounter = 0 means no transaction was  
				-- started before the procedure was called.  
				-- The procedure must commit the transaction  
				-- it started.  
				COMMIT TRANSACTION;
			END

			--Valor para validar la transacción si es llamado por otro SP
			RETURN 1;

		END TRY
	
		BEGIN CATCH
			SELECT
				'ERROR' AS message
			   ,'FALSE' blnResult
			   ,CAST(500 AS VARCHAR(5)) StatusResult
			   ,CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber
			   ,CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity
			   ,CAST(ERROR_STATE() AS VARCHAR) AS ErrorState
			   ,CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure
			   ,CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine
			   ,CAST(ERROR_MESSAGE() AS VARCHAR(100)) AS ResultMessage;
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
			
			IF @TranCounter1 = 0  
			BEGIN
				-- Transaction started in procedure.  
				-- Roll back complete transaction.  
				ROLLBACK TRANSACTION;  
			END
			ELSE  
			BEGIN
				-- Transaction started before procedure  
				-- called, do not roll back modifications  
				-- made before the procedure was called.  
				IF XACT_STATE() <> -1  
				BEGIN
				-- If the transaction is still valid, just  
				-- roll back to the savepoint set at the  
				-- start of the stored procedure.  
					ROLLBACK TRANSACTION Filter5;  
				-- If the transaction is uncommitable,			
				END
			END


			--RAISERROR('Error en la transacción', 16, 1);
			
			--Valor para validar la transacción si es llamado por otro SP 
			RETURN 0
			
		END CATCH;
		-- FIN MODIFICACIÓN

	end 
END