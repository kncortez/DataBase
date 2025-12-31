/*
================================================================================
FECHA DE CREACIÓN: 2025-12-04
AUTOR: IGONZALEZ
================================================================================
*/

CREATE PROCEDURE dbo.Support_UpdateCustomerEmail
(
    @IdCustomer INT,
    @NewEmail VARCHAR(100),
    @TokenUpdated VARCHAR(100),
    @DateUpdated DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

         
        -- PASO 1: Validar existencia del cliente
         
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.Customer WITH (NOLOCK)
            WHERE IdCustomer = @IdCustomer
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El cliente no existe.' AS Mensaje,
                @IdCustomer AS IdCustomer;
            RETURN;
        END


         
        -- PASO 2: Capturar valores actuales (antes del UPDATE)
         
        DECLARE 
            @PrevRegexEmail VARCHAR(100),
            @PrevDomain VARCHAR(100);
            
        SELECT 
            @PrevRegexEmail = RegexEmail,
            @PrevDomain = Domain
        FROM dbo.Customer WITH (NOLOCK)
        WHERE IdCustomer = @IdCustomer;


         
        -- PASO 3: Validar correo ingresado
         
        IF @NewEmail NOT LIKE '%@%'
        BEGIN
            SELECT
                'Error' AS Estado,
                'El correo ingresado no es válido. Debe contener @' AS Mensaje,
                @NewEmail AS CorreoIngresado;
            RETURN;
        END


         
        -- PASO 4: Normalizar correo (minúsculas)
         
        SET @NewEmail = LOWER(@NewEmail);


         
        -- PASO 5: Crear formato RegexEmail  (^correo$)
         
        DECLARE @EmailRegex VARCHAR(100);
        SET @EmailRegex = '^' + @NewEmail + '$';


         
        -- PASO 6: Extraer dominio y crear formato Domain (^@dominio$)
         
        DECLARE @Domain VARCHAR(100);
        DECLARE @DomainRegex VARCHAR(100);

        -- Extraer lo que sigue después del @
        SET @Domain = SUBSTRING(@NewEmail, CHARINDEX('@', @NewEmail), LEN(@NewEmail));

        SET @DomainRegex = '^' + @Domain + '$';


         
        -- PASO 7: Actualizar Customer
         
        UPDATE dbo.Customer
        SET 
            RegexEmail   = @EmailRegex,
            Domain       = @DomainRegex,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = @DateUpdated
        WHERE IdCustomer = @IdCustomer;


         
        -- PASO 8: Respuesta final
         
        SELECT
            'Éxito' AS Estado,
            'El correo fue actualizado correctamente.' AS Mensaje,
            @IdCustomer AS IdCustomer,

            -- Valores anteriores
            @PrevRegexEmail AS RegexEmail_Anterior,
            @PrevDomain AS Domain_Anterior,

            -- Valores nuevos
            @EmailRegex AS RegexEmail_Nuevo,
            @DomainRegex AS Domain_Nuevo;

    END TRY
    BEGIN CATCH
        SELECT 
            'Error' AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE() AS ErrorLinea;
            
        THROW;

    END CATCH
END
GO


/*
================================================================================
EJEMPLO DE EJECUCIÓN
================================================================================
EXEC dbo.Support_UpdateCustomerEmail
     @IdCustomer = 73623,
     @NewEmail = 'ejemplo@gmail.com',
     @TokenUpdated = 'SYS-IGONZALEZ',
     @DateUpdated = GETDATE();
================================================================================
HISTORIAL DE CAMBIOS:
    - 2025-12-04: Primera versión documentada del procedimiento.
    - 2025-12-04: Se agregó visualización de valores anteriores y nuevos.
================================================================================
*/