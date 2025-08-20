CREATE PROCEDURE [dbo].[SupportActivateSubscription]
    @Email NVARCHAR(50)        --IdUser al que se le desea agregar el beneficio
  , @PackageName NVARCHAR(50)  --Paquete que se va brindar
  , @Token NVARCHAR(50)        --TOKEN DE USUARIO
  , @Autorization NVARCHAR(20) -- autorizacion 
  , @CanalDeVenta NVARCHAR(10) -- Telemercadeo|Individual

AS
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @UsrIdUser INT;

        DECLARE @SubscriptionId INT;
        DECLARE @SubscriptionValidy INT;
        DECLARE @SubscriptionMaxServiceFixedValue INT;
        DECLARE @CatTypeSubscriptionId INT;

        DECLARE @IdNewSubscriptions INT;
        DECLARE @Cost DECIMAL(18, 2);

        --DECLARE @idMembership INT;


        SELECT TOP 1
               @UsrIdUser = rg.UsrIdUser
        FROM dbo.RegisterUser rg WITH (NOLOCK)
        WHERE rg.UsrEmail = @Email
              AND rg.UsrRowStatus = 1;



        --SELECT TOP 1
        --       @idMembership = mb.IdMembership
        --FROM dbo.RegisterUser                 rg
        --    INNER JOIN dbo.RolByUserByAccount ac
        --        ON ac.RuaIdUser = rg.UsrIdUser
        --           AND ac.RuaRowStatus = 1
        --    INNER JOIN dbo.Membership         mb
        --        ON mb.AccountId = ac.RuaIdAccount
        --           AND mb.RowStatus = 1
        --           AND CONVERT(DATE, mb.ExpirationDate) >= CONVERT(DATE, GETDATE())
        --WHERE rg.UsrEmail = @Email
        --      AND ac.RuaRowStatus = 1;

        IF @UsrIdUser IS NULL
        BEGIN
            SELECT 'Usuario no existe , valide correo electronico '
                 , @Email;
        END;
        ELSE
        BEGIN

            --IF @idMembership IS NULL
            --BEGIN
            --    SELECT 'Cliente no cuenta con membresia o ya venció';
            --END;
            --ELSE
            --BEGIN
            --Subscripción que se va dar
            SELECT TOP 1
                   @SubscriptionId                   = IdCatSubscription
                 , @SubscriptionValidy               = SubscriptionValidity
                 , @SubscriptionMaxServiceFixedValue = SubscriptionMaxServiceFixedValue
                 , @CatTypeSubscriptionId            = CatTypeSubscriptionId
                 , @Cost                             = SubscriptionCost
            FROM DeliveryBackOffice.dbo.CatSubscription
            WHERE SubscriptionName = @PackageName
                  AND RowStatus = 1; --'Paquete Gold'

            PRINT @SubscriptionId;
            PRINT @SubscriptionValidy;
            PRINT @SubscriptionMaxServiceFixedValue;
            PRINT @CatTypeSubscriptionId;
            PRINT @Cost;

            IF @SubscriptionId IS NULL
            BEGIN
                SELECT 'No existe ninguna suscripcion con ese nombre valide el nombre del paquete '
                     , @PackageName;
            END;
            ELSE
            BEGIN


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
                )
                SELECT A1.IdMembership
                     , @SubscriptionId
                     , 2
                     , @Cost
                     , A1.CustomerId
                     , A1.AccountId
                     , NULL
                     , NULL
                     , 0
                     , 0
                     , @SubscriptionMaxServiceFixedValue
                     , 0
                     , GETDATE() + @SubscriptionValidy
                     , 1
                     , @Token
                     , GETDATE()
                     , DAY(GETDATE())
                     , @CatTypeSubscriptionId
                FROM DeliveryBackOffice.dbo.RegisterUser                 UNO
                    INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount DOS
                        ON UNO.UsrIdUser = DOS.RuaIdUser
                           AND DOS.RuaRowStatus = 1
                    INNER JOIN DeliveryBackOffice.dbo.Membership         A1
                        ON A1.AccountId = DOS.RuaIdAccount
                WHERE UNO.UsrIdUser = @UsrIdUser; --41071

                SET @IdNewSubscriptions = SCOPE_IDENTITY();
                IF (@IdNewSubscriptions > 0)
                BEGIN
                    PRINT '@IdNewSubscriptions';
                    PRINT @IdNewSubscriptions;
                    ----------Rango de descuento
                    INSERT INTO [DeliveryBackOffice].[dbo].[SubscriptionDiscountRange]
                    (
                        SubscriptionId
                      , ValueTypeId
                      , DiscountValue
                      , DiscountLowServiceRange
                      , DiscountTopServiceRange
                      , RowStatus
                      , TokenCreated
                      , DateCreated
                    )
                    SELECT @IdNewSubscriptions
                         , CMDR.ValueTypeId
                         , CMDR.DiscountValue
                         , CMDR.DiscountLowServiceRange
                         , CMDR.DiscountTopServiceRange
                         , 1
                         , @Token
                         , GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[CatSubscriptionDiscountRange] CMDR WITH (NOLOCK)
                    WHERE CMDR.CatSubscriptionId = @SubscriptionId;


                    IF (@CanalDeVenta = 'Individual')
                    BEGIN
						INSERT INTO dbo.SubscriptionPaymentLog
						(
						    SubscriptionId
						  , [Authorization]
						  , TypeOfInOutOfMoneyId
						  , RowStatus
						  , TokenCreated
						  , DateCreated
						  , TokenUpdated
						  , DateUpdated
						  , TransactionOrder
						  , PaymentImageURL
						)
						VALUES
						(    @IdNewSubscriptions         -- SubscriptionId - int
						  , @Autorization      -- Authorization - nvarchar(50)
						  , 2         -- TypeOfInOutOfMoneyId - int
						  , 1   -- RowStatus - bit
						  , @Token       -- TokenCreated - nvarchar(50)
						  , GETDATE() -- DateCreated - datetime
						  , NULL      -- TokenUpdated - nvarchar(50)
						  , NULL      -- DateUpdated - datetime
						  , NULL      -- TransactionOrder - nvarchar(50)
						  , NULL      -- PaymentImageURL - nvarchar(600)
						    )

                    END;

                    ELSE
                    BEGIN
                       INSERT INTO dbo.SubscriptionPaymentLog
                       (
                           SubscriptionId
                         , [Authorization]
                         , TypeOfInOutOfMoneyId
                         , RowStatus
                         , TokenCreated
                         , DateCreated
                         , TokenUpdated
                         , DateUpdated
                         , TransactionOrder
                         , PaymentImageURL
                       )
                       VALUES
                       (   @IdNewSubscriptions         -- SubscriptionId - int
                         , NULL      -- Authorization - nvarchar(50)
                         , 6         -- TypeOfInOutOfMoneyId - int
                         , 1   -- RowStatus - bit
                         , @Token       -- TokenCreated - nvarchar(50)
                         , GETDATE() -- DateCreated - datetime
                         , NULL      -- TokenUpdated - nvarchar(50)
                         , NULL      -- DateUpdated - datetime
                         , @Autorization      -- TransactionOrder - nvarchar(50)
                         , 'imagen no disponible'      -- PaymentImageURL - nvarchar(600)
                           )
                    END;

                END;
            --END;
            END;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_NUMBER()
             , ERROR_LINE()
             , ERROR_MESSAGE();
    END CATCH;



END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportActivateSubscription] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportActivateSubscription] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportActivateSubscription] TO [cvaldes]
    AS [dbo];

