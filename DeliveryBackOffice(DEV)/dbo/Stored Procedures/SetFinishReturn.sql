



-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-05-18>
-- Description:	<Finaliza el proceso de recoleccion insertando informacion en las tablas de costos>
-- ==============================================

CREATE PROCEDURE [dbo].[SetFinishReturn]
	-- Add the parameters for the stored procedure here
	@TblGuidesReturns AS [TblGuidesReturns] READONLY,
	@TblPaymentType AS [TblPaymentReturn] READONLY,

--@InGuides   NVARCHAR(400) = 'FD22221,FD22361,FD22223,FD22359,FD22226',
	@ServiceManagementId int = 2,
--@TypeofInOutMoneyId int = 1,
--	@IdStatusPickup int = 3,
	@Token varchar(200) = null,
	@FullPayment decimal (14,2) =0,
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
		
	print 'token valido'
	

			--CREATE TABLE #Temp (
			--    Guide      VARCHAR(255),
			--    Message       VARCHAR(255),
			--)
			--INSERT INTO #Temp (Guide, Message)
			--EXEC  [dbo].[spws_get_validate_guides_pickup]
			--	-- Add the parameters for the stored procedure here
			--	@InGuides  = @InGuides,
			--	@IdPickup = @IdPickup
			-- --if (SELECT  count(*) FROM #Temp)=0
			-- declare @test int = (select COUNT(*) from #Temp)
		
		print 'clavo token valido'
		
		
			 --if (true)
				-- begin
				 	BEGIN TRANSACTION
					BEGIN TRY
		
		--				--IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
		--		--------------------------------------------------------------------------------------------------------------
		--				IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		
		--				select SUBSTRING(Item, 1,2) ItemSerie,
		--					SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber --, 
		--				into #listGuides
		--				from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')
		
		-----declare @IdCustomer int = (select IdCustomer from Account where AccIdAccount = @IdAccount)
		--------------------------------------------------------------------------------------------------------------------------------
			print 'token valido1'
		--------------------------------inserta en una tabla temporal, los campos requeridos para insertar en DeliveryPaymentDetail las guias no generadas en el portal--------------------------------------
			
			print 'tarifa recoleccion'	
	      
		  declare @incident1 int = (select top 1 ni.State from @TblGuidesReturns ni where ni.State <> 200) 
		  
	
			if ( @incident1 > 0 )
			begin

			insert into DeliveryOrderDetail (
						[Guide_Serie]
						    ,[Guide_Number]
						    ,[StatusOrderId]
						    ,[UserCreated]
						    ,[DateCreated]
						    ,[DateCreatedInSystem]
						    ,[Observations]
						    ,[Temperature_Celsius]
							,[PieceId]
						)
						select ni.Serie
						,ni.NumberGuide
						,14
						,@Token
						,GETDATE()
						,GETDATE()
						,null
						,null
						,ni.NoPiece
							from @TblGuidesReturns ni

				update DeliveryOrder set StatusOrderId = 14
				, LastCollectOnDelivery = Collect_OnDelivery
				,Collect_OnDelivery =0
				from DeliveryOrder
				where Guide_Number in (select NumberGuide from @TblGuidesReturns) and Guide_Serie in (select Serie from @TblGuidesReturns)
				----------------------------------Bitacora de detalle de manifiesto-----------------------------------------------------------------------


								;WITH LatestID AS (
									SELECT 
										Guide_Number,
										MAX(ID) AS LastID
									FROM 
										[dbo].[DeliverySettlementDetail] WITH (NOLOCK)
									WHERE Guide_Number in (SELECT NumberGuide FROM @TblGuidesReturns)
									GROUP BY 
										Guide_Number
								)

								UPDATE ds
								SET 
									ds.StatusOrderId = 14
								FROM 
									[dbo].[DeliverySettlementDetail] ds
								INNER JOIN 
									LatestID li ON ds.Guide_Number = li.Guide_Number AND ds.ID = li.LastID
								INNER JOIN 
									@TblGuidesReturns tg ON ds.Guide_Number = tg.NumberGuide;

---------------------------------------------- Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia --------------------
						
						
						update DeliveryOrderPiece set StatusOrderId = 14
						from DeliveryOrderPiece
						where GuideNumber in (select NumberGuide from @TblGuidesReturns) and GuideSerie in (select Serie from @TblGuidesReturns) and NoPiece in (select NoPiece	 from @TblGuidesReturns)
						
		---------------------------------------------- Actualiza el Status del Servicio  -------------------------------------------------------------------------
				
			
				 insert into DeliveryBackOffice.dbo.IncidenceServices(ServiceManagementId,IncidenceTypeId, DescriptionIncidence,
				 Latitude, Longitude, Accuracy, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated,
				 Guide, Observations)
					select @ServiceManagementId, ni.State, ci.NameIncidence, null, null, null, 1, @Token, GETDATE(), null, null, CONCAT(ni.Serie, ni.NumberGuide,'-' ,convert(nvarchar(10), ni.NoPiece)), null
					from @TblGuidesReturns ni
					join CatTypeIncidence ci on (ci.IdIncidenceType = ni.State)
		
					declare @incidence int  = SCOPE_IDENTITY()

					declare @Status int = (	select IdServiceStatus from  CatServiceStatus where IdServiceStatus =  8)
													
					update ServiceManagement set ServiceStatusId = @Status
						from ServiceManagement
						where IdServiceManagement = @ServiceManagementId
					
						declare @transac int = (select top 1 IdServiceManagement from ServiceManagement where IdServiceManagement = @ServiceManagementId)
					
					   --------------------------------------------- Inserta en EventService el comportamiento del Pickup  -------------------------------------------------------------------------	
					
					insert into EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
					values( @transac, @Status, 1, @Token, GETDATE(), null )

					if @FullPayment> 0
						declare @amont decimal(14,2)  = (select Amount from @TblPaymentType)
						declare @idpay int = (select IdPayment from @TblPaymentType)
						declare @vouchers nvarchar(25) = (select Voucher from @TblPaymentType)
						DECLARE @fecha as date = getdate()
							begin
								Exec [dbo].[SetPaymentTransaction]
										@ProductNumber = @ServiceManagementId,
										@Amount = @amont,
										@IdModule  = 1,
										@PaymentType  = @idpay,
										@Voucher =@vouchers,
										@Token = @Token,
										@PaymentDate =@fecha
							end
			
			
				end
		
			else 
			begin
					
						
		--------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------
			print 'Registra en la tabla DeliveryOrderDetail la entrega de la guia'
						insert into DeliveryOrderDetail (
						[Guide_Serie]
						    ,[Guide_Number]
						    ,[StatusOrderId]
						    ,[UserCreated]
						    ,[DateCreated]
						    ,[DateCreatedInSystem]
						    ,[Observations]
						    ,[Temperature_Celsius]
							,[PieceId]
						)
						select ni.Serie
						,ni.NumberGuide
						,14
						,@Token
						,GETDATE()
						,GETDATE()
						,null
						,null
						,ni.NoPiece
							from @TblGuidesReturns ni
						
		
		-------------------------- Drop la tabla temporal -------------------------------------------------------------------
						
							--DROP TABLE #UpdateNow
						--DROP TABLE #NowInsert
					
						
		---------------------------------Obtner los datos a actualizar del encabezado del lote de guias -------------------------------------

						update DeliveryOrder set StatusOrderId = 14
						from DeliveryOrder
						where Guide_Number in (select NumberGuide from @TblGuidesReturns) and Guide_Serie in (select Serie from @TblGuidesReturns)

						-------------------WEBHOOK.INI-----------------------			
	--		IF ( SELECT ISNULL(WebhookEndpointId,0) 
	--	FROM WebhookEndpoint wep
	--	WHERE wep.IdCustomer  IN (
	--						select od.IdCustomer
	--						from   @TblGuidesReturns ls
	--							  INNER JOIN  dbo.DeliveryOrder od on od.Guide_Serie =  ls.Serie AND od.Guide_Number = ls.NumberGuide
	--							)
	--	) > 0
	--BEGIN 
	--					INSERT INTO [dbo].[WebhookTrackingQueue]
	--					       ([Guide_Serie]
	--					       ,[Guide_Number]
	--					       ,[IdCustomer]
	--					       ,[Status]
	--					       ,[WebhookEndpointId]
	--					       ,[HasNotified]
	--					       ,[ChangedDate])
	--					SELECT  od.[Guide_Serie]
	--					       ,od.[Guide_Number]
	--					       ,od.[IdCustomer]
	--					       ,od.[StatusOrderId]
	--					       ,(SELECT WebhookEndpointId FROM WebhookEndpoint WHERE IdCustomer = od.IdCustomer)
	--					       ,0
	--					       ,GETDATE()
	--					FROM   @TblGuidesReturns ls
	--						   INNER JOIN  dbo.DeliveryOrder od on od.Guide_Serie =  ls.Serie AND od.Guide_Number = ls.NumberGuide
	--	END
						-------------------WEBHOOK.FIN------------------------------	
						
		---------------------------------------------- Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia --------------------
						
						
						update DeliveryOrderPiece set StatusOrderId = 14
						from DeliveryOrderPiece
						where GuideNumber in (select NumberGuide from @TblGuidesReturns) and GuideSerie in (select Serie from @TblGuidesReturns) and NoPiece in (select NoPiece	 from @TblGuidesReturns)
						
		---------------------------------------------- Actualiza el Status del Servicio  -------------------------------------------------------------------------
						
						declare @Status2 int = (	select IdServiceStatus from  CatServiceStatus where IdServiceStatus =  7)
						
						update ServiceManagement set ServiceStatusId = @Status , PuSignaturePath = @PuSignaturePath
							from ServiceManagement
							where IdServiceManagement = @ServiceManagementId
						
						declare @transac2 int = (select top 1 IdServiceManagement from ServiceManagement where IdServiceManagement = @ServiceManagementId)
									
		---------------------------------------------- Inserta en EventService el comportamiento del Pickup  -------------------------------------------------------------------------	
										
						insert into EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
						values( @transac2, @Status2, 1, @Token, GETDATE(), null )
									
		-----------------------------------------Registrar pago ---------------------------------------------------------------------------
								
						if @FullPayment> 0
						declare @amont2 decimal(14,2)  = (select Amount from @TblPaymentType)
						declare @idpay2 int = (select IdPayment from @TblPaymentType)
						declare @vouchers2 nvarchar(25) = (select Voucher from @TblPaymentType)
						DECLARE @fecha2 as date = getdate()
							begin
								Exec [dbo].[SetPaymentTransaction]
										@ProductNumber = @ServiceManagementId,
										@Amount = @amont2,
										@IdModule  = 1,
										@PaymentType  = @idpay2,
										@Voucher =@vouchers2,
										@Token = @Token,
										@PaymentDate =@fecha2
							end
					end		
							
		-- retornar resultado en formato json
		
					END TRY
					BEGIN CATCH
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
						
					

						set @jsonResult = (SELECT STUFF(( 
							SELECT  
						',"Messege":"Cambios realizados exitosamente"}'

						FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
												) )
				
				
				--- succesfull
					END
				
		 			select ('[{' + @jsonResult +  ']') jsonResult

					
		 -----------------------------------------------
			--else if(@test>0)
			--	begin
			--	 set @jsonResult1 =(
			--					SELECT STUFF(( 
			--					SELECT ',{"Error":"' +  isnull(convert(varchar,Guide), 'N/A' )  +  + '"}' 
			--					from #Temp where Guide in (select Guide from #Temp)
			--					FOR XML PATH(''), TYPE
			--					).value('.', 'varchar(max)'),1,1,''
			--						  ) 
			--				)
					
			--		print @jsonResult1
				
			--	 set @jsonResult2 =(
			--					SELECT STUFF(( 
			--					SELECT ',{"Message":"' + isnull(convert( nvarchar(max),Message), 'N/A') +  + '"}' 
			--					from #Temp where Guide in (select Guide from #Temp)
			--					FOR XML PATH(''), TYPE
			--					).value('.', 'varchar(max)'),1,1,''
			--						  ) 
			--				)
		
			--		print @jsonResult2
			--	  SET @jsonError =
		 --                       (
		 --                           SELECT STUFF(
		 --                       (
		 --                           SELECT '{"IdResult":412' + ',' + '"Guides":[' + @jsonResult1 + '],' + '"Messege":[' + @jsonResult2 + ']' + '' FOR XML PATH(''), TYPE
		 --                       ).value('.', 'varchar(max)'), 1, 1, '')
		 --                       );
			--	print @jsonError
				
			--	select ('{' + @jsonError +  '}') jsonError
		
			--	end
		
		
		--------------------
		end

	if(@TokenAct = 0 or @TokenAct is null or @hourtoken > 8)
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

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
		IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;

		-- retornar resultado en formato json

				

END

