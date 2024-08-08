
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-05-11>
-- Description:	<Factura y limpia carrito de marketplace usario telemercadeo >
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_InsertMembershipOrSubscriptionFacTeleMarket]
 @OrderNumber AS NVARCHAR(25),
 @ImageURL NVARCHAR(600) = NULL,
 @IdCountry NVARCHAR(3)='GT'
AS
BEGIN

    -- Datos cliente Cabecera de factura   


    DECLARE @TypeSalePackage AS NVARCHAR(50)
    DECLARE @IdSalePackage INT
    DECLARE @IdAccount INT
    DECLARE @Token AS VARCHAR(200)
  -- Datos de Facturación
    DECLARE @TaxId NVARCHAR(50) = 'CF'
    DECLARE @FiscalAddress NVARCHAR(200) = 'Guatemala'
    DECLARE @TaxName NVARCHAR(100) = 'Consumidor Final'
    DECLARE @InvoiceEmail NVARCHAR(50) =''
	DECLARE @Vaucher NVARCHAR(50) =''
	DECLARE @IdTarjeta AS INT = NULL
	DECLARE @CustomerType INT = 0;
	DECLARE @ActivationCode NVARCHAR(100) = N'';

	DECLARE @AddedPointExpirationDate INT = 0;
	DECLARE @ActiveMembershipId INT = 0;

	SELECT Top 1 
	    @IdTarjeta = GetCardsCredit 
	   , @TypeSalePackage = TypeSalePackage  
	  , @IdSalePackage = IdSalePackage             
	  , @IdAccount = AccountId              
	  , @Vaucher =Vaucher           
	  , @Token = TokenCreated
	  , @TaxId = TaxId
	  , @FiscalAddress =AddressTax
	  , @TaxName =  NameTax
	  , @InvoiceEmail  = InvoiceEmail
  FROM dbo.RegistrationofTransactionProcessStates Where OrderNumber= @OrderNumber
  ORDER BY DateCreated DESC

    -- Datos del cliente para promo
    SELECT 
           @CustomerType = ISNULL(Cu.IdCustomerType, 0)
    FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
            ON Acc.IdCustomer = Cu.IdCustomer
               AND Acc.AccIdAccount = @IdAccount
    WHERE Acc.AccIdAccount = @IdAccount;


    DECLARE @inv_vpCodeOfReferences AS INT =
            (
                SELECT TOP 1
                       [VPC].[CodeOfReference]
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                WHERE VPC.[DescriptionOfClient] = 'EXPRESS CENTER CLUBFORZA' --COLLATE Latin1_General_CI_AI
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
           @inv_cli_name   = InvoiceName
         , @inv_cli_nit    = TaxIdNumber
         , @inv_cli_email  = InvoiceEmail
         , @inv_cli_adress = FiscalAddress
    FROM [DeliveryBackOffice].[dbo].[Membership] M
    WHERE [M].[AccountId] = @IdAccount
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
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' --COLLATE Latin1_General_CI_AI
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
                WHERE Name = 'MEMBRESIA ANUAL CLUB FORZA' --COLLATE Latin1_General_CI_AI
            );
    DECLARE @SendToInvoice BIT = 1;
    DECLARE @Descriptionp AS NVARCHAR(500);
    DECLARE @SuscriptionDesc AS NVARCHAR(200);
    DECLARE @Authorizacion AS NVARCHAR(20);
    DECLARE @IdMemberOrSuscription AS NVARCHAR(200);
    DECLARE @MembershipId AS INT = NULL;
    DECLARE @SubscriptionId AS INT = NULL;
	 DECLARE @ServiceAmmount DECIMAL = 0;

    SET @SuscriptionDesc =
    (
        SELECT TOP 1
               ISNULL(SubscriptionName, '')
        FROM [dbo].[CatSubscription] WITH (NOLOCK)
        WHERE IdCatSubscription = @IdSalePackage
    );

    IF (
           @SuscriptionDesc = 'Plan Básico'
           AND @TypeSalePackage <> 'Membership' --COLLATE Latin1_General_CI_AI
       )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL A' --COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Básico +'
                AND @TypeSalePackage <> 'Membership' --COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL B' --COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Gold'
                AND @TypeSalePackage <> 'Membership' --COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL C' --COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Corporativo'
                AND @TypeSalePackage <> 'Membership' --COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'SUSCRIPCION MENSUAL D' --COLLATE Latin1_General_CI_AI
    )   ;
    ELSE IF (
                @SuscriptionDesc = 'Plan Diamante'
                AND @TypeSalePackage <> 'Membership' --COLLATE Latin1_General_CI_AI
            )
        SET @dti_description =
    (
        SELECT TOP 1
               [Description]
        FROM [dbo].[CatArticleSAP] WITH (NOLOCK)
        WHERE [Name] = 'MEMBRESIA DIAMANTE' --COLLATE Latin1_General_CI_AI
    )   ;

    IF (@InvoiceEmail = '')
    BEGIN

        SET @InvoiceEmail =
        (
            SELECT TOP 1
                   InvoiceEmail
            FROM [DeliveryBackOffice].[dbo].[Membership] M
            WHERE [M].[AccountId] = @IdAccount
                  AND [M].[RowStatus] = 1
        );

    END;

	DECLARE @IdTransaction BIGINT = 0;


    BEGIN TRANSACTION;
    BEGIN TRY

	SELECT 
				@IdTransaction = [IdTransaction],
				@ServiceAmmount = [Ammount]
			FROM 
				DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH (NOLOCK)
			WHERE 
				OrderNumber = @OrderNumber;

        IF (Exists(SELECT Top 1 1 FROM dbo.RegistrationofTransactionProcessStates Where OrderNumber = @OrderNumber 
                AND TypeSalePackage = 'MEMBERSHIP')) --COLLATE Latin1_General_CI_AI
        BEGIN

            SELECT TOP 1
                   @inv_amount            = M.MembershipCost
                 , @inv_cli_email         = M.InvoiceEmail
                 , @inv_cli_adress        = M.FiscalAddress
                 , @inv_cli_nit           = REPLACE(M.TaxIdNumber, '-', '')
                 , @inv_cli_name          = M.InvoiceName
                 , @inv_IVA               = M.MembershipCost - (M.MembershipCost / 1.12)
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
                AND TypeSalePackage != 'MEMBERSHIP')) --COLLATE Latin1_General_CI_AI
            BEGIN
                SELECT TOP 1
                       @inv_amount            = S.SubscriptionCost
                     , @inv_cli_email         = @InvoiceEmail
                     , @inv_cli_adress        = @FiscalAddress
                     , @inv_cli_nit           = REPLACE(@TaxId, '-', '')
                     , @inv_cli_name          = @TaxName
                     , @inv_IVA               = S.SubscriptionCost - (S.SubscriptionCost / 1.12)
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
                    WHERE [M].[AccountId] = @IdAccount
                          AND [M].[RowStatus] = 1;
                END;

            END
        







	     DECLARE @IdCart INT =(select  Top 1 IdMarketplaceCart from dbo.MarketplaceCart where AccountId = @IdAccount AND IdCountry=@IdCountry ORDER BY DateCreated DESC)

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


 IF (
			 EXISTS( SELECT TOP 1 1 FROM dbo.RegistrationofTransactionProcessStates where OrderNumber= @OrderNumber
                AND TypeSalePackage = 'MEMBERSHIP') --COLLATE Latin1_General_CI_AI
           )
        BEGIN

            PRINT 'INSERT MEMBRESIA';
            DECLARE @AuxNewMembership AS TABLE (IdNewMembership INT);

            INSERT INTO [DeliveryBackOffice].[dbo].[Membership]
            (
                CatMembershipId
              , CatMembershipStatusId
              , MembershipCost
              , CustomerId
              , AccountId
              , MembershipCode
              , CustomerPaymentId
              , IsAutoRenewable
              , MembershipFixedValue
              , MembershipMaxServiceFixedValue
              , ActualServiceCount
              , ExpirationDate
              , RowStatus
              , TokenCreated
              , DateCreated
              , TaxIdNumber
              , InvoiceName
              , InvoiceEmail
              , FiscalAddress
              , RenewalFixedDay
              , AvailablePoints
              , AccumulatedPoints
              , PointsExpirationDate
              , CatValueTypeId
			  ,ProductGiftShippingEmail
			  ,ActivationCode
            )
            OUTPUT inserted.IdMembership
            INTO @AuxNewMembership
            (
                IdNewMembership
            )
            SELECT CM.IdCatMembership
                 , 2
                 , CM.MembershipCost
			     ,CASE WHEN
		                        EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.InvoiceEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE') 
															 AND RTP.ProductGiftShippingEmail IS NULL 
							
							THEN  (SELECT   ac.IdCustomer
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.InvoiceEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')
						    WHEN  EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE') 
														
							
							THEN  
							      
							(SELECT   ac.IdCustomer
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')
					
								ELSE NULL
				

							END
                     
					, CASE 
					          WHEN EXISTS(SELECT  TOP 1 1
										FROM [dbo].RegisterUser  usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
										WHERE usr.UsrEmail = RTP.ProductGiftShippingEmail
														     AND res.UstStatus  ='ACTIVE') 
							
							THEN  
							      
							(SELECT   ac.AccIdAccount
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')

                            WHEN 		EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.InvoiceEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE') 
															 AND RTP.ProductGiftShippingEmail IS NULL   
                                THEN  
                                           (SELECT   ac.AccIdAccount
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.InvoiceEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')
				
							ELSE  NULL

							END

                 , IIF(@CustomerType = 2, @ActivationCode, NULL) -- agregar columna en insert para codigo de membresia 
                 ,NULL                                             -- Si es corporativo y tiene credito o si esta pagando con tarjeta asociada
                 , 0
                 , CM.MembershipFixedValue
                 , CM.MembershipMaxServiceFixedValue
                 , 0
                 , DATEADD(MONTH, CM.MembershipValidity, GETDATE())
                 ,  CASE 
						    WHEN  EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = RTP.ProductGiftShippingEmail
														     AND res.UstStatus  ='ACTIVE') 
							
							THEN 1
							WHEN   (SELECT
																					 ISNULL(res.UstStatus, 'N/A')
																				FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
																					INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																						ON rus.RusIdUser = usr.UsrIdUser
																						   AND rus.RusIdSystem = 1
																					LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																						ON res.UstIdUser = rus.RusIdUser
																						   AND res.UstIdSystem = rus.RusIdSystem
																					LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																						ON rua.RuaIdUser = usr.UsrIdUser
																						   AND rua.RuaRowStatus = 1
																					INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																						ON ac.AccIdAccount = rua.RuaIdAccount
																						   AND ac.AccRowStatus = 1
																				WHERE usr.UsrEmail = RTP.InvoiceEmail  ) = 'ACTIVE' 
																				AND RTP.ProductGiftShippingEmail  IS NULL
																				THEN 1
							ELSE 0
							END
                 , @Token
                 , GETDATE()
                 , @TaxId
                 , @TaxName
                 , @InvoiceEmail   
                 , @FiscalAddress
                 , DAY(GETDATE())
                 , 0
                 , 0
                 , DATEADD(DAY, @AddedPointExpirationDate, DATEADD(DAY, [CM].[MembershipValidity], GETDATE()))
                 , CDR.ValueTypeId
				 ,RTP.ProductGiftShippingEmail
				 ,(SELECT TOP 1
							CASE 
								WHEN number < 65 THEN CHAR(number + 65)  -- Convertir número a letra (A=65, B=66, ..., H=72)
								ELSE CHAR(number + 73)  -- Saltar las letras "I" y "O"
							END
						 FROM master.dbo.spt_values
						 WHERE type = 'P' AND number BETWEEN 0 AND 25
						 ORDER BY NEWID()
						) + RIGHT('000000' + CAST(CM.IdCatMembership AS NVARCHAR(6)), 6) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 65)

            FROM [DeliveryBackOffice].[dbo].[CatMembership] CM WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange] CDR WITH (NOLOCK)
                    ON CM.IdCatMembership = CDR.CatMembershipId
			   INNER JOIN [dbo].[RegistrationofTransactionProcessStates] RTP  WITH (NOLOCK)
			        ON CM.IdCatMembership = RTP.IdSalePackage	
			
            WHERE RTP.OrderNumber = @OrderNumber
			AND RTP.TypeSalePackage = 'MEMBERSHIP'
          
			   DECLARE @RandomLettersM CHAR(1);

			SELECT @RandomLettersM = (
				SELECT TOP 1
					CHAR(number + 65)
				FROM master.dbo.spt_values
				WHERE type = 'P' AND number BETWEEN 0 AND 24
				AND CHAR(number + 65) NOT IN ('I', 'O')  -- Excluir letras "I" y "O"
				ORDER BY NEWID()
			);

			DECLARE @RandomNumberM NVARCHAR(6);
			SELECT @RandomNumberM = RIGHT('000000' + CAST(201 AS NVARCHAR(6)), 6);

			-- Selección de la segunda letra aleatoria que no sea "I" ni "O"
			DECLARE @RandomLetterM2 CHAR(1);
			WITH RandomLettersM AS (
				SELECT TOP 24 CHAR(number + 65) AS Letter
				FROM master.dbo.spt_values
				WHERE type = 'P' AND number BETWEEN 0 AND 24
				AND CHAR(number + 65) NOT IN ('I', 'O')  -- Excluir letras "I" y "O"
				ORDER BY NEWID()
			)
			SELECT TOP 1 @RandomLetterM2 = Letter
			FROM RandomLettersM
			ORDER BY NEWID()

			UPDATE [dbo].[Membership] 
					SET ActivationCode = @RandomLettersM
											+ RIGHT('000000' + CAST(B.IdMembership AS NVARCHAR(6)), 6)
											+  @RandomLetterM2
			FROM @AuxNewMembership A 
			    INNER JOIN 
				[dbo].[Membership] B With(Nolock)
				ON A.IdNewMembership = B.IdMembership


			  IF (EXISTS (SELECT TOP 1 1 FROM @AuxNewMembership))
            BEGIN
                ----------Rango de descuento
                INSERT INTO [DeliveryBackOffice].[dbo].[MembershipDiscountRange]
                (
                    MembershipId
                  , ValueTypeId
                  , DiscountValue
                  , DiscountLowServiceRange
                  , DiscountTopServiceRange
                  , RowStatus
                  , TokenCreated
                  , DateCreated
                )
                SELECT ANM.IdNewMembership
                     , CMDR.ValueTypeId
                     , CMDR.DiscountValue
                     , CMDR.DiscountLowServiceRange
                     , CMDR.DiscountTopServiceRange
                     , CMDR.RowStatus
                     , @Token
                     , GETDATE()
                FROM [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange] CMDR WITH (NOLOCK)
				    INNER JOIN [DeliveryBackOffice].[dbo].RegistrationofTransactionProcessStates RT WITH (NOLOCK)
					ON CMDR.CatMembershipId = RT.IdSalePackage
                    CROSS JOIN @AuxNewMembership ANM
                WHERE RT.Ordernumber = @OrderNumber 
			
                ---- Log de pago de membresia
                INSERT INTO [DeliveryBackOffice].[dbo].[MembershipPaymentLog]
                (
                    MembershipId
                  , TypeOfInOutOfMoneyId
                  , [Authorization]
                  , RowStatus
                  , TokenCreated
                  , DateCreated
				  ,PaymentImageURL
                )
                SELECT ANM.IdNewMembership
                     , 6
                     , 
                      @Vaucher
                      
                     , 1
                     , @Token
                     , GETDATE()
					 ,@ImageURL
                FROM @AuxNewMembership ANM;


             
                --- Insert tabla dbo.Cost

  	        Insert Into [dbo].[Cost] (IdProduct, ProductNumber, IdTypeCharge, TotalAmount, PaymentDate, IdModule, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
		    values (1, @OrderNumber, 2, @inv_amount, GETDATE(), 1, 1, @Token,GETDATE(), null, null ) 

         

            END;

            


			END

   IF (
               EXISTS( SELECT TOP 1 1 FROM dbo.RegistrationofTransactionProcessStates where OrderNumber= @OrderNumber
                AND TypeSalePackage != 'MEMBERSHIP') --COLLATE Latin1_General_CI_AI
                )
        BEGIN

		  
            DECLARE @AuxNewSubscriptions AS TABLE (IdNewSubscriptions INT);

           INSERT INTO [DeliveryBackOffice].[dbo].[Subscription]
            (
                MembershipId
              , CatSubscriptionId
              , CatSubscriptionStatusId
              , SubscriptionCost
              , CustomerId
              , AccountId
              , SubscriptionCode
              , CustomerPaymentId
              , IsAutoRenewable
              , SubscriptionFixedValue
              , SubscriptionMaxServiceFixedValue
              , ActualServiceCount
              , ExpirationDate
              , RowStatus
              , TokenCreated
              , DateCreated
              , RenewalFixedDay
              , CatTypeSubscriptionId
			  ,ActivationCode
			  ,ProductGiftShippingEmail
            )
            OUTPUT inserted.IdSubscription
            INTO @AuxNewSubscriptions
            (
                IdNewSubscriptions
            )
            SELECT NULL
                 , CS.IdCatSubscription
                 , 2
                 , CS.SubscriptionCost
				,CASE WHEN
		                        EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.InvoiceEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE') 
															 AND RTP.ProductGiftShippingEmail IS NULL 
							
							THEN  (SELECT   ac.IdCustomer
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.InvoiceEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')
						    WHEN  EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE') 
														
							
							THEN  
							      
							(SELECT   ac.IdCustomer
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')
					
								ELSE NULL
				
							

							END
					, CASE 
					          WHEN EXISTS(SELECT  TOP 1 1
										FROM [dbo].RegisterUser  usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
										WHERE usr.UsrEmail = RTP.ProductGiftShippingEmail
														     AND res.UstStatus  ='ACTIVE') 
							
							THEN  
							      
							(SELECT   ac.AccIdAccount
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')
                             WHEN EXISTS(SELECT  TOP 1 1
										FROM [dbo].RegisterUser  usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
										WHERE usr.UsrEmail = RTP.InvoiceEmail
														     AND res.UstStatus  ='ACTIVE') 
                                                             AND RTP.ProductGiftShippingEmail IS NULL
							
							THEN  
							      
							(SELECT   ac.AccIdAccount
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.InvoiceEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE')
				
							ELSE  NULL

							END
                 , IIF(@CustomerType = 2, @ActivationCode, NULL) -- agregar columna en insert para codigo de membresia 
                 , 
                   NULL                                             -- Si es corporativo y tiene credito o si esta pagando con tarjeta asociada
                 , 0
                 , CS.SubscriptionFixedValue
                 , CS.SubscriptionMaxServiceFixedValue
                 , 0
                 , DATEADD(MONTH, CS.SubscriptionValidity, GETDATE())
                 , CASE 
						    WHEN  EXISTS(SELECT  TOP 1 1
														FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
															INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																ON rus.RusIdUser = usr.UsrIdUser
																   AND rus.RusIdSystem = 1
															LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																ON res.UstIdUser = rus.RusIdUser
																   AND res.UstIdSystem = rus.RusIdSystem
															LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																ON rua.RuaIdUser = usr.UsrIdUser
																   AND rua.RuaRowStatus = 1
															INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																ON ac.AccIdAccount = rua.RuaIdAccount
																   AND ac.AccRowStatus = 1
														WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail,'N/D')
														     AND res.UstStatus  ='ACTIVE') 
							
							THEN 1
							WHEN  @IdAccount IS NOT NULL AND (SELECT
																					 ISNULL(res.UstStatus, 'N/A')
																				FROM [dbo].RegisterUser                   usr WITH (NOLOCK)
																					INNER JOIN [dbo].RolByUserBySystem    rus WITH (NOLOCK)
																						ON rus.RusIdUser = usr.UsrIdUser
																						   AND rus.RusIdSystem = 1
																					LEFT JOIN [dbo].UserSystemRestriction res WITH (NOLOCK)
																						ON res.UstIdUser = rus.RusIdUser
																						   AND res.UstIdSystem = rus.RusIdSystem
																					LEFT JOIN [dbo].[RolByUserByAccount]  rua WITH (NOLOCK)
																						ON rua.RuaIdUser = usr.UsrIdUser
																						   AND rua.RuaRowStatus = 1
																					INNER JOIN [dbo].Account              ac WITH (NOLOCK)
																						ON ac.AccIdAccount = rua.RuaIdAccount
																						   AND ac.AccRowStatus = 1
																				WHERE usr.UsrEmail = RTP.InvoiceEmail  ) = 'ACTIVE' 
																				AND  RTP.ProductGiftShippingEmail IS NULL
																				THEN 1
							ELSE 0
							END
                 , RTP.TokenCreated
                 , GETDATE()
                 , DAY(GETDATE())
                 , CS.CatTypeSubscriptionId
				 ,(SELECT TOP 1
							CASE 
								WHEN number < 65 THEN CHAR(number + 65)  -- Convertir número a letra (A=65, B=66, ..., H=72)
								ELSE CHAR(number + 73)  -- Saltar las letras "I" y "O"
							END
						 FROM master.dbo.spt_values
						 WHERE type = 'P' AND number BETWEEN 0 AND 25
						 ORDER BY NEWID()
						) + RIGHT('000000' + CAST(CS.IdCatSubscription AS NVARCHAR(6)), 6) + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 65),
				RTP.ProductGiftShippingEmail
            FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
			INNER JOIN [dbo].[RegistrationofTransactionProcessStates] RTP  WITH (NOLOCK)
			ON CS.IdCatSubscription = RTP.IdSalePackage
            WHERE 
			RTP.OrderNumber = @OrderNumber
			AND RTP.TypeSalePackage != 'MEMBERSHIP'
			
           DECLARE @RandomLetterS CHAR(1);

			SELECT @RandomLetterS = (
				SELECT TOP 1
					CHAR(number + 65)
				FROM master.dbo.spt_values
				WHERE type = 'P' AND number BETWEEN 0 AND 24
				AND CHAR(number + 65) NOT IN ('I', 'O')  -- Excluir letras "I" y "O"
				ORDER BY NEWID()
			);

			DECLARE @RandomNumberS NVARCHAR(6);
			SELECT @RandomNumberS = RIGHT('000000' + CAST(201 AS NVARCHAR(6)), 6);

			-- Selección de la segunda letra aleatoria que no sea "I" ni "O"
			DECLARE @RandomLetterS2 CHAR(1);
			WITH RandomLettersS AS (
				SELECT TOP 24 CHAR(number + 65) AS Letter
				FROM master.dbo.spt_values
				WHERE type = 'P' AND number BETWEEN 0 AND 24
				AND CHAR(number + 65) NOT IN ('I', 'O')  -- Excluir letras "I" y "O"
				ORDER BY NEWID()
			)
			SELECT TOP 1 @RandomLetterS2 = Letter
			FROM RandomLettersS
			ORDER BY NEWID()

			UPDATE dbo.Subscription 
					SET ActivationCode= @RandomLetterS+ RIGHT('000000' + CAST(B.IdSubscription AS NVARCHAR(6)), 6) + @RandomLetterS2
			FROM @AuxNewSubscriptions A 
			    INNER JOIN 
				[dbo].[Subscription] B With(Nolock)
				ON A.IdNewSubscriptions = B.IdSubscription

			

            SET @SubscriptionId = SCOPE_IDENTITY();

			---- Log de pago de suscripción
                INSERT INTO [DeliveryBackOffice].[dbo].[SubscriptionPaymentLog]
                (
                    [SubscriptionId],
                    [Authorization],
                    [TypeOfInOutOfMoneyId],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated],                    
                    [TransactionOrder],
                    [PaymentImageURL]
                )                
                SELECT IdNewSubscriptions
					 , @OrderNumber
                     , 6                     
                     , 1
                     , @Token
                     , GETDATE()
					 ,NULL
					 , @ImageURL
				FROM @AuxNewSubscriptions
				
                

			---------- Rango de descuento
            INSERT INTO [dbo].[SubscriptionDiscountRange]
            (
                [SubscriptionId]
              , [ValueTypeId]
              , [DiscountValue]
              , [DiscountLowServiceRange]
              , [DiscountTopServiceRange]
              , [RowStatus]
              , [TokenCreated]
              , [DateCreated]
            )
            SELECT S.IdSubscription                 -- MembershipId
                 , [CSDR].[ValueTypeId]             -- ValueType
                 , [CSDR].[DiscountValue]           -- DiscountValue
                 , [CSDR].[DiscountLowServiceRange] -- DiscountLowServiceRange
                 , [CSDR].[DiscountTopServiceRange] -- DiscountTopServiceRange
                 , 1                                -- RowStatus 
                 , @Token                           -- TokenCreated
                 , SYSDATETIME()                    -- DateCreated
            FROM [dbo].[CatSubscriptionDiscountRange] CSDR WITH (NOLOCK)
			     INNER JOIN [dbo].RegistrationofTransactionProcessStates RTS WITH (NOLOCK)
				 ON [CSDR].[CatSubscriptionId] = RTS.IdSalePackage
				 INNER JOIN [dbo].Subscription S WITH (NOLOCK)
				 ON [CSDR].[CatSubscriptionId] = S.CatSubscriptionId
				 INNER JOIN @AuxNewSubscriptions ANS
				 ON ANS.IdNewSubscriptions = S.IdSubscription
				 WHERE RTS.OrderNumber = @OrderNumber
				 
		
				END



			SELECT 
                 @inv_amount =    SUM(  ISNULL((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)) , CM.MembershipCost) ) ,
                @inv_IVA =      SUM(ISNULL((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)), CM.MembershipCost) - (ISNULL((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)), CM.MembershipCost) / 1.12))
			 FROM  [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates] RTPS WITH (NOLOCK)
		          LEFT JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
			      ON CS.IdCatSubscription = RTPS.IdSalePackage
				  AND RTPS.TypeSalePackage !='MEMBERSHIP' 
				  LEFT JOIN [DeliveryBackOffice].[dbo].[CatMembership] CM WITH (NOLOCK)
				  ON  CM.IdCatMembership =  RTPS.IdSalePackage
				    AND RTPS.TypeSalePackage ='MEMBERSHIP' 
			WHERE RTPS.OrderNumber = @OrderNumber

			

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
        (@inv_vpCodeOfReferences, @inv_cmp_nit, ISNULL(@inv_cli_name,'CF'), @inv_cli_adress, @inv_cli_nit, @inv_cli_email, @inv_date
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
		     (CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0))	
		   ,CS.SubscriptionName	
		   ,(CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)) -((CS.SubscriptionCost - ISNULL(CS.SubscriptionFixedValue,0)) / 1.12)
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
		   ,CS.MembershipCost -((CS.MembershipCost) / 1.12)
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
	   
        COMMIT TRANSACTION;

        SELECT Result                = 1
             , 'Transacción exitosa' AS 'Description'
             , @dti_fk_header        IdInvoice
             , @inv_cli_email        inv_cli_email
             , @Token                Token
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