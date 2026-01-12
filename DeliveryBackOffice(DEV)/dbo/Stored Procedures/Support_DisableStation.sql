/*
================================================================================
FECHA DE CREACIÓN: 2025-11-13
AUTOR: IGONZALEZ
================================================================================
*/

CREATE PROCEDURE dbo.Support_DisableStation
    @IdStation INT,
    @TokenUpdated VARCHAR(50),                         
    @DateUpdated DATETIME                              
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        
        -- PASO 1: Validar existencia de la estación
        
        IF NOT EXISTS (
            SELECT TOP 1
            FROM dbo.CatStation WITH (NOLOCK)
            WHERE IdStation = @IdStation
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'No fue posible realizar el cambio: no se encontró la estación.' AS Mensaje,
                @IdStation AS IdStation;
            RETURN;
        END

        
        -- PASO 2: Obtener CodeOfReference
        
        DECLARE @CodeOfReference INT;

        SELECT TOP 1 
            @CodeOfReference = CodeOfReference
        FROM dbo.CatStation WITH (NOLOCK)
        WHERE IdStation = @IdStation;

        
        -- PASO 3: Obtener VisitPointClient asociado
        
        DECLARE @IdVisitPointClient INT;

        SELECT TOP 1
            @IdVisitPointClient = IdVisitPointClient
        FROM dbo.VisitPointClient WITH (NOLOCK)
        WHERE CodeOfReference = @CodeOfReference;

        IF @IdVisitPointClient IS NULL
        BEGIN
            SELECT 
                'Error' AS Estado,
                'No fue posible realizar el cambio: no se encontró relación con VisitPointClient.' AS Mensaje,
                @IdStation AS IdStation;
            RETURN;
        END

        
        -- PASO 4: Deshabilitar estación
        
        UPDATE dbo.CatStation
        SET 
            RowStatus = 0,
            TokenUpdated = @TokenUpdated,
            DateUpdated = @DateUpdated
        WHERE IdStation = @IdStation;

        
        -- PASO 5: Deshabilitar VisitPointClient asociado
        
        UPDATE dbo.VisitPointClient
        SET 
            StatusClient = 0,
            TokenUpdated = @TokenUpdated,
            DateUpdated = @DateUpdated
        WHERE IdVisitPointClient = @IdVisitPointClient;

        
        -- Mensaje de éxito
        
        SELECT 
            'Éxito' AS Estado,
            'Actualización realizada correctamente.' AS Mensaje,
            @IdStation AS IdStation_Afectada,
            @IdVisitPointClient AS IdVisitPointClient_Afectado;

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
EXEC dbo.Support_DisableStation
     @IdStation = 125,
     @TokenUpdated = 'SYS-IGONZALEZ',
     @DateUpdated = GETDATE();
================================================================================
HISTORIAL DE CAMBIOS:
    - 2025-11-13: Primera versión documentada.
    - 2025-11-21: Se agregan parámetros @TokenUpdated y @DateUpdated.
================================================================================
*/
