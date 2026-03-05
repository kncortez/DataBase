/* =================================================
   SP:        Support_ValidacionPagoZigi
   Propósito: Validar si una o varias guías fueron pagadas vía ZIGI.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5629
   Fecha:     2026-02-06
=========================================== */
CREATE PROCEDURE Support_ValidacionPagoZigi
(
    @Guides VARCHAR(MAX) 
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- PASO 1: Validar que se hayan enviado guías
        IF @Guides IS NULL OR LTRIM(RTRIM(@Guides)) = ''
        BEGIN
            SELECT 'Error' AS Estado, 'Debe proporcionar al menos una guía.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Parsear la lista de guías en una tabla temporal
        DROP TABLE IF EXISTS #Guides;
        SELECT 
            TRY_CAST(LTRIM(RTRIM(value)) AS INT) AS GuideNumber
        INTO #Guides
        FROM STRING_SPLIT(@Guides, ',')
        WHERE LTRIM(RTRIM(value)) <> '';

        -- PASO 3: Validar que todos los valores sean numéricos
        IF EXISTS (SELECT 1 FROM #Guides WHERE GuideNumber IS NULL)
        BEGIN
            SELECT 'Error' AS Estado, 'Uno o más valores no son números de guía válidos.' AS Mensaje;
            RETURN;
        END

        -- PASO 4: Consulta de pagos ZIGI
        SELECT
            CASE 
                WHEN PZ.ZigiTransactionId IS NULL THEN 'Sin registro'
                WHEN PZ.ZigiLinkStatus != 'PAID'  THEN 'No pagado'
                ELSE 'Exito' 
            END AS Estado,
            PZ.ZigiLinkStatus,
            CONCAT(PZ.GuideSerie, PZ.GuideNumber) AS Guia,
            G.GuideNumber AS GuideNumberBuscado,
            PZ.ZigiTransactionId,
            PZ.PaidAmount,
            PZ.CollectValue,
            PZ.CODValue,
            PZ.DateCreated
        FROM #Guides G
        LEFT JOIN DeliveryBackOffice.dbo.PaymentZigi PZ WITH(NOLOCK)
            ON G.GuideNumber = PZ.GuideNumber
           AND PZ.GuideSerie = 'FD'
        ORDER BY PZ.DateCreated DESC;

    END TRY
    BEGIN CATCH
        SELECT 
            'Error'  AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;
        THROW;
    END CATCH
END
GO