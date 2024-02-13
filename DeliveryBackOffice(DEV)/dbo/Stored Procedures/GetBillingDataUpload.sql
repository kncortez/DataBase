
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-12-20>
-- Description:	<Description,data para facturación de usuarios logueados>
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingDataUpload] 
@OrderNumber AS NVARCHAR(25)
AS
BEGIN
	
	SET NOCOUNT ON;

		-- Variables para la asociación y activación de Membresías o suscripciones
	DECLARE @IdTarjeta AS INT = NULL         -- puede ser null por ex c y por credito
    DECLARE @TypeSalePackage AS NVARCHAR(50) -- membership or suscription
    DECLARE @IdSalePackage AS INT            -- id membership or suscription
    DECLARE @IdAcount AS BIGINT              ---- user
    DECLARE @Vaucher AS NVARCHAR(50) = NULL  -- comprobante de factura pago con tarjeta
    DECLARE @TypeOfInMoneyId INT             -- Tipo de pago
    DECLARE @ModulId AS INT = NULL           --  pagina o form desde donde se hizo la operación 
    DECLARE @SystemId AS INT                 --  1 y 2 web o 
    DECLARE @Token AS NVARCHAR(50)
    DECLARE @TaxId NVARCHAR(50) = 'CF'
    DECLARE @FiscalAddress NVARCHAR(200) = 'Ciudad'
    DECLARE @TaxName NVARCHAR(100) = 'CONSUMIDOR FINAL'
    DECLARE @InvoiceEmail NVARCHAR(50) = ''
    DECLARE @IsAutoRenewable Bit = 0

SELECT Top 1 
    @IdTarjeta = GetCardsCredit         
  , @TypeSalePackage = TypeSalePackage  
  , @IdSalePackage = IdSalePackage             
  , @IdAcount = AccountId              
  , @Vaucher =Vaucher
  , @TypeOfInMoneyId = 2        
  , @ModulId = 1          
  , @SystemId = 1             
  , @Token = TokenCreated
  , @TaxId = TaxId
  , @FiscalAddress =AddressTax
  , @TaxName =  NameTax
  , @InvoiceEmail  = InvoiceEmail
  , @IsAutoRenewable  = GetRenovacionAutomatica 
  FROM dbo.RegistrationofTransactionProcessStates WITH (NOLOCK)
  Where OrderNumber= @OrderNumber



  SELECT Top 1 
    @IdTarjeta AS GetCardsCredit         
  , @TypeSalePackage AS TypeSalePackage  
  , @IdSalePackage AS  IdSalePackage             
  , @IdAcount AS  AccountId              
  , @Vaucher  AS Vaucher
  , @TypeOfInMoneyId AS  TypeOfInMoneyId        
  , @ModulId AS ModulId          
  , @SystemId AS  SystemId             
  , @Token AS TokenCreated
  , @TaxId AS TaxId
  , @FiscalAddress AS AddressTax
  , @TaxName AS  NameTax
  , @InvoiceEmail  AS InvoiceEmail
  , @IsAutoRenewable AS IsAutoRenewable




   
END