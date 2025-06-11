
-- =============================================
-- Author:      Cristian Azurdia
-- Create date: 2025-06-06
-- Description: Actualización de un nuevo token Generado
-- =============================================

CREATE PROCEDURE [dbo].[UpdateAuthorizationInvoice]
(
    @Authorization NVARCHAR(512)= '',
    @StartDate DATETIME = GETDATE,
    @EndDate   DATETIME = GETDATE,
    @Token NVARCHAR(100) = 'SYS-CAZURDIA'
)
AS
BEGIN
    DECLARE @NewAuthorization     NVARCHAR(512),
            @NewEndDAte           DATETIME,
            @Code                 INT = 0,
            @Message              NVARCHAR(250);

    DECLARE @OldAuthorizationId INT;
    DECLARE @NewAuthorizationId INT;
    
    -- Validaciones básicas
    IF LTRIM(RTRIM(@Authorization)) = ''
    BEGIN
        SET @Code = 0;
        SET @Message = 'El parámetro Authorization no puede estar vacío';
        GOTO ErrorExit;
    END
    
    IF @StartDate > @EndDate
    BEGIN
        SET @Code = 0;
        SET @Message = 'La fecha de inicio no puede ser mayor a la fecha de fin';
        GOTO ErrorExit;
    END

    BEGIN TRANSACTION;

    BEGIN TRY

         SELECT @OldAuthorizationId = IdInvoiceAuthorizationHeader 
         FROM InvoiceAuthorizationHeader
         WHERE RowStatus = 1;

         --Actualizamos a la nueva Authorization
         UPDATE InvoiceAuthorizationHeader 
         SET RowStatus = 0,
             TokenUPdated = @Token,
             DateUpdated = GETDATE()
         WHERE IdInvoiceAuthorizationHeader = @OldAuthorizationId;

         INSERT InvoiceAuthorizationHeader ([Authorization],[StartDate],[EndDate],[RowStatus],[TokenCreated],[DateCreated])
         VALUES(@Authorization,@StartDate,@EndDate,1,@Token,GETDATE());

         SELECT @NewAuthorizationId = IdInvoiceAuthorizationHeader 
         FROM InvoiceAuthorizationHeader
         WHERE RowStatus = 1;

         --Insertamos la Relacion con los CodeOfReference Activos
         -- Registrados anteiormente y que este activos
         INSERT INTO InvoiceAuthorizationRelationships (CodeOfReference,InvoiceAuthorizationHeaderId,RowStatus,TokenCreated,DateCreated)
         SELECT CodeOfReference, @NewAuthorizationId, 1 RowStatus, @Token, GETDATE()
         FROM InvoiceAuthorizationRelationships
         WHERE InvoiceAuthorizationHeaderId = @OldAuthorizationId
           AND RowStatus = 1

         --Invalidamos la Relacion con los CodeOfReference Anteriores
         --Para que tome en cuenta los útlimos registrados
         UPDATE InvoiceAuthorizationRelationships
         SET RowStatus = 0,
             TokenUPdated = @Token,
             DateUpdated = GETDATE()
         WHERE InvoiceAuthorizationHeaderId = @OldAuthorizationId;

         COMMIT TRANSACTION;
        
        -- Establecer valores de retorno exitosos
        SET @Code = 1;
        SET @Message = 'Autorización actualizada exitosamente';
        SET @NewAuthorization = @Authorization;
        SET @NewEndDate = @EndDate;

    END TRY
    BEGIN CATCH
        -- En caso de error, revertir toda la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Capturar información del error
        SET @Code = ERROR_NUMBER();
        SET @Message = 'Error: ' + ERROR_MESSAGE() + 
                      ' (Línea: ' + CAST(ERROR_LINE() AS NVARCHAR(10)) + 
                      ', Severidad: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(10)) + ')';
        SET @Authorization = '';
        SET @EndDate = GETDATE();

    END CATCH
    
    ErrorExit:
    -- Retornar resultados
    SELECT @Code [Code], @Message [Message]
    SELECT  @NewAuthorization [Authorization], @NewEndDate [EndDate]

END;