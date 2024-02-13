-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date, 2023-09-10>
-- Description:	<Description,Insertar registro que indica inicio del  proceso de una transacción de compra carrito marketplace TeleMercadeo>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_RegistrationofTransactionProcessStatesMarketPlaceTeleMarketing] 
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
	
	

    BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON; 
	
	DECLARE  @isSuscription AS BIT 
	DECLARE  @Result AS INT=0


	IF(NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[RegistrationofTransactionProcessStates] WHERE 
	                     OrderNumber=@OrderNumber))
BEGIN
	INSERT INTO [dbo].[RegistrationofTransactionProcessStates]
	(
	  AccountId,
	  CustomerId,
	  OrderNumber,
	  NameTax,
	  AddressTax,
	  TaxId,
	  IsSuscription,
	  GetRenovacionAutomatica,
	  GetCardsCredit,
	  TokenCreated,
	  DateCreated,
	  InvoiceEmail,
	  Vaucher,
	  IdSalePackage,
	 TypeSalePackage,
	 ProductGiftShippingEmail,
	 [PaymentImageURL]
	)
	 SELECT
        @AccountId,
        @CustomerId,
        @OrderNumber,
        @NameTax,
        @FiscalAddress,
        @TaxId,
		(Select Case WHEN  T.TypeSalePackage ='Suscripción mensual' THEN 1 ELSE 0 END ),
        @IsAutoRenewable,
        @CardId,
        @Token,
        GETDATE(),
        @InvoiceEmail,
        @Vaucher,
        T.IdCatProduct,
        T.TypeSalePackage,
		CASE WHEN 
		              T.ProductGiftShippingEmail = 'NULL'
					  THEN NULL
					  ELSE T.ProductGiftShippingEmail
					  END,
		@ImageURL
    FROM @TblSalePackageMarketPlace AS T;

	SET @Result=1;
END

	COMMIT TRAN
	SELECT @Result AS 'ResultCode' 




END TRY
	BEGIN CATCH
	
	ROLLBACK TRAN
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

	END CATCH
 
END