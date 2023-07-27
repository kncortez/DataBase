-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2023-03-29>
-- Description:	< Actualiza la cola de ejecución con el tipo correspondiente para servicio HermesInvoiceHelper >
-- =============================================
CREATE PROCEDURE [dbo].[UpdateInvoiceHelperExecutionQueue]
	@ProcessToUpdate TblServiceExecutionProcess READONLY,
	@Token NVARCHAR(50) = 'SYS-HERMESINVOICEHELPER'
AS
BEGIN

	IF(@Token IS NULL)
		SET @Token = 'SYS-HERMESINVOICEHELPER'

	BEGIN TRANSACTION
	BEGIN TRY

		-- Actualizar los procesos con 
		UPDATE
			IDE
		SET
			IDE.ProcessPending = ISNULL(PTU.[ServiceExecutionProcessIsPending], IDE.ProcessPending)
			,IDE.ProcessStarted = ISNULL(PTU.[ServiceExecutionProcessHasStarted], IDE.ProcessStarted)
			,IDE.ProcessFinished = ISNULL(PTU.[ServiceExecutionProcessHasCompleted], IDE.ProcessFinished)
			,IDE.TokenUpdated = @Token
			,IDE.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[InvoiceDailyExecution] IDE WITH(NOLOCK)
			INNER JOIN
				@ProcessToUpdate PTU 
				ON
					IDE.IdInvoiceDailyExecution = PTU.ServiceExecutionProcessId
					AND
					IDE.InvoiceProcessName = PTU.ServiceExecutionProcessName

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