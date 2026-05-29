/* =================================================
   SP:        dbo.Support_UpdateCustomerEmail
   Propósito: Actualizar el correo del cliente y sus expresiones asociadas.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5241
   Fecha:     2025-12-04
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateCustomerEmail
(
    @IdCustomer   INT,
    @NewEmail     NVARCHAR(100),
    @TokenUpdated NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validar existencia del cliente

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.Customer WITH (NOLOCK)
            WHERE IdCustomer = @IdCustomer
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El cliente no existe.' AS Mensaje,
                @IdCustomer AS IdCustomer;
            RETURN;
        END


        -- PASO 2: Validar tipo de cliente

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.Customer WITH (NOLOCK)
            WHERE IdCustomer = @IdCustomer
              AND IdCustomerType = 1
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El cliente no es corporativo.' AS Mensaje,
                @IdCustomer AS IdCustomer;
            RETURN;
        END


        -- PASO 3: Capturar valores actuales

        DECLARE
            @PrevRegexEmail NVARCHAR(100),
            @PrevDomain     NVARCHAR(50);

        SELECT
            @PrevRegexEmail = RegexEmail,
            @PrevDomain     = Domain
        FROM DeliveryBackOffice.dbo.Customer WITH (NOLOCK)
        WHERE IdCustomer = @IdCustomer;


        -- PASO 4: Validar correo ingresado

        IF (
            LEN(@NewEmail) - LEN(REPLACE(@NewEmail, '@', '')) <> 1
            OR @NewEmail NOT LIKE N'%_@%.%'
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El correo ingresado no es válido.' AS Mensaje,
                @NewEmail AS CorreoIngresado;
            RETURN;
        END


        -- PASO 5: Normalizar correo

        SET @NewEmail = LOWER(@NewEmail);


        -- PASO 6: Crear formato RegexEmail (^correo$)

        DECLARE @EmailRegex NVARCHAR(100);
        SET @EmailRegex = '^' + @NewEmail + '$';


        -- PASO 7: Extraer dominio y crear formato Domain (^@dominio$)

        DECLARE @Domain NVARCHAR(50);
        DECLARE @DomainRegex NVARCHAR(50);

        SET @Domain = SUBSTRING(@NewEmail, CHARINDEX('@', @NewEmail), LEN(@NewEmail));
        SET @DomainRegex = '^' + @Domain + '$';


        -- PASO 8: Actualizar Customer

        UPDATE DeliveryBackOffice.dbo.Customer
        SET
            RegexEmail   = @EmailRegex,
            Domain       = @DomainRegex,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdCustomer = @IdCustomer;


        -- PASO 9: Respuesta final

        SELECT
            'Éxito' AS Estado,
            'El correo fue actualizado correctamente.' AS Mensaje,
            @IdCustomer AS IdCustomer,
            @PrevRegexEmail AS RegexEmail_Anterior,
            @PrevDomain     AS Domain_Anterior,
            @EmailRegex     AS RegexEmail_Nuevo,
            @DomainRegex    AS Domain_Nuevo;

    END TRY
    BEGIN CATCH

        SELECT
            'Error' AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH
END