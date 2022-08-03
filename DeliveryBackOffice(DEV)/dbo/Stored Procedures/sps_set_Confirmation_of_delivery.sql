


-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-06-12>
-- Description:	<Confirmar entrega de guía>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-06-28>
-- Description:	<Agregar Filtro para saber si tiene pago con tarjeta o datafono en CostDetail>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-08-01>
-- Description:	<Agregar validación para impedir entrega cuando el destino sea un express center>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_Confirmation_of_delivery]
		@Guide_Serie AS VARCHAR(2), --guide serie
		@Guide_Number AS INT, --guide number
		@DateOfDelivery VARCHAR(50),--Date of delivery
		@NameOfReceiver VARCHAR(200), --Name of receiver
		@TokenId AS VARCHAR(50) --token user
AS
BEGIN
	DECLARE @StatusId tinyint = 5 --Status of delivery 
	DECLARE @ValidateOperation BIGINT
	DECLARE @Times INT -- cantidad de veces que se encuentra el registro con estado de entregado
	DECLARE @CatModuleId INT -- CatModuleId del modulo
	DECLARE @CourierId INT -- CourierId de la guía
	DECLARE @COD DECIMAL(14,2) -- COD de la guía
	DECLARE @Datetime DATETIME -- Fecha y hora del último checkpoint
	

	BEGIN TRANSACTION
		BEGIN TRY
			-- Buscar si la guía ya cuenta con estado de entrega previa, en caso que exista no se procede a registrar transacción para evitar registro duplicado
			SET @Times = (SELECT COUNT(Guide_Number) FROM DeliveryBackOffice.dbo.DeliveryOrderDetail WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number AND (StatusOrderId = @StatusId  OR StatusOrderId = 14))

			 
       IF(NOT EXISTS (select top 1 1 from dbo.DeliveryOrder 
										where IdDeliveryOption = 3
										  AND Guide_Serie=@Guide_Serie AND Guide_Number= @Guide_Number)
		  )
	   BEGIN
			IF (@Times = 0)
			BEGIN

				SET @Datetime = (SELECT TOP 1 DateCreated 
								FROM DeliveryBackOffice.dbo.DeliveryOrderDetail 
								WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number 
								ORDER BY DateCreated DESC
				)

				IF (@DateOfDelivery > @Datetime)
				BEGIN

					-- Actualizar registro de guía a último estado 
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET StatusOrderId = @StatusId, --Status of delivery 			
					NameOfReceiver = @NameOfReceiver
					WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number	

					UPDATE DeliveryBackOffice.dbo.DeliveryAttempt
					SET Delivered = 1 --Status of delivery 	
					WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number AND CAST(Date_Created AS Date) = CAST(GETDATE() AS Date)
			
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

					DECLARE @IdCustomer int
					DECLARE @COLLECT INT = 0
					-- se obtiene COD de la guía
					SELECT 
						@COD =  ord.Collect_OnDelivery
						, @IdCustomer = cus.IdCustomer
					FROM DeliveryBackOffice.dbo.DeliveryOrder ord
							LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
							LEFT JOIN dbo.Customer cus ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
					WHERE ord.Guide_Serie = @Guide_Serie AND  ord.Guide_Number = @Guide_Number

					SELECT 
						@COLLECT =  1
					FROM DeliveryBackOffice.dbo.DeliveryOrder ord
							LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
							LEFT JOIN dbo.Customer cus ON cus.IdCustomer = ISNULL(ord.IdCustomer, vp.CustomerID)
					WHERE ord.Guide_Serie = @Guide_Serie AND  ord.Guide_Number = @Guide_Number 
					AND ord.IsCollect = 'true'

					-- se verifica que no exita en ProcessGuideCOD Y COD > 0
					IF (@COD > 0 OR @COLLECT = 1) AND 
						NOT EXISTS 
							(SELECT 1
							FROM DeliveryBackOffice.dbo.ProcessedGuideCOD
							WHERE GuideSerie = @Guide_Serie AND GuideNumber = @Guide_Number
						)  AND NOT EXISTS
                    (
                        SELECT 1
                        FROM DeliveryBackOffice.dbo.Cost C WITH (NOLOCK)
                            JOIN CostDetail CD WITH (NOLOCK)
                                ON CD.IdCost = C.IdCost
                                   AND CD.IdTypeOfMoney IN ( 2, 6 )
                        WHERE C.ProductNumber = CONCAT(@Guide_Serie, CAST(@Guide_Number AS VARCHAR(50)))
                    )

					BEGIN
						--Buscar ID modulo liquidación COD
						SET @CatModuleId = ISNULL((SELECT ModIdModule
												FROM DeliveryBackOffice.dbo.CatModule
												WHERE ModName = 'Confirmación de Entrega'),0)
						-- Obtener ID de Courier
						SELECT TOP 1 @CourierId = ID_Courier 
						FROM DeliveryBackOffice.dbo.DeliveryAttempt 
						WHERE Guide_Serie = @Guide_Serie
							AND Guide_Number = @Guide_Number
						ORDER BY Date_Created DESC

						INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
						   (GuideSerie
						   ,GuideNumber
						   ,CourierManId
						   ,Date
						   ,BatchCODId
						   ,BatchCODIdCommission
						   ,DataOriginId
						   ,Notificated
						   ,Token
						   ,CustomerId)
						VALUES 
							(@Guide_Serie
							,@Guide_Number
							,@CourierId
							,GETDATE()
							,NULL
							,NULL
							,@CatModuleId
							,0
							,@TokenId
							,@IdCustomer)

					END
			


				END
				ELSE
					SET @ValidateOperation = -2
				
			END
			-- registro existente
			ELSE
				SET @ValidateOperation = -1
         
		 -- si destino es Ex C
		 END
		 ELSE
				SET @ValidateOperation = -3
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
			 
				 select top 10 Guide_Serie + CAST(Guide_Number as varchar) Guide,Ticket_Number Ticket, Receiver_FirstName + ' '+ Receiver_LastName Name, Courier_Route Route, convert(varchar, Dispatched_Date, 103) RouteDate 
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
					'Guías cuyo destino sea un express center no pueden ser entregadas' AS 'Description', 
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
