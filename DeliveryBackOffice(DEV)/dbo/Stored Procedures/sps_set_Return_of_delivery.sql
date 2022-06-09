

-- =============================================
-- Author:		<Hernandez, Josselyn>
-- Create date: <2020-09-15>
-- Description:	<Devolucion entrega de guía>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_Return_of_delivery]
		@Guide_Serie AS VARCHAR(2), --guide serie
		@Guide_Number AS INT, --guide number
		@DateOfDelivery VARCHAR(50),--Date of delivery
		@TokenId AS VARCHAR(50) --token user
AS
BEGIN
	DECLARE @StatusId tinyint = 14 --Status of returned 
	DECLARE @ValidateOperation BIGINT
	DECLARE @Times INT -- cantidad de veces que se encuentra el registro con estado de entregado
	DECLARE @Datetime DATETIME -- Fecha y hora del último checkpoint

	BEGIN TRANSACTION
		BEGIN TRY

		DECLARE @CurrentStatus int 

		SELECT @CurrentStatus = dr.StatusOrderId FROM dbo.DeliveryOrder dr
		WHERE dr.Guide_Serie = @Guide_Serie AND dr.Guide_Number = @Guide_Number

		IF (@CurrentStatus IN(17,16))
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
					'Para operar una guia en este mópdulo debe estar en estado [Programado para recolección] o [Programado para devolución]' AS 'Description', 
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
