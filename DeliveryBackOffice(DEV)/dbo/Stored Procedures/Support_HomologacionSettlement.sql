/* =================================================
   SP:        DeliveryBackOffice.dbo.Support_HomologacionSettlement
   Propósito: Homologar un poblado actualizando el ID de Ultra Entregas.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5528
   Fecha:     2026-02-06
=========================================== */

CREATE PROCEDURE dbo.Support_HomologacionSettlement
(
    @SettlementForzaId BIGINT,          
    @SettlementUEId    BIGINT,          
    @TokenUpdated      NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validaciones básicas

        IF @SettlementForzaId IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'SettlementForzaId es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @SettlementUEId IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'SettlementUEId es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @TokenUpdated IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'TokenUpdated es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia del SettlementForzaId

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.SettlementMapping WITH (NOLOCK)
            WHERE SettlementForzaId = @SettlementForzaId
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El SettlementForzaId indicado no existe en SettlementMapping.' AS Mensaje,
                @SettlementForzaId AS SettlementForzaId;
            RETURN;
        END


        -- PASO 3: Captura de valores ANTES

        DECLARE 
            @SettlementUEId_Before INT,
            @SettlementUEId_After  INT;

        SELECT 
            @SettlementUEId_Before = SettlementUEId
        FROM DeliveryBackOffice.dbo.SettlementMapping WITH (NOLOCK)
        WHERE SettlementForzaId = @SettlementForzaId;


        -- PASO 4: Actualización

        UPDATE DeliveryBackOffice.dbo.SettlementMapping
        SET 
            SettlementUEId = @SettlementUEId,
            TokenUpdated   = @TokenUpdated,
            DateUpdated    = GETDATE()
        WHERE SettlementForzaId = @SettlementForzaId;


        -- PASO 5: Captura de valores DESPUÉS

        SELECT 
            @SettlementUEId_After = SettlementUEId
        FROM DeliveryBackOffice.dbo.SettlementMapping WITH (NOLOCK)
        WHERE SettlementForzaId = @SettlementForzaId;


        -- PASO 6: Resultado final (ANTES / DESPUÉS)

        SELECT 
            'Exito' AS Estado,
            'La homologación del poblado fue realizada correctamente.' AS Mensaje,
            sm.SettlementForzaId     AS SettlementForzaId,
            p.ProvinceName           AS Departamento,
            t.TownshipName           AS Municipio,
            s.Settlement             AS Poblado,
            @SettlementUEId_Before   AS SettlementUEId_Anterior,
            @SettlementUEId_After    AS SettlementUEId_Actual,
            @TokenUpdated            AS TokenUpdated,
            sm.DateUpdated           AS DateUpdated
        FROM DeliveryBackOffice.dbo.SettlementMapping sm WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.Settlement s WITH (NOLOCK)
            ON sm.SettlementForzaId = s.IdSettlement
        INNER JOIN DeliveryBackOffice.dbo.Township t WITH (NOLOCK)
            ON s.IdTownship = t.IdTownship
        INNER JOIN DeliveryBackOffice.dbo.Province p WITH (NOLOCK)
            ON s.IdProvince = p.IdProvince
        WHERE sm.SettlementForzaId = @SettlementForzaId;

    END TRY


    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            'Ocurrio un error durante la ejecucion del procedimiento.' AS Mensaje,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE() AS ErrorLinea;

        THROW;

    END CATCH
END