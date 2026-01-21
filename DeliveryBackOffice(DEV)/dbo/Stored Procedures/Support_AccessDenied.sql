/* =================================================
   SP:        dbo.Support_AccessDenied
   Propósito: Corregir configuración cuando presenta “Acceso Denegado”.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5390
   Fecha:     2026-01-17
============================================
=== CHANGELOG ================================
2026-01-17 | Historia: FDAPI-5390 | Autor: IRVIN GONZALEZ |

=========================================== */

CREATE PROCEDURE dbo.Support_AccessDenied
(
    @IdUser       NVARCHAR(100),
    @IdStation    INT,
    @IdCountry    NVARCHAR(5)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validaciones básicas de entrada

IF NULLIF(LTRIM(RTRIM(@IdUser)), '') IS NULL
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdUser es obligatorio.' AS Mensaje;
            RETURN;
        END
        
        IF NULLIF(LTRIM(RTRIM(@IdCountry)), '') IS NULL
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdCountry es obligatorio.' AS Mensaje;
            RETURN;
        END
        
        IF @IdStation IS NULL
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdStation es obligatorio.' AS Mensaje;
            RETURN;
        END


        -- PASO 2: Validar existencia del usuario en LGN_RolByUserByRegion

        IF NOT EXISTS (
            SELECT 1
            FROM [DenariusUser_Dev].[dbo].[LGN_RolByUserByRegion] WITH (NOLOCK)
            WHERE RUR_IdUser = @IdUser
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdUser no existe en LGN_RolByUserByRegion.' AS Mensaje,
                @IdUser AS IdUser;
            RETURN;
        END


        -- PASO 3: Capturar valores actuales (ANTES del UPDATE)

        DECLARE 
            @OldIdStation INT,
            @OldIdCountry NVARCHAR(5);

        SELECT
            @OldIdStation = RUR_IdStation,
            @OldIdCountry = RUR_IdCountry
        FROM [DenariusUser_Dev].[dbo].[LGN_RolByUserByRegion] WITH (NOLOCK)
        WHERE RUR_IdUser = @IdUser;


        -- PASO 4: Actualizar configuración de acceso

        UPDATE [DenariusUser_Dev].[dbo].[LGN_RolByUserByRegion]
        SET 
            RUR_IdStation = @IdStation,
            RUR_IdCountry = @IdCountry
        WHERE RUR_IdUser = @IdUser;


        -- PASO 5: Respuesta final (ANTES y DESPUÉS)

        SELECT
            'Exito' AS Estado,
            'La configuración de acceso fue actualizada correctamente.' AS Mensaje,
            @IdUser        AS IdUser,
            @OldIdStation  AS IdStationAnterior,
            @IdStation     AS IdStationNuevo,
            @OldIdCountry  AS CountryAnterior,
            @IdCountry     AS CountryNuevo;

    END TRY


    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            'Ocurrio un error durante la ejecucion del procedimiento.' AS Mensaje,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE() AS ErrorLinea;

        THROW;

    END CATCH

END
GO