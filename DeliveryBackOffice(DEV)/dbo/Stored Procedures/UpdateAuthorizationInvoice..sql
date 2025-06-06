
-- =============================================
-- Author:      Cristian Azurdia
-- Create date: 2025-06-06
-- Description: Se obtiene el token de autorización
-- =============================================

CREATE PROCEDURE [dbo].[UpdateAuthorizationInvoice]
(
    @Authorization NVARCHAR(512)= '',
    @StartDate DATE = GETDATE,
    @EndDate   DATE   = GETDATE,
    @Token NVARCHAR(100) = 'SYS-CAZURDIA'
)
AS
BEGIN
    DECLARE @NewAuthorization     NVARCHAR(512),
            @NewEndDAte           DATETIME,
            @Code                 INT = 0,
            @Message              NVARCHAR(250);

    DECLARE @OldAuthorizationId INT;

         SELECT @OldAuthorizationId = IdInvoiceAuthorizationHeader 
         FROM InvoiceAuthorizationHeader
         WHERE RowStatus = 1;

         --Actualizamos a la nueva Authorization
         UPDATE InvoiceAuthorizationHeader 
         SET RowStatus = 0
         WHERE IdInvoiceAuthorizationHeader = @OldAuthorizationId;

         INSERT InvoiceAuthorizationHeader ([Authorization],[StartDate],[EndDate],[RowStatus],[TokenCreated],[DateCreated])
         VALUES(@Authorization,@StartDate,@EndDate,1,@Token,GETDATE());

         --Insertamos la Relacion con los CodeOfReference Activos
         -- Registrados anteiormente y que este activos
         INSERT INTO InvoiceAuthorizationRelationships (CodeOfReference,InvoiceAuthorizationHeaderId,RowStatus,TokenCreated,DateCreated)
         SELECT CodeOfReference, InvoiceAuthorizationHeaderId, RowStatus, TokenCreated, DateCreated
         FROM InvoiceAuthorizationRelationships
         WHERE InvoiceAuthorizationHeaderId = @OldAuthorizationId
           AND RowStatus = 1;

         --Invalidamos la Relacion con los CodeOfReference Anteriores
         --Para que tome en cuenta los útlimos registrados
         UPDATE InvoiceAuthorizationRelationships
         SET RowStatus = 0
         WHERE InvoiceAuthorizationHeaderId = @OldAuthorizationId;

         SELECT @NewAuthorization AS 'Authorization',
                @NewEndDAte AS'EndDate'

END;