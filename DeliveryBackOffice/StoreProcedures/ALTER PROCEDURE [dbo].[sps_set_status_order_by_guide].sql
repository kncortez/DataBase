USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_set_status_order_by_guide]    Script Date: 28/12/2021 11:04:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-06-10>
-- Description:	<Cambiar el estado de una lista de guías>
-- =============================================
ALTER PROCEDURE [dbo].[sps_set_status_order_by_guide]
		@Guide_Serie AS VARCHAR(2), -- same guide for all numbers provided
		@Guide_Number AS VARCHAR(MAX), -- a list of guides separated by comma
		@StatusId AS INT, -- status from StatusOrder
		@TokenId AS VARCHAR(50),
		@DateOfStatus DATETIME, -- datetime of event
		@Observations AS VARCHAR(200) = '', --Observations by checkpoint
		@Temperature_Celsius AS DECIMAL(5,2),
		@courierName as varchar(200) = ''
AS
BEGIN
	DECLARE @ValidateOperation BIGINT = 0
	DECLARE @RowUpdated INT
	DECLARE @ItemsTable AS TABLE (
		Guide_Number INT
	)

	BEGIN TRANSACTION

		BEGIN TRY
			
			-- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
			INSERT @ItemsTable
			SELECT CAST(Item AS INT) FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,',')

			-- Actualizar registro de guía a último estado 
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder
			SET StatusOrderId = @StatusId
			WHERE Guide_Serie = @Guide_Serie AND Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,','))

			SET @RowUpdated = @@ROWCOUNT

			IF (@RowUpdated > 0)
			BEGIN
				-- Activar bandera de proceso de SMS
				IF (@StatusId = 4) -- En ruta | (11) Arribó a instalaciones
					IF((select top 1 ue.UpdateStatus
						from [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue
						where ue.RowStatus=1
						and ue.ElementId=1001)=0)
					BEGIN
						update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
						set UpdateStatus=1, UpdateDateTime=GETDATE()
						where RowStatus=1
						and ElementId=1001
					END
			
				-- Insertar nuevo estado de guía en tabla histórica
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem], [Observations], [Temperature_Celsius])
				SELECT @Guide_Serie, it.Guide_Number, @StatusId, @TokenId, GETDATE(), GETDATE(), @Observations, @Temperature_Celsius
				FROM @ItemsTable it

				SET @ValidateOperation = COALESCE(@@ROWCOUNT,0)
			END

			IF @StatusId = 4
			BEGIN
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET Courier_Name = @courierName,
				Dispatched_Date = GETDATE()
				WHERE Guide_Serie = @Guide_Serie AND Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,','))
			END

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
			IF (@ValidateOperation > 0)
			BEGIN
				SELECT			  
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'

				SELECT Guide_Serie + CAST(Guide_Number as varchar) Guide,Ticket_Number Ticket, Receiver_FirstName + ' '+ Receiver_LastName Name, Courier_Route Route, convert(varchar, Dispatched_Date, 103) RouteDate 
				FROM DeliveryBackOffice.dbo.DeliveryOrder
				WHERE Guide_Serie = @Guide_Serie and Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,','))
			END
			ELSE
			BEGIN
				SELECT 
					0 AS 'StatusCode',
					'El registro no existe' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			COMMIT TRANSACTION;			
		END
END
