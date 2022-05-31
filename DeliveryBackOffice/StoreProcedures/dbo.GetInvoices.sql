USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-05-24>
-- Description:	<Obtiene el listado de facturas filtrado por parámetros>
-- =============================================
CREATE PROCEDURE [dbo].[GetInvoices]
	-- Add the parameters for the stored procedure here
	@CustomerId INT = -1,
	@CertificationFEL VARCHAR(200) = '',
	@DateStart DATE = '2022-05-17',
	@DateEnd DATE = '2022-05-24',
	@Email VARCHAR(150) = '',
	@GuideSerie NVARCHAR(2) = '',
	@GuideNumber INT = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		ih.inv_pk_id InvoiceId
	   ,CONCAT(cu.[Name], ' (', cu.IdCustomer, ')') Customer
	   ,ih.inv_MailSendFEL Email
	   ,CONCAT(id.dti_fk_orderSerie, id.dti_fk_orderNumber) Guide
	   ,ih.inv_certificationFEL FEL
	   ,ih.inv_dateRegister InvoiceDate
	   ,ih.inv_amount InvoiceAmount
	   ,ISNULL(ih.IsPaid, 'TRUE') IsPaid
	   ,ih.inv_status [Status]
	FROM invoiceHeader ih
	INNER JOIN invoiceDetail id
		ON id.dti_fk_header = ih.inv_pk_id
	INNER JOIN DeliveryOrder do WITH (NOLOCK)
		ON do.Guide_Serie = id.dti_fk_orderSerie
			AND do.Guide_Number = id.dti_fk_orderNumber
	LEFT JOIN VisitPointClient vp
		ON vp.CodeOfReference = do.Sender_ID
	LEFT JOIN Customer cu
		ON ISNULL(do.IdCustomer, vp.CustomerID) = cu.IdCustomer
	WHERE CAST(ih.inv_dateRegister AS DATE) BETWEEN @DateStart AND @DateEnd
	AND (cu.IdCustomer = @CustomerId
	OR @CustomerId = -1)
	AND (ih.inv_certificationFEL = @CertificationFEL
	OR @CertificationFEL = '')
	AND (ih.inv_MailSendFEL = @Email
	OR @Email = '')
	AND ((id.dti_fk_orderSerie = @GuideSerie
	AND id.dti_fk_orderNumber = @GuideNumber)
	OR (@GuideSerie = ''
	OR @GuideNumber = -1))
	GROUP BY ih.inv_pk_id
			,ih.inv_MailSendFEL
			,id.dti_fk_orderSerie
			,id.dti_fk_orderNumber
			,cu.IdCustomer
			,cu.[Name]
			,ih.inv_certificationFEL
			,ih.inv_dateRegister
			,ih.inv_amount
			,ih.IsPaid
			,ih.inv_status
	ORDER BY InvoiceId
END
GO