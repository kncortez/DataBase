/* =================================================
   SP:        dbo.Support_UpdateCommercialSegmentName
   Propósito: Actualizar el nombre y descripción del segmento comercial y su canal de ventas asociado
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6042
   Fecha:     2026-04-10
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateCommercialSegmentName
(
    @IdCommercialSegment           INT,
    @IdSalesChannel                INT,
    @CommercialSegmentName         NVARCHAR(75),
    @CommercialSegmentDescription  NVARCHAR(200),
    @SalesChannelDescription       NVARCHAR(50),
    @TokenUpdated                  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDACIONES
        IF @IdCommercialSegment IS NULL 
        OR @IdSalesChannel IS NULL
        OR ISNULL(@CommercialSegmentName,'') = ''
        OR ISNULL(@CommercialSegmentDescription,'') = ''
        OR ISNULL(@SalesChannelDescription,'') = ''
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- VALIDAR LONGITUDES (CONTROL EXPLICITO)
        IF LEN(@CommercialSegmentName) > 75
        BEGIN
            SELECT 'Error' AS Estado, 'CommercialSegmentName excede 75 caracteres.' AS Mensaje;
            RETURN;
        END

        IF LEN(@CommercialSegmentDescription) > 200
        BEGIN
            SELECT 'Error' AS Estado, 'CommercialSegmentDescription excede 200 caracteres.' AS Mensaje;
            RETURN;
        END

        IF LEN(@SalesChannelDescription) > 50
        BEGIN
            SELECT 'Error' AS Estado, 'SalesChannel Description excede 50 caracteres.' AS Mensaje;
            RETURN;
        END

        -- VALIDAR EXISTENCIA
        IF NOT EXISTS (
            SELECT 1 FROM DeliveryBackOffice.dbo.CatCommercialSegment WITH(NOLOCK)
            WHERE IdCommercialSegment = @IdCommercialSegment
        )
        BEGIN
            SELECT 'Error' AS Estado, 'El segmento comercial no existe.' AS Mensaje;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1 FROM DeliveryBackOffice.dbo.CatSalesChannel WITH(NOLOCK)
            WHERE IdSalesChannel = @IdSalesChannel
        )
        BEGIN
            SELECT 'Error' AS Estado, 'El canal de ventas no existe.' AS Mensaje;
            RETURN;
        END

        -- CAPTURA ANTES
        DECLARE 
            @PrevSegmentName NVARCHAR(75),
            @PrevSegmentDesc NVARCHAR(200),
            @PrevChannelDesc NVARCHAR(50);

        SELECT 
            @PrevSegmentName = CommercialSegmentName,
            @PrevSegmentDesc = CommercialSegmentDescription
        FROM DeliveryBackOffice.dbo.CatCommercialSegment WITH(NOLOCK)
        WHERE IdCommercialSegment = @IdCommercialSegment;

        SELECT 
            @PrevChannelDesc = Description
        FROM DeliveryBackOffice.dbo.CatSalesChannel WITH(NOLOCK)
        WHERE IdSalesChannel = @IdSalesChannel;

        BEGIN TRAN;

        -- UPDATE SEGMENTO
        UPDATE DeliveryBackOffice.dbo.CatCommercialSegment
        SET 
            CommercialSegmentName           = @CommercialSegmentName,
            CommercialSegmentDescription    = @CommercialSegmentDescription,
            TokenUpdated                    = @TokenUpdated,
            DateUpdated                     = GETDATE()
        WHERE IdCommercialSegment = @IdCommercialSegment;

        -- UPDATE CANAL
        UPDATE DeliveryBackOffice.dbo.CatSalesChannel
        SET 
            Description         = @SalesChannelDescription,
            TokenUpdated        = @TokenUpdated,
            DateUpdated         = GETDATE()
        WHERE IdSalesChannel    = @IdSalesChannel;

        COMMIT;

        -- RESULTADO FINAL
        SELECT 
            'Exito'                         AS Estado,
            @PrevSegmentName                AS SegmentName_ANTES,
            @CommercialSegmentName          AS SegmentName_DESPUES,
            @PrevSegmentDesc                AS SegmentDesc_ANTES,
            @CommercialSegmentDescription   AS SegmentDesc_DESPUES,
            @PrevChannelDesc                AS ChannelDesc_ANTES,
            @SalesChannelDescription        AS ChannelDesc_DESPUES;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK;

        SELECT 
            'Error' AS Estado,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH

END
GO