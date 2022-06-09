
-- =============================================
-- Author:		<Morales, Oscar>
-- Create date: <2021-09-16>
-- Description:	<Recupera información para form Billing>
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingData]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT,
		@CatInvoiceTypeId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @IdCustomer INT 
	DECLARE @Email NVARCHAR(100)
	DECLARE @Amount DECIMAL(14,2)
	DECLARE @IdFEL BIGINT
	DECLARE @TypeService VARCHAR(3)
	DECLARE @Segment VARCHAR(MAX)
	DECLARE @NameArticle VARCHAR(100)
	DECLARE @SAPCode VARCHAR(100)
	DECLARE @CardPercent DECIMAL(3,2)
	DECLARE @CardAmount DECIMAL(14,2)
	DECLARE @Category VARCHAR(50)
	DECLARE @Description NVARCHAR(100)
	DECLARE @EnvioTypeInvoice INT
	DECLARE @ComisionTypeInvoice INT

	SET NOCOUNT ON;

	SELECT 
		@EnvioTypeInvoice = IdCatInvoiceType
	FROM CatInvoiceType 
	WHERE [Name] = 'Envío'

	SELECT 
		@ComisionTypeInvoice = IdCatInvoiceType
	FROM CatInvoiceType 
	WHERE [Name] = 'Comisión COD'

	-- Table 0
	SELECT 
		@IdCustomer = cu.IdCustomer
		,@Email = cu.RegexEmail
		,@Amount = do.PriceShippment
		,@TypeService = do.TypeService
	FROM DeliveryOrder do WITH(NOLOCK)
	LEFT JOIN VisitPointClient vpc
		ON do.Sender_ID = vpc.CodeOfReference
	INNER JOIN Customer cu
		ON COALESCE(do.IdCustomer, vpc.CustomerID) = cu.IdCustomer
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

	IF @CatInvoiceTypeId = @EnvioTypeInvoice
	BEGIN

		IF @TypeService IS NULL
			SET @TypeService = 'NDD'

		SET @Segment = (SELECT [dbo].[fn_get_segment] (@GuideSerie,@GuideNumber))
	
		IF @Segment IS NULL
			SET @Segment = 'LOC'

		IF @Segment = 'FOR'
			IF @TypeService = 'SDD'
				SET @NameArticle = 'SAME DAY DELIVERY FORANEO'
			ELSE
				SET @NameArticle = 'NEXT DAY DELIVERY FORANEO'
		ELSE
			IF @TypeService = 'SDD'
				SET @NameArticle = 'SAME DAY DELIVERY LOCAL'
			ELSE
				SET @NameArticle = 'NEXT DAY DELIVERY LOCAL'

	END
	ELSE IF @CatInvoiceTypeId = @ComisionTypeInvoice
	BEGIN 
		SET @NameArticle = 'COMISION COD'

		SET @Amount =
		ISNULL((SELECT
				Commission
			FROM BatchDetailCOD
			WHERE GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber
			AND CatConceptCODId = (SELECT
					IdCatConceptCOD
				FROM CatConceptCOD
				WHERE Concept = 'COMISION Y ENVIO')
			AND RowStatus = 1)
		, 0)
	END

	SELECT
		@SAPCode = SAPCode
		,@CardPercent = CardPercent
		,@CardAmount = CardAmount
		,@Category = Category
		,@Description = CONCAT(Description, '. ', @GuideSerie, @GuideNumber)
	FROM CatArticleSAP
	WHERE Name = @NameArticle

	SELECT @IdCustomer Customer, @Email Email, @Amount Amount
		, @CardPercent CardPercent, @CardAmount CardAmount, @Category Category
		, @SAPCode Code, @Description Description

	-- Table 1
	SELECT 
		bp.BlpTaxId Nit
		,bp.BlpAddress Address
		,bp.BlpName Name 
	FROM BillingProfile bp
	INNER JOIN Account ac 
		ON bp.BlpIdAccount = ac.AccIdAccount
	WHERE ac.IdCustomer = @IdCustomer

	IF @CatInvoiceTypeId = @EnvioTypeInvoice
	BEGIN
		SELECT
			@IdFEL = ih.inv_pk_id
		FROM invoiceDetail id
		INNER JOIN invoiceHeader ih
			ON id.dti_fk_header = ih.inv_pk_id
		WHERE id.dti_fk_orderSerie = @GuideSerie
		AND id.dti_fk_orderNumber = @GuideNumber
		AND (ih.CatInvoiceTypeId IS NULL
		OR ih.CatInvoiceTypeId = @CatInvoiceTypeId)
	END
	ELSE IF @CatInvoiceTypeId = @ComisionTypeInvoice
	BEGIN
		SELECT
			@IdFEL = ih.inv_pk_id
		FROM invoiceDetail id
		INNER JOIN invoiceHeader ih
			ON id.dti_fk_header = ih.inv_pk_id
		WHERE id.dti_fk_orderSerie = @GuideSerie
		AND id.dti_fk_orderNumber = @GuideNumber
	AND ih.CatInvoiceTypeId = @CatInvoiceTypeId
	END

	-- Table 2
	SELECT TOP 1 ih.inv_cli_nit Nit
		, ih.inv_cli_name Name
		, CONCAT(ih.inv_serieFEL, '-', ih.inv_numberFEL) FEL
		, ih.inv_certificationFEL Certification
	FROM invoiceHeader ih
	WHERE ih.inv_pk_id = @IdFEL
		AND ih.inv_certificationFEL IS NOT NULL
		AND ih.inv_certificationFEL != ''
	ORDER BY ih.inv_date DESC

	-- Table 3
	SELECT CONCAT(id.dti_fk_orderSerie, id.dti_fk_orderNumber) Guide
		, id.dti_priceUnit Amount
	FROM invoiceDetail id
	WHERE id.dti_fk_header = @IdFEL

	SET NOCOUNT OFF;
END	