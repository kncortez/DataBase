-- =============================================
-- Author:      Cristian Azurdia
-- Create date: 2024-07-25
-- Description: Se obtiene los valores de emisor de facturas para HN
-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2018-08-08
-- Description: Se obtienen los valores de serie y number FEL
-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024/08/16
-- Description: Se agregaron validaciones de lotes
-- =============================================
CREATE PROCEDURE [dbo].[GetBatchInvoiceByCountry_DR]
(
    @idInvoice       BIGINT,
    @user            NVARCHAR(100) = 'SYSTEM',
    @CodeOfReference INT = 0
)
AS
BEGIN
     DECLARE @Batch                BIGINT,
             @InitialRange         BIGINT,
             @FinalRange           BIGINT,
             @CAI                  NVARCHAR(100),
             @LastProcessed        BIGINT,
             @inv_certificationFEL NVARCHAR(75),
             @Code                 INT = 0,
             @Message              NVARCHAR(250)

     /*
       InvoiceBatchHeader
       status = 1 y enable = 1 es cuando el lote esta habilidado y activo
       status = 0 y enable = 1 es un error - no contemplado
       status = 1 y enable = 0 es cuando no se puede facturar, porque se detuvo facturación (Ya viene lote nuevo ejemplo)
     */

    EXEC [ValidateBatchInvoice] @TypeDocument    = 1,
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
                ,@LastProcessed = invHe.Last_Process + 1
           FROM InvoiceBatchHeader invHe
                INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                  ON invHe.Id_Lote = ibr.Id_Lote
          WHERE ibr.CodeOfReference = @CodeOfReference
            AND [Status] = 1
            AND [Enable] = 1
            AND TypeDocument = 1

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

    END

    IF @Code <> 0
    BEGIN
         SELECT CONCAT(@inv_certificationFEL, RIGHT('00000000' + CAST(@LastProcessed AS VARCHAR), 8)) AS 'inv_certificationFEL',
                @CAI AS 'inv_serieFEL',
                @LastProcessed AS'inv_numberFEL',
                @Code AS code,
                @Message AS [message]
    END

END;