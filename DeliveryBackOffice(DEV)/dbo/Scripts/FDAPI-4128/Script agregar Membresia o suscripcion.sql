--=============================================================
--========= SCRIPT AGREGAR MEMBRESIA/SUSCRIPCION ==============
--=============================================================

--VARIABLES DEL USUARIO
DECLARE 
  @OrderNumber				AS NVARCHAR(38) = 'SP00025115780'  -- Ej. SP00025123696 debe ser unico
, @ECIIndicator				AS VARCHAR(2) = '05' -- Default '05'
, @Authenticationresult		AS VARCHAR(1) = 'Y' -- Default 'Y'
, @TransactionStain			AS VARCHAR(50) = 'wz59oor0o9tscshbiqaf972sonuylqai2ks8n12satxdwsqr43' -- NewResultFAC GetCustomerPaymentData
, @CAVV						AS NVARCHAR(50) = 'AJkBCQIGiIYplVGQaQaIAAAAAAA=' -- NewResultFAC GetCustomerPaymentData
, @ReasonCode				AS NVARCHAR(50) = '00'  -- NewResultFAC 00 APROBADO, SP4 PENDIENTE
, @ReasonDescription		AS NVARCHAR(100) = 'Transaction is approved' -- NewResultFAC 00 APROBADO, SP4 PENDIENTE
, @StatusSend				AS INT = 0 -- NewResultFAC
, @RowStatus				AS BIT = 1
, @TokenUpdated				AS NVARCHAR(50) = 'SYS-WOROZCO'  -- Token de ejecutor
, @DateUpdated				AS DATETIME = GETDATE()  -- Fecha a actualizar

--==============================================================
--= VARIABLES ASOCIACION/ACTIVACION DE MEMBRESIA O SUSCRIPCION =
--==============================================================
DECLARE @IdTransaction			BIGINT = 0
DECLARE @ServiceAmmount			DECIMAL = 0
DECLARE @AccountId				INT = 0
DECLARE @IdTarjeta				INT = NULL; -- puede ser null por exc y por credito
DECLARE @TypeSalePackage		NVARCHAR(100); -- membership or suscription
DECLARE @IdSalePackage			INT; -- id membership or suscription
DECLARE @IdAcount				BIGINT; ---- user
DECLARE @Vaucher				NVARCHAR(50) = NULL; -- comprobante de factura pago con tarjeta
DECLARE @TypeOfInMoneyId		INT; -- Tipo de pago
DECLARE @ModulId				INT = NULL; --  pagina o form desde donde se hizo la operación 
DECLARE @SystemId				INT; --  1 y 2 web o 
DECLARE @Token					NVARCHAR(50);
DECLARE @TaxId					NVARCHAR(50) = N'CF';
DECLARE @FiscalAddress			NVARCHAR(200) = N'Ciudad';
DECLARE @TaxName				NVARCHAR(100) = N'CONSUMIDOR FINAL';
DECLARE @InvoiceEmail			NVARCHAR(50) = N'';
DECLARE @IsAutoRenewable		BIT = 0;
DECLARE @CustomerType			INT = 0;

--=============================================================
--=== Transacción para actualización de proceso con tarjeta ===
--=============================================================
BEGIN TRANSACTION LogTransactionTypeTwo;
BEGIN TRY

    SELECT 
		  @IdTransaction  = [IdTransaction]
        , @ServiceAmmount = [Ammount]
    FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH (NOLOCK)
    WHERE OrderNumber = @OrderNumber;

    UPDATE DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
    SET 
		  ReasonCode			= @ReasonCode
        , ReasonDescription		= @ReasonDescription
        , DateUpdated			= GETDATE() ---@DateUpdated,
        , TokenUpdated			= @TokenUpdated
        , ECIIndicator			= @ECIIndicator
        , Authenticationresult	= @Authenticationresult
        , TransactionStain		= @TransactionStain
        , CAVV					= @CAVV
        , StatusSend			= @StatusSend
    WHERE IdTransaction = @IdTransaction
    AND OrderNumber		= @OrderNumber
    AND StatusSend		<> 1
    AND CAST(@DateUpdated AS DATE) = CAST(DateCreated AS DATE);

	--=============================================================
	--============== Asociar membresía o sucripción ===============
	--=============================================================
    IF (@ReasonCode = '00')
    BEGIN

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
        FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates WITH (NOLOCK)
        WHERE OrderNumber = @OrderNumber;

        -- Variables estaticas "globales"
        DECLARE @StartingStatus INT =
                (
                    SELECT TOP 1
						CSPS.IdCatSalesPackageStatus
                    FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                    WHERE CSPS.SalesPackageStatusName = 'Activa'
                );

        -- Variables de control de flujo
        DECLARE @ActivationCode NVARCHAR(100) = N'';
        DECLARE @ActiveMembershipId INT = 0;
        DECLARE @StatusMembershipt INT = 0;
        DECLARE @HasCredit BIT = 0;
        DECLARE @AddedPointExpirationDate INT = 0;
        DECLARE @Idcustumer AS INT;
        DECLARE @SubscriptionId INT = 0;

        --- validar si cliente posee credito​
        SELECT TOP 1
			  @CustomerType = ISNULL(Cu.IdCustomerType, 0)
			, @HasCredit    = 
				ISNULL(   
					(CASE
                        WHEN CCOP.ConditionOfPaymenAbbreviation LIKE '%CREDITO%' 
						THEN 1 ELSE 0
                    END), 0) ---custumerType es 1 para corporativos
            , @Idcustumer   = Cu.IdCustomer
        FROM [DeliveryBackOffice].[dbo].[Account]                        AC		WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]              Cu		WITH (NOLOCK)
                ON AC.IdCustomer = Cu.IdCustomer
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatConditionOfPayment] CCOP	WITH (NOLOCK)
                ON Cu.ConditionOfPaymentID = CCOP.IdConditionOfPayment
        WHERE AC.AccIdAccount = @IdAcount;

		--=============================================================
		--======================= MEMBRESIA ===========================
		--=============================================================

        --- Estado de membresia
        SELECT TOP 1
			  @StatusMembershipt  = 1
            , @ActiveMembershipId = IdMembership
        FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK)
        WHERE AccountId = @IdAcount AND RowStatus = 1;

        IF (EXISTS
				(
					SELECT TOP 1
						1
					FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates	WITH (NOLOCK)
					WHERE OrderNumber = @OrderNumber
					AND TypeSalePackage = 'MEMBERSHIP' COLLATE Latin1_General_CI_AI
				)
			)
        BEGIN

            PRINT 'INSERT MEMBRESIA';
            DECLARE @AuxNewMembership AS TABLE ( IdNewMembership INT );

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
            SELECT 
				 CM.IdCatMembership
                , @StartingStatus
                , CM.MembershipCost
                , RTP.CustomerId
                , RTP.AccountId
                , IIF(@CustomerType = 2, @ActivationCode, NULL) -- agregar columna en insert para codigo de membresia 
                , (CASE
                        WHEN @CustomerType = 1
                        AND  @HasCredit = 1
                        AND  @IdTarjeta = 0
                        AND  @TypeOfInMoneyId = 8 THEN
                            NULL
                        WHEN @CustomerType = 2 THEN
                            NULL
                        WHEN @AccountId = 0 THEN
                            NULL
                        ELSE
                            @IdTarjeta
					END)                -- Si es corporativo y tiene credito o si esta pagando con tarjeta asociada
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
							FROM DeliveryBackOffice.dbo.RegisterUser					usr		WITH (NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem		rus		WITH (NOLOCK)
									ON rus.RusIdUser = usr.UsrIdUser
								LEFT JOIN DeliveryBackOffice.dbo.UserSystemRestriction	res		WITH (NOLOCK)
									ON res.UstIdUser = rus.RusIdUser
										AND res.UstIdSystem = rus.RusIdSystem
								LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount		rua		WITH (NOLOCK)
									ON rua.RuaIdUser = usr.UsrIdUser
										AND rua.RuaRowStatus = 1
								INNER JOIN DeliveryBackOffice.dbo.Account				ac		WITH (NOLOCK)
									ON ac.AccIdAccount = rua.RuaIdAccount
							WHERE usr.UsrEmail = RTP.ProductGiftShippingEmail
							AND res.UstStatus = 'ACTIVE'
							AND rus.RusIdSystem = 1
							AND ac.AccRowStatus = 1
						)	THEN
                            1
                        WHEN
                        (
                            SELECT ISNULL(res.UstStatus, 'N/A')
                            FROM DeliveryBackOffice.dbo.RegisterUser					usr		WITH (NOLOCK)
                                INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem		rus		WITH (NOLOCK)
                                    ON rus.RusIdUser = usr.UsrIdUser
                                LEFT JOIN DeliveryBackOffice.dbo.UserSystemRestriction	res		WITH (NOLOCK)
                                    ON res.UstIdUser = rus.RusIdUser
                                        AND res.UstIdSystem = rus.RusIdSystem
                                LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount		rua		WITH (NOLOCK)
                                    ON rua.RuaIdUser = usr.UsrIdUser
                                        AND rua.RuaRowStatus = 1
                                INNER JOIN DeliveryBackOffice.dbo.Account				ac		WITH (NOLOCK)
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
                , (SELECT TOP 1
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
            FROM [DeliveryBackOffice].[dbo].[CatMembership]							CM	WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange]	CDR WITH (NOLOCK)
                    ON CM.IdCatMembership = CDR.CatMembershipId
                INNER JOIN [dbo].[RegistrationofTransactionProcessStates]			RTP	WITH (NOLOCK)
                    ON CM.IdCatMembership = RTP.IdSalePackage
            WHERE RTP.OrderNumber = @OrderNumber AND RTP.TypeSalePackage = 'MEMBERSHIP';

            DECLARE @RandomLettersM CHAR(1);

            SELECT @RandomLettersM =
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

            DECLARE @RandomNumberM NVARCHAR(6);
            SELECT @RandomNumberM = RIGHT('000000' + CAST(201 AS NVARCHAR(6)), 6);

            -- Selección de la segunda letra aleatoria que no sea "I" ni "O"
            DECLARE @RandomLetterM2 CHAR(1);
            WITH RandomLettersM
            AS (SELECT TOP 24
                        CHAR(number + 65) AS Letter
                FROM master.dbo.spt_values
                WHERE type = 'P'
                AND number
                BETWEEN 0 AND 24
                AND CHAR(number + 65) NOT IN ( 'I', 'O' ) -- Excluir letras "I" y "O"
                ORDER BY NEWID())
            SELECT TOP 1
                    @RandomLetterM2 = Letter
            FROM RandomLettersM
            ORDER BY NEWID();

            UPDATE [dbo].[Membership]
            SET ActivationCode = @RandomLettersM + RIGHT('000000' + CAST(B.IdMembership AS NVARCHAR(6)), 6)
                                 + @RandomLetterM2
            FROM @AuxNewMembership            A
                INNER JOIN [dbo].[Membership] B WITH (NOLOCK)
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
                FROM [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange]                     CMDR	WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].RegistrationofTransactionProcessStates RT		WITH (NOLOCK)
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
                SELECT 
				      ANM.IdNewMembership
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
					  END)
					, 1
					, @Token
					, GETDATE()
                FROM @AuxNewMembership ANM;


                --- Insert tabla dbo.Cost
                INSERT INTO [dbo].[Cost]
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

		--=============================================================
		--======================= SUSCRIPÇION =========================
		--=============================================================

        IF (EXISTS
				(
					SELECT TOP 1
						1
					FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates WITH(NOLOCK)
					WHERE OrderNumber = @OrderNumber
					AND TypeSalePackage != 'MEMBERSHIP' COLLATE Latin1_General_CI_AI
				)
            )
        BEGIN

            DECLARE @AuxNewSubscriptions AS TABLE ( IdNewSubscriptions INT );

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
            SELECT 
				  NULL                                          --IIF(@CustomerType = 2, NULL, @ActiveMembershipId)
                , CS.IdCatSubscription
                , @StartingStatus
                , CS.SubscriptionCost
                , RTP.CustomerId
                , RTP.AccountId
                , IIF(@CustomerType = 2, @ActivationCode, NULL) -- agregar columna en insert para codigo de membresia 
                , (CASE
                        WHEN @CustomerType = 1
                        AND  @HasCredit = 1
                        AND  @IdTarjeta = 0
                        AND  @TypeOfInMoneyId = 8 THEN
                            NULL
                        WHEN @CustomerType = 2 THEN
                            NULL
                        ELSE
                            @IdTarjeta
                    END ) -- Si es corporativo y tiene credito o si esta pagando con tarjeta asociada
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
						FROM DeliveryBackOffice.dbo.RegisterUser					usr WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem		rus WITH (NOLOCK)
								ON rus.RusIdUser = usr.UsrIdUser
							LEFT JOIN DeliveryBackOffice.dbo.UserSystemRestriction	res WITH (NOLOCK)
								ON res.UstIdUser = rus.RusIdUser
									AND res.UstIdSystem = rus.RusIdSystem
							LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount		rua WITH (NOLOCK)
								ON rua.RuaIdUser = usr.UsrIdUser
									AND rua.RuaRowStatus = 1
							INNER JOIN DeliveryBackOffice.dbo.Account				ac	WITH (NOLOCK)
								ON ac.AccIdAccount = rua.RuaIdAccount
						WHERE usr.UsrEmail = ISNULL(RTP.ProductGiftShippingEmail, 'N/D')
						AND res.UstStatus = 'ACTIVE'
						AND rus.RusIdSystem = 1
						AND ac.AccRowStatus = 1
					)   THEN
                        1
                    WHEN @AccountId IS NOT NULL
                    AND
                    (
                        SELECT ISNULL(res.UstStatus, 'N/A')
                        FROM dbo.RegisterUser										usr		WITH (NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem		rus		WITH (NOLOCK)
                                ON rus.RusIdUser = usr.UsrIdUser
                            LEFT JOIN DeliveryBackOffice.dbo.UserSystemRestriction	res		WITH (NOLOCK)
                                ON res.UstIdUser = rus.RusIdUser
                                    AND res.UstIdSystem = rus.RusIdSystem
                            LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount		rua		WITH (NOLOCK)
                                ON rua.RuaIdUser = usr.UsrIdUser
                                    AND rua.RuaRowStatus = 1
                            INNER JOIN DeliveryBackOffice.dbo.Account				ac		WITH (NOLOCK)
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
            FROM [DeliveryBackOffice].[dbo].[CatSubscription]									CS WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates]	RTP WITH (NOLOCK)
                    ON CS.IdCatSubscription = RTP.IdSalePackage
            WHERE RTP.OrderNumber = @OrderNumber AND RTP.TypeSalePackage != 'MEMBERSHIP';

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
                INNER JOIN [DeliveryBackOffice].[dbo].[Subscription] B WITH (NOLOCK)
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
            SELECT 
				  IdNewSubscriptions
                , @OrderNumber
                , @TypeOfInMoneyId
                , 1
                , @Token
                , GETDATE()
                , NULL
                , NULL
            FROM @AuxNewSubscriptions;

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
            SELECT 
				  S.IdSubscription                 -- MembershipId
                , [CSDR].[ValueTypeId]             -- ValueType
                , [CSDR].[DiscountValue]           -- DiscountValue
                , [CSDR].[DiscountLowServiceRange] -- DiscountLowServiceRange
                , [CSDR].[DiscountTopServiceRange] -- DiscountTopServiceRange
                , 1                                -- RowStatus 
                , @Token                           -- TokenCreated
                , SYSDATETIME()                    -- DateCreated
            FROM [DeliveryBackOffice].[dbo].[CatSubscriptionDiscountRange]						CSDR	WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[RegistrationofTransactionProcessStates]	RTS		WITH (NOLOCK)
                    ON [CSDR].[CatSubscriptionId] = RTS.IdSalePackage
                INNER JOIN [DeliveryBackOffice].[dbo].[Subscription]							S		WITH (NOLOCK)
                    ON [CSDR].[CatSubscriptionId] = S.CatSubscriptionId
                INNER JOIN @AuxNewSubscriptions													ANS
                    ON ANS.IdNewSubscriptions = S.IdSubscription
            WHERE RTS.OrderNumber = @OrderNumber;

            --- Insert tabla dbo.Cost

            INSERT INTO [dbo].[Cost]
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
    COMMIT TRANSACTION LogTransactionTypeTwo;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION LogTransactionTypeTwo;

	INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
    (
          DateCreated
        , TokenCreated
        , ErrorLine
        , ErrorDescription
        , ErrorProcedure
    )
    VALUES
    (GETDATE(), 'SCRIPT MEMBRE/SUSCR', ERROR_LINE(), ERROR_MESSAGE(), ERROR_PROCEDURE());

END CATCH;

--=============================================================
--============= "Registro" de llamada en bitácora =============
--=============================================================

BEGIN TRY

    INSERT INTO DenariusLog_Dev.dbo.LOG_Http_Interceptor
    (
        [TypeOfUse]
        , [IdSystem]
        , [EntityObjectName]
        , [TransactionID]
        , [RQ_Method]
        , [RQ_Uri]
        , [RQ_Service]
        , [RQ_Header]
        , [RQ_Body]
        , [RQ_Object]
        , [RQ_Datetime]
        , [RQ_LauValue]
        , [RQ_Token]
        , [RQ_IdOrder]
        , [RS_Service]
        , [RS_StatusCode]
        , [RS_ReasonPhrase]
        , [RS_ReasonCode]
        , [RS_ReasonCodeMessage]
        , [RS_Header]
        , [RS_Body]
        , [RS_Object]
        , [RS_Datetime]
        , [RS_IdOrder]
        , [RS_LauValue]
        , [RS_Token]
    )
    VALUES
    ('Push', 15, 'DeliveryBackOffice.dbo.CreditCardTransaction', @IdTransaction, 'SOAP'
    , 'https://ecm.firstatlanticcommerce.com/PGService/Services.svc', 1, NULL, NULL, NULL, @DateUpdated, NULL
    , NULL, 1, 2, 0, NULL, @ReasonCode, @ReasonDescription, NULL, NULL, NULL, @DateUpdated, @OrderNumber, NULL
    , @TokenUpdated);

END TRY
BEGIN CATCH

    INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
    (
          DateCreated
        , TokenCreated
        , ErrorLine
        , ErrorDescription
        , ErrorProcedure
    )
    VALUES
    (GETDATE(), 'ERROR HTTP LOG', ERROR_LINE(), ERROR_MESSAGE(), ERROR_PROCEDURE());

END CATCH;
