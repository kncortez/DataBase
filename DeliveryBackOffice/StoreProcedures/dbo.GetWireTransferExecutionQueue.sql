USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[GetWireTransferExecutionQueue]    Script Date: 6/9/2022 17:19:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-06-07>
-- Description:	< Obtener cola de ejecución de procesos de servicio HermesWireTransfer >
-- =============================================
CREATE PROCEDURE [dbo].[GetWireTransferExecutionQueue]
AS
BEGIN

	-- Variables de control de flujo
	DECLARE @DailyExecutionExists BIT = 0;
	DECLARE @DailyExecutionQueue AS TABLE(
		CodDailyScheduleId INT,
		ExecutionDate DATE,
		CoDProcessName NVARCHAR(100),
		DeliveryBankId INT,
		ExecutionTime TIME,
		ProcessPriority INT
	);

	-- Variables de respuesta
	DECLARE @IsSuccessful BIT = 0;
	DECLARE @EstimatedLine INT = 0;
	DECLARE @ResponseMessage NVARCHAR(500) = '';
	DECLARE @ResponseExecutionQueue AS TABLE(
		ResponseOrder INT,
		CoDProcessName NVARCHAR(100),
		DeliveryBankId INT,
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
			[DeliveryBackOffice].[dbo].[CoDDailyExecution] CDE WITH(NOLOCK) 
		WHERE 
			CDE.ExecutionDate = CAST(GETDATE() AS DATE) 
			AND 
			CDE.RowStatus = 1
	),0)

	BEGIN TRANSACTION
	BEGIN TRY
		IF( @DailyExecutionExists = 1 )
		BEGIN

			-- Ya existen registros para el día de hoy para ejecución de CoD
			INSERT INTO
				@ResponseExecutionQueue
				(ResponseOrder, CoDProcessName, DeliveryBankId, ExecutionDate, ExecutionTime, ExecutionPriority, ExecutionIsPending, ExecutionHasStarted, ExecutionHasCompleted)
			SELECT
				CDE.IdCoDDailyExecution, CDE.CoDProcessName, CDE.DeliveryBankId, CDE.ExecutionDate, CDE.ExecutionTime, CDE.ProcessPriority, CDE.ProcessPending, CDE.ProcessStarted, CDE.ProcessFinished
			FROM
				[DeliveryBackOffice].[dbo].[CoDDailyExecution] CDE WITH(NOLOCK)
			WHERE
				CDE.ExecutionDate = CAST(GETDATE() AS DATE)
				AND
				CDE.RowStatus = 1
			ORDER BY
				CDE.ExecutionTime ASC,
				CDE.ProcessPriority DESC,
				CDE.DeliveryBankId ASC

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
				(CodDailyScheduleId, ExecutionDate, CoDProcessName, DeliveryBankId, ExecutionTime, ProcessPriority)
			SELECT
				CCDS.IdCatCoDDailySchedule
				,CAST(GETDATE() AS DATE)
				,CCDS.CoDProcessName
				,CCDS.DeliveryBankId
				,CCDS.ExecutionTime
				,CCDS.ProcessPriority
			FROM
				[DeliveryBackOffice].[dbo].[CatCoDDailySchedule] CCDS WITH(NOLOCK)
			WHERE
				CCDS.RowStatus = 1

			IF( EXISTS(SELECT TOP 1 1 FROM @DailyExecutionQueue) )
			BEGIN

				-- Existen datos de procesos de CoD a ejecutar
				INSERT INTO 
					[DeliveryBackOffice].[dbo].[CoDDailyExecution]
					(CodDailyScheduleId, ExecutionDate, CoDProcessName, DeliveryBankId, ExecutionTime, ProcessPriority, DateCreated, TokenCreated)
				OUTPUT
					inserted.IdCoDDailyExecution, inserted.CoDProcessName, inserted.DeliveryBankId, inserted.ExecutionDate, inserted.ExecutionTime, inserted.ProcessPriority, inserted.ProcessPending, inserted.ProcessStarted, inserted.ProcessFinished
					INTO @ResponseExecutionQueue(ResponseOrder, CoDProcessName, DeliveryBankId, ExecutionDate, ExecutionTime, ExecutionPriority, ExecutionIsPending, ExecutionHasStarted, ExecutionHasCompleted)
				SELECT
					DEQ.CodDailyScheduleId, DEQ.ExecutionDate, DEQ.CoDProcessName, DEQ.DeliveryBankId, DEQ.ExecutionTime, DEQ.ProcessPriority, GETDATE(), 'SYS-HERMESWIRETRANSFER'
				FROM
					@DailyExecutionQueue DEQ
				ORDER BY
					DEQ.ExecutionTime ASC,
					DEQ.ProcessPriority DESC,
					DEQ.DeliveryBankId ASC

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

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION;
			
			SELECT
				CAST(1 AS BIT) [blnResult],
				@ResponseMessage [successMessage]

			SELECT
				REQ.ResponseOrder
				,REQ.CoDProcessName
				,REQ.DeliveryBankId
				,REQ.ExecutionDate
				,REQ.ExecutionTime
				,REQ.ExecutionIsPending
				,REQ.ExecutionHasStarted
				,REQ.ExecutionHasCompleted
			FROM
				@ResponseExecutionQueue REQ
			ORDER BY
				REQ.ExecutionTime ASC,
				REQ.ExecutionPriority DESC,
				REQ.DeliveryBankId ASC

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;

			SELECT
				CAST(0 AS BIT) [blnResult],
				0 AS [ErrorNumber],
				0 AS [ErrorSeverity],
				0 AS [ErrorState],
				'GetWireTransferExecutionQueue' AS [ErrorProcedure],
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
GO


