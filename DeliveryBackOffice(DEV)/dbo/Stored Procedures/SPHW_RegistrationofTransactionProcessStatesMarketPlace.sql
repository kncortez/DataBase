
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date, 2024-01-08>
-- Description:	<Description,Insertar registro que indica inicio del  proceso de una transacción de compra carrito marketplace>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_RegistrationofTransactionProcessStatesMarketPlace] 
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
@ImageURL NVARCHAR(600) = NULL,
@PhoneNumber AS NVARCHAR(10)=NULL

	
AS
BEGIN
	
	

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
	 TypeSalePackage,
	 ProductGiftShippingEmail,
	 [PaymentImageURL],
	 PhoneNumber
	)
	 SELECT
        CASE 
			   WHEN  
					EXISTS(SELECT  TOP 1 1
										FROM [dbo].RegisterUser  usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
										WHERE usr.UsrEmail = T.ProductGiftShippingEmail AND rus.RusIdSystem = 1
										AND rua.RuaRowStatus = 1 AND ac.AccRowStatus = 1 AND res.UstStatus  ='ACTIVE') 
							
							THEN  
							      
							(SELECT   ac.AccIdAccount
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
														WHERE usr.UsrEmail = ISNULL(T.ProductGiftShippingEmail,'N/D')
														AND rus.RusIdSystem = 1 AND rua.RuaRowStatus = 1
														AND ac.AccRowStatus = 1 AND res.UstStatus  ='ACTIVE')
				
							ELSE  @AccountId

							END,
                CASE
						  WHEN  EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
														WHERE usr.UsrEmail = T.ProductGiftShippingEmail AND rus.RusIdSystem = 1
														AND rua.RuaRowStatus = 1 AND ac.AccRowStatus = 1
														AND res.UstStatus  ='ACTIVE') 
															
							
							THEN  
							      
							(SELECT   ac. IdCustomer
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
														WHERE usr.UsrEmail = ISNULL(T.ProductGiftShippingEmail,'N/D')
														AND rus.RusIdSystem = 1 AND rua.RuaRowStatus = 1
														AND ac.AccRowStatus = 1 AND res.UstStatus  ='ACTIVE')
				
							ELSE  @CustomerId

							END,

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
		@ImageURL,
		@PhoneNumber
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
