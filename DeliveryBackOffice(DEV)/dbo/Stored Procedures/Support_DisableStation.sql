/* =================================================
   SP:        dbo.Support_DisableStation
   Propósito: Deshabilitar una estación
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5094
   Fecha:     2025-11-13
================================================= */
CREATE PROCEDURE dbo.Support_DisableStation
    @IdStation INT,
    @TokenUpdated NVARCHAR(50)                         
    
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TranStarted BIT = 0;
    
    BEGIN TRY

        -- Validar campos obligatorios
        IF @TokenUpdated IS NULL OR LTRIM(RTRIM(@TokenUpdated)) = ''
        BEGIN
            SELECT 
                'Error' AS Estado, 
                'TokenUpdated es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @IdStation IS NULL OR LTRIM(RTRIM(@IdStation)) = ''
        BEGIN
            SELECT 
                'Error' AS Estado, 
                'IdStation es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- Validar existencia de la estación
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
            RETURN;
        END
        -- Iniciar transacción
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @TranStarted = 1;
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
            
            IF @TranStarted = 1
                ROLLBACK TRANSACTION;
            
            RETURN;
        END
        
        -- PASO 4: Deshabilitar estación
        UPDATE dbo.CatStation
        SET 
            RowStatus = 0,
            TokenUpdated = @TokenUpdated,
            DateUpdated = GETDATE()
        WHERE IdStation = @IdStation;
        
        -- PASO 5: Deshabilitar VisitPointClient asociado
        UPDATE dbo.VisitPointClient
        SET 
            StatusClient = 0,
            TokenUpdated = @TokenUpdated,
            DateUpdated = GETDATE()
        WHERE IdVisitPointClient = @IdVisitPointClient;
        
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