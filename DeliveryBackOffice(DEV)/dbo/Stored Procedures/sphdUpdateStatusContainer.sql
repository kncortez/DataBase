-- =============================================  
-- Author:		<Brandon, Pedroza>  
-- Create date: <2025-01-13>  
-- Description: <Contenerizacion guias - Actualiza estado de contenedor contenedor>  
-- =============================================  
CREATE PROCEDURE [dbo].[sphdUpdateStatusContainer]
    @ReferenceContainer NVARCHAR(50),
    @IdCustomer NVARCHAR(5)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @IdContainerLiquid INT;
BEGIN TRY
    SET @IdContainerLiquid = (SELECT IdCatStatus FROM CatShipContainerStatus WITH(NOLOCK) WHERE [Name] = 'Liquidado');
        
        
    UPDATE ShippingContainer
    SET IdStatusContainer = @IdContainerLiquid,
        UserUpdated = 'SYS-PICKUPLIQUID',
        DateUpdated = GETDATE(),
        TokenUpdated = 'SYS-PICKUPLIQUID'
    WHERE ReferenceContainer = @ReferenceContainer AND IdCustomer = @IdCustomer
		AND RowStatus = 1;
        
    -- Verifica si se actualizó algún registro
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('No se encontró ningún contenedor con los parámetros proporcionados.', 16, 1);
    END
        
    SELECT 200 AS StatusCode, 'Contenedor actualizado correctamente' AS [Description];
END TRY
BEGIN CATCH
    SELECT  0 AS StatusCode,
			'Error al actualizar estado de contenedor' AS [Description],
			ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
END;