-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date, 2023-09-10>
-- Description:	<Description,Insertar registro que indica inicio del inicio del proceso de una transacción>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_RegistrationofTransactionProcessStates] 
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
@TypeSalePackage AS NVARCHAR(25),
@IdSalePackage AS INT,
@InvoiceEmail AS NVARCHAR(500),
@Vaucher AS NVARCHAR (50) 

	
AS
BEGIN
	

	BEGIN TRY
		SET NOCOUNT ON; 
	
	DECLARE  @isSuscription AS BIT =(Select Case WHEN @TypeSalePackage ='Suscription' THEN 1 ELSE 0 END )



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
	 TypeSalePackage
	)
	VALUES
	(
	 @AccountId,
	 @CustomerId,
	 @orderNumber,
	 @NameTax,
	 @FiscalAddress,
	 @TaxId,
	 @isSuscription,
	 @IsAutoRenewable,
	 @CardId,
	 @Token,
	 GETDATE(),
	 @InvoiceEmail,
	 @Vaucher,
	 @IdSalePackage,
	 @TypeSalePackage
	)


	SELECT 1 AS 'ResultCode' 




END TRY
	BEGIN CATCH
	
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

	END CATCH
 
END