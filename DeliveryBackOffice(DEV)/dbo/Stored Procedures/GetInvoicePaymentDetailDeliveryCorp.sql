-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-11-19>
-- Description: <Obtenemos la informacion de guias o comisiones de COD para facturarlas>
-- =============================================
CREATE PROCEDURE GetInvoicePaymentDetailDeliveryCorp
(
 @LstVisitPointClient NVARCHAR(MAX) = '',
 @CutOffDate          DATETIME,
 @IdCountry           NVARCHAR(2) = 'GT',
 @Option              TINYINT = 0
)
AS
BEGIN
  --     Inicia el bloque de manejo de excepciones
    BEGIN TRY
        --Variables locales
        DECLARE @XmlVisitPointClient XML,
                @TypeService         NVARCHAR(3);

        DECLARE @IdCatInvoiceType INT =
                (
                 SELECT TOP 1
                        IdCatInvoiceType
                   FROM CatInvoiceType  WITH(NOLOCK)
                  WHERE [Name] = 'Envío'
                    AND RowStatus = 1
                );

        SELECT @TypeService = CASE
                                 WHEN @Option = 1 THEN 'STD'
                                 WHEN @Option = 3 THEN 'COD'
                                 ELSE 'STD'
                              END

        -- Verificar si la tabla existe y eliminarla si es necesario
        IF OBJECT_ID('tempdb..#InvoiceByVisitPointDetails') IS NOT NULL
            DROP TABLE #InvoiceByVisitPointDetails;

        -- Crear la tabla
        CREATE TABLE #InvoiceByVisitPointDetails
        (
            IdVisitPointClient INT NOT NULL,
            Guide_Serie        NVARCHAR(2)  NOT NULL,
            Guide_Number       INT NOT NULL,
            CountryByGuide     NVARCHAR(55) NULL,
            SAPCode            NVARCHAR(50) NULL,
            [Name]             NVARCHAR(100) NULL,
            [Description]      NVARCHAR(200) NULL,
            Price              DECIMAL(14, 2) NULL,
            Category           NVARCHAR(50) NULL,
            SendToInvoice      BIT NULL
        );

        -- Convertir la cadena a XML
        SET @XmlVisitPointClient = CAST('<LstVisitPointClient><PointClient>' + REPLACE(@LstVisitPointClient, ',', '</PointClient><PointClient>') + '</PointClient></LstVisitPointClient>' AS XML);

        -- Inicia una transacción
        BEGIN TRANSACTION;

        --Tabla temporal para almacenar guias a procesar
        DECLARE @TempVisitPointClient TblBillingGuideDetail;

        INSERT INTO @TempVisitPointClient (IdVisitPointClient, GuideSerie, GuideNumber)
        SELECT TOP 3 vst.IdVisitPointClient,
               do.Guide_Serie,
               do.Guide_Number
          FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
               INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vst WITH(NOLOCK)
                       ON do.Sender_ID = vst.CodeOfReference
               LEFT JOIN dbo.invoiceDetail id WITH(NOLOCK) 
                      ON id.dti_fk_orderSerie = do.Guide_Serie 
                     AND id.dti_fk_orderNumber = do.Guide_Number
               LEFT JOIN dbo.invoiceHeader ih WITH(NOLOCK) 
                      ON ih.inv_pk_id = id.dti_fk_header
                     AND ih.CatInvoiceTypeId = @IdCatInvoiceType
         WHERE id.dti_fk_header IS NULL 
           AND ih.inv_certificationFEL IS NULL
           AND ih.inv_creditNote IS NULL 
           AND ih.inv_motiveCreditNote IS NULL
           AND ih.CatInvoiceTypeId IS NULL
           AND vst.IdVisitPointClient IN (
                                           SELECT v.value('.', 'NVARCHAR(MAX)') AS Valor
                                             FROM @XmlVisitPointClient.nodes('/LstVisitPointClient/PointClient') AS x(v)
                                          )
           AND CAST(do.Preparation_Date AS DATE) >= CAST(@CutOffDate AS DATE)
           AND do.IsCollect = 0
           AND do.SenderCountryId = @IdCountry
           AND do.TypeService = @TypeService
           AND EXISTS
                     (
                      SELECT TOP 1 1
                        FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH(NOLOCK)
                       WHERE dod.Guide_Serie = do.Guide_Serie
                         AND dod.Guide_Number = do.Guide_Number
                         AND dod.StatusOrderId IN (11, -- Arribó a las instalaciones
                                                   4,  -- En ruta
                                                   5,  -- Entregado
                                                   22,  --Entregado En Express Center
                                                   25,  --COD pagado
                                                   43   --En preparación de traslado
                                                   ) 
                     )
         ORDER BY do.Guide_Number DESC

        INSERT INTO #InvoiceByVisitPointDetails
        EXEC [dbo].[GetBillingGuideDetailForList] @TempVisitPointClient

            -- Validar si hay registros en la tabla temporal
            IF EXISTS (SELECT TOP 1 1 
                         FROM #InvoiceByVisitPointDetails)
            BEGIN
                SELECT 1 AS StatusCode, 
                       'Detalle obtenido con éxito' AS StatusMessage;

                SELECT *
                  FROM #InvoiceByVisitPointDetails
                 ORDER BY IdVisitPointClient DESC, Guide_Serie DESC, Guide_Number DESC;
            END
            ELSE
            BEGIN
                SELECT 0 AS StatusCode, 
                       'No existe detalle' AS StatusMessage;
            END

        -- Confirma la transacción si no hubo errores
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Deshace la transacción en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            PRINT ERROR_MESSAGE()
            SELECT 0 AS StatusCode, 
                   'Ha ocurrido un error en el proceso' AS StatusMessage
    END CATCH

    -- Validar y eliminar la tabla temporal si ya existe
    IF OBJECT_ID('tempdb..#VisitPoints') IS NOT NULL
        DROP TABLE #InvoiceByVisitPointDetails;
END;