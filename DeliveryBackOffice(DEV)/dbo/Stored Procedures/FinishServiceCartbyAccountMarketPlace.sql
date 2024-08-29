

-- =============================================
-- Author:		<Edelman>
-- Create date: <2023-12-4>
-- Description:	<Finaliza un carrito de compra MarcketPlace>
-- =============================================
ALTER PROCEDURE [dbo].[FinishServiceCartbyAccountMarketPlace]
    @IdAccount BIGINT= NULL,
	@Token NVARCHAR(50),
	@ProductInvoiceName NVARCHAR(250),
	@ProductPurchaseEmail NVARCHAR(100),
	@ProductTaxIdNumber NVARCHAR(25),
	@ProductFiscalAddress NVARCHAR(500),
	@TblProductsList [TblProductMarketPlace]  READONLY,
	@IdServiceCart  INT=NULL,
	@CardId INT=NULL,
    @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @VoidedCart BIT = 0;

	DECLARE @CollectPaymentTime INT = (SELECT TOP 1 CPT.TimePlaId FROM [DeliveryBackOffice].[dbo].[CatPaymentTime] CPT WHERE CPT.TimePlaName = 'Destino' );

	DECLARE @CountUpdated INT = 0;
	DECLARE @CountValid INT= 0;
	DECLARE @AccountStatement NVARCHAR(100)='';

	IF @IdAccount IS NOT NULL
		BEGIN
		 SET @CountValid  = (Select TOP 1 1 From [dbo].[Account] Where AccIdAccount= @IdAccount And AccRowStatus=1);

		END
	DECLARE @IdCustomer INT =(SELECT Top 1 IdCustomer  FROM [dbo].[Account]
                              WHERE AccIdAccount = ISNULL(@IdAccount,0))

    DECLARE @IdCart INT;
	IF(EXISTS(Select TOP 1 1 From [dbo].[Account] Where AccIdAccount= @IdAccount And AccRowStatus=1))
	  BEGIN
		SELECT TOP 1
			@IdCart = [IdMarketplaceCart]
		FROM [dbo].[MarketplaceCart]
		WHERE ISNULL(AccountId,0) = @IdAccount
		AND RowStatus = 1
	  END
	  ELSE
	   BEGIN
	     SELECT TOP 1
			@IdCart = [IdMarketplaceCart]
		FROM [dbo].[MarketplaceCart]
		WHERE ISNULL(RegisterUserId,0) = @IdAccount
		AND RowStatus = 1

	  END

	      SET	@IdServiceCart = (Select 
	                       Top 1 a.IdMarketplaceCartDetail
	                   From [dbo].[MarketplaceCartDetail] a	WITH(NOLOCK)  
		                    WHERE  a.MarketplaceCartId = ISNULL(@IdCart,0) And a.RowStatus=1)	

SET @AccountStatement =	(SELECT
							 ISNULL(res.UstStatus, 'N/A')
						FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
							INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
								ON rus.RusIdUser = usr.UsrIdUser
							LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
								ON res.UstIdUser = rus.RusIdUser
								   AND res.UstIdSystem = rus.RusIdSystem
							LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
								ON rua.RuaIdUser = usr.UsrIdUser
								   AND rua.RuaRowStatus = 1
							INNER JOIN [dbo].Account              ac WITH (NOLOCK)
								ON ac.AccIdAccount = rua.RuaIdAccount
						WHERE usr.UsrEmail = @ProductPurchaseEmail AND rus.RusIdSystem = 1
							  AND ac.AccRowStatus = 1)
         

	DECLARE @UpdatedGuidesInCart AS TABLE (
		IdUpdated INT
	);

	BEGIN TRANSACTION

	BEGIN TRY

	-- Generar tres letras aleatorias excluyendo "I" y "O"
		DECLARE @letras NVARCHAR(3)
		SET @letras = 
			(SELECT TOP 1
				CASE 
					WHEN number < 8 THEN CHAR(number + 65)  -- Convertir número a letra (A=65, B=66, ..., H=72)
					ELSE CHAR(number + 73)  -- Saltar las letras "I" y "O"
				END
			 FROM master.dbo.spt_values
			 WHERE type = 'P' AND number BETWEEN 0 AND 25
			 ORDER BY NEWID()
			);

		  -- Generar dos dígitos para el ID del producto (suponiendo que sea un número aleatorio)
			DECLARE @idProducto INT
			SET @idProducto = ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) % 1000000;  -- Se obtiene un número entre 0 y 999999

			-- Generar una letra aleatoria para la posición final
			DECLARE @letraFinal NVARCHAR(1)
			SET @letraFinal = CHAR((ABS(CHECKSUM(NEWID())) % 26) + 65);  -- Obtener un número entre 65 (A) y 90 (Z)


			

	-- Insertar registro de los productos que se adquirieron
	INSERT [dbo].[Product] (
	                        [CatProductId],
							[ProductCost],
							[ProductPurchaseEmail],
							[ProductGiftShippingEmail],
							[ProductCustomerId],
							[ProductAccountId],
							[ProductCodeOfReference],
							[ProductVisitPointclientByClientPortfolioId],
							[ProductInvoiceName],
							[ProductTaxIdNumber],
							[ProductFiscalAddress], 
							[ProductCustomerPaymentId],
							[ProductIsAutoRenewable],
							[ProductMaxServiceFixedValue],
							[ProductActualServiceCount],
							[ProductExpirationDate],
							[ProductDiscountValue],
							[ProductCatProductSupplierId],
							[ProductCatPointsAccumulation],
							[ProductCatConfigPointsId],
							[ProductCatSystemId],
							[ProductCatModuleId],
							[ArticleSAPId],
							[RowStatus], 
							[TokenCreated],
							[DateCreated],
							[ActivationCode])
				SELECT 
				        CP.IdCatProduct,
						CP.CatProductCost,
						@ProductPurchaseEmail,
						PL.ProductGiftShippingEmail,
						@IdCustomer,
						@IdAccount, 
						NULL,
						NULL,
						@ProductInvoiceName,
						@ProductTaxIdNumber,
						@ProductFiscalAddress,
						@CardId,--identifcador de tarjeta
						0,--es autorenovable
						0,
						1,
						GETDATE()+(ISNULL(CP.CatProductVality,1)*30),
						0,--descuento
						CP.CatProductSupplierId,
						CP.PointsAccumulation,
						CP.CatConfigPointsId,
						18,
						22,
						CP.ArticleSAPId, 
						CASE 
						    WHEN PL.IsGift = 1 AND (SELECT  ISNULL(res.UstStatus, 'N/A')
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
														WHERE usr.UsrEmail = PL.ProductGiftShippingEmail AND rus.RusIdSystem = 1
															  AND ac.AccRowStatus = 1) ='ACTIVE'
							
							THEN 1
							WHEN PL.IsGift = 0 AND @IdAccount IS NOT NULL AND @AccountStatement = 'ACTIVE'  THEN 1
							ELSE 0
							END,
						@Token,
						GETDATE(),
						(SELECT TOP 1
							CASE 
								WHEN number < 8 THEN CHAR(number + 65)  -- Convertir número a letra (A=65, B=66, ..., H=72)
								ELSE CHAR(number + 73)  -- Saltar las letras "I" y "O"
							END
						 FROM master.dbo.spt_values
						 WHERE type = 'P' AND number BETWEEN 0 AND 25
						 ORDER BY NEWID()
						) + RIGHT('000000' + CAST(CP.IdCatProduct AS NVARCHAR(6)), 6) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 65)
				FROM @TblProductsList PL 
				INNER JOIN dbo.CatProduct CP WITH(NOLOCK)
				ON PL.IdCatProduct = CP.IdCatProduct 
			

			-------------------------Facturación------------------------------------------------------------

			 DECLARE @inv_vpCodeOfReferences AS INT =
            (
                SELECT TOP 1
                       [VPC].[CodeOfReference]
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                WHERE VPC.[DescriptionOfClient] = 'EXPRESS CENTER CLUBFORZA' 
                      AND VPC.[StatusClient] = 1
                      AND CountryId = @IdCountry
            );
			DECLARE @inv_cmp_nit AS VARCHAR(100) =
					(
						SELECT dpf_FELEntity
						FROM [dbo].[del_ParametrosFactura] WITH (NOLOCK)
						WHERE dpf_VpCodeOfReference = @inv_vpCodeOfReferences
					);
			DECLARE @inv_cli_name AS VARCHAR(200)=@ProductInvoiceName;
			DECLARE @inv_cli_adress AS VARCHAR(200)=@ProductFiscalAddress;
			DECLARE @inv_cli_nit AS VARCHAR(200)=@ProductTaxIdNumber;
			DECLARE @inv_cli_email AS VARCHAR(200)=@ProductPurchaseEmail;
			DECLARE @inv_date AS DATETIME = GETDATE();
			DECLARE @inv_IVA AS MONEY;
			DECLARE @inv_amount AS MONEY;
			DECLARE @inv_status AS INT = 1;
			DECLARE @inv_dateRegister DATETIME = GETDATE();
			DECLARE @inv_tokenRegister VARCHAR(200) = @Token;
			DECLARE @typeMoneyId AS INT;

	
   
    ------------------------------------------------------------------------------------
    --Datos detalle de factura
    DECLARE @dti_fk_header BIGINT;

    DECLARE @dti_identification VARCHAR(200) = 'SERVICIO';
    DECLARE @dti_category VARCHAR(50) = 'SERVICIO';
    DECLARE @dti_quantity DECIMAL(10, 5) = 1;
    DECLARE @dti_measurement VARCHAR(20) = 'UND';
    DECLARE @dti_priceUnit MONEY;
    DECLARE @dti_description VARCHAR(MAX) =
            (
                SELECT TOP 1
                       [Description]
                  FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
                 WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' 
                   AND IdCountry = @IdCountry
            );
    DECLARE @dti_IVA MONEY;
    DECLARE @dti_amount MONEY;
    DECLARE @dti_dateRegister DATETIME = GETDATE();
    DECLARE @dti_tokenRegister VARCHAR(200) = @Token;
    DECLARE @SAPCode NVARCHAR(50) =
            (
                SELECT TOP 1
                       SAPCode
                FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' 
                  AND IdCountry = @IdCountry
            );
    DECLARE @SendToInvoice BIT = 1;
    DECLARE @Descriptionp AS NVARCHAR(500);
    DECLARE @SuscriptionDesc AS NVARCHAR(200);
    DECLARE @Authorizacion AS NVARCHAR(20);
    DECLARE @IdMemberOrSuscription AS NVARCHAR(200);
    DECLARE @MembershipId AS INT = NULL;
    DECLARE @SubscriptionId AS INT = NULL;

	

        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL A'
          AND IdCountry = @IdCountry
    );
   
       
        
    IF (@ProductPurchaseEmail = '')
    BEGIN

        SET @ProductPurchaseEmail =
        (
            SELECT TOP 1
                   P.ProductPurchaseEmail
            FROM [DeliveryBackOffice].[dbo].[Product] P
            WHERE [P].[ProductAccountId] = ISNULL(@IdAccount,0)
            ORDER BY P.DateCreated DESC

        );

    END;

	 SELECT 
                   @inv_amount            = SUM(P.CatProductCost)
                -- , @inv_cli_email         = P.ProductPurchaseEmail
                -- , @inv_cli_adress        = P.ProductFiscalAddress
             --    , @inv_cli_nit           = REPLACE(P.ProductTaxIdNumber, '-', '')
             --    , @inv_cli_name          = P.ProductInvoiceName
                 , @inv_IVA               = SUM(P.CatProductCost - (P.CatProductCost / 1.12))
               --  , @Descriptionp          = CP.CatProductName
               --  , @IdMemberOrSuscription = P.CatProductId
               --  , @MembershipId          = P.CatProductId
            FROM @TblProductsList PL 
			      INNER JOIN [DeliveryBackOffice].[dbo].[CatProduct] P WITH (NOLOCK)
				    ON PL.IdCatProduct = P.IdCatProduct
                 
				
            
			
         

            SELECT @Authorizacion = MOL.[TransactionOrder]
                 , @typeMoneyId   = MOL.TypeOfInOutOfMoneyId
            FROM [dbo].[MembershipPaymentLog] MOL WITH (NOLOCK)
            WHERE MembershipId = @IdMemberOrSuscription
            ORDER BY MOL.DateCreated DESC;

			
                SET @dti_description = @dti_description + ' ' + @Descriptionp;

                SELECT TOP 1
                       @Authorizacion = SOL.OrderNumber
                     , @typeMoneyId   = 2
                FROM [dbo].[RegistrationofTransactionProcessStates] SOL WITH (NOLOCK)
                WHERE SOL.AccountId = ISNULL(@IdAccount,0)
                ORDER BY SOL.DateCreated DESC;


       INSERT INTO [dbo].[invoiceHeader]
        (
            inv_vpCodeOfReferences
          , inv_cmp_nit
          , inv_cli_name
          , inv_cli_adress
          , inv_cli_nit
          , inv_cli_email
          , inv_date
          , inv_IVA
          , inv_amount
          , inv_status
          , inv_dateRegister
          , inv_tokenRegister
          , inv_type
        )
        VALUES
        (@inv_vpCodeOfReferences, @inv_cmp_nit, @inv_cli_name, @inv_cli_adress, @inv_cli_nit, @inv_cli_email, @inv_date
       , @inv_IVA, @inv_amount, @inv_status, @inv_dateRegister, @inv_tokenRegister, 1);



        SET @dti_fk_header = SCOPE_IDENTITY();

        INSERT INTO [dbo].[invoiceDetail]
        (
            dti_fk_header
          , dti_identification
          , dti_category
          , dti_quantity
          , dti_measurement
          , dti_priceUnit
          , dti_description
          , dti_IVA
          , dti_amount
          , dti_dateRegister
          , dti_tokenRegister
          , SAPCode
          , SendToInvoice
          , MembershipId
          , SubscriptionId
        )
        SELECT
           @dti_fk_header,
		   @dti_identification,
		   @dti_category,
		   @dti_quantity,
		   @dti_measurement,
		   CP.CatProductCost,
           CP.CatProductDescription,
		   CP.CatProductCost - (CP.CatProductCost / 1.12),
		   CP.CatProductCost,
		   @dti_dateRegister,
		   @dti_tokenRegister,
		   @SAPCode, 
		   @SendToInvoice,
           NULL, 
		   NULL--PL.IdCatProduct
		FROM @TblProductsList PL 
			INNER JOIN [dbo].[CatProduct] CP WITH(NOLOCK)
		ON PL.IdCatProduct = CP.IdCatProduct 
		
		INSERT INTO [dbo].[InOutOfMoneyDetail]
        (
            [io_type]
          , [io_vpCodeOfReferences]
          , [io_ticket]
          , [io_amount]
          , [io_status]
          , [io_invoice]
          , [io_registryToken]
          , [io_registryDate]
        )
        VALUES
       (2, @inv_vpCodeOfReferences, @Authorizacion, @inv_amount, @inv_status, @dti_fk_header, @Token, GETDATE());

    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------
			

	
		

		-- Si se puede finalizar el carrito de compras
		IF(EXISTS(Select Top 1 1 From [dbo].[MarketplaceCartDetail] a	WITH(NOLOCK)  
		                         WHERE  a.IdMarketplaceCartDetail = ISNULL(@IdServiceCart,0) And a.RowStatus=1))
		BEGIN
		
			UPDATE  [dbo].[MarketplaceCartDetail]
			  SET RowStatus = 0,
				  TokenUpdated = @Token,
				  DateUpdated  = GETDATE()
			  WHERE  MarketplaceCartId = @IdCart

			UPDATE  [dbo].[MarketplaceCart]
			  SET RowStatus = 0,
				  TokenUpdated = @Token,
				  DateUpdated  = GETDATE()
			  WHERE   IdMarketplaceCart = @IdCart


			-- Si actualizo el carrito exitosamente
			IF (@@ROWCOUNT > 0)
			BEGIN
				SET @VoidedCart = 1;
				SELECT
				    @dti_fk_header 'IdInvoice',
					1 'StatusCode'
					,'Service Cart finished successfully' 'Description'
			END
			ELSE
				SELECT
				2 'StatusCode'
			   ,'Service Cart not found' 'Description'
			
		END
		ELSE
		BEGIN

			SELECT
			    @dti_fk_header 'IdInvoice',
				1 'StatusCode'
				,'Service Cart partially finished' 'Description'

		END

		COMMIT TRANSACTION;

    END TRY
	BEGIN CATCH
		
		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';
				
		ROLLBACK TRANSACTION;
	END CATCH
END
