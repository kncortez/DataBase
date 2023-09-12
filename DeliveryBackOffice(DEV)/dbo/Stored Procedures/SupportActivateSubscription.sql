CREATE PROCEDURE [dbo].[SupportActivateSubscription]
    @Email NVARCHAR(50)       --IdUser al que se le desea agregar el beneficio
  , @PackageName NVARCHAR(50) --Paquete que se va brindar
  , @Token NVARCHAR(50)       --TOKEN DE USUARIO

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

        DECLARE @idMembership INT;


        SELECT TOP 1
               @UsrIdUser = rg.UsrIdUser
        FROM dbo.RegisterUser rg WITH (NOLOCK)
        WHERE rg.UsrEmail = @Email
              AND rg.UsrRowStatus = 1;



        SELECT TOP 1
               @idMembership = mb.IdMembership
        FROM dbo.RegisterUser                 rg
            INNER JOIN dbo.RolByUserByAccount ac
                ON ac.RuaIdUser = rg.UsrIdUser
                   AND ac.RuaRowStatus = 1
            INNER JOIN dbo.Membership         mb
                ON mb.AccountId = ac.RuaIdAccount
                   AND mb.RowStatus = 1
                   AND CONVERT(DATE, mb.ExpirationDate) >= CONVERT(DATE, GETDATE())
        WHERE rg.UsrEmail = @Email
              AND ac.RuaRowStatus = 1;

        IF @UsrIdUser IS NULL
        BEGIN
            SELECT 'Usuario no existe , valide correo electronico '
                 , @Email;
        END;
        ELSE
        BEGIN

            IF @idMembership IS NULL
            BEGIN
                SELECT 'Cliente no cuenta con membresia o ya venció';
            END;
            ELSE
            BEGIN
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

                    END;
                END;
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