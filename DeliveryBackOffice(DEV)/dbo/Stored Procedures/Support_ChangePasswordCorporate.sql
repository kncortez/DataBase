/*
================================================================================
FECHA DE CREACIÓN: 2025-10-09
AUTOR: IGONZALEZ
================================================================================
*/

CREATE PROCEDURE dbo.Support_ChangePasswordCorporate
    @Newpassword VARCHAR(400),			-- Contraseña ENCRIPTADA
    @RegisterUserId INT,                -- Id en tabla RegisterUser
    @TokenUpdate VARCHAR(50)            -- Token del soporte que realiza el cambio
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        -- Paso 1: Validar existencia de RegisterUser
        IF NOT EXISTS (
            SELECT top 1 *
            FROM dbo.RegisterUser WITH (NOLOCK) 
            WHERE UsrIdUser = @RegisterUserId
        )
        BEGIN
            SELECT 
                'Error' AS Estado, 
                'RegisterUser no encontrado. No se aplicó el cambio de contraseña.' AS Mensaje,
                @RegisterUserId AS RegisterUser;
            RETURN;
        END

        -- Paso 2: Obtener IdVisitPointClient desde VisitPointByUser
        DECLARE @IdVisitPointClient INT;

        SELECT TOP 1 
            @IdVisitPointClient = IdVisitPointClient
        FROM dbo.VisitPointByUser WITH (NOLOCK)
        WHERE RegisterUserID = @RegisterUserId;

        IF @IdVisitPointClient IS NULL
        BEGIN
            SELECT 
                'Error' AS Estado, 
                'Este no es un usuario corporativo. No se aplicó el cambio de contraseña.' AS Mensaje,
                @RegisterUserId AS RegisterUser;
            RETURN;
        END

        -- Paso 3: Obtener IdCustomer desde VisitPointClient
        DECLARE @IdCustomer INT;

        SELECT TOP 1 
            @IdCustomer = CustomerID
        FROM dbo.VisitPointClient WITH (NOLOCK)
        WHERE IdVisitPointClient = @IdVisitPointClient;

        -- Paso 4: Validar estado de confirmación de cuenta (Account.AccConfirm)
        DECLARE @AccConfirm CHAR(1);

        SELECT TOP 1 
            @AccConfirm = AccConfirm
        FROM dbo.Account WITH (NOLOCK)
        WHERE IdCustomer = @IdCustomer;

        IF @AccConfirm <> 'C'   -- 'C' = Confirmada
        BEGIN
            SELECT 
                'Advertencia' AS Estado,
                'La cuenta del cliente NO está confirmada. No se aplicó el cambio de contraseña.' AS Mensaje,
                @RegisterUserId AS RegisterUser,
                @IdCustomer AS IdCustomer,
                @AccConfirm AS EstadoCuenta;
            RETURN;
        END

        -- Paso 5: Actualizar contraseña (se guarda el valor encriptado tal cual)
        UPDATE dbo.RegisterUser
        SET 
            UsrLastPassword = @Newpassword,
            UsrTokenUpdated = @TokenUpdate,
            DateUpdated = GETDATE()
        WHERE UsrIdUser = @RegisterUserId;

        -- Resultado exitoso (result set)
        SELECT 
            'Éxito' AS Estado,
            'Contraseña actualizada correctamente.' AS Mensaje;
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
-- El valor de @Newpassword debe ser la contraseña ENCRIPTADA
EXEC dbo.Support_ChangePasswordCorporate 
     @Newpassword = 'IZwHWBhJG1G0I+VSazxyNw==', -- ejemplo de contraseña encriptada
     @RegisterUserId = 14932,
     @TokenUpdate = 'SYS-IGONZALEZ';
================================================================================
HISTORIAL DE CAMBIOS:
	- 2025-10-09: Primera versión solo cambio de contraseña.
    - 2025-10-11: Corrección: validacion de cuenta activa.
================================================================================
*/
