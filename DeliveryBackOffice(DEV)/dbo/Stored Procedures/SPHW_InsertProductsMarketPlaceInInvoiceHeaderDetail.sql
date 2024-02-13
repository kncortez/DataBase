
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2024-03-01>
-- Description:	<Guardar data de facturación de productos marketplace>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_InsertProductsMarketPlaceInInvoiceHeaderDetail]
    @TypeSalePackage AS NVARCHAR(50)
  , @IdSalePackage INT
  , @IdAccount INT
  , @Token AS VARCHAR(200)
  -- Datos de Facturación
  , @TaxId NVARCHAR(50) = 'CF'
  , @FiscalAddress NVARCHAR(200) = 'Guatemala'
  , @TaxName NVARCHAR(100) = 'Consumidor Final'
  , @InvoiceEmail NVARCHAR(50) = ''
AS
BEGIN

    -- Datos cliente Cabecera de factura   


    DECLARE @inv_vpCodeOfReferences AS INT =
            (
                SELECT TOP 1
                       [VPC].[CodeOfReference]
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                WHERE VPC.[DescriptionOfClient] = 'EXPRESS CENTER CLUBFORZA' COLLATE Latin1_General_CI_AI
                      AND VPC.[StatusClient] = 1
            );
    DECLARE @inv_cmp_nit AS VARCHAR(100) =
            (
                SELECT dpf_FELEntity
                FROM [dbo].[del_ParametrosFactura] WITH (NOLOCK)
                WHERE dpf_VpCodeOfReference = @inv_vpCodeOfReferences
            );
    DECLARE @inv_cli_name AS VARCHAR(200);
    DECLARE @inv_cli_adress AS VARCHAR(200);
    DECLARE @inv_cli_nit AS VARCHAR(200);
    DECLARE @inv_cli_email AS VARCHAR(200);
    DECLARE @inv_date AS DATETIME = GETDATE();
    DECLARE @inv_IVA AS MONEY;
    DECLARE @inv_amount AS MONEY;
    DECLARE @inv_status AS INT = 1;
    DECLARE @inv_dateRegister DATETIME = GETDATE();
    DECLARE @inv_tokenRegister VARCHAR(200) = @Token;
    DECLARE @typeMoneyId AS INT;
    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------

    SELECT TOP 1
           @inv_cli_name   = P.ProductInvoiceName
         , @inv_cli_nit    = P.ProductTaxIdNumber
         , @inv_cli_email  = P.ProductPurchaseEmail
         , @inv_cli_adress = P.ProductFiscalAddress
    FROM [DeliveryBackOffice].[dbo].[Product] P
    WHERE [P].[ProductAccountId] = @IdAccount
          --AND [P].[RowStatus] = 1
    ORDER BY DateCreated DESC;
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
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' COLLATE Latin1_General_CI_AI
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
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' COLLATE Latin1_General_CI_AI
            );
    DECLARE @SendToInvoice BIT = 1;
    DECLARE @Descriptionp AS NVARCHAR(500);
    DECLARE @SuscriptionDesc AS NVARCHAR(200);
    DECLARE @Authorizacion AS NVARCHAR(20);
    DECLARE @IdMemberOrSuscription AS NVARCHAR(200);
    DECLARE @MembershipId AS INT = NULL;
    DECLARE @SubscriptionId AS INT = NULL;

    SET @SuscriptionDesc =
    (
        SELECT TOP 1
               ISNULL(CP.CatProductDescription , '')
        FROM [dbo].[CatProduct] CP WITH (NOLOCK)
        WHERE IdCatProduct = @IdSalePackage
    );

        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL A' COLLATE Latin1_General_CI_AI
    );
   
       
        
    IF (@InvoiceEmail = '')
    BEGIN

        SET @InvoiceEmail =
        (
            SELECT TOP 1
                   P.ProductPurchaseEmail
            FROM [DeliveryBackOffice].[dbo].[Product] P
            WHERE [P].[ProductAccountId] = @IdAccount
            ORDER BY P.DateCreated DESC

        );

    END;


    BEGIN TRANSACTION;
    BEGIN TRY

       

            SELECT TOP 1
                   @inv_amount            = P.ProductCost
                 , @inv_cli_email         = P.ProductPurchaseEmail
                 , @inv_cli_adress        = P.ProductFiscalAddress
                 , @inv_cli_nit           = REPLACE(P.ProductTaxIdNumber, '-', '')
                 , @inv_cli_name          = P.ProductInvoiceName
                 , @inv_IVA               = P.ProductCost - (P.ProductCost / 1.12)
                 , @Descriptionp          = CP.CatProductName
                 , @IdMemberOrSuscription = P.CatProductId
                 , @MembershipId          = P.CatProductId
            FROM [DeliveryBackOffice].[dbo].[Product] P WITH (NOLOCK)
                INNER JOIN [dbo].[CatProduct]     CP WITH (NOLOCK)
                    ON P.CatProductId = CP.IdCatProduct
            WHERE P.ProductAccountId = @IdAccount
                  --AND P.RowStatus = 1
                  AND CP.IdCatProduct = @IdSalePackage
            ORDER BY P.DateCreated DESC;

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
                WHERE SOL.AccountId = @IdAccount
                ORDER BY SOL.DateCreated DESC;
				
			

              
          
        
                
                SET @dti_description = @dti_description + ' ' + @Descriptionp;

                SELECT TOP 1
                       @Authorizacion = SOL.TransactionOrder
                     , @typeMoneyId   = SOL.TypeOfInOutOfMoneyId
                FROM [dbo].[SubscriptionPaymentLog] SOL WITH (NOLOCK)
                WHERE SubscriptionId = @IdMemberOrSuscription
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
		   @inv_amount,
           @dti_description,
		   @inv_IVA,
		   @inv_amount,
		   @dti_dateRegister,
		   @dti_tokenRegister,
		   @SAPCode, 
		   @SendToInvoice,
           @MembershipId, 
		   @SubscriptionId
		From dbo.Product P
        

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
        --(@typeMoneyId, @inv_vpCodeOfReferences, @Authorizacion, @inv_amount, @inv_status, @dti_fk_header, @Token
       (2, @inv_vpCodeOfReferences, @Authorizacion, @inv_amount, @inv_status, @dti_fk_header, @Token
       
	   , GETDATE());

        COMMIT TRANSACTION;

        SELECT Result                = 1
             , 'Transacción exitosa' AS 'Description'
             , @dti_fk_header        IdInvoice
             , @inv_cli_email        inv_cli_email
             , @Token                Token;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT Result          = 0
             , ERROR_MESSAGE() AS 'Description'
             , IdInvoice       = 0
             , @dti_fk_header  IdInvoice
             , @inv_cli_email  inv_cli_email
             , @Token          Token;

        INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
        (
            [ErrorDescription]
          , [ErrorNumber]
          , [ErrorProcedure]
          , [ErrorLine]
          , [GuideSerie]
          , [GuideNumber]
          , [TokenCreated]
          , [DateCreated]
        )
        VALUES
        (   CAST(ERROR_MESSAGE() AS NVARCHAR(300)) -- ErrorDescription - varchar(300)
          , ERROR_NUMBER()                         -- ErrorNumber - int
          , ERROR_PROCEDURE()                      -- ErrorProcedure - varchar(100)
          , ERROR_LINE()                           -- ErrorLine - int
          , NULL                                   -- GuideSerie - nvarchar(2)
          , NULL                                   -- GuideNumber - int
          , ''                                     -- TokenCreated - varchar(50)
          , GETDATE()                              -- DateCreated - datetime
            );
    END CATCH;
END;