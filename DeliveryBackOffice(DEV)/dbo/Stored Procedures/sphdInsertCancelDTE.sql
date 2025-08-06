-- =============================================
-- Author:      <Brandon Pedroza>
-- Create date: <2025-07-18>
-- Description: <Facturacion - Insercion y actualizacion de relacion factura y cancelacion SV>
-- =============================================
CREATE PROCEDURE [dbo].[sphdInsertCancelDTE]
    @NumberFEL NVARCHAR(50),
    @Token NVARCHAR(100),
    @Sello NVARCHAR(100),
    @GeneratedCode NVARCHAR(100),
    @MotivoAnulacion NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @DateOrigen AS DATETIME,
                @DocumentOriginFEL AS NVARCHAR(50),
                @pk_inv_id AS BIGINT,
                @TypeInvCancelation AS INT = (SELECT IdRegister FROM CatTypeDocument WITH(NOLOCK) WHERE [Name] = 'Anulación DTE');
        
        IF NOT EXISTS
        (
            SELECT 1
            FROM invoiceHeader WITH(NOLOCK)
            WHERE inv_numberFEL = @NumberFEL
        )
        BEGIN
            SELECT '1' AS [Code],
                   'La factura no existe' AS [Message]
            RETURN;
        END
        SELECT @DateOrigen = inv_dateRegister,
               @DocumentOriginFEL = inv_certificationFEL,
               @pk_inv_id = inv_pk_id
        FROM invoiceHeader WITH (NOLOCK)
        WHERE inv_numberFEL = @NumberFEL

        BEGIN TRANSACTION;
        -- Insertamos la copia del registro con inv_type = 5(ANULACION)
        INSERT INTO invoiceHeader
        (
            inv_vpCodeOfReferences,
            inv_cmp_name,
            inv_cmp_nameComercial,
            inv_cmp_adress,
            inv_cmp_nit,
            inv_cli_name,
            inv_cli_adress,
            inv_cli_nit,
            inv_cli_email,
            inv_date,
            inv_documentSend,
            inv_documentRecieved,
            inv_certificationFEL,
            inv_serieFEL,
            inv_numberFEL,
            inv_descriptionFEL,
            inv_RequestorFEL,
            inv_TransactionFEL,
            inv_CountryFEL,
            inv_EntityFEL,
            inv_UserFEL,
            inv_UserName,
            inv_Data1FEL,
            inv_Data3FEL,
            inv_MailSendFEL,
            inv_subjectFEL,
            inv_IVA,
            inv_amount,
            inv_status,
            inv_dateRegister,
            inv_tokenRegister,
            inv_dateUpdate,
            inv_tokenUpdate,
            inv_type,
            inv_invoiceOfCreditNote,
            inv_motiveCreditNote,
            inv_dateOriginDocument,
            inv_documentOriginFEL,
            inv_creditNote,
            inv_establecimientoFEL,
            inv_cmp_nameFEL,
            inv_FechaHoraFEL,
            inv_SAPDocEntry,
            inv_SAPError,
            systemOperation,
            IsManualInvoice,
            inv_dateFEL,
            CatInvoiceTypeId,
            Retries,
            IdCurrency,
            IdCountry
        )
        SELECT inv_vpCodeOfReferences,
               inv_cmp_name,
               inv_cmp_nameComercial,
               inv_cmp_adress,
               inv_cmp_nit,
               inv_cli_name,
               inv_cli_adress,
               inv_cli_nit,
               inv_cli_email,
               inv_date,
               '',
               '',--documento serializado
               @Sello,
               '',
               @GeneratedCode,
               'ANULACION DE DOCUMENTO',
               '',
               '',
               inv_CountryFEL,
               inv_EntityFEL,
               '',
               inv_UserName,
               '',
               '',
               inv_MailSendFEL,
               inv_subjectFEL,
               inv_IVA,
               inv_amount,
               2,-- inv_status nuevo
               GETDATE(),
               @Token,
               NULL,
               NULL,
               @TypeInvCancelation,-- inv_type (nuevo valor)
               @pk_inv_id,
               @MotivoAnulacion,
               @DateOrigen,
               @DocumentOriginFEL,
               NULL,
               inv_establecimientoFEL,
               '',
               '',
               NULL,
               NULL,
               systemOperation,
               IsManualInvoice,
               inv_dateFEL,
               CatInvoiceTypeId,
               Retries,
               IdCurrency,
               IdCountry
        FROM invoiceHeader
        WHERE inv_numberFEL = @NumberFEL;
        
        DECLARE @new_inv_pk_id INT = SCOPE_IDENTITY();
        
        -- actualizar factura
        UPDATE invoiceHeader
        SET inv_status = -1,
            inv_tokenUpdate = @Token,
            inv_dateUpdate = GETDATE(),
            inv_creditNote = @new_inv_pk_id
        WHERE inv_numberFEL = @NumberFEL;
        COMMIT TRANSACTION;


        SELECT TOP 1
            '1' AS [Code],
            'El registro ha sido ingresado coorectamente' AS [Message],
            inv_pk_id,
            inv_numberFEL
        FROM invoiceHeader WITH (NOLOCK)
        WHERE inv_pk_id = @new_inv_pk_id

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
