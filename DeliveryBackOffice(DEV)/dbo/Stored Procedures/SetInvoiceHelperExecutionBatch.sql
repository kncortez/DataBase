
-- =============================================
-- Author:		<Cristian,Azurdia>
-- Create date: <2024-07-30>
-- Description:	< Actualizar como enviados las facturas de HermesInvoiceHelperHN >
-- =============================================

CREATE PROCEDURE [dbo].[SetInvoiceHelperExecutionBatch]
	@IdInvoice as INT
AS
BEGIN

	BEGIN TRANSACTION
	BEGIN TRY
		/*********************************************************************************************************************
		***************************** ACTUALIZACIÓN DE LISTADO DE FACTURAS PENDIENTES DE ENVIAR CORREO ***************************
		*********************************************************************************************************************/
		UPDATE InvoiceBatchDetail
		SET SendEmail = 1
			,DateUpdated = GETDATE()
			,TokenUpdated = 'SYSTEM'
		WHERE inv_pk_id = @IdInvoice

		SELECT 200 [StatusCode], 'Actualizacion exitosa' [Message]

		COMMIT TRANSACTION;
		 
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