/*
================================================================================
SP:        dbo.Support_ChangePasswordCorporate
PROPÓSITO: Cambio de contraseña para usuarios corporativos.
AUTOR:     IRVIN GONZALEZ
HISTORIA:  FDAPI-5272
FECHA:     2026-01-09
============================================
=== CHANGELOG ============================
2026-01-09 | Historia: FDAPI-5272 | Autor: IRVIN GONZALEZ |

=========================================== */

CREATE PROCEDURE dbo.Support_ChangePasswordCorporate
    @Newpassword     NVARCHAR(400),   
    @RegisterUserId  INT,             
    @TokenUpdate     NVARCHAR(100)     
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        -- Paso 1: Validar existencia de RegisterUser
        IF NOT EXISTS (
            SELECT TOP 1 1
            FROM dbo.RegisterUser WITH (NOLOCK)
            WHERE UsrIdUser = @RegisterUserId
        )
        BEGIN
            SELECT 
                N'Error' AS Estado, 
                N'RegisterUser no encontrado. No se aplicó el cambio de contraseña' AS Mensaje,
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
                N'Error' AS Estado, 
                N'Este no es un usuario corporativo. No se aplicó el cambio de contraseña.' AS Mensaje,
                @RegisterUserId AS RegisterUser;
            RETURN;
        END

        -- Paso 3: Obtener IdCustomer desde VisitPointClient
        DECLARE @IdCustomer INT;

        SELECT TOP 1
            @IdCustomer = CustomerID
        FROM dbo.VisitPointClient WITH (NOLOCK)
        WHERE IdVisitPointClient = @IdVisitPointClient;

        -- Paso 4: Validar estado de confirmación de cuenta
        DECLARE @AccConfirm CHAR(1);

        SELECT TOP 1
            @AccConfirm = AccConfirm
        FROM dbo.Account WITH (NOLOCK)
        WHERE IdCustomer = @IdCustomer;

        IF @AccConfirm <> 'C'
        BEGIN
            SELECT 
                N'Advertencia' AS Estado,
                N'La cuenta del cliente NO está confirmada. No se aplicó el cambio de contraseña.' AS Mensaje,
                @RegisterUserId AS RegisterUser,
                @IdCustomer AS IdCustomer,
                @AccConfirm AS EstadoCuenta;
            RETURN;
        END

        -- Paso 5: Actualizar contraseña
        UPDATE dbo.RegisterUser
        SET 
            UsrLastPassword = @Newpassword,
            UsrTokenUpdated = @TokenUpdate,
            DateUpdated     = GETDATE()
        WHERE UsrIdUser = @RegisterUserId;

        -- Resultado exitoso
        SELECT 
            N'Éxito' AS Estado,
            N'Contraseña actualizada correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH

        SELECT 
            N'Error' AS Estado,
            N'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH
END
GO

/*
================================================================================
EJEMPLO DE EJECUCIÓN
================================================================================
EXEC dbo.Support_ChangePasswordCorporate 
     @Newpassword     = N'IZwHWBhJG1G0I+VSazxyNw==',
     @RegisterUserId  = 14932,
     @TokenUpdate     = N'SYS-IGONZALEZ';
================================================================================
*/
