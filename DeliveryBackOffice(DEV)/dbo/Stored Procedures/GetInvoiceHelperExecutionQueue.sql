-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2023-03-29>
-- Description:	< Obtener cola de ejecución de procesos de servicio HermesInvoiceHelper >
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoiceHelperExecutionQueue]
AS
BEGIN

	-- Variables de control de flujo
	DECLARE @DailyExecutionExists BIT = 0;
	DECLARE @DailyExecutionQueue AS TABLE(
		InvoiceDailyScheduleId INT,
		ExecutionDate DATE,
		InvoiceProcessName NVARCHAR(100),
		ExecutionTime TIME,
		ProcessPriority INT
	);

	-- Variables de respuesta
	DECLARE @IsSuccessful BIT = 0;
	DECLARE @EstimatedLine INT = 0;
	DECLARE @ResponseMessage NVARCHAR(500) = '';
	DECLARE @ResponseExecutionQueue AS TABLE(
		ResponseOrder INT,
		InvoiceProcessName NVARCHAR(100),
		ExecutionDate DATE,
		ExecutionTime TIME,
		ExecutionPriority INT,
		ExecutionIsPending BIT,
		ExecutionHasStarted BIT,
		ExecutionHasCompleted BIT
	);

	-- Obtener valores de ejecución de la fecha actual
	SET @DailyExecutionExists = ISNULL((
		SELECT 
			TOP 1 
				1 
		FROM 
			[DeliveryBackOffice].[dbo].[InvoiceDailyExecution] IDE WITH(NOLOCK) 
		WHERE 
			IDE.ExecutionDate = CAST(GETDATE() AS DATE) 
			AND 
			IDE.RowStatus = 1
	),0)

	BEGIN TRANSACTION
	BEGIN TRY
		IF( @DailyExecutionExists = 1 )
		BEGIN

			-- Ya existen registros para el día de hoy para ejecución de CoD
			INSERT INTO
				@ResponseExecutionQueue
				(ResponseOrder, InvoiceProcessName, ExecutionDate, ExecutionTime, ExecutionPriority, ExecutionIsPending, ExecutionHasStarted, ExecutionHasCompleted)
			SELECT
				IDE.IdInvoiceDailyExecution, IDE.InvoiceProcessName, IDE.ExecutionDate, IDE.ExecutionTime, IDE.ProcessPriority, IDE.ProcessPending, IDE.ProcessStarted, IDE.ProcessFinished
			FROM
				[DeliveryBackOffice].[dbo].[InvoiceDailyExecution] IDE WITH(NOLOCK)
			WHERE
				IDE.ExecutionDate = CAST(GETDATE() AS DATE)
				AND
				IDE.RowStatus = 1
			ORDER BY
				IDE.ExecutionTime ASC,
				IDE.ProcessPriority DESC

			SELECT
				@IsSuccessful = 1,
				@EstimatedLine = 0,
				@ResponseMessage = CONCAT('Se obtuvo exitosamente cola de ejecución de procesos', CONVERT(nvarchar,GETDATE(), 103))

		END
		ELSE
		BEGIN

			-- No existen registros para el día de hoy para ejecución de CoD
			INSERT INTO 
				@DailyExecutionQueue
				(InvoiceDailyScheduleId, ExecutionDate, InvoiceProcessName, ExecutionTime, ProcessPriority)
			SELECT
				CIDS.IdCatInvoiceDailySchedule
				,CAST(GETDATE() AS DATE)
				,CIDS.InvoiceProcessName
				,CIDS.ExecutionTime
				,CIDS.ProcessPriority
			FROM
				[DeliveryBackOffice].[dbo].[CatInvoiceDailySchedule] CIDS WITH(NOLOCK)
			WHERE
				CIDS.RowStatus = 1

			IF( EXISTS(SELECT TOP 1 1 FROM @DailyExecutionQueue) )
			BEGIN

				-- Existen datos de procesos de facturación a ejecutar
				INSERT INTO 
					[DeliveryBackOffice].[dbo].[InvoiceDailyExecution]
					(InvoiceDailyScheduleId, ExecutionDate, InvoiceProcessName, ExecutionTime, ProcessPriority, DateCreated, TokenCreated)
				OUTPUT
					inserted.InvoiceDailyScheduleId, inserted.InvoiceProcessName, inserted.ExecutionDate, inserted.ExecutionTime, inserted.ProcessPriority, inserted.ProcessPending, inserted.ProcessStarted, inserted.ProcessFinished
					INTO @ResponseExecutionQueue(ResponseOrder, InvoiceProcessName, ExecutionDate, ExecutionTime, ExecutionPriority, ExecutionIsPending, ExecutionHasStarted, ExecutionHasCompleted)
				SELECT
					DEQ.InvoiceDailyScheduleId, DEQ.ExecutionDate, DEQ.InvoiceProcessName, DEQ.ExecutionTime, DEQ.ProcessPriority, GETDATE(), 'SYS-HERMESINVOICEHELPER'
				FROM
					@DailyExecutionQueue DEQ
				ORDER BY
					DEQ.ExecutionTime ASC,
					DEQ.ProcessPriority DESC

				IF( EXISTS(SELECT TOP 1 1 FROM @ResponseExecutionQueue) )
				BEGIN

					-- Inserto exitosamente la ejecución para el día de hoy
					SELECT
						@IsSuccessful = 1,
						@EstimatedLine = 0,
						@ResponseMessage = CONCAT('Se obtuvo exitosamente cola de ejecución de procesos', CONVERT(nvarchar,GETDATE(), 103))

				END
				ELSE
				BEGIN

					-- No inserto datos para la ejecución del día actual
					SELECT
						@IsSuccessful = 0,
						@EstimatedLine = 112,
						@ResponseMessage = CONCAT('No se pudo insertar correctamente los datos de ejecución para la fecha actual ', CONVERT(nvarchar,GETDATE(), 103))

				END

			END
			ELSE
			BEGIN

				-- No existen datos de procesos de CoD a ejecutar
				SELECT
					@IsSuccessful = 0,
					@EstimatedLine = 90,
					@ResponseMessage = CONCAT('No se pudo generar correctamente los datos de ejecución para la fecha actual ', CONVERT(nvarchar,GETDATE(), 103))
			
			END

		END

		IF( @IsSuccessful = 1 AND EXISTS(SELECT TOP 1 1 FROM @ResponseExecutionQueue) )
		BEGIN

			COMMIT TRANSACTION;
			
			SELECT
				CAST(1 AS BIT) [blnResult],
				@ResponseMessage [successMessage]

			SELECT
				REQ.[ResponseOrder]
				,REQ.[InvoiceProcessName]
				,REQ.[ExecutionDate]
				,REQ.[ExecutionTime]
				,REQ.[ExecutionIsPending]
				,REQ.[ExecutionHasStarted]
				,REQ.[ExecutionHasCompleted]
			FROM
				@ResponseExecutionQueue REQ
			ORDER BY
				REQ.[ExecutionTime] ASC,
				REQ.[ExecutionPriority] DESC

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;

			SELECT
				CAST(0 AS BIT) [blnResult],
				0 AS [ErrorNumber],
				0 AS [ErrorSeverity],
				0 AS [ErrorState],
				'GetInvoiceHelperExecutionQueue' AS [ErrorProcedure],
				@EstimatedLine AS [ErrorLine],
				@ResponseMessage AS [ErrorMessage];

		END

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT 
			CAST(0 AS BIT) [blnResult],
			ERROR_NUMBER() AS [ErrorNumber],
			ERROR_SEVERITY() AS [ErrorSeverity],
			ERROR_STATE() AS [ErrorState],
			ERROR_PROCEDURE() AS [ErrorProcedure],
			ERROR_LINE() AS [ErrorLine],
			ERROR_MESSAGE() AS [ErrorMessage];

		-- INSERTAR A BITACORA DEL SERVICIO

	END CATCH
END