USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ValidateBatchInvoice]    Script Date: 5/06/2025 15:57:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Cristian Azurdia
-- Create date: 2024-08-14
-- Description: Se realizan las validaciones necesarias para las Autorizaciones para facturar 
-- =============================================
CREATE PROCEDURE [dbo].[ValidateAuthorizationInvoice]
(
  @CodeOfReference INT = 0,
  @Code            SMALLINT OUTPUT,
  @Message         NVARCHAR(250) OUTPUT
)
AS
BEGIN

     IF NOT EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceAuthorizationHeader iah WITH(NOLOCK)
                           INNER JOIN InvoiceAuthorizationRelationships iar WITH(NOLOCK)
                             ON iah.IdInvoiceAuthorizationHeader = iar.InvoiceAuthorizationHeaderId
                     WHERE iar.CodeOfReference = @CodeOfReference
                       AND iah.[RowStatus] = 1
                       AND iar.[RowStatus] = 1
                   )
     BEGIN
          SELECT @Code = 2,
                 @Message = 'No existe una Autorización activa para el CodeOfReference indicado'

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceAuthorizationHeader iah WITH(NOLOCK)
                       INNER JOIN InvoiceAuthorizationRelationships iar WITH(NOLOCK)
                         ON iah.IdInvoiceAuthorizationHeader = iar.InvoiceAuthorizationHeaderId
                 WHERE iar.CodeOfReference = @CodeOfReference
                   AND iah.[RowStatus] = 1
                   AND iar.[RowStatus] = 1
                   AND (
                        ISNULL(iah.[Authorization],'') = ''
                   )
               )
     BEGIN
          SELECT @Code = 2,
                 @Message = 'No existe autorización para el codeOfReference'

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

     IF EXISTS (
                SELECT TOP 1 1
                  FROM InvoiceAuthorizationHeader iah WITH(NOLOCK)
                       INNER JOIN InvoiceAuthorizationRelationships iar WITH(NOLOCK)
                         ON iah.IdInvoiceAuthorizationHeader = iar.InvoiceAuthorizationHeaderId
                 WHERE iar.CodeOfReference = @CodeOfReference
                   AND iah.[RowStatus] = 1
                   AND iar.[RowStatus] = 1
                   AND (
                        ISNULL(iah.[DateCreated], '') = ''
                        OR ISNULL(iah.[EndDate],'') = ''
                   )
               )
     BEGIN
          SELECT @Code = 0,
                 @Message = 'La autorización tiene pendientes las fechas por configurar'

          SELECT @Code AS code,
                 @Message AS [Message];
          RETURN;
     END

     IF EXISTS (
                    SELECT TOP 1 1
                      FROM InvoiceAuthorizationHeader iah WITH(NOLOCK)
                           INNER JOIN InvoiceAuthorizationRelationships iar WITH(NOLOCK)
                             ON iah.IdInvoiceAuthorizationHeader = iar.InvoiceAuthorizationHeaderId
                     WHERE iar.CodeOfReference = @CodeOfReference
                       AND iah.[RowStatus] = 1
                       AND iar.[RowStatus] = 1
                       AND GETDATE() >= iah.EndDate
                   )
     BEGIN
          SELECT @Code = 2,
                 @Message = 'La fecha actual excede la fecha limite de facturación para la autorización'

          SELECT @Code AS code,
                 @Message AS [Message];

          RETURN;
     END

     SELECT @Code = 1,
            @Message = 'Si existe Autorización Activa y Válida'

     SELECT @Code AS code,
            @Message AS [Message];

END;