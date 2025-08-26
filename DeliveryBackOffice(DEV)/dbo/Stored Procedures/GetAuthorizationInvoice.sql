
-- =============================================
-- Author:      Cristian Azurdia
-- Create date: 2025-06-06
-- Description: Se obtiene el token de autorización
-- =============================================

CREATE PROCEDURE [dbo].[GetAuthorizationInvoice]
(
    @CodeOfReference INT = 0
)
AS
BEGIN
     DECLARE @Authorization        NVARCHAR(512),
             @EndDAte              DATETIME,
             @Code                 INT = 0,
             @Message              NVARCHAR(250)

    EXEC [ValidateAuthorizationInvoice] @CodeOfReference = @CodeOfReference,
                                        @Code            = @Code OUTPUT,
                                        @Message         = @Message OUTPUT

    -- Si todas las validaciones fueron correctas
    IF @Code = 1
    BEGIN
         SELECT  @Authorization = invHe.[Authorization]
                ,@EndDAte = invHe.[EndDate]
           FROM InvoiceAuthorizationHeader invHe WITH(NOLOCK)
                INNER JOIN InvoiceAuthorizationRelationships iar WITH(NOLOCK)
                  ON invHe.IdInvoiceAuthorizationHeader = iar.InvoiceAuthorizationHeaderId
          WHERE iar.CodeOfReference = @CodeOfReference
            AND invHe.[RowStatus] = 1
            AND iar.[RowStatus] = 1

    END

    IF @Code <> 0
    BEGIN

         SELECT @Authorization AS 'Authorization',
                @EndDAte AS'EndDate';
    END

END;