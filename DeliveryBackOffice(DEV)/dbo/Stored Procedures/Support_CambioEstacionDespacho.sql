/* =================================================
   SP:        dbo.Support_CambioEstacionDespacho
   Propósito: Actualizar la estación de despacho y liquidación de un manifiesto.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5302
   Fecha:     2025-12-19
=========================================== */

CREATE PROCEDURE dbo.Support_CambioEstacionDespacho
    @ManifiestoId INT,              -- Id del manifiesto en DeliveryOrderBySettlement
    @NuevaEstacionId INT           -- Id de la nueva estación (para ambos campos)
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

        -- PASO 2: Validar existencia de la nueva estación
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatStation WITH (NOLOCK)
            WHERE IdStation = @NuevaEstacionId
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'La estación no existe.' AS Mensaje,
                @NuevaEstacionId AS NuevaEstacionId;
            RETURN;
        END

        -- PASO 3: Obtener estaciones y países
        DECLARE 
            @DispatchedStationIdAntes INT,
            @SettlementStationIdAntes INT,
            @PaisActual INT,
            @PaisNueva  INT;

        SELECT TOP 1
            @DispatchedStationIdAntes = DispatchedStationId,
            @SettlementStationIdAntes = SettlementStationId
        FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement WITH (NOLOCK)
        WHERE Id = @ManifiestoId;

        -- País de la estación actual
        SELECT 
            @PaisActual = CountryId
        FROM DeliveryBackOffice.dbo.CatStation WITH (NOLOCK)
        WHERE IdStation = @DispatchedStationIdAntes;

        -- País de la nueva estación
        SELECT 
            @PaisNueva = CountryId
        FROM DeliveryBackOffice.dbo.CatStation WITH (NOLOCK)
        WHERE IdStation = @NuevaEstacionId;
        IF @PaisActual <> @PaisNueva
        BEGIN
            SELECT 
                'Error' AS Estado,
                'No es permitido cambiar a un país distinto' AS Mensaje,
                @PaisActual AS PaisActual,
                @PaisNueva  AS PaisDestino;
            RETURN;
        END

        -- PASO 4: Actualizar estación de despacho y liquidación
        
        UPDATE DeliveryBackOffice.dbo.DeliveryOrderBySettlement
        SET 
            DispatchedStationId = @NuevaEstacionId,
            SettlementStationId = @NuevaEstacionId
        WHERE Id = @ManifiestoId;

        
        SELECT 
            'Éxito' AS Estado,
            'El cambio de estación fue aplicado con éxito.' AS Mensaje,
            @ManifiestoId             AS ManifiestoId,
            @DispatchedStationIdAntes AS DispatchedStationId_Antes,
            @NuevaEstacionId          AS DispatchedStationId_Despues,
            @SettlementStationIdAntes AS SettlementStationId_Antes,
            @NuevaEstacionId          AS SettlementStationId_Despues;

    END TRY

    BEGIN CATCH
    SELECT 
            'Error' AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;
            
        THROW;

    END CATCH
END
GO