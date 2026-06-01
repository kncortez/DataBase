/* =================================================
   SP:        dbo.Support_UpdateUserCurrency
   Propósito: Actualizar la moneda asociada a un usuario validando estado y país.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5210
   Fecha:     2025-11-28
=========================================== */

CREATE PROCEDURE [dbo].[Support_UpdateUserCurrency]
(
    @UsrIdUser      INT,
    @NuevaMoneda    NVARCHAR(10),
    @TokenUpdated   NVARCHAR(50)
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


        -- PASO 2: Obtener datos actuales del usuario + Nacionalidad

        DECLARE
            @RowStatus        BIT,
            @MonedaActual     NVARCHAR(10),
            @Nationality      NVARCHAR(10),
            @NationalityEsperada NVARCHAR(10);

        SELECT
            @RowStatus    = r.UsrRowStatus,
            @MonedaActual = r.UsrCurrency,
            @Nationality  = p.PerNationality
        FROM dbo.RegisterUser r WITH (NOLOCK)
        INNER JOIN dbo.Person p WITH (NOLOCK)
            ON p.PerIdPerson = r.UsrIdPerson
        WHERE r.UsrIdUser = @UsrIdUser;


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


        -- PASO 5: Validar relación entre moneda y nacionalidad

        SET @NationalityEsperada = CASE @NuevaMoneda
                                      WHEN N'GTQ' THEN N'GT'
                                      WHEN N'USD' THEN N'SV'
                                      WHEN N'HNL' THEN N'HN'
                                   END;

        IF @Nationality <> @NationalityEsperada
        BEGIN
            SELECT
                'Error' AS Estado,
                'La moneda no corresponde a la nacionalidad del usuario.' AS Mensaje,
                @Nationality          AS NacionalidadActual,
                @NationalityEsperada  AS NacionalidadRequerida;
            RETURN;
        END


        -- PASO 6: Aplicar el cambio en RegisterUser

        UPDATE dbo.RegisterUser
        SET
            UsrCurrency     = @NuevaMoneda,
            UsrTokenUpdated = @TokenUpdated,
            UsrDateUpdated  = GETDATE()
        WHERE UsrIdUser = @UsrIdUser;


        -- PASO 7: Resultado final

        SELECT
            N'Éxito' AS Estado,
            N'Moneda actualizada correctamente.' AS Mensaje,
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