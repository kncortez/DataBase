USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetFinishPickUp]    Script Date: 08/09/2021 9:27:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Finaliza el proceso de recoleccion insertando informacion en las tablas de costos>
-- =============================================

ALTER PROCEDURE [dbo].[SetFinishPickUp]
	-- Add the parameters for the stored procedure here
	@InGuides   NVARCHAR(max) = 'FD22221,FD22361,FD22223,FD22359,FD22226',
	@IdPickup int = 2,
	@TypeofInOutMoneyId int = 1,
--	@IdStatusPickup int = 3,
	@Token varchar(200) = null,
	@Observations varchar (200) = null,
	@Amount decimal (12,2) =0,
	@Voucher nvarchar(200) = ' ',
	@PuSignaturePath NVARCHAR (250) = ' '

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @jsonResult NVARCHAR(MAX)
	DECLARE @jsonResult1 NVARCHAR(MAX) 
	DECLARE @jsonResult2 NVARCHAR(MAX) 
	DECLARE @jsonError NVARCHAR(MAX) 
	DECLARE @jsonToken NVARCHAR(MAX)
	
	
	print 'validar token'
		-- insertar en tabla temporal posbibles mensajes de respuesta
			--IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
			IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL DROP TABLE #NowInsert;
			IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
		    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
			select * INTO #responsemessage from (SELECT  200 AS IdResult
															,'Estado  cambiado correctamente' AS Message
															,'OK' as Id 
													union
													SELECT  500 AS IdResult
															,'Error faltal intente de nuevo mas tarde' AS Message
															,'Transac' as Id 
												 )  as errror

	declare @TokenAct int  = (select top 1 RowStatus from LogTokenPOD where LogTokenPOD LIKE '%' + @Token + '%' order by DateCreated desc)
	declare @hourtoken int = (select top 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) as horas from LogTokenPOD where LogTokenPOD  LIKE '%' + @Token + '%')
	
	print 'validando token'
	if (@TokenAct = 1 and @hourtoken <= 8)
	begin 
			PRINT '@TokenAct'
			PRINT @TokenAct
			print 'token valido'
			PRINT '@hourtoken'
			PRINT @hourtoken

			create table #Temp(
			    Guide        VARCHAR(255),
			    Message      VARCHAR(255),
			)

			--select * from #Temp
			--DECLARE @Tabla1 TABLE(id INT, nombreVARCHAR(20), telefonoVARCHAR(12));


			INSERT INTO #Temp (Guide, Message)
			EXEC  [dbo].[spws_get_validate_guides_pickup]
				-- Add the parameters for the stored procedure here
				@InGuides  = @InGuides,
				@IdPickup = @IdPickup
			 --if (SELECT  count(*) FROM #Temp)=0
			 
			

			 declare @test int = (select COUNT(*) from #Temp)
		
			print 'clavo token valido'
		
		
			 if (@test = 0)
				 begin
				 	BEGIN TRANSACTION
					BEGIN TRY
		
						--IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
						IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		
						select SUBSTRING(Item, 1,2) ItemSerie,
							SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber --, 
						into #listGuides
						from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

		
		---declare @IdCustomer int = (select IdCustomer from Account where AccIdAccount = @IdAccount)
		
			print 'token valido1'
		--------------------------------inserta en una tabla temporal, los campos requeridos para insertar en DeliveryPaymentDetail las guias no generadas en el portal--------------------------------------
			
			print 'tarifa recoleccion'	
	      
	

		   declare @AmountPickup  decimal (14,2) = ( select convert(decimal (14,2) ,Value) from CatToCharge where IdToCharge = 1)
	
		--	print 'tarifa recoleccion1'  + @AmountPickup
						
		--	select Guide_Number, Guide_Serie, PriceShippment from DeliveryOrder
		--	where Guide_Number = 198915			
						
						SELECT 
									
						[Guide_Number] ,
						[Guide_Serie],
						[PriceShippment],
						[recolect]
						INTO #NowInsert
						FROM  (select   ord.Guide_Number  , ord.Guide_Serie, ord.PriceShippment , (@AmountPickup) as recolect from DeliveryOrder ord 
																				left join DeliveryOrderPaymentDetail dop on (ord.Guide_Number = dop.GuideNumber and ord.Guide_Serie = dop.GuideSerie)
																				inner join #listGuides ls on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
																				where ord.Guide_Number in (select ItemNumber from #listGuides) and ord.StatusOrderId in (15,1,16)
																				and dop.GuideNumber is null)  as Table1
								
					--	declare @AmountPickup decimal (18,2) = (select  Convert(decimal(18,2),Value) from ConfigParams where ConfigParamsId = 15)
						
						
						
		----------------------------------------------Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal ----------------------------------
						 print 'Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal '
						insert into dbo.DeliveryOrderPaymentDetail
							(  [GuideNumber]
						      ,[GuideSerie]
						      ,[PayTypeId]
						      ,[TypeofInOutMoneyId]
						      ,[TimePlaId]
						      ,[amount]
						      ,[TokenCreated]
						      ,[DateCreated]
						      ,[TokenUpdated]
						      ,[DateUpdated]
						      ,[PaymentRecollections]
						      ,[PaymentNow]
						      ,[PaymentDelivery]
						      ,[StartDate]
						      ,[EndDate]
						      ,[ShipmentCompleted]
						      ,[RecollectionCompleted]
						      ,[PaidGuide]
						      ,[TransaccionFAC]
						      ,[IdHeaderRecolection]
						      ,[RecolectNow]
						      ,[RecolectDelivery]
						      ,[RecolectPayment]
							  )
							  select distinct ls.Guide_Number 
							,ls.Guide_Serie
							,1
							,@TypeofInOutMoneyId
							,2
							,null
							,@Token
							,getdate()
							,null
							,null
							,null
							,0.00
							,0.00
							,null
							,null
							,null
							,null
							,null
							,null
							,@IdPickup
							,0.00
							,0.00
							,@AmountPickup
							  from #NowInsert ls
						
						
		--------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------
			print 'Registra en la tabla DeliveryOrderDetail la recoleccion de la guia'
						insert into DeliveryOrderDetail (
						[Guide_Serie]
						    ,[Guide_Number]
						    ,[StatusOrderId]
						    ,[UserCreated]
						    ,[DateCreated]
						    ,[DateCreatedInSystem]
						    ,[Observations]
						    ,[Temperature_Celsius]
						)
						select ni.ItemSerie
						,ni.ItemNumber
						,2
						,@Token
						,GETDATE()
						,GETDATE()
						,null
						,null
							from #listGuides ni
						
		--- MODIFICACION - JOSE ANDRES RUIZ PEER - 2021-09-08
		--- UPDATE PARA MANEJO DE ENVIO DE MENSAJITOS EN HORA DE RECOLECCION
			update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
			set UpdateStatus=1
			where ElementId=1002
		--- FIN MODIFICACION
		
		-------------------------- Drop la tabla temporal -------------------------------------------------------------------
						
							--DROP TABLE #UpdateNow
						DROP TABLE #NowInsert
					
						
		---------------------------------Obtner los datos a actualizar del encabezado del lote de guias -------------------------------------
						print 'Obtner los datos a actualizar del encabezado del lote de guias'
						declare @SenderId int  = (select top 1 ord.Sender_ID  from #listGuides ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
										where ord.Guide_Number in (select ItemNumber from #listGuides ))

						declare @CustomerId int  = (select top 1 isnull( ord.IdCustomer,6)  from #listGuides ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
										where ord.Guide_Number in (select ItemNumber from #listGuides ))
						
						declare @SenderName varchar (50)  = (select top 1  concat(ord.Sender_FirstName, ord.Sender_LastName) as SenderName  from #listGuides ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
										where ord.Guide_Number in (select ItemNumber from #listGuides ))
						
						declare @Sender_Phone varchar (20)  = (select top 1  ord.Sender_Phone from #listGuides ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
										where ord.Guide_Number in (select ItemNumber from #listGuides ))
						
						
						declare @IdHublogistic int  = (select top 1  thb.IdHublogistic from #listGuides ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
										inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
										inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
										where ord.Guide_Number in (select ItemNumber from #listGuides ))
					
						
						declare @Sender_Address varchar (200)  = (select top 1 ord.Sender_Address from #listGuides ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
										where ord.Guide_Number in (select ItemNumber from #listGuides ))

						declare @Sender_Email varchar (200)  = (select top 1 isnull( REPLACE( REPLACE(cus.RegexEmail,'$',''),'^',''),' ') from #listGuides  ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)
										left join dbo.Customer cus on cus.IdCustomer = ord.IdCustomer)
						
						
		-----------------------------------------------------Actualiza los datos obtenidos anteriormente para la tabla SchedulePickup-----------------------------------------------------------
						
						update dbo.SchedulePickup  set  SenderId = @SenderId, SenderName = @SenderName, SenderPhone = @Sender_Phone , IdHubLogistics = @IdHublogistic, AddressPickup = @Sender_Address, AmountPickup = @AmountPickup
						where SchedulePickupId = @IdPickup
						
		---------------------------------------------------------Agrupa el lote de guias a una sola transaccion ------------------------------------------------------------------------------
						
						update DeliveryOrderPaymentDetail  set  IdHeaderRecolection = @IdPickup
						from DeliveryOrderPaymentDetail dop
						inner join DeliveryOrder ord on (ord.Guide_Number = dop.GuideNumber and ord.Guide_Serie = dop.GuideSerie)
						where GuideNumber in( select ItemNumber from #listGuides) and ord.StatusOrderId in (15,1,16) and (dop.IdHeaderRecolection = @IdPickup or dop.IdHeaderRecolection is null)
						
		------------------------------------------------- Actualiza su StatusId a 2 = Recoleccion todas las guias del lote -------------------------------------
						
						update DeliveryOrder set StatusOrderId = 2
						from DeliveryOrder
						where Guide_Number in (select ItemNumber from #listGuides) and Guide_Serie in (select ItemSerie from #listGuides)

						
						-------------------WEBHOOK.INI-----------------------			
			IF ( SELECT ISNULL(WebhookEndpointId,0) 
		FROM WebhookEndpoint wep
		WHERE wep.IdCustomer  IN (
							select od.IdCustomer
							from  #listGuides ls
								  INNER JOIN  dbo.DeliveryOrder od on od.Guide_Serie =  ls.ItemSerie AND od.Guide_Number = ls.ItemNumber
								)
		) > 0
	BEGIN 
						INSERT INTO [dbo].[WebhookTrackingQueue]
						       ([Guide_Serie]
						       ,[Guide_Number]
						       ,[IdCustomer]
						       ,[Status]
						       ,[WebhookEndpointId]
						       ,[HasNotified]
						       ,[ChangedDate])
						SELECT  od.[Guide_Serie]
						       ,od.[Guide_Number]
						       ,od.[IdCustomer]
						       ,od.[StatusOrderId]
						       ,(SELECT WebhookEndpointId FROM WebhookEndpoint WHERE IdCustomer = od.IdCustomer)
						       ,0
						       ,GETDATE()
						FROM   #listGuides ls
							   INNER JOIN  dbo.DeliveryOrder od on od.Guide_Serie =  ls.ItemSerie AND od.Guide_Number = ls.ItemNumber
		END
						-------------------WEBHOOK.FIN------------------------------	
						
		---------------------------------------------- Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia --------------------
						
						
						update DeliveryOrderPiece set IsPickup = 1
						from DeliveryOrderPiece
						where GuideNumber in (select ItemNumber from #listGuides) and GuideSerie in (select ItemSerie from #listGuides)
						
		---------------------------------------------- Actualiza el Status del Servicio  -------------------------------------------------------------------------
						
						declare @Status int = (	select IdServiceStatus from  CatServiceStatus where IdServiceStatus =  3)
						
						update ServiceManagement set ServiceStatusId = @Status , PuSignaturePath = @PuSignaturePath
							from ServiceManagement
							where IdSchedulePickup = @IdPickup
						
						declare @transac int = (select top 1 IdServiceManagement from ServiceManagement where IdSchedulePickup = @IdPickup)
									
		---------------------------------------------- Inserta en EventService el comportamiento del Pickup  -------------------------------------------------------------------------	
										
						insert into EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
						values( @transac, @Status, 1, @Token, GETDATE(), @Observations )
									
		-----------------------------------------Registrar pago ---------------------------------------------------------------------------
								
						DECLARE @fecha as date = getdate()
						if @Amount> 0
							begin
								Exec [dbo].[SetPaymentTransaction]
										@ProductNumber = @IdPickup,
										@Amount = @Amount,
										@IdModule  = 1,
										@PaymentType  = @TypeofInOutMoneyId,
										@Voucher =@Voucher,
										@Token = @Token,
										@PaymentDate =@fecha
							 end
								declare @mail varchar (200) = (select top 1 RegexEmail from Customer ct
													inner join DeliveryOrder ord on(ord.IdCustomer = ct.IdCustomer)
													where ord.Guide_Number in  (select ItemNumber from #listGuides)) 


		-----------------------------------------Registrar Manifiesto ---------------------------------------------------------------------------
		print 'insertando manifiesto'
					DECLARE @ManifestNumber AS int = (SELECT MAX([Manifest_Number]) + 1 FROM [DeliveryBackOffice].[dbo].[ServiceRequest])
				print 'Manifest number'
			print @ManifestNumber

			DECLARE @ManifestSerie  as nvarchar(5) = (select top 1 Value from dbo.ConfigParams where Name = 'ManifestSerie')

			print '[Receiver_Name]'
			print @SenderName

			print '[Receiver_Email]'
			print @Sender_Email

			print '[CustomerID] '
			print @CustomerId

			print 'Manifest serie'
			print @ManifestSerie

				INSERT INTO DeliveryBackOffice.dbo.ServiceRequest (
					[Receiver_Name], 
					[Receiver_Email], 
					[Status], 
					[Receiver_Date], 
					[DateCreated], 
					[Manifest_Serie], 
					[Manifest_Number],
					[CustomerID]
				)
				values(  
					@SenderName,
					@Sender_Email,
					'', 
					getdate(), 
					getdate(),
					@ManifestSerie,
					@ManifestNumber,
					@CustomerId
				)
				--select * from #listGuides
				update dbo.DeliveryOrder set Manifest_Serie = @ManifestSerie , Manifest_Number = @ManifestNumber
				from 
				#listGuides ls
				 join	DeliveryOrder ord on (ord.Guide_Number = ls.ItemNumber and ord.Guide_Serie = ls.ItemSerie)



							print 'exito'			
							
		-- retornar resultado en formato json
		
					END TRY
					BEGIN CATCH
					print 'hago rollback'
						ROLLBACK TRANSACTION
							select ERROR_MESSAGE()
								-- retornar mensaje de error
							set @jsonResult =(
								SELECT STUFF(( 
								SELECT '"IdResult":' +  convert(varchar,IdResult)    +',' 
								+ '"Message":"' + convert( nvarchar(max),ERROR_MESSAGE()) + '"}' from #responsemessage where Id ='Invalid'
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
									  ) 
							)
					END CATCH;
					IF @@TRANCOUNT > 0 BEGIN
						COMMIT TRANSACTION;
						
					print 'hago commit'

						set @jsonResult = (SELECT STUFF(( 
							SELECT  
						',{"Message":"Cambios realizados exitosamente"}'

						FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
												) )
				
				
				print 'succesfull'
				print @jsonResult
					END
				
		 			select ('[' + @jsonResult +  ']') jsonResult
						print @jsonResult
					select @mail 
					--print @mail
			end
		 
			else if(@test>0)
				begin
				 set @jsonResult1 =(
								SELECT STUFF(( 
								SELECT ',{"Error":"' +  isnull(convert(varchar,Guide), 'N/A' )  +  + '"}' 
								from #Temp where Guide in (select Guide from #Temp)
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
									  ) 
							)
					
					print @jsonResult1
				
				 set @jsonResult2 =(
								SELECT STUFF(( 
								SELECT ',{"Message":"' + isnull(convert( nvarchar(max),Message), 'N/A') +  + '"}' 
								from #Temp where Guide in (select Guide from #Temp)
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
									  ) 
							)
		
					print @jsonResult2
				  SET @jsonError =
		                        (
		                            SELECT STUFF(
		                        (
		                            SELECT '{"IdResult":412' + ',' + '"Guides":[' + @jsonResult1 + '],' + '"Messege":[' + @jsonResult2 + ']' + '' FOR XML PATH(''), TYPE
		                        ).value('.', 'varchar(max)'), 1, 1, '')
		                        );
				print @jsonError
				
				select ('{' + @jsonError +  '}') jsonError
		
				end
		
		
		
		end
	else if(@TokenAct = 0 or @TokenAct is null or @hourtoken > 8)
		begin 
		     print 'token inválido'
					SET @jsonToken = (
				   SELECT STUFF((
		   			SELECT  
					',{"IdResult":' + '403' + ',' +
					'"DescriptionError":"' + 'Token inválido'  + '"' +	  	  
					'}' 
					FOR XML PATH(''), TYPE
				   ).value('.', 'varchar(max)'),1,1,''
		   					  ) 
				   )
					 select '['+ @jsonToken + ']' jsonToken
	
				   return
		end
	
	
--		DROP TABLE #Temp

		-- destruir tablas temporales
		print 'destruyendo tablas'
		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
		IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
		print 'tablas destruidas'
		-- retornar resultado en formato json

				

END

