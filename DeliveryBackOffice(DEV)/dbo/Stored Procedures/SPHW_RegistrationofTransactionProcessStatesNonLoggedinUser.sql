==========================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date, 2023-12-13>
-- Description:	<Description,Insertar registro que indica inicio del inicio del proceso de una transacción ususarios no logueados marketplace>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_RegistrationofTransactionProcessStatesNonLoggedinUser] 
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
@TblSalePackageMarketPlace [TblSalePackageMarketPlace] READONLY,
@InvoiceEmail AS NVARCHAR(500),
@Vaucher AS NVARCHAR (50) 

	
AS
BEGIN
	
	SET @CustomerId = (SELECT TOP 1  A2.IdCustomer 
	        FROM DeliveryBackOffice.dbo.RolByUserByAccount A1 WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Account A2 ON A2.AccIdAccount = A1.RuaIdAccount
			AND A2.AccRowStatus = 1
		WHERE A1.RuaIdAccount = @AccountId AND A1.RuaRowStatus = 1
		ORDER BY A2.AccDateCreated DESC
		)
    BEGIN TRAN
	BEGIN TRY
		SET NOCOUNT ON; 
	
	DECLARE  @isSuscription AS BIT 


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
	 SELECT
        @AccountId,
        @CustomerId,
        @OrderNumber,
        @NameTax,
        @FiscalAddress,
        @TaxId,
		(Select Case WHEN  T.TypeSalePackage ='Suscription' THEN 1 ELSE 0 END ),
        @IsAutoRenewable,
        @CardId,
        @Token,
        GETDATE(),
        @InvoiceEmail,
        @Vaucher,
        T.IdSalePackage,
        T.TypeSalePackage
    FROM @TblSalePackageMarketPlace AS T;

	COMMIT TRAN

	SELECT 1 AS 'ResultCode' 



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