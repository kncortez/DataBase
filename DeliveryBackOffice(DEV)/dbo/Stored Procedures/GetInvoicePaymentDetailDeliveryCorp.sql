/* =================================================
   SP:        DeliveryBackOffice.GetInvoicePaymentDetailDeliveryCorp
   Propósito: Obtenemos la informacion de guias o comisiones de COD para facturarlas
   Autor:     Daniel Ramirez
   Fecha:     2024-11-19
============================================
=== CHANGELOG ================================
2026-04-08 | Historia/épica: FDAPI-5989 | Autor: Hanss Espinoza |
=========================================== */
CREATE PROCEDURE [dbo].[GetInvoicePaymentDetailDeliveryCorp]
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
                   FROM DeliveryBackOffice.dbo.CatInvoiceType  WITH(NOLOCK)
                  WHERE [Name] = 'Envío'
                    AND RowStatus = 1
                );

        SELECT @TypeService = CASE
                                 WHEN @Option = 1 THEN 'STD'
                                 WHEN @Option IN (3, 4, 5) THEN 'COD'
                                 ELSE 'STD'
                              END

        -- Crear la tabla
        DECLARE @InvoiceByVisitPointDetails TABLE
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
        SELECT vst.IdVisitPointClient,
               do.Guide_Serie,
               do.Guide_Number
          FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
               INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vst WITH(NOLOCK)
                       ON do.Sender_ID = vst.CodeOfReference
               INNER JOIN DeliveryBackOffice.dbo.Customer cus WITH(NOLOCK)
                       ON vst.CustomerID = cus.IdCustomer
               LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail id WITH(NOLOCK)
                      ON id.dti_fk_orderSerie = do.Guide_Serie
                     AND id.dti_fk_orderNumber = do.Guide_Number
               LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader ih WITH(NOLOCK)
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
           AND CAST(do.Preparation_Date AS DATE) <= CAST(@CutOffDate AS DATE)
           AND do.IsCollect = 0
           AND do.SenderCountryId = @IdCountry
           AND do.TypeService = @TypeService
           -- Filtros para sub-productos COD (opciones 3, 4, 5)
           AND (
               @Option NOT IN (3, 4, 5)
               OR (
                   (@Option = 3 AND ISNULL(ISNULL(vst.ExcludePriceShippingCOD, cus.ExcludePriceShippingCOD), 0) = 0 AND ISNULL(do.IsLastMileReturn, 0) = 0)  -- COD Contado (NULL se trata como Contado)
                   OR (@Option = 4 AND ISNULL(ISNULL(vst.ExcludePriceShippingCOD, cus.ExcludePriceShippingCOD), 0) = 1 AND ISNULL(do.IsLastMileReturn, 0) = 0)  -- COD Crédito
                   OR (@Option = 5 AND ISNULL(do.IsLastMileReturn, 0) = 1)                                                                          -- Intentos de entrega
               )
           )
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

        INSERT INTO @InvoiceByVisitPointDetails
        EXEC [dbo].[GetBillingGuideDetailForList] @TempVisitPointClient

            -- Validar si hay registros en la tabla temporal
            IF EXISTS (SELECT TOP 1 1
                         FROM @InvoiceByVisitPointDetails)
            BEGIN
                SELECT 1 AS StatusCode,
                       'Detalle obtenido con éxito' AS StatusMessage;

                SELECT IdVisitPointClient,
                       Guide_Serie,
                       Guide_Number,
                       CountryByGuide,
                       SAPCode,
                       [Name],
                       [Description],
                       Price,
                       Category,
                       SendToInvoice
                  FROM @InvoiceByVisitPointDetails
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
            SELECT 0 AS StatusCode,
                   'Ha ocurrido un error en el proceso' AS StatusMessage
    END CATCH

END;
