-- =============================================
-- Author:        <Cristian,Azurdia>
-- Create date: <2024-07-24>
-- Description:    < Obtener Lotes pendientes de envió de correo HermesInvoiceHelperHN >
-- =============================================
-- Author:        <Daniel, Ramirez>
-- Create date:   <2024-08-16>
-- Description:   <Se agrego validacion por lotes al momento de obtener el numero de factura>
-- =============================================
-- Author:        <Daniel, Ramirez>
-- Create date:   <2024-08-21>
-- Description:   <Ajuste para obtener info para tienda virtual desde Invoice Helper>
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoiceHelperExecutionBatch]
    @Option as INT,
    @CodeOfReference as INT = 0,
    @IdCountry AS VARCHAR(2) = 'GT'
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY

     DECLARE @Pbx          NVARCHAR(15) = ''
       /*
            InvoiceBatchHeader
            status = 1 y enable = 1 es cuando el lote esta habilidado y activo
            status = 0 y enable = 1 es un error - no contemplado
            status = 1 y enable = 0 es cuando no se puede facturar, porque se detuvo facturación (Ya viene lote nuevo ejemplo)
        */

        IF (@Option = 1)
        BEGIN
            
            /*********************************************************************************************************************
            ***************************** OBTENCIÓN DE INFORMACION DE LOTES EN BASE CODEOFREFERENCE *****************************
            *********************************************************************************************************************/

            SELECT IBH.Id_Lote
                   , IBR.CodeOfReference
                   , IBH.CAI
                   , IBH.LimitDateEmision
                   , IBH.DaysLeftNotifycation
                   , IBH.PercentInvoiceLeftNotifycation
                   , IBH.EmailNotification
              FROM InvoiceBatchHeader IBH WITH (NOLOCK)
                   LEFT JOIN InvoiceBatchRelationships IBR WITH (NOLOCK)
                      ON IBH.Id_Lote = IBR.Id_Lote
                     AND IBR.CodeOfReference = @CodeOfReference
             WHERE IBH.[Status] = 1
               AND IBH.[Enable] = 1
               AND IBR.RowStatus = 1;

            COMMIT TRANSACTION;
        END
        ELSE IF(@Option = 2)
        BEGIN
            
            /*********************************************************************************************************************
            ***************************** OBTENCIÓN INFORMACIÓN DE FACTURAS PENDIENTES DE ASIGNAR CORRELATIVO ********************
            *********************************************************************************************************************/

            SELECT IH.inv_pk_id
                   , IH.IdCountry
                   , IH.inv_vpCodeOfReferences
                   , ISNULL(vpc.DescriptionOfClient, '') [inv_nameCodeOfReferences]
                   , ISNULL(IH.inv_certificationFEL, '') [inv_certificationFEL]
                   , ISNULL(IH.inv_serieFEL, '')         [inv_serieFEL]
                   , ISNULL(IH.inv_numberFEL, '')        [inv_numberFEL]
                   , IH.inv_FechaHoraFEL                 [inv_FechaHoraFEL]
                   , ISNULL(IH.inv_subjectFEL, '')       [inv_subjectFEL]
                   , ISNULL(IH.inv_descriptionFEL,'')    [inv_descriptionFEL]
                   , IH.inv_status                       [inv_status]
                   , IH.inv_MailSendFEL                  [inv_MailSendFEL]
                   , IH.inv_cli_email                    [inv_cli_email]
                   , ISNULL(IH.inv_CountryFEL,'')        [inv_CountryFEL]
                   , ISNULL(IH.inv_documentSend,'')      [inv_documentSend]
                   , ISNULL(inv_documentRecieved,'')     [inv_documentRecieved]
                   , ISNULL(inv_RequestorFEL,'')         [inv_RequestorFEL]
                   , ISNULL(inv_TransactionFEL, '')      [inv_TransactionFEL]
                   , ISNULL(inv_EntityFEL, '')           [inv_EntityFEL]
                   , ISNULL(inv_UserFEL, '')             [inv_UserFEL]
                   , ISNULL(inv_UserName, '')            [inv_UserName]
                   , ISNULL(inv_Data1FEL, '')            [inv_Data1FEL]
                   , ISNULL(inv_Data3FEL, '')            [inv_Data3FEL]
                   , ISNULL(inv_tokenRegister, '')       [inv_tokenRegister]
                   , ISNULL(IH.inv_cmp_name, '')         [inv_cmp_name]
                   , ISNULL(IH.inv_cmp_nameComercial, '')[inv_cmp_nameComercial]
                   , ISNULL(inv_cmp_adress, '')          [inv_cmp_adress]
                   , ISNULL(inv_establecimientoFEL, '')  [inv_establecimientoFEL]
                   , ISNULL(inv_cmp_nameFEL,'')          [inv_cmp_nameFEL]
                   , ISNULL(inv_cli_name,'')             [inv_cli_name]
              FROM InvoiceHeader AS IH WITH(NOLOCK)
                   INNER JOIN del_ParametrosFactura AS dpf WITH(NOLOCK) 
                   ON IH.inv_vpCodeOfReferences = dpf.dpf_VpCodeOfReference
                   LEFT JOIN VisitPointClient as vpc  WITH(NOLOCK)
                   ON IH.inv_vpCodeOfReferences = vpc.CodeOfReference
             WHERE IH.IdCountry = @IdCountry
               AND ISNULL(IH.inv_numberFEL,'') = ''
               AND ISNULL(IH.inv_FechaHoraFEL, '') = ''
               AND IH.inv_type = 1
               AND IH.inv_status = 1
               AND dpf.dpf_FELCountry = @IdCountry
             ORDER BY IH.inv_pk_id

            COMMIT TRANSACTION;
        END
        ELSE IF(@Option = 3)
        BEGIN

           SELECT @Pbx = [Value]
             FROM ConfigParams
            WHERE [Name] = 'PBX'
              AND IdCountry = @IdCountry

        /*********************************************************************************************************************
        ***************************** OBTENCIÓN DE LISTADO DE FACTURAS PENDIENTES DE ENVIAR CORREO ***************************
        *********************************************************************************************************************/
             CREATE TABLE #listInvoicePending
             (
                 Id_Lote               INT,
                 ProcessedCorrelative  NVARCHAR(50),
                 inv_pk_id             INT
             );
            
            CREATE NONCLUSTERED INDEX IX_LIP_SERIE ON #listInvoicePending (inv_pk_id);

             INSERT INTO #listInvoicePending
             (
                 Id_Lote,
                 ProcessedCorrelative,
                 inv_pk_id
             )
             SELECT ibd.Id_Lote
                    ,ProcessedCorrelative
                    ,inv_pk_id
               FROM invoiceBatchDetail ibd WITH(NOLOCK)
                    INNER JOIN InvoiceBatchHeader ibh WITH(NOLOCK)
                            ON ibd.Id_Lote = ibh.Id_Lote
              WHERE SendEmail = 0
                AND ibh.TypeDocument = 1
                AND ibh.[Status] = 1
                AND ibh.[Enable] = 1
                AND ibh.RowStatus = 1
                AND ISNULL(ProcessedCorrelative,0) <> 0

        /*********************************************************************************************************************
        ***************************** OBTENCIÓN INFORMACIÓN DE FACTURAS PENDIENTES DE ENVIAR CORREO **************************
        *********************************************************************************************************************/

             --SELECT * FROM #listInvoicePending
             -- ENCABEZADO
             SELECT ISNULL(IH.inv_pk_id,0) inv_pk_id
                    ,ISNULL(IH.inv_cmp_nit,'') inv_cmp_nit
                    ,ISNULL(IH.inv_cmp_name,'') inv_cmp_name
                    ,ISNULL(IH.inv_cmp_adress,'') inv_cmp_adress
                    ,ISNULL(IH.inv_certificationFEL,'') inv_certificationFEL
                    ,ISNULL(IH.inv_serieFEL,'') inv_serieFEL
                    ,ISNULL(IH.inv_numberFEL,0) inv_numberFEL
                    ,ISNULL(IH.inv_FechaHoraFEL,'') inv_FechaHoraFEL
                    ,ISNULL(IH.inv_MailSendFEL, '') [inv_MailSendFEL]
                    ,ISNULL(IH.inv_subjectFEL,'') inv_subjectFEL
                    ,ISNULL(IH.inv_cli_nit,'') inv_cli_nit
                    ,ISNULL(IH.inv_cli_name,'') inv_cli_name
                    ,ISNULL(IH.inv_cli_adress,'') inv_cli_adress
                    ,ISNULL(IH.inv_cli_email,'') [inv_cli_email]
                    ,ISNULL(IH.inv_amount ,0.00) inv_amount
                    ,ISNULL(curr.Symbol,'Q ') Symbol
                    ,ISNULL(LTRIM(RTRIM(@Pbx)),'') Pbx
               FROM #listInvoicePending   as LIP
                    INNER JOIN invoiceHeader  as IH  WITH (NOLOCK)
                        ON IH.inv_pk_id = LIP.inv_pk_id
                    LEFT JOIN CatCurrencyCOD as curr WITH(NOLOCK)
                        ON IH.IdCurrency = curr.IdCatCurrencyCOD
              WHERE IH.inv_status = 2
                AND LEN(IH.inv_numberFEL) > 0
                AND LEN(IH.inv_serieFEL) > 0
              ORDER BY IH.inv_pk_id

            --DETALLE
             SELECT ISNULL(LIP.inv_pk_id,0) inv_pk_id
                    ,ISNULL(ID.dti_identification,'') dti_identification
                    ,ISNULL(ID.dti_category,'') dti_category
                    ,ISNULL(ID.dti_quantity,0.00) dti_quantity
                    ,ISNULL(ID.dti_measurement,'') dti_measurement
                    ,ISNULL(ID.dti_description,'') dti_description
                    ,ISNULL(ID.dti_priceUnit,0.00) dti_priceUnit
                    ,ISNULL(ID.dti_IVA,0.00) dti_IVA
                    ,ISNULL(ID.dti_amount,0.00) dti_amount
               FROM #listInvoicePending   as LIP
                    INNER JOIN invoiceHeader  as IH  WITH (NOLOCK)
                        ON IH.inv_pk_id = LIP.inv_pk_id
                    INNER JOIN InvoiceDetail  as ID  WITH (NOLOCK)
                        ON ID.dti_fk_header = LIP.inv_pk_id
              WHERE IH.inv_status = 2
                AND LEN(IH.inv_numberFEL) > 0
                AND LEN(IH.inv_serieFEL) > 0
              ORDER BY LIP.inv_pk_id

               IF OBJECT_ID('tempdb.dbo.#listInvoicePending', 'U') IS NOT NULL
               DROP TABLE #listInvoicePending;

               COMMIT TRANSACTION;
        END
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT CAST(0 AS BIT) [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

        -- INSERTAR A BITACORA DEL SERVICIO

    END CATCH
END
