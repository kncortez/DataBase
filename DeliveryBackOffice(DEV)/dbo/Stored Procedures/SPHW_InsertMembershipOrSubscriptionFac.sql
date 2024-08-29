
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2020-01-08>
-- Description:	<Integración de marketplace  a estrcutura club forza para facturación usuarios logueados y no logueados>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-08-20>
-- Description: <Se agrego filtro por pais, se filtra CodeOfReference para facturacion, calculo de IVA obtenido de configParams>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-08-26>
-- Description: < Ajustes por tienda virtual para Facturar>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_InsertMembershipOrSubscriptionFac]
 @OrderNumber AS NVARCHAR(25),
 @IdCountry   AS NVARCHAR(2) = 'GT'
AS
BEGIN

    -- Datos cliente Cabecera de factura   

    DECLARE @idType INT = 0;
    DECLARE @TypeSalePackage AS NVARCHAR(50)
    DECLARE @IdSalePackage INT
    DECLARE @IdAccount INT
    DECLARE @systemOrigen INT = 0
    DECLARE @Token AS VARCHAR(200)
  -- Datos de Facturación
    DECLARE @TaxId NVARCHAR(50) = 'CF'
    DECLARE @FiscalAddress NVARCHAR(200) = 'Guatemala'
    DECLARE @TaxName NVARCHAR(100) = 'Consumidor Final'
    DECLARE @InvoiceEmail NVARCHAR(50) =''
	DECLARE @Vaucher NVARCHAR(50) =''
    DECLARE @Iva DECIMAL(12,6) = 1.12
    DECLARE @IdCurrency INT 

    SELECT @Iva = ISNULL([Value],1.12)
      FROM ConfigParams
     WHERE [Name] = 'TaxPercentage'
       AND IdCountry = @IdCountry

	SELECT Top 1 
	    @TypeSalePackage = TypeSalePackage  
	  , @IdSalePackage = IdSalePackage             
	  , @IdAccount = AccountId              
	  , @Vaucher =Vaucher           
	  , @Token = TokenCreated
	  , @TaxId = TaxId
	  , @FiscalAddress =AddressTax
	  , @TaxName =  NameTax
	  , @InvoiceEmail  = InvoiceEmail
  FROM dbo.RegistrationofTransactionProcessStates Where OrderNumber= @OrderNumber

  DECLARE @IdAccountCart INT = (SELECT   ac.AccIdAccount
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
														WHERE usr.UsrEmail = @InvoiceEmail AND rus.RusIdSystem = 1
                                                             AND ac.AccRowStatus = 1
														     AND res.UstStatus  ='ACTIVE')


    DECLARE @inv_vpCodeOfReferences AS INT =
            (
                SELECT TOP 1
                       [VPC].[CodeOfReference]
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                WHERE VPC.[DescriptionOfClient] = 'EXPRESS CENTER CLUBFORZA' 
                      AND VPC.[StatusClient] = 1
                      AND ISNULL(VPC.CountryId,'GT') = @IdCountry
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
           @inv_cli_name   = InvoiceName
         , @inv_cli_nit    = TaxIdNumber
         , @inv_cli_email  = InvoiceEmail
         , @inv_cli_adress = FiscalAddress
    FROM [DeliveryBackOffice].[dbo].[Membership] M
    WHERE [M].[AccountId] = @IdAccountCart
          AND [M].[RowStatus] = 1
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
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' 
                  AND ISNULL(IdCountry,'GT') = @IdCountry
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
                  AND ISNULL(IdCountry,'GT') = @IdCountry
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
               ISNULL(SubscriptionName, '')
        FROM [dbo].[CatSubscription] WITH (NOLOCK)
        WHERE IdCatSubscription = @IdSalePackage
          AND ISNULL(IdCountry,'GT') = @IdCountry
    );

    IF (
           @SuscriptionDesc = 'Plan Básico'
           AND @TypeSalePackage <> 'Membership' 
       )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL A' 
          AND ISNULL(IdCountry,'GT') = @IdCountry
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Básico +'
                AND @TypeSalePackage <> 'Membership' 
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL B' 
          AND ISNULL(IdCountry,'GT') = @IdCountry
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Gold'
                AND @TypeSalePackage <> 'Membership' 
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL C' 
          AND ISNULL(IdCountry,'GT') = @IdCountry
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Corporativo'
                AND @TypeSalePackage <> 'Membership' 
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL D' 
          AND ISNULL(IdCountry,'GT') = @IdCountry
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Diamante'
                AND @TypeSalePackage <> 'Membership' 
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'MEMBRESIA DIAMANTE' 
          AND ISNULL(IdCountry,'GT') = @IdCountry
    )   ;

    IF (@InvoiceEmail = '')
    BEGIN

        SET @InvoiceEmail =
        (
            SELECT TOP 1
                   InvoiceEmail
            FROM [DeliveryBackOffice].[dbo].[Membership] M
            WHERE [M].[AccountId] = @IdAccountCart
                  AND [M].[RowStatus] = 1
        );

    END;

	


    BEGIN TRANSACTION;
    BEGIN TRY

        IF (Exists(SELECT Top 1 1 FROM dbo.RegistrationofTransactionProcessStates Where OrderNumber = @OrderNumber 
                AND TypeSalePackage = 'MEMBERSHIP' ))
        BEGIN

            SELECT TOP 1
                   @inv_amount            = M.MembershipCost
                 , @inv_cli_email         = M.InvoiceEmail
                 , @inv_cli_adress        = M.FiscalAddress
                 , @inv_cli_nit           = REPLACE(M.TaxIdNumber, '-', '')
                 , @inv_cli_name          = M.InvoiceName
                 , @inv_IVA               = M.MembershipCost - (M.MembershipCost / @Iva)
                 , @Descriptionp          = CM.MembershipName
                 , @IdMemberOrSuscription = M.IdMembership
                 , @MembershipId          = M.IdMembership
            FROM [DeliveryBackOffice].[dbo].[Membership] M WITH (NOLOCK)
                INNER JOIN [dbo].[CatMembership]         CM WITH (NOLOCK)
                    ON M.CatMembershipId = CM.IdCatMembership
				INNER JOIN 
					[dbo].[RegistrationofTransactionProcessStates] RTP WITH (NOLOCK)
					ON M.CatMembershipId = RTP.IdSalePackage
            WHERE-- M.AccountId = @IdAccount
                --  AND M.RowStatus = 1
				   RTP.OrderNumber = @OrderNumber 
            ORDER BY M.DateCreated DESC;

            SELECT @Authorizacion = MOL.[TransactionOrder]
                 , @typeMoneyId   = MOL.TypeOfInOutOfMoneyId
            FROM [dbo].[MembershipPaymentLog] MOL WITH (NOLOCK)
            WHERE MembershipId = @IdMemberOrSuscription
            ORDER BY MOL.DateCreated DESC;


        END
       
	    IF (Exists(SELECT Top 1 1 FROM dbo.RegistrationofTransactionProcessStates Where OrderNumber = @OrderNumber 
                AND TypeSalePackage != 'MEMBERSHIP' ))
            BEGIN
                SELECT TOP 1
                       @inv_amount            = S.SubscriptionCost
                     , @inv_cli_email         = @InvoiceEmail
                     , @inv_cli_adress        = @FiscalAddress
                     , @inv_cli_nit           = REPLACE(@TaxId, '-', '')
                     , @inv_cli_name          = @TaxName
                     , @inv_IVA               = S.SubscriptionCost - (S.SubscriptionCost / @Iva)
                     , @Descriptionp          = CS.SubscriptionName
                     , @IdMemberOrSuscription = S.IdSubscription
                     , @SubscriptionId        = [S].[IdSubscription]
                FROM [dbo].[Subscription] S WITH (NOLOCK)

                    INNER JOIN dbo.CatSubscription  CS
                        ON S.CatSubscriptionId = CS.IdCatSubscription
					INNER JOIN 
					[dbo].[RegistrationofTransactionProcessStates] RTP WITH (NOLOCK)
					ON CS.IdCatSubscription = RTP.IdSalePackage
                WHERE --S.AccountId = @IdAccount
                      --AND S.RowStatus = 1
                       RTP.OrderNumber = @OrderNumber 
                ORDER BY S.DateCreated DESC;

                --SET @dti_description = @dti_description + ' ' + @Descriptionp;

                SELECT TOP 1
                       @Authorizacion = SOL.TransactionOrder
                     , @typeMoneyId   = SOL.TypeOfInOutOfMoneyId
                FROM [dbo].[SubscriptionPaymentLog] SOL WITH (NOLOCK)
                WHERE SubscriptionId = @IdMemberOrSuscription
                ORDER BY SOL.DateCreated DESC;

                IF (ISNULL(@TaxId, 'CF') <> 'CF')
                BEGIN
                    UPDATE [M]
                    SET InvoiceName = @TaxName
                      , TaxIdNumber = @TaxId
                      , InvoiceEmail = @InvoiceEmail
                      , FiscalAddress = @FiscalAddress
                    FROM [DeliveryBackOffice].[dbo].[Membership] M
                    WHERE [M].[AccountId] = @IdAccountCart
                          AND [M].[RowStatus] = 1;
                END;

            END;
            


		
          SELECT 
                 @inv_amount =    SUM(  ISNULL((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)) , CM.MembershipCost) ) ,
                @inv_IVA =      SUM(ISNULL((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)), CM.MembershipCost) - (ISNULL((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)), CM.MembershipCost) / @Iva))
			 FROM  [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates] RTPS WITH (NOLOCK)
		          LEFT JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
			      ON CS.IdCatSubscription = RTPS.IdSalePackage
				  AND RTPS.TypeSalePackage !='MEMBERSHIP' 
				  LEFT JOIN [DeliveryBackOffice].[dbo].[CatMembership] CM WITH (NOLOCK)
				  ON  CM.IdCatMembership =  RTPS.IdSalePackage
				    AND RTPS.TypeSalePackage ='MEMBERSHIP' 
			WHERE RTPS.OrderNumber = @OrderNumber

        SET @systemOrigen = (
                             SELECT TOP 1 SysIdSystem
                               FROM DeliveryBackOffice.dbo.CatSystem
                              WHERE SysNameSystem = 'Tienda Virtual'
                            )

        SET @idType = (SELECT IdCatInvoiceType
                         FROM CatInvoiceType 
                        WHERE Name = 'Otros')

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
          , systemOperation
          , CatInvoiceTypeId
        )
        VALUES
        (@inv_vpCodeOfReferences, @inv_cmp_nit, ISNULL(@inv_cli_name,'CF'), @inv_cli_adress, @inv_cli_nit, @inv_cli_email, @inv_date
       , @inv_IVA, @inv_amount, @inv_status, @inv_dateRegister, @inv_tokenRegister, 1, @systemOrigen, @idType);



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
		    (CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0))	
		   ,CS.SubscriptionName	
		   ,(CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)) -((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)) / @Iva)
		   ,(CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0))
		   ,@dti_dateRegister
		   ,@dti_tokenRegister
		   ,@SAPCode
		   ,@SendToInvoice
		   ,NULL IdMembership
           ,S.IdSubscription	
		FROM [dbo].[Subscription] S WITH (NOLOCK)
                    INNER JOIN dbo.CatSubscription  CS
                        ON S.CatSubscriptionId = CS.IdCatSubscription
					INNER JOIN 
					[dbo].[SubscriptionPaymentLog] SPL WITH (NOLOCK)
					ON  S.IdSubscription = SPL.SubscriptionId
					  WHERE 
                       SPL.[Authorization] = @OrderNumber
        UNION ALL
			SELECT 
		   @dti_fk_header,
		   @dti_identification,
		   @dti_category,
		   @dti_quantity,
		   @dti_measurement,
		   CS.MembershipCost	
		   ,CS.MembershipName	
		   ,CS.MembershipCost -((CS.MembershipCost) / @Iva)
		   ,CS.MembershipCost
		   ,@dti_dateRegister
		   ,@dti_tokenRegister
		   ,@SAPCode
		   ,@SendToInvoice
		   ,S.IdMembership
           ,NULL IdSubscription	 
		 FROM [dbo].[Membership] S WITH (NOLOCK)
                    INNER JOIN dbo.CatMembership  CS
                        ON S.CatMembershipId = CS.IdCatMembership
					INNER JOIN 
					[dbo].[MembershipPaymentLog] SPL WITH (NOLOCK)
					ON  S.IdMembership = SPL.MembershipId
				
                WHERE 
                       SPL.[Authorization] = @OrderNumber

        SELECT @IdCountry = T.IdCountry,
               @IdCurrency = T.IdCatCurrencyCOD
          FROM (
                SELECT IdCountry,
                       IdCatCurrencyCOD
                  FROM [dbo].[Subscription] S WITH (NOLOCK)
                       INNER JOIN dbo.CatSubscription  CS
                          ON S.CatSubscriptionId = CS.IdCatSubscription
                       INNER JOIN [dbo].[SubscriptionPaymentLog] SPL WITH (NOLOCK)
                          ON  S.IdSubscription = SPL.SubscriptionId
                  WHERE SPL.[Authorization] = @OrderNumber
                  UNION
                 SELECT IdCountry,
                        IdCatCurrencyCOD
                   FROM [dbo].[Membership] S WITH (NOLOCK)
                        INNER JOIN dbo.CatMembership  CS
                           ON S.CatMembershipId = CS.IdCatMembership
                        INNER JOIN [dbo].[MembershipPaymentLog] SPL WITH (NOLOCK)
                           ON  S.IdMembership = SPL.MembershipId
                        WHERE SPL.[Authorization] = @OrderNumber
               ) AS T

        UPDATE [invoiceHeader]
           SET IdCountry = @IdCountry,
               IdCurrency = @IdCurrency
         WHERE inv_pk_id = @dti_fk_header


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
        (2, @inv_vpCodeOfReferences, @Authorizacion, @inv_amount, @inv_status, @dti_fk_header, @Token
       , GETDATE());

	     DECLARE @IdCart INT =(select  Top 1 IdMarketplaceCart from dbo.MarketplaceCart where AccountId = @IdAccountCart ORDER BY DateCreated DESC)

		 UPDATE  [dbo].[MarketplaceCartDetail]
			  SET RowStatus = 0,
				  TokenUpdated = @Token,
				  DateUpdated  = GETDATE()
			  WHERE  MarketplaceCartId = @IdCart

			UPDATE  [dbo].[MarketplaceCart]
			  SET RowStatus = 0,
				  TokenUpdated = @Token,
				  DateUpdated  = GETDATE()
			  WHERE IdMarketplaceCart = @IdCart

        COMMIT TRANSACTION;

        SELECT Result                = 1
             , 'Transacción exitosa' AS 'Description'
             , @dti_fk_header        IdInvoice
             , @inv_cli_email        inv_cli_email
             , @Token                Token
             , @inv_vpCodeOfReferences inv_vpCodeOfReferences
             , ISNULL(@inv_cli_name,'CF') inv_cli_name;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT Result          = 0
             , ERROR_MESSAGE() AS 'Description'
             , IdInvoice       = 0
             , @dti_fk_header  IdInvoice
             , @inv_cli_email  inv_cli_email
             , @Token          Token
             , @inv_vpCodeOfReferences inv_vpCodeOfReferences
             , ISNULL(@inv_cli_name,'') inv_cli_name;

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
