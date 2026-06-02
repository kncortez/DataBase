
/* =================================================
   SP: SPHW_UpdateCustomerTransactionPWO
   Propósito: Actualizar y asociar  el estado de la transacción de pasarela de pago PayWayOne SV
   Autor:     Edelman Vázquez
   Historia:  PENDIENTE
   Fecha:     2025-08-12
================================================= */
/* === CHANGELOG ============================
2025-08-12 | Historia/épica: PENDIENTE    | Autor: Edelman Vásquez | Actualizar y asociar  el estado de la transacción de pasarela de pago PayWayOne SV
2026-04-20 | Historia/épica: FDAPI-5867   | Autor: Bilkar Morataya | Se agregan guards de idempotencia antes de INSERT de Membresía
--                                                                   y Suscripción. Previene doble inserción cuando este SP
--                                                                   y spws_set_facapidelcreditcardtransaction se ejecutan en el
--                                                                   mismo flujo 3DS para el mismo OrderNumber. Usa GOTO para
--                                                                   saltar el bloque si ya existe un registro para la cuenta/orden.
=========================================== */

CREATE PROCEDURE [dbo].[SPHW_UpdateCustomerTransactionPWO] 
    @Type AS INT = -1
  , @System AS INT = 1
  , @CardNumber AS NVARCHAR(50) =NULL
  , @Signature AS NVARCHAR(100) = NULL
  , @ReferenceNumber AS VARCHAR(50) = ''
  , @TransactionStain AS VARCHAR(50) = ''
  , @ReasonCode AS NVARCHAR(50) = NULL
  , @ReasonDescription AS NVARCHAR(100) = NULL
  , @StatusSend AS INT = NULL
  , @TokenUpdated AS NVARCHAR(50) = NULL
  , @OrderNumber AS NVARCHAR(50) = NULL

AS
BEGIN

        DECLARE @IdTransaction BIGINT = 0;
		DECLARE @Code INT=0;
		DECLARE @Description NVARCHAR(50)='ERROR';
		DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE)

		  -- Variables para la asociación y activación de Membresías o suscripciones
		DECLARE @IdTarjeta AS INT = NULL; -- puede ser null por ex c y por credito
		DECLARE @TypeSalePackage AS NVARCHAR(100); -- membership or suscription
		DECLARE @IdSalePackage AS INT; -- id membership or suscription
		DECLARE @IdAcount AS BIGINT; ---- user
		DECLARE @Vaucher AS NVARCHAR(50) = NULL; -- comprobante de factura pago con tarjeta
		DECLARE @TypeOfInMoneyId INT; -- Tipo de pago
		DECLARE @ModulId AS INT = NULL; --  pagina o form desde donde se hizo la operación 
		DECLARE @SystemId AS INT; --  1 y 2 web o 
		DECLARE @Token AS NVARCHAR(50);
		DECLARE @TaxId NVARCHAR(50) = N'CF';
		DECLARE @FiscalAddress NVARCHAR(200) = N'Ciudad';
		DECLARE @TaxName NVARCHAR(100) = N'CONSUMIDOR FINAL';
		DECLARE @InvoiceEmail NVARCHAR(50) = N'';
		DECLARE @IsAutoRenewable BIT = 0;
		DECLARE @AccountId INT = 0

		DECLARE @StatusMembershipt INT = 0;
		DECLARE @ActiveMembershipId INT = 0;

		 -- Variables estaticas "globales"
                DECLARE @StartingStatus INT =
                        (
                            SELECT TOP 1
                                   CSPS.IdCatSalesPackageStatus
                            FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                            WHERE CSPS.SalesPackageStatusName = 'Activa' 
                        );

		 -- Variables adicionales de datos
		DECLARE @CustomerId INT = 0;
		DECLARE @CustomerType INT = 0;
		DECLARE @VisitPointClientIdByUser INT = 0;
		DECLARE @ActivationCode NVARCHAR(100) = N'';
        DECLARE @HasCredit BIT = 0;     
		DECLARE @SubscriptionId INT = 0;
        DECLARE @AddedPointExpirationDate INT = 0;
		DECLARE @ServiceAmmount DECIMAL = 0;
    -- Transacción para ingreso de proceso con tarjeta
        BEGIN TRANSACTION LogTransactionTypeOne;
        BEGIN TRY

		IF(@OrderNumber IS NULL)
		BEGIN
            -- Flujo normal de spws_set_facapidelcreditcardtransaction
            -- Si @Signature viene vacío (caso Using3dsSecureTransactionSV), buscar por @TransactionStain
            IF (@Signature IS NOT NULL AND @Signature <> '')
            BEGIN
                SELECT @IdTransaction = ISNULL([IdTransaction], 0),
                       @OrderNumber   = ISNULL(OrderNumber,'') 
                FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC WITH (NOLOCK)
                WHERE [CCTBC].[Signature] = @Signature
            END
            ELSE
            BEGIN
                SELECT @IdTransaction = ISNULL([IdTransaction], 0),
                       @OrderNumber   = ISNULL(OrderNumber,'') 
                FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC WITH (NOLOCK)
                WHERE [CCTBC].[TransactionStain] = @TransactionStain
            END
		END
		ELSE
		      BEGIN

			        SELECT @IdTransaction = ISNULL([IdTransaction], 0),
						  @OrderNumber   = ISNULL(CCTBC.OrderNumber,''), 
						  @Signature = CCTBC.[Signature]
					FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC WITH (NOLOCK)
					WHERE [CCTBC].OrderNumber = @OrderNumber

		      END;

             IF (@IdTransaction > 0)
             BEGIN

			      IF(@CardNumber<>null)
				   BEGIN
						UPDATE [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer]
						SET [System] = @System
						  , CardNumber = @CardNumber
						  , [Signature] = @Signature
						  , ReferenceNumber = @ReferenceNumber
						  , TransactionStain = @TransactionStain
						  , ReasonCode = @ReasonCode
						  , ReasonDescription = @ReasonDescription
						  , StatusSend = @StatusSend
						  , TokenUpdated = @TokenUpdated
						  , DateUpdated = GETDATE()
						WHERE IdTransaction = @IdTransaction
							  
					END
					   ELSE
					   BEGIN
					        UPDATE [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer]
							SET 
							    ReasonCode = @ReasonCode
							  , ReasonDescription = @ReasonDescription
							  , TokenUpdated = @TokenUpdated
							  , DateUpdated = GETDATE()
							WHERE IdTransaction = @IdTransaction
								 
					   END
					   
				    IF (@ReasonCode = '00')
						BEGIN

							SELECT @IdTransaction  = [IdTransaction]
								 , @ServiceAmmount = [Ammount]
							FROM [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] WITH (NOLOCK)
							WHERE OrderNumber = @OrderNumber;

							SELECT TOP 1
								   @IdTarjeta       = GetCardsCredit
								 , @TypeSalePackage = TypeSalePackage
								 , @IdSalePackage   = IdSalePackage
								 , @IdAcount        = AccountId
								 , @Vaucher         = Vaucher
								 , @TypeOfInMoneyId = 2
								 , @ModulId         = 1
								 , @SystemId        = 1
								 , @Token           = TokenCreated
								 , @TaxId           = TaxId
								 , @FiscalAddress   = AddressTax
								 , @TaxName         = NameTax
								 , @InvoiceEmail    = InvoiceEmail
								 , @IsAutoRenewable = GetRenovacionAutomatica
							FROM [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates] WITH (NOLOCK)
							WHERE OrderNumber = @OrderNumber;

					-- Sincronizar @AccountId con el AccountId real del registro de transacción
					SET @AccountId = ISNULL(CAST(@IdAcount AS INT), 0);
							
                IF (EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates] WITH (NOLOCK)
                    WHERE OrderNumber = @OrderNumber
                          AND TypeSalePackage = 'MEMBERSHIP'
                )
                   )
                BEGIN

                    -- Guard de idempotencia: verificar que no exista ya una Membresía activa
                    -- para esta cuenta y orden. Previene doble inserción cuando este SP
                    -- y spws_set_facapidelcreditcardtransaction se ejecutan en el mismo flujo 3DS.
                    IF EXISTS (
                        SELECT TOP 1 1
                        FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK)
                        WHERE AccountId = @IdAcount
                          AND RowStatus = 1
                          AND CAST(DateCreated AS DATE) = @CurrentDate
                    )
                    BEGIN
                       -- SKIP INSERT MEMBRESIA - ya existe para esta cuenta
                        GOTO SkipMembership;
                    END
                    -- INSERT MEMBRESIA
                    DECLARE @AuxNewMembership AS TABLE
                    (
                        IdNewMembership INT
                    );

					 --- Estado de membresia
							SELECT TOP 1
								   @StatusMembershipt  = 1
								 , @ActiveMembershipId = IdMembership
							FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK)
							WHERE AccountId = @IdAcount
								  AND RowStatus = 1;

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
                      , ProductGiftShippingEmail
                      , ActivationCode
                    )
                    OUTPUT inserted.IdMembership
                    INTO @AuxNewMembership
                    (
                        IdNewMembership
                    )
                    SELECT CM.IdCatMembership
                         , @StartingStatus
                         , CM.MembershipCost
                         , RTP.CustomerId
                         , RTP.AccountId
                         , IIF(@CustomerType = 2, @ActivationCode, NULL) -- agregar columna en insert para codigo de membresia 
                         , (CASE
                                WHEN @CustomerType = 1
                                     AND @HasCredit = 1
                                     AND @IdTarjeta = 0
                                     AND @TypeOfInMoneyId = 8 THEN
                                    NULL
                                WHEN @CustomerType = 2 THEN
                                    NULL
                                WHEN @AccountId = 0 THEN
                                    NULL
                                ELSE
                                    @IdTarjeta
                            END
                           )  -- Si es corporativo y tiene credito o si esta pagando con tarjeta asociada
                         , @IsAutoRenewable
                         , CM.MembershipFixedValue
                         , CM.MembershipMaxServiceFixedValue
                         , 0
                         , DATEADD(MONTH, CM.MembershipValidity, GETDATE())
                         , CASE
                               WHEN EXISTS
                (
                    SELECT TOP 1
                           1
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
                    WHERE usr.UsrEmail = RTP.ProductGiftShippingEmail
                          AND res.UstStatus = 'ACTIVE'
                          AND rus.RusIdSystem = 1
                          AND ac.AccRowStatus = 1
                )          THEN
                                   1
                               WHEN
                               (
                                   SELECT ISNULL(res.UstStatus, 'N/A')
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
                                   WHERE usr.UsrEmail = RTP.InvoiceEmail
                                         AND rus.RusIdSystem = 1
                                         AND ac.AccRowStatus = 1
                               ) = 'ACTIVE'
                               AND RTP.ProductGiftShippingEmail IS NULL THEN
                                   1
                               ELSE
                                   0
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
                         , RTP.ProductGiftShippingEmail
                         , (
                               SELECT TOP 1
                                      CASE
                                          WHEN number < 65 THEN
                                              CHAR(number + 65) -- Convertir número a letra (A=65, B=66, ..., H=72)
                                          ELSE
                                              CHAR(number + 73) -- Saltar las letras "I" y "O"
                                      END
                               FROM master.dbo.spt_values
                               WHERE type = 'P'
                                     AND number
                                     BETWEEN 0 AND 25
                               ORDER BY NEWID()
                           ) + RIGHT('000000' + CAST(CM.IdCatMembership AS NVARCHAR(6)), 6)
                           + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 65)
                    FROM [DeliveryBackOffice].[dbo].[CatMembership]                        CM WITH (NOLOCK)
                        INNER JOIN [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange] CDR WITH (NOLOCK)
                            ON CM.IdCatMembership = CDR.CatMembershipId
                        INNER JOIN [dbo].[RegistrationofTransactionProcessStates]          RTP WITH (NOLOCK)
                            ON CM.IdCatMembership = RTP.IdSalePackage
                    WHERE RTP.OrderNumber = @OrderNumber
                          AND RTP.TypeSalePackage = 'MEMBERSHIP';

                    DECLARE @RandomLettersM CHAR(1);

                    SELECT @RandomLettersM =
                    (
                        SELECT TOP 1
                               CHAR(number + 65)
                        FROM [master].[dbo].[spt_values]
                        WHERE type = 'P'
                              AND number
                              BETWEEN 0 AND 24
                              AND CHAR(number + 65) NOT IN ( 'I', 'O' ) -- Excluir letras "I" y "O"
                        ORDER BY NEWID()
                    );

                    DECLARE @RandomNumberM NVARCHAR(6);
                    SELECT @RandomNumberM = RIGHT('000000' + CAST(201 AS NVARCHAR(6)), 6);

                    -- Selección de la segunda letra aleatoria que no sea "I" ni "O"
                    DECLARE @RandomLetterM2 CHAR(1);
                    WITH RandomLettersM
                    AS (SELECT TOP 24
                               CHAR(number + 65) AS Letter
                        FROM [master].[dbo].[spt_values]
                        WHERE type = 'P'
                              AND number
                              BETWEEN 0 AND 24
                              AND CHAR(number + 65) NOT IN ( 'I', 'O' ) -- Excluir letras "I" y "O"
                        ORDER BY NEWID())
                    SELECT TOP 1
                           @RandomLetterM2 = Letter
                    FROM RandomLettersM
                    ORDER BY NEWID();

                    UPDATE [DeliveryBackOffice].[dbo].[Membership]
                    SET ActivationCode = @RandomLettersM + RIGHT('000000' + CAST(B.IdMembership AS NVARCHAR(6)), 6)
                                         + @RandomLetterM2
                    FROM @AuxNewMembership            A
                        INNER JOIN [DeliveryBackOffice].[dbo].[Membership] B WITH (NOLOCK)
                            ON A.IdNewMembership = B.IdMembership;



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
                        FROM [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange]                     CMDR WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates] RT WITH (NOLOCK)
                                ON CMDR.CatMembershipId = RT.IdSalePackage
                            CROSS JOIN @AuxNewMembership                                                 ANM
                        WHERE RT.OrderNumber = @OrderNumber;

                        ---- Log de pago de membresia
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipPaymentLog]
                        (
                            MembershipId
                          , TypeOfInOutOfMoneyId
                          , [Authorization]
                          , RowStatus
                          , TokenCreated
                          , DateCreated
                        )
                        SELECT ANM.IdNewMembership
                             , @TypeOfInMoneyId
                             , (CASE
                                    WHEN @CustomerType = 1
                                         AND @HasCredit = 1
                                         AND @IdTarjeta = 0
                                         AND @TypeOfInMoneyId = 8 THEN
                                        'CREDIT'
                                    WHEN @CustomerType = 2
                                         AND @TypeOfInMoneyId = 1 THEN
                                        'CASH'
                                    ELSE
                                        @Vaucher
                                END
                               )
                             , 1
                             , @Token
                             , GETDATE()
                        FROM @AuxNewMembership ANM;


                        --- Insert tabla dbo.Cost

                        INSERT INTO [DeliveryBackOffice].[dbo].[Cost]
                        (
                            IdProduct
                          , ProductNumber
                          , IdTypeCharge
                          , TotalAmount
                          , PaymentDate
                          , IdModule
                          , RowStatus
                          , TokenCreated
                          , DateCreated
                          , TokenUpdated
                          , DateUpdated
                        )
                        VALUES
                        (1, @OrderNumber, 2, @ServiceAmmount, GETDATE(), @ModulId, 1, @Token, GETDATE(), NULL, NULL);



                    END;




                END;

                       END;
                   SkipMembership:
                   IF (EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates] WITH (NOLOCK)
                    WHERE OrderNumber = @OrderNumber
                          AND TypeSalePackage != 'MEMBERSHIP'
                )
                   )
                BEGIN

                    -- Guard de idempotencia: verificar que no exista ya una Suscripción
                    -- para esta cuenta y orden. Previene doble inserción en flujo 3DS.
                    IF EXISTS (
                        SELECT TOP 1 1
                        FROM [DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] WITH (NOLOCK)
                        WHERE [Authorization] = @OrderNumber
                          AND RowStatus = 1
                    )
                    BEGIN
                        -- SKIP INSERT SUSCRIPCION - ya existe log de pago para esta orden
                        GOTO SkipSubscription;
                    END

                    DECLARE @AuxNewSubscriptions AS TABLE
                    (
                        IdNewSubscriptions INT
                    );

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
                      , ActivationCode
                      , ProductGiftShippingEmail
                    )
                    OUTPUT inserted.IdSubscription
                    INTO @AuxNewSubscriptions
                    (
                        IdNewSubscriptions
                    )
                    SELECT NULL                                          --IIF(@CustomerType = 2, NULL, @ActiveMembershipId)
                         , CS.IdCatSubscription
                         , @StartingStatus
                         , CS.SubscriptionCost
                         , RTP.CustomerId
                         , RTP.AccountId
                                                                         --IIF(@CustomerType = 2, NULL, @IdAcount)
                         , IIF(@CustomerType = 2, @ActivationCode, NULL) -- agregar columna en insert para codigo de membresia 
                         , (CASE
                                WHEN @CustomerType = 1
                                     AND @HasCredit = 1
                                     AND @IdTarjeta = 0
                                     AND @TypeOfInMoneyId = 8 THEN
                                    NULL
                                WHEN @CustomerType = 2 THEN
                                    NULL
                                ELSE
                                    @IdTarjeta
                            END
                           )                                             -- Si es corporativo y tiene credito o si esta pagando con tarjeta asociada
                         , 0
                         , CS.SubscriptionFixedValue
                         , CS.SubscriptionMaxServiceFixedValue
                         , 0
                         , DATEADD(MONTH, CS.SubscriptionValidity, GETDATE())
                         , CASE
                               WHEN EXISTS
                (
                    SELECT TOP 1
                           1
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
                    WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail, 'N/D')
                          AND res.UstStatus = 'ACTIVE'
                          AND rus.RusIdSystem = 1
                          AND ac.AccRowStatus = 1
                )          THEN
                                   1
                               WHEN
                                    (
                                        SELECT ISNULL(res.UstStatus, 'N/A')
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
                                        WHERE usr.UsrEmail = RTP.InvoiceEmail
                                              AND rus.RusIdSystem = 1
                                              AND ac.AccRowStatus = 1
                                    ) = 'ACTIVE'
                                    AND RTP.ProductGiftShippingEmail IS NULL THEN
                                   1
                               ELSE
                                   0
                           END
                         , RTP.TokenCreated
                         , GETDATE()
                         , DAY(GETDATE())
                         , CS.CatTypeSubscriptionId
                         , (
                               SELECT TOP 1
                                      CASE
                                          WHEN number < 65 THEN
                                              CHAR(number + 65) -- Convertir número a letra (A=65, B=66, ..., H=72)
                                          ELSE
                                              CHAR(number + 73) -- Saltar las letras "I" y "O"
                                      END
                               FROM master.dbo.spt_values
                               WHERE type = 'P'
                                     AND number
                                     BETWEEN 0 AND 25
                               ORDER BY NEWID()
                           ) + RIGHT('000000' + CAST(CS.IdCatSubscription AS NVARCHAR(6)), 6)
                           + CHAR((ABS(CHECKSUM(NEWID())) % 26) + 65)
                         , RTP.ProductGiftShippingEmail
                    FROM [DeliveryBackOffice].[dbo].[CatSubscription]             CS WITH (NOLOCK)
                        INNER JOIN [dbo].[RegistrationofTransactionProcessStates] RTP WITH (NOLOCK)
                            ON CS.IdCatSubscription = RTP.IdSalePackage
                    WHERE RTP.OrderNumber = @OrderNumber
                          AND RTP.TypeSalePackage != 'MEMBERSHIP';

                    DECLARE @RandomLetterS CHAR(1);

                    SELECT @RandomLetterS =
                    (
                        SELECT TOP 1
                               CHAR(number + 65)
                        FROM master.dbo.spt_values
                        WHERE type = 'P'
                              AND number
                              BETWEEN 0 AND 24
                              AND CHAR(number + 65) NOT IN ( 'I', 'O' ) -- Excluir letras "I" y "O"
                        ORDER BY NEWID()
                    );

                    DECLARE @RandomNumberS NVARCHAR(6);
                    SELECT @RandomNumberS = RIGHT('000000' + CAST(201 AS NVARCHAR(6)), 6);

                    -- Selección de la segunda letra aleatoria que no sea "I" ni "O"
                    DECLARE @RandomLetterS2 CHAR(1);
                    WITH RandomLettersS
                    AS (SELECT TOP 24
                               CHAR(number + 65) AS Letter
                        FROM master.dbo.spt_values
                        WHERE type = 'P'
                              AND number
                              BETWEEN 0 AND 24
                              AND CHAR(number + 65) NOT IN ( 'I', 'O' ) -- Excluir letras "I" y "O"
                        ORDER BY NEWID())
                    SELECT TOP 1
                           @RandomLetterS2 = Letter
                    FROM RandomLettersS
                    ORDER BY NEWID();

                    UPDATE dbo.Subscription
                    SET ActivationCode = @RandomLetterS + RIGHT('000000' + CAST(B.IdSubscription AS NVARCHAR(6)), 6)
                                         + @RandomLetterS2
                    FROM @AuxNewSubscriptions           A
                        INNER JOIN [dbo].[Subscription] B WITH (NOLOCK)
                            ON A.IdNewSubscriptions = B.IdSubscription;



                    SET @SubscriptionId = SCOPE_IDENTITY();

                    ---- Log de pago de suscripción
                    INSERT INTO [DeliveryBackOffice].[dbo].[SubscriptionPaymentLog]
                    (
                        [SubscriptionId]
                      , [Authorization]
                      , [TypeOfInOutOfMoneyId]
                      , [RowStatus]
                      , [TokenCreated]
                      , [DateCreated]
                      , [TransactionOrder]
                      , [PaymentImageURL]
                    )
                    SELECT IdNewSubscriptions
                         , @OrderNumber
                         , @TypeOfInMoneyId
                         , 1
                         , @Token
                         , GETDATE()
                         , NULL
                         , NULL
                    FROM @AuxNewSubscriptions;
                    --	From [dbo].[RegistrationofTransactionProcessStates]
                    --	WHERE OrderNumber = @OrderNumber


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
                    FROM [DeliveryBackOffice].[dbo].[CatSubscriptionDiscountRange]                   CSDR WITH (NOLOCK)
                        INNER JOIN [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates] RTS WITH (NOLOCK)
                            ON [CSDR].[CatSubscriptionId] = RTS.IdSalePackage
                        INNER JOIN [DeliveryBackOffice].[dbo].[Subscription]                           S WITH (NOLOCK)
                            ON [CSDR].[CatSubscriptionId] = S.CatSubscriptionId
                        INNER JOIN @AuxNewSubscriptions                         ANS
                            ON ANS.IdNewSubscriptions = S.IdSubscription
                    WHERE RTS.OrderNumber = @OrderNumber;




                    --- Insert tabla dbo.Cost

                    INSERT INTO [DeliveryBackOffice].[dbo].[Cost]
                    (
                        IdProduct
                      , ProductNumber
                      , IdTypeCharge
                      , TotalAmount
                      , PaymentDate
                      , IdModule
                      , RowStatus
                      , TokenCreated
                      , DateCreated
                      , TokenUpdated
                      , DateUpdated
                    )
                    VALUES
                    (1, @OrderNumber, 2, @ServiceAmmount, GETDATE(), @ModulId, 1, @Token, GETDATE(), NULL, NULL);


                END;
                      
                 SkipSubscription:
                 SET @Code = 1;
				 SET @Description = 'Success';

            END
		    
			 SELECT @Code    AS   'Code',
                    @Description AS [Description],
					@OrderNumber AS 'OrderNumber'

            COMMIT TRANSACTION LogTransactionTypeOne;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION LogTransactionTypeOne;

			SELECT 0    AS   'Code'
             , 'Error' AS [Description]
			 , @OrderNumber AS 'OrderNumber'

        END CATCH;

END