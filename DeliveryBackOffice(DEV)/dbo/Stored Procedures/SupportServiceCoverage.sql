-- =============================================
-- Author:		<Kevin,Oliva>
-- Create date: <2026-02-17>
-- Description:	<Administracion de Poblados >
-- ===========================================

CREATE PROCEDURE SupportServiceCoverage
    @IdSettlement INT,
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
            FROM DeliveryBackOffice.dbo.Settlement WITH(NOLOCK)
            WHERE IdSettlement = @IdSettlement
        )
        BEGIN
            RAISERROR('No se encontró poblado', 16, 1);
            RETURN;
        END;
        
        -- Activar o desactivar en la Settlement
        UPDATE DeliveryBackOffice.dbo.Settlement 
        SET SettlementSatus = @RowStatus 
        WHERE IdSettlement = @IdSettlement;
        
        -- Activar o desactivar en DumpServiceCoverage
        UPDATE DeliveryBackOffice.dbo.DumpServiceCoverage
        SET RowStatus = @RowStatus
        WHERE IdSettlement = @IdSettlement;
        
        -- Confirmar la transacción
        COMMIT TRANSACTION;
        
        -- Mostrar valores actualizados
        SELECT 'Settlement ACTUALIZADO' AS Descripcion, 
               IdSettlement, 
               SettlementSatus 
        FROM DeliveryBackOffice.dbo.Settlement WITH(NOLOCK) 
        WHERE IdSettlement = @IdSettlement;
        
        SELECT 'DumpServiceCoverage ACTUALIZADO' AS Descripcion, 
               IdSettlement, 
               RowStatus 
        FROM DeliveryBackOffice.dbo.DumpServiceCoverage WITH(NOLOCK) 
        WHERE IdSettlement = @IdSettlement;
        
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