
-- =============================================
-- Author:		<Cristian,Azurdia>
-- Create date: <2024-07-24>
-- Description:	< Obtener Lotes pendientes de envió de correo HermesInvoiceHelperHN >
-- =============================================

ALTER PROCEDURE [dbo].[GetInvoiceHelperExecutionBatch]

AS
BEGIN

	BEGIN TRANSACTION
	BEGIN TRY

	   /*
			InvoiceBatchHeader
			status = 1 y enable = 1 es cuando el lote esta habilidado y activo
			status = 0 y enable = 1 es un error - no contemplado
			status = 1 y enable = 0 es cuando no se puede facturar, porque se detuvo facturación (Ya viene lote nuevo ejemplo)
		*/

		/*********************************************************************************************************************
		***************************** OBTENCIÓN DE LISTADO DE FACTURAS PENDIENTES DE ENVIAR CORREO ***************************
		*********************************************************************************************************************/
		CREATE TABLE #listInvoicePending
        (
            Id_Lote					INT,
            ProcessedCorrelative	NVARCHAR(50),
            inv_pk_id				INT
        );

		INSERT INTO #listInvoicePending
        (
            Id_Lote,
            ProcessedCorrelative,
            inv_pk_id
        )
		SELECT  Id_Lote
				,ProcessedCorrelative
				,inv_pk_id
		FROM	invoiceBatchDetail
		WHERE	SendEmail = 0

		/*********************************************************************************************************************
		***************************** OBTENCIÓN INFORMACIÓN DE FACTURAS PENDIENTES DE ENVIAR CORREO **************************
		*********************************************************************************************************************/

		--SELECT * FROM #listInvoicePending
		-- ENCABEZADO
		SELECT	 IH.inv_pk_id
				,IH.inv_cmp_nit
				,IH.inv_cmp_name
				,IH.inv_cmp_adress
				,IH.inv_certificationFEL
				,IH.inv_serieFEL
				,IH.inv_numberFEL
				,IH.inv_FechaHoraFEL
				,ISNULL(IH.inv_MailSendFEL, '') [inv_MailSendFEL]
				,IH.inv_subjectFEL
				,IH.inv_cli_nit
				,IH.inv_cli_name
				,IH.inv_cli_adress
				,IH.inv_cli_email
				,IH.inv_amount 
		FROM	#listInvoicePending   as LIP
			INNER JOIN invoiceHeader  as IH  WITH (NOLOCK)
				ON IH.inv_pk_id = LIP.inv_pk_id
		WHERE IH.inv_status = 1
		ORDER BY IH.inv_pk_id

		--DETALLE
		SELECT  LIP.inv_pk_id
				,ID.dti_identification
				,ID.dti_category
				,ID.dti_quantity
				,ID.dti_measurement
				,ID.dti_description
				,ID.dti_priceUnit
				,ID.dti_IVA
				,ID.dti_amount
		FROM	#listInvoicePending   as LIP
			INNER JOIN InvoiceDetail  as ID  WITH (NOLOCK)
				ON ID.dti_fk_header = LIP.inv_pk_id
			INNER JOIN DeliveryOrder  as DO WITH(NOLOCK)
				ON  DO.Guide_Number = ID.dti_fk_orderNumber
				AND DO.Guide_Serie  = ID.dti_fk_orderSerie
		ORDER BY LIP.inv_pk_id


		IF OBJECT_ID('tempdb.dbo.#listInvoicePending', 'U') IS NOT NULL
        DROP TABLE #listInvoicePending;

		COMMIT TRANSACTION;
		 
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT 
			CAST(0 AS BIT) [blnResult],
			ERROR_NUMBER() AS [ErrorNumber],
			ERROR_SEVERITY() AS [ErrorSeverity],
			ERROR_STATE() AS [ErrorState],
			ERROR_PROCEDURE() AS [ErrorProcedure],
			ERROR_LINE() AS [ErrorLine],
			ERROR_MESSAGE() AS [ErrorMessage];

		-- INSERTAR A BITACORA DEL SERVICIO

	END CATCH
END
