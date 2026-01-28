/* =================================================
   SP:        dbo.Support_DisableStation
   Propósito: Deshabilitar una estación
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5094
   Fecha:     2025-11-13
============================================
============== CHANGELOG ===================
2025-11-13 | Historia: FDAPI-5094 | Autor: IRVIN GONZALEZ |

================================================= */
CREATE PROCEDURE dbo.Support_DisableStation
    @IdStation INT,
    @TokenUpdated NVARCHAR(100),                         
    @DateUpdated DATETIME                              
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TranStarted BIT = 0;
    
    BEGIN TRY
        -- Iniciar transacción
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @TranStarted = 1;
        END
        
        -- PASO 1: Validar existencia de la estación
        IF NOT EXISTS (
            SELECT TOP 1 1
            FROM dbo.CatStation WITH (NOLOCK)
            WHERE IdStation = @IdStation
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'No fue posible realizar el cambio: no se encontró la estación.' AS Mensaje,
                @IdStation AS IdStation;
            
            -- Rollback si iniciamos la transacción
            IF @TranStarted = 1
                ROLLBACK TRANSACTION;
            
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
            
            -- Rollback si iniciamos la transacción
            IF @TranStarted = 1
                ROLLBACK TRANSACTION;
            
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
        
        -- Confirmar transacción si todo fue exitoso
        IF @TranStarted = 1
            COMMIT TRANSACTION;
        
        -- Mensaje de éxito
        SELECT 
            'Éxito' AS Estado,
            'Actualización realizada correctamente.' AS Mensaje,
            @IdStation AS IdStation_Afectada,
            @IdVisitPointClient AS IdVisitPointClient_Afectado;
            
    END TRY
    BEGIN CATCH
        -- Revertir transacción en caso de error
        IF @TranStarted = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
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
     @TokenUpdated = N'SYS-IGONZALEZ',
     @DateUpdated = GETDATE();
================================================================================
*/