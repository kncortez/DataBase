

-- =============================================
-- Author:		<Hernandez, Josselyn>
-- Create date: <2020-09-15>
-- Description:	<Devolucion entrega de guía>
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-09-26>
-- Description:	<Al momento de finalizar el proceso de devolución se debe realizar update en la tabla warehouse al campo Rack_Position, colocarlo como NULL>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-10-19>
-- Description:	<confirmación de devolución, ingreso a cola de webhooks>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2023-03-20>
-- Description:	<Validar que guía esta en estado terminal y evitar cualquier proceso>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_Return_of_delivery]
		@Guide_Serie AS VARCHAR(2), --guide serie
		@Guide_Number AS INT, --guide number
		@DateOfDelivery VARCHAR(50),--Date of delivery
		@TokenId AS VARCHAR(50) --token user
AS
BEGIN
	DECLARE @StatusId tinyint = (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Devuelto' AND RowStatus = 1) --Status of returned 
	DECLARE @ValidateOperation BIGINT
	DECLARE @Times INT -- cantidad de veces que se encuentra el registro con estado de entregado
	DECLARE @Datetime DATETIME -- Fecha y hora del último checkpoint
	
	DECLARE @IsLastMileReturn BIT = ISNULL(( SELECT TOP 1 DO.[IsLastMileReturn] 
												From [dbo].[DeliveryOrder] DO With(Nolock) 
												Where DO.Guide_Serie = @Guide_Serie And 
													  DO.Guide_Number = @Guide_Number
	                                          ),0)

	DECLARE @StatusDescription NVARCHAR(200)= ( Select SO.OrderDescription 
												From [dbo].[DeliveryOrder] DO With(Nolock) 
													 INNER JOIN 
													 [dbo].[StatusOrder] SO With(Nolock)
												ON DO.StatusOrderId = SO.StatusOrderId
												Where DO.Guide_Serie = @Guide_Serie And 
													  DO.Guide_Number = @Guide_Number
	                                          )
	DECLARE @IsStatusTerminal int = ISNULL(( Select 1 From [dbo].[DeliveryOrder] DO WITH(NOLOCK) Where DO.Guide_Serie= @Guide_Serie And DO.Guide_Number =@Guide_Number 
	                                                                                          And DO.StatusOrderId  IN (SELECT SO.[StatusOrderId]
                                                                                                                              FROM	[dbo].[StatusOrder] SO  WITH(NOLOCK)
																														WHERE [CatCheckpointTypeId] = 3 AND SO.RowStatus = 1)),0)
									

	BEGIN TRANSACTION
		BEGIN TRY

		DECLARE @CurrentStatus int 

		SELECT @CurrentStatus = dr.StatusOrderId FROM dbo.DeliveryOrder dr WITH(NOLOCK)
		WHERE dr.Guide_Serie = @Guide_Serie AND dr.Guide_Number = @Guide_Number




		IF(@IsStatusTerminal = 0)
		BEGIN

		IF ( @IsLastMileReturn = 1 )
			BEGIN
			-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
			SET @Times = (SELECT COUNT(Guide_Number) FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number AND (StatusOrderId = @StatusId OR StatusOrderId = 5))

			IF (@Times = 0)
			BEGIN

				SET @Datetime = (SELECT TOP 1 DateCreated 
								FROM DeliveryBackOffice.dbo.DeliveryOrderDetail 
								WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number 
								ORDER BY DateCreated DESC
				)

				IF (@DateOfDelivery > @Datetime)
				BEGIN

				 --al momento de finalizar el proceso de devolución se debe realizar update en la tabla warehouse al campo Rack_Position, colocarlo como NULL
				  UPDATE  dbo.warehouse SET Active=0,
				           UserUpdated = @TokenId,
						   DateUpdated = GETDATE()
				  where Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number AND Active=1

					-- Actualizar registro de guía a último estado 
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET StatusOrderId = @StatusId --Status of delivery 			
					,Collect_OnDelivery = 0 -- establecer valor a cobrar en cero cuando la guía es una devolución (solicitado por Van Ardón)
					WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number			
			
					-- Insertar nuevo estado de guía en tabla histórica
					INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
					([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated],[DateCreatedInSystem])			
					select @Guide_Serie, @Guide_Number, @StatusId, @TokenId,CONVERT(Datetime,@DateOfDelivery, 120), GETDATE()
					WHERE EXISTS
					(
					 SELECT 1 
					 FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)			 
					  WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number
					)
			
					SET @ValidateOperation = COALESCE(@@ROWCOUNT,0)

					
	-------------------WEBHOOK.INI--------------------------------------------------------------------------------------------
				DECLARE @WebhookCustomerId INT = -1;
				DECLARE @CustomerEndpointId INT = -1;
				-- Debido a que se procesa únicamente 1 guía
				DECLARE @GuideCurrentStatus INT = -1;

				BEGIN TRY
					DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI AND WT.RowStatus = 1);

					SET @WebhookCustomerId = ISNULL((SELECT TOP 1 DO.IdCustomer FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @Guide_Number AND DO.Guide_Serie = @Guide_Serie),-1);
					SET @CustomerEndpointId = ISNULL((SELECT TOP 1 WE.IdWebhookEndpoint FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK) WHERE WE.CustomerId = @WebhookCustomerId AND  WE.WebhookTypeId = @GuideStatusChangeWebhook),-1);

					SET @GuideCurrentStatus = (SELECT TOP 1 DO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Number = @Guide_Number AND DO.Guide_Serie = @Guide_Serie);

					-- Cliente tiene webhook configurado para el tipo especificado
					-- Estado actual de la guía coincide dentro de las restricciónes por usuario
					IF ( @WebhookCustomerId > 0 AND @CustomerEndpointId > 0 AND @GuideCurrentStatus IN (SELECT WRBU.StatusOrderId FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK) WHERE WRBU.CustomerId = @WebhookCustomerId AND WRBU.WebhookTypeId = @GuideStatusChangeWebhook) )
					BEGIN 

						DECLARE @ResponseTable AS TABLE (
							InsertedId BIGINT
						);

						INSERT INTO 
							[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
							(
								[GuideSerie]
								,[GuideNumber]
								,[CustomerId]
								,[StatusOrderId]
								,[WebhookEndpointId]
								,[HasNotified]
								,[TokenCreated]
								,[DateCreated]
							)
						OUTPUT inserted.IdWebhookTrackingQueue INTO @ResponseTable (InsertedId)
						VALUES
							(
								 @Guide_Serie
								,@Guide_Number
								,@WebhookCustomerId
								,@GuideCurrentStatus
								,@CustomerEndpointId
								,0
								,@TokenId
								,GETDATE()
							)

					END

				END TRY
				BEGIN CATCH

				END CATCH
							
					-------------------WEBHOOK.INI FIN----------------------------------------------------------------------------------------


				END
				ELSE
					SET @ValidateOperation = -2	
			END
			-- registro existente
			ELSE
				SET @ValidateOperation = -1
			END
			ELSE
				SET @ValidateOperation = -3
			END
			ELSE
			    SET @ValidateOperation = -4
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			if (@ValidateOperation >0 )
			 BEGIN
				 SELECT			  
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			 
				 select top 10 Guide_Serie + CAST(Guide_Number as varchar) Guide,Ticket_Number Ticket, Courier_Route Route, convert(varchar, Dispatched_Date, 103) RouteDate 
				 from DeliveryBackOffice.dbo.DeliveryOrder
				 where Guide_Serie = @Guide_Serie and Guide_Number = @Guide_Number

				print 'REGISTER EXISTS ' + CAST(COALESCE(@ValidateOperation,0) as varchar)
			END
			ELSE IF (@ValidateOperation = -1)
			BEGIN
				SELECT			  
					-1 AS 'StatusCode',
					'Registro duplicado' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE IF (@ValidateOperation = -2)
			BEGIN
				SELECT			  
					-2 AS 'StatusCode',
					'Fecha y hora incorrecta' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE IF (@ValidateOperation = -3)
			BEGIN
				SELECT			  
					-3 AS 'StatusCode',
					'Para operar una guia en este módulo debe estar declarada para devolución' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE IF (@ValidateOperation = -4)
			BEGIN
				SELECT			  
					-4 AS 'StatusCode',
					'Para operar una guia en este módulo no debe estar en  estado : ['+ @StatusDescription + '] por ser estado Terminal.' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE
			BEGIN
				SELECT 
					0 AS 'StatusCode',
					'El registro no existe' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
				print 'REGISTER NOT EXISTS ' + CAST(COALESCE(@ValidateOperation,0) as varchar)
			END
			COMMIT TRANSACTION;			
		END
END
