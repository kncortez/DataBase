/*
================================================================================
FECHA DE CREACIÓN: 2025-11-28
AUTOR: IGONZALEZ
================================================================================*/

CREATE PROCEDURE dbo.Support_UpdateDumpServiceCoverage
(
    @RowStatus TINYINT,
    @TokenUpdated VARCHAR(100),
    @DateUpdated DATETIME,
    @IdsSettlement VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

         
        -- PASO 1: Convertir CSV de IdSettlement en tabla temporal
         
        DECLARE @Poblados TABLE (IdSettlement INT);

        INSERT INTO @Poblados (IdSettlement)
        SELECT value
        FROM STRING_SPLIT(@IdsSettlement, ',')
        WHERE TRIM(value) <> '';


         
        -- PASO 2: Validar existencia de IdSettlement
         
        IF EXISTS (
            SELECT P.IdSettlement
            FROM @Poblados P
            LEFT JOIN DumpServiceCoverage DSC ON P.IdSettlement = DSC.IdSettlement
            WHERE DSC.IdSettlement IS NULL
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                CONCAT('El IdSettlement ', P.IdSettlement, ' no existe. No se realizó el UPDATE.') AS Mensaje
            FROM @Poblados P
            LEFT JOIN DumpServiceCoverage DSC ON P.IdSettlement = DSC.IdSettlement
            WHERE DSC.IdSettlement IS NULL;

            RETURN;
        END


         
        -- PASO 3: Consulta BEFORE UPDATE
         
        SELECT
            'ANTES' AS Estado,
            DSC.IdSettlement,
            DSC.RowStatus AS RowStatus_Anterior
        FROM DumpServiceCoverage DSC WITH (NOLOCK)
        INNER JOIN @Poblados P ON P.IdSettlement = DSC.IdSettlement;


         
        -- PASO 4: UPDATE de RowStatus + Auditoría
         
        UPDATE DSC
        SET 
            DSC.RowStatus = @RowStatus,
            DSC.TokenUpdated = @TokenUpdated,
            DSC.DateUpdated = @DateUpdated
        FROM DumpServiceCoverage DSC
        INNER JOIN @Poblados P ON P.IdSettlement = DSC.IdSettlement;


         
        -- PASO 5: Consulta AFTER UPDATE
         
        SELECT
            'DESPUÉS' AS Estado,
            DSC.IdSettlement,
            DSC.RowStatus AS RowStatus_Nuevo
        FROM DumpServiceCoverage DSC WITH (NOLOCK)
        INNER JOIN @Poblados P ON P.IdSettlement = DSC.IdSettlement;

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
     @RowStatus = 0,   -- 0 = deshabilitar poblado, 1 = habilitar poblado
     @TokenUpdated = 'SYS-IGONZALEZ',
     @DateUpdated = GETDATE(),
     @IdsSettlement = '2469,2566,3562,9999';  -- 9999 no existe para probar error
================================================================================

HISTORIAL DE CAMBIOS:
    • 2025-11-28  Primera versión del procedimiento.
    • 2025-11-28  Se agregó auditoría y consultas Before/After del update.
    • 2025-12-12  Se agregó validación de existencia de IdSettlement y TRY-CATCH de errores.
================================================================================
*/