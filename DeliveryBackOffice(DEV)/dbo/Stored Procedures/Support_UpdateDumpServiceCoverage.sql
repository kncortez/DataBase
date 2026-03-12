/* =================================================
   SP:        dbo.Support_UpdateDumpServiceCoverage
   Propósito: Actualizar el RowStatus de DumpServiceCoverage para los poblados indicados.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5273
   Fecha:     2025-11-28
============================================
=== CHANGELOG ============================
2025-11-28 | Historia/épica: FDAPI-5273 | Autor: IRVIN GONZALEZ |
-----
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateDumpServiceCoverage
(
    @RowStatus     BIT,
    @TokenUpdated  NVARCHAR(100),
    @DateUpdated   DATETIME,
    @IdsSettlement NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Convertir CSV de IdSettlement en tabla temporal
        DECLARE @Poblados TABLE (IdSettlement INT);

        INSERT INTO @Poblados (IdSettlement)
        SELECT TRY_CONVERT(INT, TRIM(value))
        FROM STRING_SPLIT(@IdsSettlement, ',')
        WHERE TRY_CONVERT(INT, TRIM(value)) IS NOT NULL;

        -- Validar que se parseó al menos un ID
        IF NOT EXISTS (SELECT 1 FROM @Poblados)
        BEGIN
            SELECT 'Error' AS Estado, 
                   'No se proporcionaron IDs válidos.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia de IdSettlement
        IF EXISTS (
            SELECT P.IdSettlement
            FROM @Poblados P
            LEFT JOIN [DeliveryBackOffice].[dbo].DumpServiceCoverage DSC
                   ON DSC.IdSettlement = P.IdSettlement
            WHERE DSC.IdSettlement IS NULL
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                STRING_AGG(CAST(P.IdSettlement AS NVARCHAR), ', ') 
                    + ' no existen en DumpServiceCoverage.' AS Mensaje
            FROM @Poblados P
            LEFT JOIN [DeliveryBackOffice].[dbo].DumpServiceCoverage DSC
                   ON DSC.IdSettlement = P.IdSettlement
            WHERE DSC.IdSettlement IS NULL;
            RETURN;
        END


        -- PASO 3: Consulta BEFORE UPDATE
        SELECT
            'ANTES' AS Estado,
            DSC.IdSettlement,
            DSC.RowStatus AS RowStatus_Anterior
        FROM [DeliveryBackOffice].[dbo].DumpServiceCoverage DSC WITH (NOLOCK)
        INNER JOIN @Poblados P
                ON DSC.IdSettlement = P.IdSettlement;


        -- PASO 4: UPDATE de RowStatus + Auditoría
        UPDATE DSC
        SET 
            DSC.RowStatus    = @RowStatus,
            DSC.TokenUpdated = @TokenUpdated,
            DSC.DateUpdated  = @DateUpdated
        FROM [DeliveryBackOffice].[dbo].DumpServiceCoverage DSC
        INNER JOIN @Poblados P
                ON DSC.IdSettlement = P.IdSettlement;


        -- PASO 5: Consulta AFTER UPDATE
        SELECT
            'DESPUÉS' AS Estado,
            DSC.IdSettlement,
            DSC.RowStatus AS RowStatus_Nuevo
        FROM [DeliveryBackOffice].[dbo].DumpServiceCoverage DSC WITH (NOLOCK)
        INNER JOIN @Poblados P
                ON DSC.IdSettlement = P.IdSettlement;

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
EXEC dbo.Support_UpdateDumpServiceCoverage
     @RowStatus     = 0,   -- 0 = deshabilitar poblado, 1 = habilitar poblado
     @TokenUpdated  = N'SYS-IGONZALEZ',
     @DateUpdated   = GETDATE(),
     @IdsSettlement = N'2469,2566,3562';  
================================================================================
*/
