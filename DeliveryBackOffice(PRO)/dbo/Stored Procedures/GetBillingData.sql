
-- =============================================
-- Author:		<Morales, Oscar>
-- Create date: <2021-09-16>
-- Description:	<Recupera información para form Billing>
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingData]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @IdCustomer INT 
	DECLARE @Email NVARCHAR(100)
	DECLARE @Amount DECIMAL(14,2)
	DECLARE @IsCOD BIT
	DECLARE @IdFEL BIGINT
	DECLARE @TypeService VARCHAR(3)
	DECLARE @Segment VARCHAR(MAX)
	DECLARE @NameArticle VARCHAR(100)
	DECLARE @SAPCode VARCHAR(100)
	DECLARE @CardPercent DECIMAL(3,2)
	DECLARE @CardAmount DECIMAL(14,2)
	DECLARE @Category VARCHAR(50)
	DECLARE @Description NVARCHAR(100)

	SET NOCOUNT ON;

	-- Table 0
	SELECT 
		@IdCustomer = cu.IdCustomer
		,@Email = cu.RegexEmail
		,@Amount = do.PriceShippment
		,@TypeService = do.TypeService
		,@IsCOD = (CASE WHEN do.Collect_OnDelivery > 0 THEN 1 ELSE 0 END)
	FROM DeliveryOrder do WITH(NOLOCK)
	LEFT JOIN VisitPointClient vpc WITH(NOLOCK)
		ON do.Sender_ID = vpc.CodeOfReference
	INNER JOIN Customer cu WITH(NOLOCK)
		ON COALESCE(do.IdCustomer, vpc.CustomerID) = cu.IdCustomer
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

	SET @Segment = (SELECT [dbo].[fn_get_segment] (@GuideSerie,@GuideNumber))
	
	IF @TypeService IS NULL
		SET @TypeService = 'STD'

	IF @Segment IS NULL
		SET @Segment = 'LOC'
		
	-- FRESH DELIVERY
    IF (@TypeService = 'FDD')
    BEGIN
		SET @NameArticle = 'TARIFA DE ENVIO FRESH';
    END;
	-- COD
    ELSE IF (@TypeService = 'COD' OR @IsCOD = 1)
    BEGIN
		SET @NameArticle = 'TARIFA DE ENVIO COD';
    END;
	-- ESTANDAR
	ELSE
	BEGIN
		SET @NameArticle = 'TARIFA DE ENVIO ESTANDAR';
	END

	SELECT
		@SAPCode = SAPCode
		,@CardPercent = CardPercent
		,@CardAmount = CardAmount
		,@Category = Category
		,@Description = CONCAT(Description, '. ', @GuideSerie, @GuideNumber)
	FROM CatArticleSAP WITH(NOLOCK)
	WHERE Name = @NameArticle

	SELECT @IdCustomer Customer, @Email Email, @Amount Amount
		, @CardPercent CardPercent, @CardAmount CardAmount, @Category Category
		, @SAPCode Code, @Description Description

	-- Table 1
	SELECT 
		bp.BlpTaxId Nit
		,bp.BlpAddress Address
		,bp.BlpName Name 
	FROM BillingProfile bp WITH(NOLOCK)
	INNER JOIN Account ac  WITH(NOLOCK)
		ON bp.BlpIdAccount = ac.AccIdAccount
	WHERE ac.IdCustomer = @IdCustomer

	SELECT
		@IdFEL = ih.inv_pk_id
	FROM invoiceDetail id WITH(NOLOCK)
	INNER JOIN invoiceHeader ih WITH(NOLOCK)
		ON id.dti_fk_header = ih.inv_pk_id
	WHERE id.dti_fk_orderSerie = @GuideSerie
		AND id.dti_fk_orderNumber = @GuideNumber

	-- Table 2
	SELECT TOP 1 ih.inv_cli_nit Nit
		, ih.inv_cli_name Name
		, CONCAT(ih.inv_serieFEL, '-', ih.inv_numberFEL) FEL
		, ih.inv_certificationFEL Certification
	FROM invoiceHeader ih WITH(NOLOCK)
	WHERE ih.inv_pk_id = @IdFEL
		AND ih.inv_certificationFEL IS NOT NULL
		AND ih.inv_certificationFEL != ''
	ORDER BY ih.inv_date DESC

	-- Table 3
	SELECT CONCAT(id.dti_fk_orderSerie, id.dti_fk_orderNumber) Guide
		, id.dti_priceUnit Amount
	FROM invoiceDetail id WITH(NOLOCK)
	WHERE id.dti_fk_header = @IdFEL

	SET NOCOUNT OFF;
END	