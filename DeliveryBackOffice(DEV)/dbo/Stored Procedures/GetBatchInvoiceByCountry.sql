-- =============================================
-- Author:      Cristian Azurdia
-- Create date: 2024-07-25
-- Description: Se obtiene los valores de emisor de facturas para HN
-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2018-08-08
-- Description: Se obtienen los valores de serie y number FEL
-- =============================================
CREATE PROCEDURE [dbo].[GetBatchInvoiceByCountry]
    @idInvoice BIGINT,
    @user      NVARCHAR(100) = 'SYSTEM'
AS
BEGIN
     DECLARE @Batch BIGINT,
             @InitialRange BIGINT,
             @FinalRange BIGINT,
             @CAI NVARCHAR(100),
             @LastProcessed BIGINT,
             @inv_certificationFEL NVARCHAR(75)

     /*
       InvoiceBatchHeader
       status = 1 y enable = 1 es cuando el lote esta habilidado y activo
       status = 0 y enable = 1 es un error - no contemplado
       status = 1 y enable = 0 es cuando no se puede facturar, porque se detuvo facturación (Ya viene lote nuevo ejemplo)
     */

    SELECT  @inv_certificationFEL = CONCAT(RIGHT('000' + CAST(invHe.Establishment AS VARCHAR), 3), '-',
                                           RIGHT('000' + CAST(invHe.Emision_Point AS VARCHAR), 3),'-',
                                           RIGHT('00' + CAST(invHe.TypeDocument AS VARCHAR), 2),'-')
           ,@Batch = invHe.Id_Lote
           ,@InitialRange = invHe.InitialRange
           ,@FinalRange = invHe.FinalRange
           ,@CAI = invHe.CAI
           ,@LastProcessed = invHe.Last_Process + 1  --1
      FROM InvoiceBatchHeader invHe
     WHERE TypeDocument = 1
       AND [STATUS] = 1
       AND [ENABLE] = 1

     --Asignamos a la factura el número de certificación del lote
     /*UPDATE invoiceHeader
     SET inv_certificationFEL = @LastProcessed
         ,inv_subjectFEL = 'Forza Delivery - Factura Electrónica'
         ,inv_FechaHoraFEL = GETDATE()
         ,inv_descriptionFEL = 'PROCESO REALIZADO'
         ,inv_TransactionFEL = 'SYSTEM_REQUEST'
         ,inv_status = 2
     WHERE inv_pk_id = @idInvoice*/

    --Actualizamos el último procesado 
    UPDATE InvoiceBatchHeader
       SET Last_Process = @LastProcessed
     WHERE Id_Lote = @Batch

    --Insertamos Factura Procesada
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
            @idInvoice,
            0,
            1,
            @user,
            GETDATE()
           );

    SELECT CONCAT(@inv_certificationFEL, RIGHT('00000000' + CAST(@LastProcessed AS VARCHAR), 8)) AS 'inv_certificationFEL',
           @CAI AS 'inv_serieFEL',
           @LastProcessed'inv_numberFEL'
END;