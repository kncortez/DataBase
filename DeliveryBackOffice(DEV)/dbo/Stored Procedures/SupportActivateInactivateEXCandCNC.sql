CREATE PROCEDURE SupportActivateInactivateEXCandCNC
    @CodeOfReference INT,
    @RowStatus INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- VERIFICAR QUE EL POBLADO EXISTE
        IF NOT EXISTS 
        (
            SELECT TOP 1 1
            FROM dbo.VisitPointClient WITH(NOLOCK)
            WHERE CodeOfReference = @CodeOfReference
        )
        BEGIN
            RAISERROR('No se encontró EXC O CNC', 16, 1);
            RETURN;
        END;
        
        -- Activar o desactivar en la Settlement
        UPDATE VisitPointClient 
        SET StatusClient = @RowStatus 
        WHERE CodeOfReference = @CodeOfReference;
        
        -- Activar o desactivar en DumpServiceCoverage
        UPDATE CatStation
        SET RowStatus = @RowStatus
        WHERE CodeOfReference = @CodeOfReference;
        
        -- Confirmar la transacción
        COMMIT TRANSACTION;
        
        -- Mostrar valores actualizados
        SELECT 'VisitPointClient ACTUALIZADO' AS Descripcion, 
               CodeOfReference,
			   DescriptionOfClient,
               StatusClient 
        FROM VisitPointClient WITH(NOLOCK) 
        WHERE CodeOfReference = @CodeOfReference;
        
        SELECT 'CatStation ACTUALIZADO' AS Descripcion, 
               CodeOfReference, 
			   StationName,
               RowStatus 
        FROM CatStation WITH(NOLOCK) 
        WHERE CodeOfReference = @CodeOfReference;
        
    END TRY
    BEGIN CATCH
        -- Si hay un error, revertir la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Mostrar el mensaje de error
        SELECT ERROR_MESSAGE() AS RESPUESTA,
               ERROR_NUMBER() AS ErrorNumber,
               ERROR_SEVERITY() AS ErrorSeverity,
               ERROR_STATE() AS ErrorState;
    END CATCH
END;