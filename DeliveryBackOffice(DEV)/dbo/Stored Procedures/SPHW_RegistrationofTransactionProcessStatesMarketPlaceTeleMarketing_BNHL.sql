
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date, 2023-09-10>
-- Description:	<Description,Insertar registro que indica inicio del  proceso de una transacción de compra carrito marketplace TeleMercadeo>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_RegistrationofTransactionProcessStatesMarketPlaceTeleMarketing_BNHL] 
@AccountId AS INT,
@CustomerId AS INT,
@OrderNumber AS NVARCHAR(50),
@NameTax  AS NVARCHAR(250),
@FiscalAddress AS NVARCHAR(500),
@TaxId AS NVARCHAR (100),
@IsAutoRenewable AS BIT,
@CardId AS NVARCHAR (20),
@Token AS NVARCHAR(50),
@System AS INT,
@TblSalePackageMarketPlace [TblProductMarketPlace2] READONLY,
@InvoiceEmail AS NVARCHAR(500),
@Vaucher AS NVARCHAR (50),
@ImageURL NVARCHAR(600) = NULL

	
AS
BEGIN

PRINT 'test'	
	 
END