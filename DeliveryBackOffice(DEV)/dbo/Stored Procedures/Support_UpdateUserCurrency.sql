/* =================================================
   SP:        dbo.Support_UpdateUserCurrency
   Propósito: Actualizar la moneda asociada a un usuario validando estado y país.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5210
   Fecha:     2025-11-28
============================================
=== CHANGELOG ============================
2025-11-28 | Historia/épica: FDAPI-5210 | Autor: IRVIN GONZALEZ |

=========================================== */

CREATE PROCEDURE dbo.Support_UpdateUserCurrency
(
    @UsrIdUser      INT,
    @NuevaMoneda    NVARCHAR(10),
    @TokenUpdated   NVARCHAR(100),
    @DateUpdated    DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validar existencia del usuario

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.RegisterUser WITH (NOLOCK)
            WHERE UsrIdUser = @UsrIdUser
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El RegisterUser no existe.' AS Mensaje,
                @UsrIdUser AS IdUser;
            RETURN;
        END

        -- PASO 2: Obtener datos actuales del usuario

        DECLARE
            @RowStatus BIT,
            @PrefixCallingCode NVARCHAR(10),
            @MonedaActual VARCHAR(10);

        SELECT
            @RowStatus         = UsrRowStatus,
            @PrefixCallingCode = PrefixCallingCode,
            @MonedaActual      = UsrCurrency
        FROM dbo.RegisterUser WITH (NOLOCK)
        WHERE UsrIdUser = @UsrIdUser;

        -- PASO 3: Validar usuario activo

        IF @RowStatus <> 1
        BEGIN
            SELECT
                'Error' AS Estado,
                'El usuario no se encuentra activo.' AS Mensaje,
                @UsrIdUser AS IdUser;
            RETURN;
        END

        -- PASO 4: Validar que la moneda sea permitida

        IF @NuevaMoneda NOT IN (N'GTQ', N'USD', N'HNL')
        BEGIN
            SELECT
                'Error' AS Estado,
                'La moneda seleccionada no es válida.' AS Mensaje,
                @NuevaMoneda AS MonedaIngresada;
            RETURN;
        END

        -- PASO 5: Validar relación entre moneda y país

        DECLARE @PrefixEsperado VARCHAR(10);

        SET @PrefixEsperado = CASE @NuevaMoneda
                                WHEN N'GTQ' THEN '+502'
                                WHEN N'USD' THEN '+503'
                                WHEN N'HNL' THEN '+504'
                              END;

        IF @PrefixCallingCode <> @PrefixEsperado
        BEGIN
            SELECT
                'Error' AS Estado,
                'La moneda no corresponde al país del usuario.' AS Mensaje,
                @PrefixCallingCode AS PrefixActual,
                @PrefixEsperado    AS PrefixRequerido;
            RETURN;
        END

        -- PASO 6: Aplicar el cambio en RegisterUser

        UPDATE dbo.RegisterUser
        SET
            UsrCurrency     = @NuevaMoneda,
            UsrTokenUpdated = @TokenUpdated,
            UsrDateUpdated  = @DateUpdated
        WHERE UsrIdUser = @UsrIdUser;

        -- PASO 7: Resultado final

        SELECT
            'Éxito' AS Estado,
            'Moneda actualizada correctamente.' AS Mensaje,
            @MonedaActual AS Moneda_Anterior,
            @NuevaMoneda  AS Moneda_Actual,
            @UsrIdUser    AS RegisterUser;

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
GO

/*
================================================================================
EJEMPLO DE EJECUCIÓN
================================================================================
EXEC dbo.Support_UpdateUserCurrency
     @UsrIdUser    = 73872,
     @NuevaMoneda  = N'GTQ',
     @TokenUpdated = N'SYS-IGONZALEZ',
     @DateUpdated  = GETDATE();
================================================================================
*/
