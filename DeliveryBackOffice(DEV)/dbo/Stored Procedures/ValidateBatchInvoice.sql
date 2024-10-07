
-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024-08-14
-- Description: Se agregan las validaciones necesarias para el lote de facturacion
-- =============================================
CREATE PROCEDURE [ValidateBatchInvoice]
(
  @TypeDocument    SMALLINT = 1,
  @CodeOfReference INT = 0,
  @Code            SMALLINT OUTPUT,
  @Message         NVARCHAR(250) OUTPUT
)
AS
BEGIN

 --Solo aplica para facturación
 IF(@TypeDocument = 1)
 BEGIN
     IF NOT EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                           INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                             ON ibh.Id_Lote = ibr.Id_Lote
                     WHERE ibr.CodeOfReference = @CodeOfReference
                       AND ibh.[Status] = 1
                       AND ibh.[Enable] = 1
                       AND ibr.[RowStatus] = 1
                       AND TypeDocument = 1
                   )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'No existe un lote activo para el tipo de documento de facturación '

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                       INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                         ON ibh.Id_Lote = ibr.Id_Lote
                 WHERE ibr.CodeOfReference = @CodeOfReference
                   AND ibh.[Status] = 1
                   AND ibh.[Enable] = 1
                   AND ibr.[RowStatus] = 1
                   AND ibh.TypeDocument = 1
                   AND (
                        ISNULL(ibh.RTN,'') = ''
                        OR ISNULL(ibh.CAI,'') = ''
                        OR ISNULL(ibh.NoDeclaracion,'') = ''
                        OR ISNULL(InitialRange,'') = ''
                        OR ISNULL(FinalRange,'') = ''
                   )
               )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'El lote contiene valores vacios en campos obligatorios '

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

     IF NOT EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                           INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                             ON ibh.Id_Lote = ibr.Id_Lote
                     WHERE ibr.CodeOfReference = @CodeOfReference
                       AND ibh.[Status] = 1
                       AND ibh.[Enable] = 1
                       AND ibr.[RowStatus] = 1
                       AND TypeDocument = 1
                       AND GETDATE() <= LimitDateEmision 
                   )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'La fecha actual excede la fecha limite de facturación para el lote asignado'

          SELECT @Code AS code,
                 @Message AS [Message];

          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                       INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                         ON ibh.Id_Lote = ibr.Id_Lote
                 WHERE ibr.CodeOfReference = @CodeOfReference
                   AND ibh.[Status] = 1
                   AND ibh.[Enable] = 1
                   AND ibr.[RowStatus] = 1
                   AND TypeDocument = 1
                   AND Last_Process = FinalRange
               )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'Ya ha sido generado el ultimo correlativo disponible del lote asignado actual';

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

          SELECT @Code = 1,
                 @Message = 'Lote validado correctamente';

          SELECT @Code AS code,
                 @Message AS [Message];

          RETURN;
 END -- Fin conditions type document 1

 IF(@TypeDocument = 6)
 BEGIN
     IF NOT EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                           INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                             ON ibh.Id_Lote = ibr.Id_Lote
                     WHERE ibr.CodeOfReference = @CodeOfReference
                       AND ibh.[Status] = 1
                       AND ibh.[Enable] = 1
                       AND ibr.[RowStatus] = 1
                       AND TypeDocument = 6
                   )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'No existe un lote activo para el tipo de documento de nota de credito '

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                       INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                         ON ibh.Id_Lote = ibr.Id_Lote
                 WHERE ibr.CodeOfReference = @CodeOfReference
                   AND ibh.[Status] = 1
                   AND ibh.[Enable] = 1
                   AND ibr.[RowStatus] = 1
                   AND ibh.TypeDocument = 6
                   AND (
                        ISNULL(ibh.RTN,'') = ''
                        OR ISNULL(ibh.CAI,'') = ''
                        OR ISNULL(ibh.NoDeclaracion,'') = ''
                        OR ISNULL(InitialRange,'') = ''
                        OR ISNULL(FinalRange,'') = ''
                   )
               )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'El lote contiene valores vacios en campos obligatorios '

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

     IF NOT EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                           INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                             ON ibh.Id_Lote = ibr.Id_Lote
                     WHERE ibr.CodeOfReference = @CodeOfReference
                       AND ibh.[Status] = 1
                       AND ibh.[Enable] = 1
                       AND ibr.[RowStatus] = 1
                       AND TypeDocument = 6
                       AND GETDATE() <= LimitDateEmision 
                   )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'La fecha actual excede la fecha limite de nota de credito para el lote asignado'

          SELECT @Code AS code,
                 @Message AS [Message];

          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceBatchHeader ibh WITH(NOLOCK)
                       INNER JOIN InvoiceBatchRelationships ibr WITH(NOLOCK)
                         ON ibh.Id_Lote = ibr.Id_Lote
                 WHERE ibr.CodeOfReference = @CodeOfReference
                   AND ibh.[Status] = 1
                   AND ibh.[Enable] = 1
                   AND ibr.[RowStatus] = 1
                   AND TypeDocument = 6
                   AND Last_Process = FinalRange
               )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'Ya ha sido generado el ultimo correlativo disponible del lote asignado actual';

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

          SELECT @Code = 1,
                 @Message = 'Lote validado correctamente';

          SELECT @Code AS code,
                 @Message AS [Message];

          RETURN;
 END -- Fin conditions type document 1

END;