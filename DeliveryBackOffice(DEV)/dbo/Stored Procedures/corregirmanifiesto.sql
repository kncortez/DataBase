
CREATE PROCEDURE corregirmanifiesto
    @NumeroManifiesto BIGINT,
    @CorregirManifiesto NVARCHAR(3)
AS
BEGIN
    DECLARE @UpperCorregirManifiesto NVARCHAR(3) = UPPER(LTRIM(RTRIM(@CorregirManifiesto)))

    BEGIN TRY
        -- Validar si existe el manifiesto
        IF NOT EXISTS (SELECT 1 FROM [dbo].[DeliveryOrderBySettlement] WITH (NOLOCK) WHERE [ID] = @NumeroManifiesto)
        BEGIN
            THROW 50001, 'Manifiesto no existe.', 1
        END

        IF @UpperCorregirManifiesto = 'NO'
        BEGIN
            -- Mostrar datos del manifiesto sin hacer cambios
            SELECT * 
            FROM [dbo].[DeliveryOrderBySettlement] WITH (NOLOCK)
            WHERE [ID] = @NumeroManifiesto
        END
        ELSE IF @UpperCorregirManifiesto = 'SI'
        BEGIN
            -- Actualizar el manifiesto
            UPDATE [dbo].[DeliveryOrderBySettlement]
            SET [User_Received] = [User_Dispatched],
                [Date_Received] = GETDATE(),
                [Pieces_Dry_Received] = [Pieces_Dry_Dispatched],
                [Pieces_Cold_Received] = [Pieces_Cold_Dispatched],
                [Guides_Received] = [Guides_Dispatched],
                [Route_Received] = GETDATE(),
                [SettlementStationId] = [DispatchedStationId]
            WHERE [ID] = @NumeroManifiesto

            -- Confirmar la corrección
            SELECT 'Manifiesto corregido' AS respuesta;
        END
        ELSE
        BEGIN
            -- Error si el valor de @CorregirManifiesto no es válido
            THROW 50002, 'Valor de @CorregirManifiesto no es válido. Debe ser SI o NO.', 1
        END
    END TRY
    BEGIN CATCH
        -- Captura de errores
        SELECT ERROR_MESSAGE() AS respuesta;
    END CATCH
END