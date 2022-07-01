
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-06-07>
-- Description:	< Actualiza la cola de ejecución con el tipo correspondiente >
-- =============================================
CREATE PROCEDURE [dbo].[UpdateWireTransferExecutionQueue]
	@ProcessToUpdate TblCoDExecutionProcess READONLY,
	@IsPending BIT = NULL,
	@HasStarted BIT = NULL,
	@HasCompleted BIT = NULL,
	@Token NVARCHAR(50) = 'SYS-HERMESWIRETRANSFER'
AS
BEGIN

	IF(@Token IS NULL)
		SET @Token = 'SYS-HERMESWIRETRANSFER'

	BEGIN TRANSACTION
	BEGIN TRY

		-- Actualizar los procesos con 
		UPDATE
			CDE
		SET
			CDE.ProcessPending = ISNULL(@IsPending, CDE.ProcessPending)
			,CDE.ProcessStarted = ISNULL(@HasStarted, CDE.ProcessStarted)
			,CDE.ProcessFinished = ISNULL(@HasCompleted, CDE.ProcessFinished)
			,CDE.TokenUpdated = @Token
			,CDE.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[CoDDailyExecution] CDE WITH(NOLOCK)
			INNER JOIN
				@ProcessToUpdate PTU 
				ON
					CDE.IdCoDDailyExecution = PTU.CoDExecutionProcessId
					AND
					CDE.CoDProcessName = PTU.CoDExecutionProcessName
					AND
					CDE.ExecutionTime = PTU.CoDExecutionProcessTime
					AND
					CDE.DeliveryBankId = PTU.CoDExecutionProcessBankId

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION;

		SELECT
			CAST(1 AS BIT) [blnResult]

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

	END CATCH

END