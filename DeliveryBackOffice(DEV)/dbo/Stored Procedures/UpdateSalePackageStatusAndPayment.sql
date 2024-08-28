-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <202207-14>
-- Description:	< Método para renovación y registro de pago de membresias y subscripciones mediante sistema automatizado >
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSalePackageStatusAndPayment]
    @SalePackageToRenew INT,
    @TypeOfInOutMoneyId INT = 2,
    @AuthorizationValue NVARCHAR(50),
    @TypeSalePackage NVARCHAR(20) = 'MEMBERSHIP',
    @TypeUpdate NVARCHAR(50) = 'SUCCESSFUL',
    @Token NVARCHAR(50) = 'SYS-HERMESCHARGESERVICE',
    @TransactionId NVARCHAR(50) = '',
    @TransactionOrder NVARCHAR(50) = ''
AS
BEGIN
    -- Variables estaticas globales
    DECLARE @ActiveStatus INT =
            (
                SELECT TOP 1
                       CSPS.IdCatSalesPackageStatus
                FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                WHERE CSPS.SalesPackageStatusName = 'Activa' 
                      AND CSPS.RowStatus = 1
            );
    DECLARE @SystemId INT =
            (
                SELECT TOP 1
                       CS.SysIdSystem
                FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH (NOLOCK)
                WHERE CS.SysNameSystem = 'Hermes Charge Service' 
                      AND CS.SysRowStatus = 1
            );
    DECLARE @ModuleId INT =
            (
                SELECT TOP 1
                       CM.ModIdModule
                FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH (NOLOCK)
                WHERE CM.ModName = 'Hermes Charge Service' 
                      AND CM.ModRowStatus = 1
            );

    DECLARE @AddedDaysToPointsExpiration INT
        = CAST(
          (
              SELECT TOP 1
                     CP.[Value]
              FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH (NOLOCK)
              WHERE CP.[Name] = 'ForzaPointsExpirationDays' 
          ) AS INT);

    -- Variables de control de flujo
    DECLARE @MustFailTransaction BIT = 0;
    DECLARE @CompletedFullTransaction BIT = 0;
    DECLARE @RenewedPayment AS TABLE
    (
        IdPaymentLog INT
    );
    DECLARE @RenewedSalePackage AS TABLE
    (
        IdSalePackage INT
    );

    BEGIN TRANSACTION;
    BEGIN TRY

        -- MEmbresia
        IF (@TypeSalePackage = 'MEMBERSHIP' )
        BEGIN

            -- Es del tipo membresia
            IF (@TypeUpdate = 'SUCCESSFUL' )
            BEGIN

                INSERT INTO [DeliveryBackOffice].[dbo].[MembershipPaymentLog]
                (
                    MembershipId,
                    [Authorization],
                    TypeOfInOutOfMoneyId,
                    RowStatus,
                    DateCreated,
                    TokenCreated,
                    TransactionOrder
                )
                OUTPUT inserted.IdMembershipPaymentLog
                INTO @RenewedPayment
                (
                    IdPaymentLog
                )
                VALUES
                (@SalePackageToRenew, @TransactionOrder, @TypeOfInOutMoneyId, 1, GETDATE(), @Token, @AuthorizationValue);

                IF (EXISTS (SELECT TOP 1 1 FROM @RenewedPayment))
                BEGIN
                    -- Ingreso exitosamente el pago a la bitácora

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentCompleted;
                    BEGIN TRY
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            MembershipId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Mmshp.IdMembership,
                               Mmshp.CatMembershipStatusId,
                               'Exitosamente se actualizo el pago de la renovación de la membresia.',
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp
                        WHERE Mmshp.IdMembership = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentCompleted;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentCompleted;
                    END CATCH;

                    DECLARE @FixedDate DATETIME = GETDATE();

                    UPDATE Mmshp
                    SET Mmshp.LastPaymentDate = @FixedDate,
                        Mmshp.ExpirationDate = (CASE
                                                    WHEN DAY(EOMONTH(DATEADD(MONTH, 12, @FixedDate))) <= Mmshp.RenewalFixedDay THEN
                                                        EOMONTH(DATEADD(MONTH, 12, @FixedDate))
                                                    ELSE
														DATEADD(MONTH, 12, DATEADD(DAY, Mmshp.RenewalFixedDay - DAY(@FixedDate), @FixedDate))
                                                END
                                               ),
                        Mmshp.CatMembershipStatusId = @ActiveStatus,
                        Mmshp.ActualServiceCount = 0,
                        Mmshp.RowStatus = 1,
                        Mmshp.DateUpdated = @FixedDate,
                        Mmshp.TokenUpdated = @Token,
                        Mmshp.RenewalFixedDay = ISNULL(Mmshp.RenewalFixedDay, DAY(@FixedDate)),
                        Mmshp.AccumulatedPoints = 0,
                        Mmshp.AvailablePoints = (CASE
                                                     WHEN @FixedDate <= Mmshp.PointsExpirationDate THEN
                                                         Mmshp.AvailablePoints
                                                     ELSE
                                                         0
                                                 END
                                                ),
                        Mmshp.PointsExpirationDate = DATEADD(
                                                                DAY,
                                                                @AddedDaysToPointsExpiration,
                                                                (CASE
                                                                     WHEN DAY(EOMONTH(DATEADD(MONTH, 12, @FixedDate))) <= Mmshp.RenewalFixedDay THEN
                                                                         EOMONTH(DATEADD(MONTH, 12, @FixedDate))
                                                                     ELSE
																		 DATEADD(MONTH, 12, DATEADD(DAY, Mmshp.RenewalFixedDay - DAY(@FixedDate), @FixedDate))
                                                                 END
                                                                )
                                                            )
                    OUTPUT inserted.IdMembership
                    INTO @RenewedSalePackage
                    (
                        IdSalePackage
                    )
                    FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp WITH (NOLOCK)
                        INNER JOIN [DeliveryBackOffice].[dbo].[CatMembership] CM WITH (NOLOCK)
                            ON Mmshp.CatMembershipId = CM.IdCatMembership
                    WHERE Mmshp.IdMembership = @SalePackageToRenew;

                    IF (EXISTS (SELECT TOP 1 1 FROM @RenewedSalePackage))
                    BEGIN

                        -- Actualizo exitosamente los datos de la membresia (Pudo renovar)
                        SET @CompletedFullTransaction = 1;

                        -- Microtransacción de bitácora
                        BEGIN TRANSACTION Log_SalePackage_UpdateCompleted;
                        BEGIN TRY
                            -- Registra exito en actualziar membresia
                            INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                            (
                                SystemId,
                                ModuleId,
                                MembershipId,
                                SalesPackageStatusId,
                                LogActionDescription,
                                RowStatus,
                                TokenCreated,
                                DateCreated
                            )
                            SELECT TOP 1
                                   @SystemId,
                                   @ModuleId,
                                   Mmshp.IdMembership,
                                   Mmshp.CatMembershipStatusId,
                                   'Exitosamente se actualizo los datos de la membresia.',
                                   1,
                                   @Token,
                                   GETDATE()
                            FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp
                            WHERE Mmshp.IdMembership = @SalePackageToRenew;

                            COMMIT TRANSACTION Log_SalePackage_UpdateCompleted;
                        END TRY
                        BEGIN CATCH
                            ROLLBACK TRANSACTION Log_SalePackage_UpdateCompleted;
                        END CATCH;

                    END;
                    ELSE
                    BEGIN

                        -- NO Actualizo exitosamente los datos de la membresia (No pudo renovar)
                        SET @MustFailTransaction = 1;

                        -- Microtransacción de bitácora
                        BEGIN TRANSACTION Log_SalePackage_UpdateFailure;
                        BEGIN TRY
                            -- Registra fallo en actualizar membresia
                            INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                            (
                                SystemId,
                                ModuleId,
                                MembershipId,
                                SalesPackageStatusId,
                                LogActionDescription,
                                RowStatus,
                                TokenCreated,
                                DateCreated
                            )
                            SELECT TOP 1
                                   @SystemId,
                                   @ModuleId,
                                   Mmshp.IdMembership,
                                   Mmshp.CatMembershipStatusId,
                                   CONCAT('Error al actualizar la membresia con la autorización: ', @AuthorizationValue),
                                   1,
                                   @Token,
                                   GETDATE()
                            FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp
                            WHERE Mmshp.IdMembership = @SalePackageToRenew;

                            COMMIT TRANSACTION Log_SalePackage_UpdateFailure;
                        END TRY
                        BEGIN CATCH
                            ROLLBACK TRANSACTION Log_SalePackage_UpdateFailure;
                        END CATCH;

                    END;

                END;
                ELSE
                BEGIN

                    -- NO se ingreso correctamente el pago de la membresia
                    SET @MustFailTransaction = 1;

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentFailure;
                    BEGIN TRY
                        -- Registra fallo en registrar pago
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            MembershipId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Mmshp.IdMembership,
                               Mmshp.CatMembershipStatusId,
                               CONCAT('Error al actualizar el pago de la membresia: ', @AuthorizationValue),
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp
                        WHERE Mmshp.IdMembership = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentFailure;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentFailure;
                    END CATCH;

                END;

            END;
            ELSE
            BEGIN

                -- Se registra el rechazo 
                INSERT INTO [DeliveryBackOffice].[dbo].[MembershipPaymentLog]
                (
                    MembershipId,
                    [Authorization],
                    TypeOfInOutOfMoneyId,
                    RowStatus,
                    DateCreated,
                    TokenCreated,
                    TransactionOrder
                )
                OUTPUT inserted.IdMembershipPaymentLog
                INTO @RenewedPayment
                (
                    IdPaymentLog
                )
                VALUES
                (@SalePackageToRenew, @TransactionOrder, @TypeOfInOutMoneyId, 1, GETDATE(), @Token, 'REJECTED');

                -- Ingresar a bitácora 
                IF (EXISTS (SELECT TOP 1 1 FROM @RenewedPayment))
                BEGIN

                    -- Ingreso exitosamente el pago rechazado
                    SET @CompletedFullTransaction = 1;

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentFailure;
                    BEGIN TRY
                        -- Registra exito al registrar rechazo del pago
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            MembershipId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Mmshp.IdMembership,
                               Mmshp.CatMembershipStatusId,
                               'Se rechaza la transacción del pago.',
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp
                        WHERE Mmshp.IdMembership = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentFailure;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentFailure;
                    END CATCH;

                END;
                ELSE
                BEGIN

                    -- NO se ingreso exitosamente el pago rechazado
                    SET @MustFailTransaction = 1;

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentFailure;
                    BEGIN TRY
                        -- Registra fallo al registrar rechazo del pago
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Mmshp.CatMembershipStatusId,
                               'Error al ingresar el rechazo del pago.',
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp
                        WHERE Mmshp.IdMembership = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentFailure;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentFailure;
                    END CATCH;

                END;

            END;

        END;
        -- Subscripción
        ELSE IF (@TypeSalePackage = 'SUBSCRIPTION' )
        BEGIN

            -- Es del tipo subscripcion
            IF (@TypeUpdate = 'SUCCESSFUL' )
            BEGIN

                INSERT INTO [DeliveryBackOffice].[dbo].[SubscriptionPaymentLog]
                (
                    SubscriptionId,
                    [Authorization],
                    TypeOfInOutOfMoneyId,
                    RowStatus,
                    DateCreated,
                    TokenCreated,
                    TransactionOrder
                )
                OUTPUT inserted.IdSubscriptionPaymentLog
                INTO @RenewedPayment
                (
                    IdPaymentLog
                )
                VALUES
                (@SalePackageToRenew, @TransactionOrder, @TypeOfInOutMoneyId, 1, GETDATE(), @Token, @AuthorizationValue);

                IF (EXISTS (SELECT TOP 1 1 FROM @RenewedPayment))
                BEGIN
                    -- Ingreso exitosamente el pago a la bitácora

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentCompleted;
                    BEGIN TRY
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            MembershipId,
                            SubscriptionId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Sbscrptn.MembershipId,
                               Sbscrptn.SubscriptionCode,
                               Sbscrptn.CatSubscriptionStatusId,
                               'Exitosamente se actualizo el pago de la renovación de la subscripción.',
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn
                        WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentCompleted;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentCompleted;
                    END CATCH;

                    DECLARE @FixedDate2 DATETIME = GETDATE();

                    UPDATE Sbscrptn
                    SET Sbscrptn.LastPaymentDate = @FixedDate2,
                        Sbscrptn.ExpirationDate = (CASE
                                                       WHEN DAY(EOMONTH(DATEADD(MONTH, 1, @FixedDate2))) <= Sbscrptn.RenewalFixedDay THEN
                                                           EOMONTH(DATEADD(MONTH, 1, @FixedDate2))
                                                       ELSE
                                                           DATEADD(MONTH, 1, DATEADD(DAY, Sbscrptn.RenewalFixedDay - DAY(@FixedDate2), @FixedDate2))
                                                   END
                                                  ),
                        Sbscrptn.CatSubscriptionStatusId = @ActiveStatus,
                        Sbscrptn.ActualServiceCount = 0,
                        Sbscrptn.RowStatus = 1,
                        Sbscrptn.DateUpdated = @FixedDate2,
                        Sbscrptn.TokenUpdated = @Token,
                        Sbscrptn.RenewalFixedDay = ISNULL(Sbscrptn.RenewalFixedDay, DAY(@FixedDate2))
                    OUTPUT inserted.IdSubscription
                    INTO @RenewedSalePackage
                    (
                        IdSalePackage
                    )
                    FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn WITH (NOLOCK)
                        INNER JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
                            ON Sbscrptn.CatSubscriptionId = CS.IdCatSubscription
                    WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

                    IF (EXISTS (SELECT TOP 1 1 FROM @RenewedSalePackage))
                    BEGIN

                        -- Actualizo exitosamente los datos de la membresia (Pudo renovar)
                        SET @CompletedFullTransaction = 1;

                        -- Microtransacción de bitácora
                        BEGIN TRANSACTION Log_SalePackage_UpdateCompleted;
                        BEGIN TRY
                            -- Registra exito en actualziar membresia
                            INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                            (
                                SystemId,
                                ModuleId,
                                MembershipId,
                                SubscriptionId,
                                SalesPackageStatusId,
                                LogActionDescription,
                                RowStatus,
                                TokenCreated,
                                DateCreated
                            )
                            SELECT TOP 1
                                   @SystemId,
                                   @ModuleId,
                                   Sbscrptn.MembershipId,
                                   Sbscrptn.IdSubscription,
                                   Sbscrptn.CatSubscriptionStatusId,
                                   'Exitosamente se actualizo los datos de la membresia.',
                                   1,
                                   @Token,
                                   GETDATE()
                            FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn
                            WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

                            COMMIT TRANSACTION Log_SalePackage_UpdateCompleted;
                        END TRY
                        BEGIN CATCH
                            ROLLBACK TRANSACTION Log_SalePackage_UpdateCompleted;
                        END CATCH;

                    END;
                    ELSE
                    BEGIN

                        -- NO Actualizo exitosamente los datos de la membresia (No pudo renovar)
                        SET @MustFailTransaction = 1;

                        -- Microtransacción de bitácora
                        BEGIN TRANSACTION Log_SalePackage_UpdateFailure;
                        BEGIN TRY
                            -- Registra fallo en actualizar membresia
                            INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                            (
                                SystemId,
                                ModuleId,
                                MembershipId,
                                SubscriptionId,
                                SalesPackageStatusId,
                                LogActionDescription,
                                RowStatus,
                                TokenCreated,
                                DateCreated
                            )
                            SELECT TOP 1
                                   @SystemId,
                                   @ModuleId,
                                   Sbscrptn.MembershipId,
                                   Sbscrptn.IdSubscription,
                                   Sbscrptn.CatSubscriptionStatusId,
                                   CONCAT('Error al actualizar la membresia con la autorización: ', @AuthorizationValue),
                                   1,
                                   @Token,
                                   GETDATE()
                            FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn
                            WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

                            COMMIT TRANSACTION Log_SalePackage_UpdateFailure;
                        END TRY
                        BEGIN CATCH
                            ROLLBACK TRANSACTION Log_SalePackage_UpdateFailure;
                        END CATCH;

                    END;

                END;
                ELSE
                BEGIN

                    -- NO se ingreso correctamente el pago de la membresia
                    SET @MustFailTransaction = 1;

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentFailure;
                    BEGIN TRY
                        -- Registra fallo en registrar pago
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            MembershipId,
                            SubscriptionId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Sbscrptn.MembershipId,
                               Sbscrptn.IdSubscription,
                               Sbscrptn.CatSubscriptionStatusId,
                               CONCAT('Error al actualizar el pago de la membresia: ', @AuthorizationValue),
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn
                        WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentFailure;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentFailure;
                    END CATCH;

                END;

            END;
            ELSE
            BEGIN

                -- Se registra el rechazo 
                INSERT INTO [DeliveryBackOffice].[dbo].[SubscriptionPaymentLog]
                (
                    SubscriptionId,
                    [Authorization],
                    TypeOfInOutOfMoneyId,
                    RowStatus,
                    DateCreated,
                    TokenCreated,
                    TransactionOrder
                )
                OUTPUT inserted.IdSubscriptionPaymentLog
                INTO @RenewedPayment
                (
                    IdPaymentLog
                )
                VALUES
                (@SalePackageToRenew, @TransactionOrder, @TypeOfInOutMoneyId, 1, GETDATE(), @Token, 'REJECTED');

                -- Ingresar a bitácora 
                IF (EXISTS (SELECT TOP 1 1 FROM @RenewedPayment))
                BEGIN

                    -- Ingreso exitosamente el pago rechazado
                    SET @CompletedFullTransaction = 1;

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentFailure;
                    BEGIN TRY
                        -- Registra exito al registrar rechazo del pago
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            MembershipId,
                            SubscriptionId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Sbscrptn.MembershipId,
                               Sbscrptn.IdSubscription,
                               Sbscrptn.CatSubscriptionStatusId,
                               'Se rechaza la transacción del pago.',
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn
                        WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentFailure;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentFailure;
                    END CATCH;

                END;
                ELSE
                BEGIN

                    -- NO se ingreso exitosamente el pago rechazado
                    SET @MustFailTransaction = 1;

                    -- Microtransacción de bitácora
                    BEGIN TRANSACTION Log_SalePackage_PaymentFailure;
                    BEGIN TRY
                        -- Registra fallo al registrar rechazo del pago
                        INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
                        (
                            SystemId,
                            ModuleId,
                            MembershipId,
                            SubscriptionId,
                            SalesPackageStatusId,
                            LogActionDescription,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            LogTransactionId,
                            LogTransactionOrder
                        )
                        SELECT TOP 1
                               @SystemId,
                               @ModuleId,
                               Sbscrptn.MembershipId,
                               Sbscrptn.IdSubscription,
                               Sbscrptn.CatSubscriptionStatusId,
                               'Error al ingresar el rechazo del pago.',
                               1,
                               @Token,
                               GETDATE(),
                               @TransactionId,
                               @TransactionOrder
                        FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn
                        WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

                        COMMIT TRANSACTION Log_SalePackage_PaymentFailure;
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRANSACTION Log_SalePackage_PaymentFailure;
                    END CATCH;

                END;

            END;

        END;

        IF (@CompletedFullTransaction = 1 AND @MustFailTransaction = 0)
        BEGIN
            IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

            SELECT CAST(1 AS BIT) [blnResult];
        END;
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT CAST(0 AS BIT) [blnResult];
        END;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        IF (@TypeSalePackage = 'MEMBERSHIP' )
        BEGIN

            INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
            (
                SystemId,
                ModuleId,
                MembershipId,
                SalesPackageStatusId,
                LogActionDescription,
                RowStatus,
                TokenCreated,
                DateCreated,
                LogTransactionId,
                LogTransactionOrder
            )
            SELECT TOP 1
                   @SystemId,
                   @ModuleId,
                   Mmshp.IdMembership,
                   Mmshp.CatMembershipStatusId,
                   ERROR_MESSAGE(),
                   1,
                   @Token,
                   GETDATE(),
                   @TransactionId,
                   @TransactionOrder
            FROM [DeliveryBackOffice].[dbo].[Membership] Mmshp
            WHERE Mmshp.IdMembership = @SalePackageToRenew;

        END;
        ELSE IF (@TypeSalePackage = 'SUBSCRIPTION' )
        BEGIN

            INSERT INTO [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog]
            (
                SystemId,
                ModuleId,
                MembershipId,
                SubscriptionId,
                SalesPackageStatusId,
                LogActionDescription,
                RowStatus,
                TokenCreated,
                DateCreated,
                LogTransactionId,
                LogTransactionOrder
            )
            SELECT TOP 1
                   @SystemId,
                   @ModuleId,
                   Sbscrptn.MembershipId,
                   Sbscrptn.IdSubscription,
                   Sbscrptn.CatSubscriptionStatusId,
                   ERROR_MESSAGE(),
                   1,
                   @Token,
                   GETDATE(),
                   @TransactionId,
                   @TransactionOrder
            FROM [DeliveryBackOffice].[dbo].[Subscription] Sbscrptn
            WHERE Sbscrptn.IdSubscription = @SalePackageToRenew;

        END;

        SELECT CAST(0 AS BIT) [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

    END CATCH;
END;