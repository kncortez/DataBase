-- =============================================  
-- Author:      <Daniel Ramirez>  
-- Create date: <2024-11-23>  
-- Description: <Obtiene el detalle de las guías a facturar por comisión >
-- =============================================  
CREATE PROCEDURE [dbo].[GetInvoicePaymentDetailCommissionCODCorp]
(
 @LstVisitPointClient NVARCHAR(MAX),
 @CutOffDate          DATETIME,
 @IdCountry           NVARCHAR(2) = 'GT',
 @Option TINYINT = 0
)
AS
BEGIN
    BEGIN TRY
        -- Inicia una transacción
        BEGIN TRANSACTION;

        DECLARE @DEBUG BIT = 'TRUE'; --PARA PRUEBAS -> TRUE  
        DECLARE @SAPCode VARCHAR(100);
        DECLARE @CardPercent DECIMAL(3, 2);
        DECLARE @CardAmount DECIMAL(14, 2);
        DECLARE @Category VARCHAR(50);
        DECLARE @Name NVARCHAR(100);
        DECLARE @Description NVARCHAR(100);
        DECLARE @NameVolumeBillingDefault NVARCHAR(50) = N'Completo';
        DECLARE @NameArticle VARCHAR(100) = N'COMISION COD';

        DECLARE @IdCatConceptCOD INT =
                (
                 SELECT TOP 1
                        IdCatConceptCOD
                   FROM CatConceptCOD WITH(NOLOCK)
                  WHERE Concept = 'PAGO DE LA GUIA'
                    AND RowStatus = 1
                );

        DECLARE @IdCatInvoiceType INT =
                (
                 SELECT TOP 1
                        IdCatInvoiceType
                   FROM CatInvoiceType  WITH(NOLOCK)
                  WHERE [Name] = 'Comisión COD'
                    AND RowStatus = 1
                );
  
        IF OBJECT_ID('tempdb.dbo.#GuidesCommission', 'U') IS NOT NULL
            DROP TABLE #GuidesCommission;

        IF OBJECT_ID('tempdb.dbo.#InvoicePaymentCommissionCOD', 'U') IS NOT NULL
            DROP TABLE #InvoicePaymentCommissionCOD;  

        CREATE TABLE #GuidesCommission
        (
            GuideSerie         NVARCHAR(2)
          , GuideNumber        INT
          , IdCountry          NVARCHAR(2)
          , Amount             DECIMAL(18, 2)
          , CreditDate         DATE
          , IdVisitPointClient INT
          , CodeOfReference    INT
          , CustomerID         INT
        );
        CREATE CLUSTERED INDEX ix_GuidesCommission ON #GuidesCommission ([GuideSerie], [GuideNumber]);

        CREATE TABLE #InvoicePaymentCommissionCOD  
        (
            IdVisitPointClient INT
          , GuideSerie         NVARCHAR(2)
          , GuideNumber        INT
          , IdCountry          NVARCHAR(55)
          , Amount             DECIMAL(18, 2)
        );  
        CREATE CLUSTERED INDEX ix_InvoicePaymentCommissionCOD ON #InvoicePaymentCommissionCOD ([IdVisitPointClient]);  
  
        SELECT @SAPCode     = cas.SAPCode
             , @CardPercent = cas.CardPercent
             , @CardAmount  = cas.CardAmount
             , @Category    = cas.Category
             , @Name        = cas.[Name]
             , @Description = CONCAT([Description], '. ')
          FROM CatArticleSAP cas WITH(NOLOCK)
         WHERE cas.[Name] = @NameArticle
           AND cas.IdCountry = @IdCountry;

        INSERT INTO #GuidesCommission
        (
          GuideSerie,
          GuideNumber,
          IdCountry,
          Amount,
          CreditDate,
          IdVisitPointClient,
          CodeOfReference,
          CustomerID
        )
        SELECT bdCOD.GuideSerie
             , bdCOD.GuideNumber
             , MAX(do.SenderCountryId)
             , MAX(bdCOD.Commission)
             , MAX(bdCOD.CreditDate)
             , MAX(vpc.IdVisitPointClient)
             , MAX(vpc.CodeOfReference)
             , MAX(vpc.CustomerID)
          FROM BatchDetailCOD bdCOD WITH (NOLOCK)
               INNER JOIN DeliveryOrder  do WITH (NOLOCK)
                  ON bdCOD.GuideSerie = do.Guide_Serie
                     AND bdCOD.GuideNumber = do.Guide_Number
               INNER JOIN VisitPointClient  vpc WITH (NOLOCK)
                  ON vpc.CodeOfReference = do.Sender_ID
               INNER JOIN Customer cus WITH(NOLOCK)
                  ON vpc.CustomerID = cus.IdCustomer
               OUTER APPLY (
                            SELECT TOP 1
                                   ih.inv_pk_id
                              FROM invoiceHeader   ih WITH (NOLOCK)
                                   INNER JOIN invoiceDetail id WITH (NOLOCK)
                                      ON [ih].[inv_pk_id] = [id].[dti_fk_header]
                             WHERE bdCOD.GuideSerie = id.dti_fk_orderSerie
                               AND bdCOD.GuideNumber = id.dti_fk_orderNumber
                               AND ih.CatInvoiceTypeId = @IdCatInvoiceType
                               AND ih.inv_invoiceOfCreditNote IS NULL
                               AND ih.inv_creditNote IS NULL
                           ) AS invoice
         WHERE invoice.inv_pk_id IS NULL
           AND ISNULL(vpc.ExcludeCommissionCOD, cus.ExcludeCommissionCOD) = 0
           AND bdCOD.CatConceptCODId = @IdCatConceptCOD
           AND bdCOD.RowStatus = 1
		   AND bdCOD.Excluded = 0
           AND bdCOD.AuthorizationNumber IS NOT NULL
           AND bdCOD.Commission > 0
           AND bdCOD.idCountry = @IdCountry
           AND bdCOD.CreditDate >= '20260501'   
           AND CAST(bdCOD.CreditDate AS DATE) <= CAST(@CutOffDate AS DATE)
           AND vpc.IdVisitPointClient IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@LstVisitPointClient, ','))
         GROUP BY bdCOD.GuideSerie,
                  bdCOD.GuideNumber

        IF (EXISTS (SELECT 1 FROM [#GuidesCommission]))
        BEGIN
            INSERT INTO #InvoicePaymentCommissionCOD  
            (
                IdVisitPointClient
              , GuideSerie
              , GuideNumber
              , IdCountry
              , Amount
            )  
            SELECT gc.IdVisitPointClient          IdVisitPointClient
                 , gc.GuideSerie                  GuideSerie
                 , gc.GuideNumber                 GuideNumber
                 , cCt.CountryNameES              IdCountry
                 , gc.Amount                      Amount
            FROM #GuidesCommission                gc
                 LEFT JOIN VisitPointConfiguration vpcon WITH (NOLOCK)
                     ON vpcon.VisitPointID = gc.CodeOfReference
                 INNER JOIN Customer               cu WITH (NOLOCK)
                     ON gc.CustomerID = cu.IdCustomer
                 INNER JOIN CatCountry cCt WITH(NOLOCK)
                     ON cCt.IdCountry = gc.IdCountry
                 LEFT JOIN CatBillingVolume        cbv WITH (NOLOCK)
                     ON ISNULL(vpcon.CatBillingVolumeId, cu.CatBillingVolumeId) = cbv.IdCatBillingVolume
           WHERE           
           gc.CreditDate <= @CutOffDate

            -- Validar si hay registros en la tabla temporal
            IF EXISTS (SELECT TOP 1 1
                         FROM #InvoicePaymentCommissionCOD)
            BEGIN
                SELECT 1 AS StatusCode, 
                       'Detalle obtenido con éxito' AS StatusMessage;

                SELECT ipcCOD.IdVisitPointClient AS IdVisitPointClient
                     , ipcCOD.GuideSerie         AS Guide_Serie
                     , ipcCOD.GuideNumber        AS Guide_Number
                     , ipcCOD.IdCountry          AS CountryByGuide
                     , @SAPCode                  AS SAPCode
                     , @Name                     AS [Name]
                     , CONCAT(@Description, ipcCOD.GuideSerie,ipcCOD.GuideNumber) AS [Description]
                     , ipcCOD.Amount             AS Price
                     , @Category                 AS Category
                     , 1                         AS SendToInvoice
                  FROM #InvoicePaymentCommissionCOD ipcCOD
                 ORDER BY ipcCOD.IdVisitPointClient DESC, ipcCOD.GuideSerie DESC, ipcCOD.GuideNumber DESC;
            END
            ELSE
            BEGIN
                SELECT 0 AS StatusCode, 
                       'No existe detalle' AS StatusMessage;
            END

        END;
        ELSE
        BEGIN
            SELECT 0                          AS StatusCode
                 , 'Sin datos para procesar.' AS StatusMessage;
        END;

        -- Confirma la transacción si no hubo errores
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Deshace la transacción en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

            SELECT 0 AS StatusCode,
                   'Ha ocurrido un error en el proceso' AS StatusMessage
    END CATCH;  
END;