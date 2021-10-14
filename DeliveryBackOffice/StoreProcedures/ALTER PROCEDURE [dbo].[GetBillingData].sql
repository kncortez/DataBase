USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetBillingData]    Script Date: 13/10/2021 15:58:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Morales, Oscar>
-- Create date: <2021-09-16>
-- Description:	<Recupera información para form Billing>
-- =============================================
ALTER PROCEDURE [dbo].[GetBillingData]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @IdCustomer INT 
	DECLARE @Email NVARCHAR(100)
	DECLARE @Amount DECIMAL(14,2)
	DECLARE @IdFEL BIGINT
	DECLARE @TypeService VARCHAR(100)

	SET NOCOUNT ON;

	-- Table 0
	SELECT 
		@IdCustomer = cu.IdCustomer
		,@Email = cu.RegexEmail
		,@Amount = do.PriceShippment
		,@TypeService = cas.SAPCode
	FROM DeliveryOrder do
	LEFT JOIN VisitPointClient vpc
		ON do.Sender_ID = vpc.CodeOfReference
	INNER JOIN Customer cu
		ON COALESCE(do.IdCustomer, vpc.CustomerID) = cu.IdCustomer
	LEFT JOIN CatArticleSAP cas
		ON (CASE WHEN do.TypeService IS NULL THEN 'NDD'
			WHEN do.TypeService = 'EXP' THEN 'NDD'
			ELSE do.TypeService 
			END) = cas.Name
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

	SELECT @IdCustomer Customer, @Email Email, @Amount Amount
		,CASE WHEN @TypeService IS NOT NULL THEN @TypeService
		ELSE (SELECT SAPCode FROM CatArticleSAP WHERE Name = 'NDD') END Code

	-- Table 1
	SELECT 
		bp.BlpTaxId Nit
		,bp.BlpAddress Address
		,bp.BlpName Name 
	FROM BillingProfile bp
	INNER JOIN Account ac 
		ON bp.BlpIdAccount = ac.AccIdAccount
	WHERE ac.IdCustomer = @IdCustomer

	SELECT
		@IdFEL = ih.inv_pk_id
	FROM invoiceDetail id
	INNER JOIN invoiceHeader ih
		ON id.dti_fk_header = ih.inv_pk_id
	WHERE id.dti_fk_orderSerie = @GuideSerie
		AND id.dti_fk_orderNumber = @GuideNumber

	-- Table 2
	SELECT ih.inv_cli_nit Nit
		, ih.inv_cli_name Name
		, CONCAT(ih.inv_serieFEL, '-', ih.inv_numberFEL) FEL
		, ih.inv_certificationFEL Certification
	FROM invoiceHeader ih
	WHERE ih.inv_pk_id = @IdFEL

	-- Table 3
	SELECT CONCAT(id.dti_fk_orderSerie, id.dti_fk_orderNumber) Guide
		, id.dti_priceUnit Amount
	FROM invoiceDetail id
	WHERE id.dti_fk_header = @IdFEL

	SET NOCOUNT OFF;
END