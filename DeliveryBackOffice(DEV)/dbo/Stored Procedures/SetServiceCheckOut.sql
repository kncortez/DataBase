
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-11-02>
-- Description:	< Finaliza el proceso de servicios por lote de servicios (actualmente solo servicios de recolección) >
-- =============================================

CREATE PROCEDURE [dbo].[SetServiceCheckOut]
	@IdServiceBatch INT = 0,
	@CourierToken NVARCHAR(50) = '',
	@IdPaymentType INT = 1,
	@Amount DECIMAL(12,2) ,
	@Voucher NVARCHAR(200) = ''
AS
BEGIN
	-- Tabla de datos
	DECLARE @TblAcepted TblBatchGuides;

	-- Json de salida
	DECLARE @JsonResult VARCHAR(MAX) = ''
	DECLARE @JsonAdded VARCHAR(MAX) = ''
	DECLARE @JsonRejects VARCHAR(MAX) = ''

	-- Variables de lote de servicios
	DECLARE @BatchExists BIT = ISNULL(( SELECT 1 FROM DeliveryBackOffice.dbo.ServiceBatch SB WHERE SB.IdServiceBatch = @IdServiceBatch ),0)
	DECLARE @BatchStatus BIT = 0;
	DECLARE @BatchCount INT = 0;

	-- Variables para verificación de Courierman
	DECLARE @CourierTokenStatus INT  = (SELECT TOP 1 RowStatus FROM LogTokenPOD WHERE LogTokenPOD LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)
	DECLARE @CourierTokenLife INT = (SELECT TOP 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) FROM LogTokenPOD WHERE LogTokenPOD  LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)
	
	IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL DROP TABLE #NowInsert;

	IF (@CourierTokenStatus = 1 AND @CourierTokenLife <= 8)
	BEGIN
		BEGIN TRY
			IF (@BatchExists = 1)
			BEGIN
				BEGIN TRANSACTION
				BEGIN TRY
					SET @BatchStatus =	ISNULL((
											SELECT SB.RowStatus FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB WHERE SB.IdServiceBatch = @IdServiceBatch
										),0)
					IF (@BatchStatus = 1)
					BEGIN

						DECLARE @IdSchedulePickUp INT =
						(
							SELECT TOP 1
								SM.IdSchedulePickup
							FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB
							JOIN
							[DeliveryBackOffice].[dbo].[ServiceManagement] SM
							ON SB.ServiceManagementId = SM.IdServiceManagement
						)
					
						-- Copy Pieces into TblAcepted
						INSERT INTO @TblAcepted (RowNumber,GuideId,GuideSerie,GuideNumber,GuidePiece,InternalCode)
						SELECT null, CONCAT(SBD.GuideSerie, CAST(SBD.GuideNumber AS VARCHAR), '-', CAST(SBD.PieceNumber AS VARCHAR)), SBD.GuideSerie, SBD.GuideNumber, SBD.PieceNumber, null
						FROM [DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD
						JOIN 
						[DeliveryBackOffice].[dbo].[ServiceBatch] SB
						ON SBD.ServiceBatchId = SB.IdServiceBatch
						AND SB.RowStatus = 1;

						DECLARE @AmountPickup  DECIMAL(14,2) = ( SELECT CONVERT(DECIMAL (14,2) ,Value) FROM CatToCharge WHERE IdToCharge = 1)

						SELECT 
							[Guide_Number],
							[Guide_Serie],
							[PriceShippment],
							[recolect]
						INTO #NowInsert
						FROM
						(
							SELECT 
								ord.Guide_Number
								,ord.Guide_Serie
								,ord.PriceShippment
								,(@AmountPickup) as recolect 
							FROM 
								DeliveryOrder ord 
								left join DeliveryOrderPaymentDetail dop
								on (ord.Guide_Number = dop.GuideNumber and ord.Guide_Serie = dop.GuideSerie)
								inner join @TblAcepted ls
								on (ord.Guide_Number = ls.GuideNumber and ord.Guide_Serie = ls.GuideSerie)
								where
								ord.Guide_Number in (select TA.GuideNumber from @TblAcepted TA)
								and ord.StatusOrderId in (15,1,16)
								and dop.GuideNumber is null
						) as Table1

						insert into dbo.DeliveryOrderPaymentDetail
						( 
							[GuideNumber]
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
						select distinct
							ls.Guide_Number 
							,ls.Guide_Serie
							,1
							,@IdPaymentType
							,2
							,null
							,@CourierToken
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
							,@IdSchedulePickUp
							,0.00
							,0.00
							,@AmountPickup
						from #NowInsert ls
							
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
						select
							TA.GuideSerie
							,TA.GuideNumber
							,2
							,@CourierToken
							,GETDATE()
							,GETDATE()
							,null
							,null
						from @TblAcepted ta

						update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
						set UpdateStatus=1
						where ElementId=1002

						DROP TABLE #NowInsert

						
		                -- Obtner los datos a actualizar del encabezado del lote de guias 

						declare @SenderId int;
						declare @CustomerId int;
						declare @SenderName varchar (50);
						declare @Sender_Phone varchar (20);
						declare @Sender_Address varchar (200);

						select top 1 
						@SenderId = ord.Sender_ID,
						@CustomerId = isnull( ord.IdCustomer,6),
						@SenderName = concat(ord.Sender_FirstName, ord.Sender_LastName),
						@Sender_Phone = ord.Sender_Phone,
						@Sender_Address = ord.Sender_Address
						from @TblAcepted ls
							join	DeliveryOrder ord on (ord.Guide_Number = ls.GuideNumber and ord.Guide_Serie = ls.GuideSerie)
						where ord.Guide_Number in (select GuideNumber from @TblAcepted )

						declare @IdHublogistic int  = (select top 1  thb.IdHublogistic from @TblAcepted ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.GuideNumber and ord.Guide_Serie = ls.GuideSerie)
										inner join TownshipByHubLogistic thb on (ord.SenderIdTownship = thb.IdTownship)
										inner join DeliveryOrderPaymentDetail dop on (dop.GuideNumber = ord.Guide_Number and dop.GuideSerie = ord.Guide_Serie)
										where ord.Guide_Number in (select GuideNumber from @TblAcepted ))
					

						declare @Sender_Email varchar (200)  = (select top 1 isnull( REPLACE( REPLACE(cus.RegexEmail,'$',''),'^',''),' ') from @TblAcepted  ls
											join	DeliveryOrder ord on (ord.Guide_Number = ls.GuideNumber and ord.Guide_Serie = ls.GuideSerie)
										left join dbo.Customer cus on cus.IdCustomer = ord.IdCustomer)
						
						
						--Actualiza los datos obtenidos anteriormente para la tabla SchedulePickup
						
						update dbo.SchedulePickup  set  SenderId = @SenderId, SenderName = @SenderName, SenderPhone = @Sender_Phone , IdHubLogistics = @IdHublogistic, AddressPickup = @Sender_Address, AmountPickup = @AmountPickup
						where SchedulePickupId = @IdSchedulePickUp
						
						-- Agrupa el lote de guias a una sola transaccion 
						
						update DeliveryOrderPaymentDetail  set  IdHeaderRecolection = @IdSchedulePickUp
						from DeliveryOrderPaymentDetail dop
						inner join DeliveryOrder ord on (ord.Guide_Number = dop.GuideNumber and ord.Guide_Serie = dop.GuideSerie)
						where GuideNumber in( select GuideNumber from @TblAcepted) and ord.StatusOrderId in (15,1,16) and (dop.IdHeaderRecolection = @IdSchedulePickUp or dop.IdHeaderRecolection is null)
						
						-- Actualiza su StatusId a 2 = Recoleccion todas las guias del lote 
						
						update DeliveryOrder set StatusOrderId = 2
						from DeliveryOrder
						where Guide_Number in (select GuideNumber from @TblAcepted) and Guide_Serie in (select GuideSerie from @TblAcepted)

						
						-- Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia 
						
						
						update DeliveryOrderPiece set IsPickup = 1
						from DeliveryOrderPiece
						where GuideNumber in (select GuideNumber from @TblAcepted) and GuideSerie in (select GuideSerie from @TblAcepted)
						
						-- Actualiza el Status del Servicio  
						
						declare @Status int = (	select IdServiceStatus from  CatServiceStatus where IdServiceStatus =  3)
						
						update ServiceManagement set ServiceStatusId = @Status , PuSignaturePath = ''
						from ServiceManagement
						where IdSchedulePickup = @IdSchedulePickUp
						
						declare @transac int = (select top 1 IdServiceManagement from ServiceManagement where IdSchedulePickup = @IdSchedulePickUp)
									
						-- Inserta en EventService el comportamiento del Pickup  	
										
						insert into EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
						values( @transac, @Status, 1, @CourierToken, GETDATE(), '' )

						-- Asignar costos y detalle de costos
						
						DECLARE @fecha as date = getdate()
						if @Amount> 0
							begin
								Exec [dbo].[SetPaymentTransaction]
										@ProductNumber = @IdSchedulePickUp,
										@Amount = @Amount,
										@IdModule  = 1,
										@PaymentType  = @IdPaymentType,
										@Voucher =@Voucher,
										@Token = @CourierToken,
										@PaymentDate =@fecha
							 end

						-- Registrar Manifiesto 

						DECLARE @ManifestNumber AS int = (SELECT MAX([Manifest_Number]) + 1 FROM [DeliveryBackOffice].[dbo].[ServiceRequest])

						DECLARE @ManifestSerie  as nvarchar(5) = (select top 1 Value from dbo.ConfigParams where Name = 'ManifestSerie')

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
						@TblAcepted ls
						join	DeliveryOrder ord on (ord.Guide_Number = ls.GuideNumber and ord.Guide_Serie = ls.GuideSerie)

						-- Actualizar lote de servicios
						update ServiceBatch set RowStatus = 0
						from ServiceBatch
						where ServiceBatch.IdServiceBatch = @IdServiceBatch

						-- Actualizar detalle de lote
						update ServiceBatchDetail set RowStatus = 0
						from ServiceBatchDetail
						where ServiceBatchDetail.ServiceBatchId = @IdServiceBatch
					END
					ELSE
					BEGIN
						ROLLBACK TRANSACTION;
						SET @JsonResult =(
										SELECT STUFF(( 
										SELECT '{{"IdResult":406,' 
										+ '"Message":"Lote de servicios ya fue procesado."}' 
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,'') )
						SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
					END
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION;
					SET @JsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Message":"Error en la transacción."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
					SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
				END CATCH

				IF @@TRANCOUNT > 0
				BEGIN
					SET @JsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":200,' 
								+ '"Message":"Exito en completado de servicio."' +
								+ '}'
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
					SELECT ('[' + @JsonResult +  ']') JsonResult 
					COMMIT TRANSACTION;
				END
			END
			ELSE
			BEGIN
				SET @JsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":404,' 
								+ '"Message":"No existe lote de servicios."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
				SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
			END
		END TRY
		BEGIN CATCH
			SET @JsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Message":"Error en la transacción."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
		END CATCH
	END
	ELSE
	BEGIN
		SET @JsonResult =(
						SELECT STUFF(( 
						SELECT '{{"IdResult":401,' 
						+ '"Message":"Token de repartidor expirado."}' 
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,'') )
		SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
	END
END