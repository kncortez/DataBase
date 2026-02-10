/* =================================================
   SP:        dbo.Support_CreateCommercialSegment
   Propósito: Crear un nuevo segmento comercial y canal de venta asociado.
   Autor:     IGONZALEZ
   Historia:  FDAPI-5315
   Fecha:     2026-01-02
============================================
=== CHANGELOG ================================
2026-01-02 | Historia/épica: FDAPI-5315 | Autor: IGONZALEZ |

=========================================== */

CREATE PROCEDURE dbo.Support_CreateCommercialSegment
(
    @SegmentName        VARCHAR(100),  
    @SegmentDescription VARCHAR(200),  
    @TokenCreated       VARCHAR(100),  
    @DateCreated        DATETIME       
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validaciones básicas de entrada

        IF ISNULL(@SegmentName, '') = ''
        BEGIN
            SELECT
                'Error' AS Estado,
                'El nombre del segmento es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@SegmentDescription, '') = ''
        BEGIN
            SELECT
                'Error' AS Estado,
                'La descripcion del segmento es obligatoria.' AS Mensaje;
            RETURN;
        END

        IF ISNULL(@TokenCreated, '') = ''
        BEGIN
            SELECT
                'Error' AS Estado,
                'El TokenCreated es obligatorio.' AS Mensaje;
            RETURN;
        END



        -- PASO 2: Validar no existencia previa en CatSalesChannel

        IF EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatSalesChannel WITH (NOLOCK)
            WHERE [Description] = @SegmentName
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El segmento ya existe en CatSalesChannel.' AS Mensaje,
                @SegmentName AS Segmento;
            RETURN;
        END



        -- PASO 3: Validar no existencia previa en CatCommercialSegment

        IF EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatCommercialSegment WITH (NOLOCK)
            WHERE CommercialSegmentName = @SegmentName
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El segmento ya existe en CatCommercialSegment.' AS Mensaje,
                @SegmentName AS Segmento;
            RETURN;
        END



        -- PASO 4: Insert en CatSalesChannel

        INSERT INTO DeliveryBackOffice.dbo.CatSalesChannel
        (
            [Description],
            TokenCreated,
            DateCreated,
            TokenUpdated,
            DateUpdated,
            RowStatus
        )
        VALUES
        (
            @SegmentName,
            @TokenCreated,
            @DateCreated,
            NULL,
            NULL,
            1
        );



        -- PASO 5: Insert en CatCommercialSegment

        INSERT INTO DeliveryBackOffice.dbo.CatCommercialSegment
        (
            CommercialSegmentName,
            CommercialSegmentDescription,
            RowStatus,
            TokenCreated,
            DateCreated,
            TokenUpdated,
            DateUpdated
        )
        VALUES
        (
            @SegmentName,
            @SegmentDescription,
            1,
            @TokenCreated,
            @DateCreated,
            NULL,
            NULL
        );



        -- PASO 6: Respuesta final

        SELECT
            'Exito' AS Estado,
            'El segmento comercial fue creado correctamente en ambos catalogos.' AS Mensaje,
            @SegmentName AS SegmentoCreado,
            @SegmentDescription AS Descripcion,
            @TokenCreated AS UsuarioCreacion,
            @DateCreated AS FechaCreacion;

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