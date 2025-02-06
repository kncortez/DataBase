-- =============================================
-- Author:      Oscar Rodriguez
-- Create date: 2024-08-13
-- Description: Registra y actualiza tablas para certificacion de nota de credito para HN
-- =============================================
CREATE PROCEDURE [dbo].[SetBatchInvoiceByCountryCreditNote]
    @idInvoiceCreditNote BIGINT,
    @user      NVARCHAR(100) = 'ORODRIGUEZ-SYS',
    @CodeOfReference INT = 0
AS
BEGIN
        DECLARE @Batch BIGINT,
        	 @InitialRange BIGINT,
        	 @FinalRange BIGINT,
        	 @CAI NVARCHAR(100),
        	 @LastProcessed BIGINT,
        	 @inv_certificationFEL NVARCHAR(75),
        	 @idInvoice BIGINT,
        	 @Code INT = 0,
        	 @Message NVARCHAR(250)

		 /*
		   InvoiceBatchHeader
		   status = 1 y enable = 1 es cuando el lote esta habilidado y activo
		   status = 0 y enable = 1 es un error - no contemplado
		   status = 1 y enable = 0 es cuando no se puede facturar, porque se detuvo facturación (Ya viene lote nuevo ejemplo)
		 */

		EXEC [ValidateBatchInvoice] @TypeDocument    = 6,
									@CodeOfReference = @CodeOfReference,
									@Code            = @Code OUTPUT,
									@Message         = @Message OUTPUT

    -- Si todas las validaciones fueron correctas
    IF @Code = 1
    BEGIN

		SELECT  @inv_certificationFEL = CONCAT(RIGHT('000' + CAST(invHe.Establishment AS VARCHAR), 3), '-',
											   RIGHT('000' + CAST(invHe.Emision_Point AS VARCHAR), 3),'-',
											   RIGHT('00' + CAST(invHe.TypeDocument AS VARCHAR), 2),'-')
			   ,@Batch = invHe.Id_Lote
			   ,@InitialRange = invHe.InitialRange
			   ,@FinalRange = invHe.FinalRange
			   ,@CAI = invHe.CAI
			   ,@LastProcessed = invHe.Last_Process + 1  --1
		FROM InvoiceBatchHeader invHe
		WHERE TypeDocument = 6
		   AND [STATUS] = 1
		   AND [ENABLE] = 1

		SELECT @idInvoice = ih.inv_invoiceOfCreditNote
		FROM DeliveryBackOffice.dbo.invoiceHeader ih
		WHERE ih.inv_pk_id = @idInvoiceCreditNote

		--Actualizamos el último procesado 
		UPDATE InvoiceBatchHeader
		SET Last_Process = @LastProcessed
		WHERE Id_Lote = @Batch


		--Actualizamos estado de factura cancelada
		UPDATE ibd
		SET RowStatus = 0, TokenUpdated = @user, DateUpdated = GETDATE()
		FROM DeliveryBackOffice.dbo.InvoiceBatchDetail ibd
		LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader ih ON ih.inv_pk_id = ibd.inv_pk_id
		WHERE ih.inv_pk_id = @idInvoice;

		--Insertamos Nota de Credito sobre Factura Cancelada
		INSERT INTO InvoiceBatchDetail 
			   (
				Id_Lote,
				ProcessedCorrelative,
				inv_pk_id,
				SendEmail,
				RowStatus,
				TokenCreated,
				DateCreated
			   )
		VALUES (
				@Batch,
				@LastProcessed,
				@idInvoiceCreditNote,
				0,
				1,
				@user,
				GETDATE()
			   );

		--Actualizamos certificado FEL de nota de credito generada
		UPDATE DeliveryBackOffice.dbo.invoiceHeader
		SET inv_certificationFEL = CONCAT(@inv_certificationFEL, RIGHT('00000000' + CAST(@LastProcessed AS VARCHAR), 8)),
			inv_serieFEL = @CAI,
			inv_numberFEL = @LastProcessed,
			inv_establecimientoFEL = 0,
			systemOperation = 2,
			inv_FechaHoraFel = GETDATE(),
			inv_dateFel = GETDATE(),
			inv_CountryFEL = 'HN',
			inv_EntityFEL = 'HN',
			inv_descriptionFEL = 'PROCESO REALIZADO',
			inv_RequestorFEL = '',
			inv_TransactionFEL = ''
		WHERE inv_pk_id = @idInvoiceCreditNote

    END

    IF @Code <> 0
    BEGIN
         SELECT @idInvoiceCreditNote as 'inv_pk_id',
                CONCAT(@inv_certificationFEL, RIGHT('00000000' + CAST(@LastProcessed AS VARCHAR), 8)) AS 'inv_certificationFEL',
                @CAI AS 'inv_serieFEL',
                @LastProcessed AS'inv_numberFEL',
                @Code AS code,
                @Message AS [message]
    END
END;