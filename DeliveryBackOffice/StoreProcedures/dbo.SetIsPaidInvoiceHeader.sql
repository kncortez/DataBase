USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-05-25>
-- Description:	<Establece IsPaid en tabla InvoiceHeader>
-- =============================================
CREATE PROCEDURE [dbo].[SetIsPaidInvoiceHeader]
	-- Add the parameters for the stored procedure here
	@invoiceHeaderId BIGINT,
	@IsPaid BIT,
	@Token VARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT = 0
	DECLARE @ErrorMessage NVARCHAR(100)
	DECLARE @Status INT 

	BEGIN TRANSACTION
	BEGIN TRY
		
		SET @Status = (SELECT
				ISNULL(inv_SAPDocEntryPaymentDetail, -1)
			FROM InOutOfMoneyDetail
			WHERE io_invoice = @invoiceHeaderId) --si ya se ha pagado

		IF (@Status = -1)
		BEGIN
			UPDATE invoiceHeader
			SET IsPaid = @IsPaid
			WHERE inv_pk_id = @invoiceHeaderId
			SET @RModified = @@ROWCOUNT
		END
		ELSE
		BEGIN
			SET @ErrorMessage = 'La factura ya ha sido enviada a SAP.'
		END


	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END CATCH

	IF(@@trancount > 0)
	BEGIN
		IF (@RModified > 0)
		BEGIN
			COMMIT TRANSACTION;
			SELECT			  
				200 AS 'StatusCode',
				'Registro actualizado correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SELECT			  
				0 AS 'StatusCode',
				CONCAT('Factura no actualizada,', ' ', @ErrorMessage) AS 'Description', 
				0 AS 'NumTransferID'
		END
	END
	ELSE
	BEGIN
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END
END
GO
