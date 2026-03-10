/* =================================================
   SP:        dbo.Support_CambioEstacionDespacho
   Propósito: Actualizar la estación de despacho y liquidación de un manifiesto.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5302
   Fecha:     2025-12-19
=========================================== */

CREATE PROCEDURE dbo.Support_CambioEstacionDespacho
    @ManifiestoId INT,              -- Id del manifiesto en DeliveryOrderBySettlement
    @NuevaEstacionId INT,           -- Id de la nueva estación (para ambos campos)
    @TokenUpdate VARCHAR(50)        -- Token del usuario que realiza el cambio
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        -- PASO 1: Validar existencia del manifiesto
        IF NOT EXISTS (
            SELECT 1 FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement WITH (NOLOCK)
            WHERE Id = @ManifiestoId
        )
        BEGIN
            SELECT 'Error' AS Estado, 'El manifiesto solicitado no existe' AS Mensaje,
            @ManifiestoId AS ManifiestoId;
            RETURN;
        END

        -- PASO 2: Capturar estado anterior
        DECLARE @DispatchedStationIdAntes INT;
        DECLARE @SettlementStationIdAntes INT;

        SELECT TOP 1
            @DispatchedStationIdAntes = DispatchedStationId,
            @SettlementStationIdAntes = SettlementStationId
        FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement WITH (NOLOCK)
        WHERE Id = @ManifiestoId;

        -- PASO 2: Actualizar estación de despacho y liquidación
        
        UPDATE DeliveryBackOffice.dbo.DeliveryOrderBySettlement
        SET 
            DispatchedStationId = @NuevaEstacionId,
            SettlementStationId = @NuevaEstacionId
        WHERE Id = @ManifiestoId;

        -- RESULTADO EXITOSO: Mostrar antes y después
        
        SELECT 
            'Éxito' AS Estado,
            'El cambio de estación fue aplicado con éxito.' AS Mensaje,
            @ManifiestoId AS ManifiestoId,
            @DispatchedStationIdAntes AS DispatchedStationId_Antes,
            @NuevaEstacionId AS DispatchedStationId_Despues,
            @SettlementStationIdAntes AS SettlementStationId_Antes,
            @NuevaEstacionId AS SettlementStationId_Despues;

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