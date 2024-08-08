
-- =============================================
-- Author:		<Cristian,Azurdia>
-- Create date: <2024-07-24>
-- Description:	< Obtener Lotes pendientes de envió de correo HermesInvoiceHelperHN >
-- =============================================

CREATE PROCEDURE [dbo].[GetInvoiceHelperExecutionBatch]
	@Option as INT,
	@CodeOfReference as INT = 0
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

		IF (@Option = 1)
		BEGIN
			
			/*********************************************************************************************************************
			***************************** OBTENCIÓN DE INFORMACION DE LOTES EN BASE CODEOFREFERENCE *****************************
			*********************************************************************************************************************/

			SELECT	IBH.Id_Lote
					, IBH.CAI
					, IBH.LimitDateEmision
					, IBH.DaysLeftNotifycation
					, IBH.PercentInvoiceLeftNotifycation
					, IBH.EmailNotification
			FROM	InvoiceBatchHeader IBH
			LEFT JOIN InvoiceBatchRelationships IBR
				ON	IBH.Id_Lote = IBR.Id_Lote
				AND IBR.CodeOfReference = @CodeOfReference
			WHERE	IBH.[Status] = 1
				AND IBH.[Enable] = 1
				AND IBH.RowStatus = 1;
			

			COMMIT TRANSACTION;
		END
		ELSE IF(@Option = 2)
		BEGIN
			
			/*********************************************************************************************************************
			***************************** OBTENCIÓN INFORMACIÓN DE FACTURAS PENDIENTES DE ASIGNAR CORRELATIVO ********************
			*********************************************************************************************************************/

			SELECT  IH.inv_pk_id
					, IH.IdCountry
					, IH.inv_vpCodeOfReferences
					, ISNULL(IH.inv_certificationFEL, '') [inv_certificationFEL]    
					, ISNULL(IH.inv_serieFEL, '')		  [inv_serieFEL]
					, ISNULL(IH.inv_numberFEL, '')		  [inv_numberFEL]
					, IH.inv_FechaHoraFEL				  [inv_FechaHoraFEL]
					, ISNULL(IH.inv_subjectFEL, '')       [inv_subjectFEL]
					, ISNULL(IH.inv_descriptionFEL,'')	  [inv_descriptionFEL]
					, IH.inv_status						  [inv_status]
					, IH.inv_MailSendFEL                  [inv_MailSendFEL]
					, IH.inv_cli_email					  [inv_cli_email]
					, ISNULL(IH.inv_CountryFEL,'')		  [IH.inv_CountryFEL]
					, ISNULL(IH.inv_documentSend,'')      [inv_documenteSend]
					, ISNULL(inv_documentRecieved,'')	  [inv_documentRecieved]
					, ISNULL(inv_RequestorFEL,'')		  [inv_RequestorFEL]
					, ISNULL(inv_TransactionFEL, '')      [inv_TransactionFEL]
					, ISNULL(inv_EntityFEL, '')			  [inv_EntityFEL]
					, ISNULL(inv_UserFEL, '')			  [inv_UserFEL]
					, ISNULL(inv_UserName, '')			  [inv_UserName]
					, ISNULL(inv_Data1FEL, '')			  [inv_Data1FEL]
					, ISNULL(inv_Data3FEL, '')			  [inv_Data2FEL]
			FROM	InvoiceHeader   as IH
			WHERE	IH.IdCountry = 'GT'
				AND ISNULL(IH.inv_numberFEL,'') = ''
				AND ISNULL(IH.inv_FechaHoraFEL, '') = ''
				AND IH.inv_status = 1
			ORDER BY  IH.inv_pk_id
			
			COMMIT TRANSACTION;
		END
		ELSE IF(@Option = 3)
		BEGIN

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
		END
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