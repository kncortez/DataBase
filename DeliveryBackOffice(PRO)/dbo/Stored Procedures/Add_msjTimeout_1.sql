
-- =============================================
-- Author:		Eduardo López
-- Create date: 04 Octubre 2022
-- Description:	Agregar string TimeOut en invoiceHeader cuando no se recibe respuesta de FEL y si se crea factura fisica
-- =============================================
CREATE PROCEDURE [dbo].[Add_msjTimeout]
	-- Add the parameters for the stored procedure here
	@idInvoice int

AS

	BEGIN
	BEGIN TRY
		UPDATE invoiceHeader
		SET inv_documentRecieved = 'TimeOut'
		WHERE inv_pk_id = @idInvoice
	END TRY
	BEGIN CATCH
	
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

	END CATCH

	END