-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-17>
-- Description:	<Obtiene información para >
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoicePaymentCommissionCOD]
AS
BEGIN
	BEGIN TRY
		DECLARE @DEBUG BIT = 'FALSE' --PARA PRUEBAS -> TRUE
		DECLARE @MinimumHistoricDate DATE = '2023-06-09'

		DECLARE @SAPCode VARCHAR(100)
		DECLARE @CardPercent DECIMAL(3,2)
		DECLARE @CardAmount DECIMAL(14,2)
		DECLARE @Category VARCHAR(50)
		DECLARE @Description NVARCHAR(100)

		DECLARE @IdCatConceptCOD INT = ( SELECT TOP 1
				IdCatConceptCOD
			FROM CatConceptCOD
			WHERE Concept = 'COMISION Y ENVIO'
			AND RowStatus = 1)

		DECLARE @IdCatInvoiceType INT =	(SELECT TOP 1 
				IdCatInvoiceType
			FROM CatInvoiceType 
			WHERE [Name] = 'Comisión COD'
			AND RowStatus = 1)

		DECLARE @NameVolumeBillingDefault NVARCHAR(50) = 'Individual'

		DECLARE @NameArticle VARCHAR(100) = 'COMISION COD'

		IF OBJECT_ID('tempdb.dbo.#GuidesCommission', 'U') IS NOT NULL
			DROP TABLE #GuidesCommission;
		IF OBJECT_ID('tempdb.dbo.#InvoicePaymentCommissionCOD', 'U') IS NOT NULL
			DROP TABLE #InvoicePaymentCommissionCOD;

		CREATE TABLE #GuidesCommission(
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				Amount DECIMAL(18, 2),
				CreditDate DATE
		);

		CREATE CLUSTERED INDEX ix_GuidesCommission ON #GuidesCommission ([GuideSerie],[GuideNumber]);

		CREATE TABLE #InvoicePaymentCommissionCOD(
			NameBillingVolume NVARCHAR(50),
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			IdCustomer INT,
			Nit NVARCHAR(50),
			Email NVARCHAR(100),
			Amount DECIMAL(18,2),
			[Name] NVARCHAR(100),
			[Address] VARCHAR(200)
		);

		CREATE CLUSTERED INDEX ix_InvoicePaymentCommissionCOD ON #InvoicePaymentCommissionCOD ([IdCustomer]);

		SELECT
			@SAPCode = SAPCode
		   ,@CardPercent = CardPercent
		   ,@CardAmount = CardAmount
		   ,@Category = Category
		   ,@Description = CONCAT(Description, '. ')
		FROM CatArticleSAP
		WHERE Name = @NameArticle
		INSERT INTO #GuidesCommission (GuideSerie, GuideNumber, Amount, CreditDate)
			SELECT
				bdCOD.GuideSerie
			   ,bdCOD.GuideNumber
			   ,MAX(bdCOD.Commission)
			   ,MAX(bdCOD.CreditDate)
			FROM BatchDetailCOD bdCOD WITH (NOLOCK)
			OUTER APPLY (SELECT TOP 1
					ih.inv_pk_id
				FROM invoiceHeader ih WITH (NOLOCK)
				INNER JOIN invoiceDetail id WITH (NOLOCK)
					ON [ih].[inv_pk_id] = [id].[dti_fk_header]
				WHERE bdCOD.GuideSerie = id.dti_fk_orderSerie
					AND bdCOD.GuideNumber = id.dti_fk_orderNumber
				AND ih.CatInvoiceTypeId = @IdCatInvoiceType
				AND ih.inv_invoiceOfCreditNote IS NULL
				AND ih.inv_creditNote IS NULL) invoice
			WHERE invoice.inv_pk_id IS NULL
			AND bdCOD.CatConceptCODId = @IdCatConceptCOD
			AND bdCOD.RowStatus = 1
			AND bdCOD.Commission > 0
			AND [bdCOD].[CreditDate] >= @MinimumHistoricDate
			GROUP BY bdCOD.GuideSerie
					,bdCOD.GuideNumber

		IF ( EXISTS ( SELECT TOP 1 1 FROM [#GuidesCommission] ) )
		BEGIN
		    
			SELECT
				'1' 'StatusCode'
			   ,'Datos obtenidos exitosamente.' 'Description'

			INSERT INTO #InvoicePaymentCommissionCOD (NameBillingVolume, GuideSerie, GuideNumber, IdCustomer, Nit, Email, Amount, [Name], [Address])
				SELECT
					ISNULL(cbv.NameBillingVolume, @NameVolumeBillingDefault) NameBillingVolume
				   ,gc.GuideSerie GuideSerie
				   ,gc.GuideNumber GuideNumber
				   ,cu.IdCustomer Customer
				   ,COALESCE(cu.TaxIdentificationNumber, bp.Nit, 'CF') Nit
				   ,COALESCE(cu.CODContactEmail, REPLACE(REPLACE(cu.[RegexEmail], '^', ''), '$', ''), '') Email
				   ,gc.Amount Amount
				   ,CASE
						WHEN cu.TaxIdentificationNumber IS NULL OR
							cu.TaxIdentificationNumber = '' THEN bp.[Name]
						ELSE cu.[Name]
					END [Name]
					, CASE
						WHEN cu.TaxIdentificationNumber IS NULL OR
							cu.TaxIdentificationNumber = '' THEN bp.[Address]
						ELSE cu.FiscalAddress
					END [Address]
				FROM #GuidesCommission gc
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON gc.GuideSerie = do.Guide_Serie
						AND gc.GuideNumber = do.Guide_Number
				LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
					ON vpc.CodeOfReference = do.Sender_ID
				LEFT JOIN VisitPointConfiguration vpcon WITH (NOLOCK)
					ON vpcon.VisitPointID = vpc.CodeOfReference
				INNER JOIN Customer cu WITH (NOLOCK)
					ON ISNULL(do.IdCustomer, vpc.CustomerID) = cu.IdCustomer
				LEFT JOIN CatBillingVolume cbv WITH (NOLOCK)
					ON ISNULL(vpcon.CatBillingVolumeId, cu.CatBillingVolumeId) = cbv.IdCatBillingVolume
				LEFT JOIN CatBillingTime cbt WITH (NOLOCK)
					ON ISNULL(vpcon.CatBillingTimeId, cu.CatBillingTimeId) = cbt.IdCatBillingTime
				OUTER APPLY (SELECT
					TOP 1
						bp.BlpTaxId Nit
					   ,bp.BlpAddress [Address]
					   ,bp.BlpName [Name]
					FROM BillingProfile bp
					INNER JOIN Account ac
						ON bp.BlpIdAccount = ac.AccIdAccount
					WHERE ac.IdCustomer = cu.IdCustomer
					AND bp.BlpRowStatus = 1
					ORDER BY bp.IsDefault DESC) bp
				WHERE ((cbt.DescriptionBillingTime = 'Diario')
				OR (cbt.DescriptionBillingTime = 'Fecha de corte'
				AND (DATEPART(dd, ISNULL(vpcon.BillingCut_offDate, cu.BillingCut_offDate)) = DATEPART(dd, GETDATE())
				OR DATEPART(dd, EOMONTH(GETDATE())) = DATEPART(dd, GETDATE())
				AND DATEPART(dd, EOMONTH(GETDATE())) < DATEPART(dd, ISNULL(vpcon.BillingCut_offDate, cu.BillingCut_offDate))))
				OR (cbt.IdCatBillingTime IS NULL
				AND (DATEPART(dw, GETDATE()) = 1
				OR DATEPART(dd, GETDATE()) = 2
				OR @DEBUG = 'TRUE')))
				AND gc.CreditDate > CAST(DATEADD(MONTH, -1, GETDATE()) AS DATE)

			SELECT
				NameBillingVolume NameBillingVolume
			   ,ipcCOD.IdCustomer Customer
			   ,CASE
					WHEN ipcCOD.Email = '' THEN NULL
					ELSE ipcCOD.Email
				END Email
			   ,ipcCOD.Amount Amount
			   ,@Category Category
			   ,@SAPCode Code
			   ,@Description [Description]
			   ,ipcCOD.GuideSerie GuideSerie
			   ,ipcCOD.GuideNumber GuideNumber
			   ,CASE
					WHEN ipcCOD.Nit IS NULL OR
						ipcCOD.Nit = '' THEN 'CF'
					ELSE ipcCOD.Nit
				END Nit
			   ,@IdCatInvoiceType IdCatInvoiceType
			   ,CASE
					WHEN ipcCOD.[Name] IS NULL OR
						ipcCOD.[Name] = '' THEN 'CONSUMIDOR FINAL'
					ELSE ipcCOD.[Name]
				END [Name]
			   ,CASE
					WHEN ipcCOD.[Address] IS NULL OR
						ipcCOD.[Address] = '' THEN 'CIUDAD'
					ELSE ipcCOD.[Address]
				END [Address]
			FROM #InvoicePaymentCommissionCOD ipcCOD
			ORDER BY ipcCOD.IdCustomer
			DECLARE @Retries INT = ISNULL(( SELECT
					ConfEP.ConfigParameterValue
				FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfEP WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH (NOLOCK)
					ON ConfEP.ExternalPlatformId = CEP.IdExternalPlatform
				WHERE CEP.NameExternalPlatform = 'HermesInvoiceHelper' COLLATE Latin1_General_CI_AI
				AND ConfEP.ConfigParameterName = 'Retries'
				AND ConfEP.RowStatus = 1)
			, 2)

			SELECT
				inv_pk_id Invoice
			FROM invoiceHeader WITH (NOLOCK)
			WHERE CatInvoiceTypeId = @IdCatInvoiceType
			AND (inv_descriptionFEL IS NULL
			OR (inv_descriptionFEL <> 'PROCESO REALIZADO')
			AND inv_descriptionFEL <> 'Fallo la ejecucion del comando: [POST_DOCUMENTGT], TrCode: [9], description: [Ya existe el Documento con el NIT, codigo establecimiento, tipo de documento y IDInterno, no se puede insertar un documento duplicado]')
			AND (Retries IS NULL
			OR Retries <= @Retries)
		END
		ELSE
        BEGIN
			SELECT
				'-1' 'StatusCode'
			   ,'Sin datos para procesar.' 'Description'
        END

	END TRY
	BEGIN CATCH
		
		SELECT
			'-1' 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END