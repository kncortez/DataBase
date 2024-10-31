
-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024-10-17
-- Description: Se agregan las validaciones necesarias para el lote de facturacion
-- =============================================
CREATE PROCEDURE [ValidateBatchGuideRemission]
(
  @TypeDocument    SMALLINT = 8, --Por defecto guia de remision
  @IdStation       INT = 0,
  @Code            SMALLINT OUTPUT,
  @Message         NVARCHAR(250) OUTPUT
)
AS
BEGIN

 --Solo aplica para facturación
 IF(@TypeDocument = 8)
 BEGIN
     IF NOT EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceBatchRelationships ibr
                           INNER JOIN InvoiceBatchHeader ibh 
                              ON ibr.Id_Lote = ibh.Id_Lote
                     WHERE ibr.[IdStation] = @IdStation
                       AND ibr.[RowStatus] = 1
                       AND ibh.[Enable] = 1
                       AND ibh.[Status] = 1
                       AND ibh.[RowStatus] = 1
                       AND ibh.[TypeDocument] = 8
                   )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'No existe un lote activo para el tipo de documento de Guía de Remisión'

          SELECT @Code AS StatusCode,
                 @Message AS [Message];
          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceBatchRelationships ibr 
                       INNER JOIN InvoiceBatchHeader ibh 
                          ON ibr.Id_Lote = ibh.Id_Lote
                 WHERE ibr.[IdStation] = @IdStation
                   AND ibr.[RowStatus] = 1
                   AND ibh.[Enable] = 1
                   AND ibh.[Status] = 1
                   AND ibh.[RowStatus] = 1
                   AND ibh.[TypeDocument] = 8
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
                 @Message = 'El lote contiene valores vacíos en campos obligatorios'

          SELECT @Code AS StatusCode,
                 @Message AS [Message];
          RETURN;
     END

     IF NOT EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceBatchRelationships ibr
                           INNER JOIN InvoiceBatchHeader ibh 
                              ON ibr.Id_Lote = ibh.Id_Lote
                     WHERE ibr.[IdStation] = @IdStation
                       AND ibr.[RowStatus] = 1
                       AND ibh.[Enable] = 1
                       AND ibh.[Status] = 1
                       AND ibh.[RowStatus] = 1
                       AND ibh.[TypeDocument] = 8
                       AND GETDATE() <= ibh.LimitDateEmision 
                   )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'La fecha actual excede la fecha límite de Generación para el lote asignado'

          SELECT @Code AS StatusCode,
                 @Message AS [Message];

          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceBatchRelationships ibr 
                       INNER JOIN InvoiceBatchHeader ibh 
                          ON ibr.Id_Lote = ibh.Id_Lote
                 WHERE ibr.[IdStation] = @IdStation
                   AND ibr.[RowStatus] = 1
                   AND ibh.[Enable] = 1
                   AND ibh.[Status] = 1
                   AND ibh.[RowStatus] = 1
                   AND ibh.[TypeDocument] = 8
                   AND Last_Process >= FinalRange
               )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'Ya ha sido generado el último correlativo disponible del lote asignado actual';

          SELECT @Code AS StatusCode,
                 @Message AS [Message];
          RETURN;
     END

          SELECT @Code = 1,
                 @Message = 'Lote validado correctamente';

          SELECT @Code AS StatusCode,
                 @Message AS [Message];

          RETURN;
 END -- Fin condiciones tipo 8 - Guias de Remisión

END;