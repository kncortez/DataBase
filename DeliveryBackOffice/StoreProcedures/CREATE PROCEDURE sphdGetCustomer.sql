-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-19-04>
-- Description:	<Obtiene el listado de los clientes>
-- =============================================
CREATE PROCEDURE sphdGetCustomer
	-- Add the parameters for the stored procedure here
	@IdCustomer as int = -1

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT Cast(cst.IdCustomer as nvarchar)  [IdValue], 
			   UPPER(cst.Name) + ' ' + '[' +cst.Abbreviation + ']' [NameValue],
			   cst.CountryID [IdFilter]
		FROM Customer cst
		WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
		AND cst.RowSatus = 'TRUE'
		AND (@IdCustomer = -1 or cst.IdCustomer = @IdCustomer)


		SELECT cst.SAPCardCode  [IdValue], 
			   cst.Name + ' ' + '[' +cst.Abbreviation + ']' [NameValue],
			   cst.CountryID [IdFilter]
		FROM Customer cst
		WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
		AND cst.RowSatus = 'TRUE'
		AND (@IdCustomer = -1 or cst.IdCustomer = @IdCustomer)


	       SELECT cst.[IdCustomer] , 
		   cst.[Name]    , 
		   cst.[Description], 
		   cst.[Domain], 
		   cst.[RegexSubject], 
		   cst.[RegexEmail],
		   cst.[RegexFilename], 
		   cst.[Abbreviation], 
		   cst.[IdCustomerType], 
		   cst.[CountryID]  IdFilter, 
		   cst.[CommercialName], 
		   cst.[CustomerPhone], 
		   cst.[WebsiteURI], 
		   cst.[ContactName],
		   cst.[ContactEmail], 
		   cst.[NotificationAddress],
		   cst.[SaleAdvisorID], 
		   cst.[DateUpService], 
		   cst.[DateDownService], 
		   cst.[TypeOfBusinessID],
		   cst.[BusinessSegmentID], 
		   cst.[BusinessActivityID], 
		   cst.[CommercialSegmentID], 
		   cst.[OperationContactName], 
		   cst.[OperationContactPhone],
		   cst.[OperationContactEmail],
		   cst.[LegalSponsorName], 
		   cst.[LegalSponsorLastName], 
		   cst.[LegalSponsorDPI], 
		   cst.[HasAgreement], 
		   cst.[AgreementNumber], 
		   cst.[AgreementDateStart], 
		   cst.[AgreementDateEnd], 
		   cst.[InvoiceName], 
		   cst.[TaxIdentificationNumber], 
		   cst.[FiscalAddress], 
		   cst.[InvoiceEmail], 
		   cst.[ConditionOfPaymentID],
		   cst.[InvoiceContactName], 
		   cst.[InvoiceContactPhone], 
		   cst.[InvoiceContactEmail], 
		   cst.[CODAccountBankID], 
		   cst.[CODAccountNumber], 
		   cst.[CODAccountName], 
		   cst.[CODAccountTypeID],
		   cst.[CODCurrencyID], 
		   cst.[CODContactName],
		   cst.[CODContactPhone],
		   cst.[CODContactEmail], 
		   cst.[SAPCardCode]
		FROM Customer cst
		WHERE cst.IdCustomerType != 3 --todos excepto el portal 3
		AND cst.RowSatus = 'TRUE'
		AND (@IdCustomer = -1 or cst.IdCustomer = @IdCustomer)

END
GO
