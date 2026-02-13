/* =================================================
   SP:        dbo.Support_ToggleCommercialSegment
   Propósito: Habilitar o deshabilitar lógicamente un segmento comercial existente.
   Autor:     IGONZALEZ
   Historia:  FDAPI-5316
   Fecha:     2026-01-02
============================================
=== CHANGELOG ================================
2026-01-02 | Historia/épica: FDAPI-5316 | Autor: IGONZALEZ |

=========================================== */
CREATE PROCEDURE dbo.Support_ToggleCommercialSegment
(
    @IdCommercialSegment INT, 
    @IdSalesChannel      INT, 
    @RowStatus           BIT, 
    @TokenUpdated        VARCHAR(100),
    @DateUpdated         DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validaciones básicas

        IF @RowStatus NOT IN (0,1)
        BEGIN
            SELECT
                'Error' AS Estado,
                'El valor de RowStatus solo puede ser 0 (Inactivo) o 1 (Activo).' AS Mensaje,
                @RowStatus AS RowStatusIngresado;
            RETURN;
        END

        IF ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT
                'Error' AS Estado,
                'El TokenUpdated es obligatorio.' AS Mensaje;
            RETURN;
        END


        -- PASO 2: Validar existencia en CatCommercialSegment

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatCommercialSegment WITH (NOLOCK)
            WHERE IdCommercialSegment = @IdCommercialSegment
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdCommercialSegment no existe.' AS Mensaje,
                @IdCommercialSegment AS IdCommercialSegment;
            RETURN;
        END


        -- PASO 3: Validar existencia en CatSalesChannel

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatSalesChannel WITH (NOLOCK)
            WHERE IdSalesChannel = @IdSalesChannel
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdSalesChannel no existe.' AS Mensaje,
                @IdSalesChannel AS IdSalesChannel;
            RETURN;
        END


        -- PASO 4: Capturar valores actuales (ANTES)

        DECLARE 
            @PrevRowStatusCommercial TINYINT,
            @PrevRowStatusSales      TINYINT,
            @SegmentName             VARCHAR(100),
            @SalesChannelDesc        VARCHAR(100);

        SELECT
            @PrevRowStatusCommercial = RowStatus,
            @SegmentName             = CommercialSegmentName
        FROM DeliveryBackOffice.dbo.CatCommercialSegment WITH (NOLOCK)
        WHERE IdCommercialSegment = @IdCommercialSegment;

        SELECT
            @PrevRowStatusSales = RowStatus,
            @SalesChannelDesc   = [Description]
        FROM DeliveryBackOffice.dbo.CatSalesChannel WITH (NOLOCK)
        WHERE IdSalesChannel = @IdSalesChannel;


        -- PASO 5: Actualizar CatCommercialSegment

        UPDATE DeliveryBackOffice.dbo.CatCommercialSegment
        SET 
            RowStatus    = @RowStatus,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = @DateUpdated
        WHERE IdCommercialSegment = @IdCommercialSegment;


        -- PASO 6: Actualizar CatSalesChannel

        UPDATE DeliveryBackOffice.dbo.CatSalesChannel
        SET 
            RowStatus    = @RowStatus,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = @DateUpdated
        WHERE IdSalesChannel = @IdSalesChannel;


        -- PASO 7: Respuesta final (ANTES / DESPUÉS)

        SELECT
            'Exito' AS Estado,
            'El segmento comercial fue actualizado correctamente.' AS Mensaje,

            -- CatCommercialSegment
            @IdCommercialSegment AS IdCommercialSegment,
            @SegmentName AS CommercialSegment,
            @PrevRowStatusCommercial AS Commercial_RowStatus_Anterior,
            @RowStatus AS Commercial_RowStatus_Nuevo,

            -- CatSalesChannel
            @IdSalesChannel AS IdSalesChannel,
            @SalesChannelDesc AS SalesChannel,
            @PrevRowStatusSales AS Sales_RowStatus_Anterior,
            @RowStatus AS Sales_RowStatus_Nuevo,

            @TokenUpdated AS UsuarioActualizacion,
            @DateUpdated AS FechaActualizacion;

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
GO