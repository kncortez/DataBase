/* =================================================
   SP:        [dbo].[spws_get_guide_route_reassignment]
   Propósito: Consulta la ruta reasignada de una guía
              desde Linehaul.
   Autor:     Pedro Macajol
   Historia:  FDAPI-6344
   Fecha:     26-05-2026
===== CHANGELOG ============================
    Fecha       Historia        Descripción                                  Autor
    ----------  --------------  ------------------------------------------  ----------
    2026-05-26  FDAPI-6344      Creación del SP de consulta de reasignación  Pedro Macajol
=========================================== */
CREATE PROCEDURE [dbo].[spws_get_guide_route_reassignment]
    @IdCountry VARCHAR(2),
    @NoGuia    NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        -- ── SANITIZACIÓN ──────────────────────────────────────────
        SET @NoGuia    = LTRIM(RTRIM(@NoGuia));
        SET @IdCountry = LTRIM(RTRIM(@IdCountry));

        -- ── VALIDACIÓN: @NoGuia vacío ─────────────────────────────
        IF ISNULL(@NoGuia, '') = ''
        BEGIN
            SELECT 
                '400'                                      AS StatusCode,
                N'Debe ingresar un número de guía válido'  AS [Message],
                NULL                                       AS NoGuia,
                NULL                                       AS RouteCode;
            RETURN;
        END;

        -- ── VALIDACIÓN: @IdCountry vacío ──────────────────────────
        IF ISNULL(@IdCountry, '') = ''
        BEGIN
            SELECT 
                '400'                           AS StatusCode,
                N'Debe ingresar un país válido'  AS [Message],
                NULL                            AS NoGuia,
                NULL                            AS RouteCode;
            RETURN;
        END;

        -- ── VALIDACIÓN: formato ^FD[A-Za-z]*\d+$ ──────────────────
        DECLARE @isValidFormat BIT          = 1;
        DECLARE @suffix        NVARCHAR(48) = SUBSTRING(@NoGuia, 3, LEN(@NoGuia));
        DECLARE @firstDigitPos INT          = PATINDEX('%[0-9]%', @suffix);

        -- Debe empezar con "FD"
        IF LEFT(@NoGuia, 2) <> N'FD'
            SET @isValidFormat = 0;

        -- Después de "FD" debe existir al menos un dígito
        ELSE IF @firstDigitPos = 0
            SET @isValidFormat = 0;

        -- La parte alfabética opcional no puede contener caracteres inválidos
        ELSE IF @firstDigitPos > 1
             AND PATINDEX('%[^A-Za-z]%', LEFT(@suffix, @firstDigitPos - 1)) > 0
            SET @isValidFormat = 0;

        -- El sufijo numérico no puede contener caracteres no numéricos
        ELSE IF PATINDEX('%[^0-9]%', SUBSTRING(@suffix, @firstDigitPos, LEN(@suffix))) > 0
            SET @isValidFormat = 0;

        IF @isValidFormat = 0
        BEGIN
            SELECT 
                '400'                       AS StatusCode,
                N'Formato de guía inválido' AS [Message],
                NULL                        AS NoGuia,
                NULL                        AS RouteCode;
            RETURN;
        END;

        SELECT TOP 1
            '200'                              AS StatusCode,
            N'Consulta realizada correctamente' AS [Message],
            NoGuia,
            RouteCode
        FROM dbo.GuideRouteReassignment WITH (NOLOCK)
        WHERE NoGuia    = @NoGuia
          AND IdCountry = @IdCountry
          AND RowStatus = 1
        ORDER BY DateCreated DESC;

        -- ── 404 explícito cuando no hay coincidencia ──────────────
        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 
                '404'                              AS StatusCode,
                N'La guía no tiene ruta reasignada' AS [Message],
                @NoGuia                            AS NoGuia,
                NULL                               AS RouteCode;
        END;

    END TRY
    BEGIN CATCH
        
        THROW;
    END CATCH
END;
GO