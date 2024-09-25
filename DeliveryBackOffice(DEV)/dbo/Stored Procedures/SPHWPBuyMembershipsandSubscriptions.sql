-- =============================================
-- Author:		<Author,,Edelman Vásquez>
-- Create date: <Create Date,2022-07-14>
-- Description:	<Description, adquisición de membresia o suscripción>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-05-07>
-- Description:	<quitar restricción para adquirir misma suscripción>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-07-27>
-- Description:	<Agregar bandera para indicar si membresía es autorenovable>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWPBuyMembershipsandSubscriptions]
    -- Add the parameters for the stored procedure here
    @IdTarjeta AS INT = NULL         -- puede ser null por ex c y por credito
  , @TypeSalePackage AS NVARCHAR(50) -- membership or suscription
  , @IdSalePackage AS INT            -- id membership or suscription
  , @IdAcount AS BIGINT              ---- user
  , @Vaucher AS NVARCHAR(50) = NULL  -- comprobante de factura pago con tarjeta
  , @TypeOfInMoneyId INT             -- Tipo de pago
  , @ModulId AS INT = NULL           --  pagina o form desde donde se hizo la operación 
  , @SystemId AS INT                 --  1 y 2 web o 
  , @Token AS NVARCHAR(50)
  , @TaxId NVARCHAR(50) = 'CF'
  , @FiscalAddress NVARCHAR(200) = 'Ciudad'
  , @TaxName NVARCHAR(100) = 'CONSUMIDOR FINAL'
  , @InvoiceEmail NVARCHAR(50) = ''
  , @IsAutoRenewable Bit = 0
AS
BEGIN

    SET NOCOUNT ON;

    -- Variables estaticas "globales"
    DECLARE @StartingStatus INT =
            (
                SELECT TOP 1
                       CSPS.IdCatSalesPackageStatus
                FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                WHERE CSPS.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI
            );

    DECLARE @StatusSubcription INT =
            (
                SELECT COUNT(IdSubscription)
                FROM [DeliveryBackOffice].[dbo].[Subscription]
                WHERE AccountId = @IdAcount
                      AND RowStatus = 1
                      AND CatSubscriptionId = @IdSalePackage
            );

    -- Variables de control de flujo
    DECLARE @TransactionSuccess BIT = 0;
    DECLARE @ActivationCode NVARCHAR(100) = N'';
    DECLARE @ActiveMembershipId INT = 0;
    DECLARE @StatusMembershipt INT = 0;
    DECLARE @CustomerType INT = 0;
    DECLARE @HasCredit BIT = 0;
    DECLARE @AddedPointExpirationDate INT = 0;
    DECLARE @Idcustumer AS INT;
    DECLARE @JsonResponse NVARCHAR(MAX) = N'';

    SET @AddedPointExpirationDate
        = CAST(ISNULL((
                          SELECT TOP 1
                                 [CP].[Value]
                          FROM [DeliveryBackOffice].[dbo].[ConfigParams] [CP] WITH (NOLOCK)
                          WHERE [CP].[Name] = 'ForzaPointsExpirationDays' COLLATE Latin1_General_CI_AI
                      )
                    , 0
                     ) AS INT);
    --- Estado de membresia
    SELECT TOP 1
           @StatusMembershipt  = 1
         , @ActiveMembershipId = IdMembership
    FROM [DeliveryBackOffice].[dbo].[Membership]
    WHERE AccountId = @IdAcount
          AND RowStatus = 1;

    --- validar si cliente posee credito​
    SELECT TOP 1
           @CustomerType = ISNULL(Cu.IdCustomerType, 0)
         , @HasCredit    = ISNULL(   (CASE
                                          WHEN CCOP.ConditionOfPaymenAbbreviation LIKE '%CREDITO%' THEN
                                              1
                                          ELSE
                                              0
                                      END
                                     )
                                   , 0
                                 ) ---custumerType es 1 para corporativos
         , @Idcustumer   = Cu.IdCustomer
    FROM [DeliveryBackOffice].[dbo].[Account]                        AC WITH (NOLOCK)
        LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]              Cu WITH (NOLOCK)
            ON AC.IdCustomer = Cu.IdCustomer
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatConditionOfPayment] CCOP WITH (NOLOCK)
            ON Cu.ConditionOfPaymentID = CCOP.IdConditionOfPayment
    WHERE AC.AccIdAccount = @IdAcount;

    IF (@CustomerType = 2)
    BEGIN
        SET @ActivationCode = NEWID();
    END;
    ---- adquisición de membresia​
    BEGIN TRANSACTION;
    BEGIN TRY
        IF (
               @TypeSalePackage = 'Membership' COLLATE Latin1_General_CI_AI
               AND ISNULL(@StatusMembershipt, 0) < 1
           )
        BEGIN

            PRINT 'INSERT MEMBRESIA';
            DECLARE @AuxNewMembership AS TABLE
            (
                IdNewMembership INT
            );

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
            )
            OUTPUT inserted.IdMembership
            INTO @AuxNewMembership
            (
                IdNewMembership
            )
            SELECT CM.IdCatMembership
                 , @StartingStatus
                 , CM.MembershipCost
                 , IIF(@CustomerType = 2, NULL, @Idcustumer)
                 , IIF(@CustomerType = 2, NULL, @IdAcount)
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
                 , 1
                 , CM.MembershipFixedValue
                 , CM.MembershipMaxServiceFixedValue
                 , 0
                 , DATEADD(MONTH, CM.MembershipValidity, GETDATE())
                 , 1
                 , @Token
                 , GETDATE()
                 , @TaxId
                 , @TaxName
                 , @InvoiceEmail
                 , @FiscalAddress
                 , DAY(GETDATE())
                 , 0
                 , 0
                 , DATEADD(DAY, @AddedPointExpirationDate, DATEADD(MONTH, [CM].[MembershipValidity], GETDATE()))
                 , CDR.ValueTypeId
            FROM [DeliveryBackOffice].[dbo].[CatMembership] CM WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange] CDR WITH (NOLOCK)
			ON CM.IdCatMembership = CDR.CatMembershipId
            WHERE CM.IdCatMembership = @IdSalePackage
                  AND NOT EXISTS
            (
                SELECT TOP 1
                       1
                FROM [DeliveryBackOffice].[dbo].[Membership] M WITH (NOLOCK)
                WHERE M.CustomerId = @Idcustumer
                      AND (M.AccountId = @IdAcount)
                      AND M.RowStatus = 1
            );

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
                     , 1
                     , @Token
                     , GETDATE()
                FROM [DeliveryBackOffice].[dbo].[CatMembershipDiscountRange] CMDR WITH (NOLOCK)
                    CROSS JOIN @AuxNewMembership                             ANM
                WHERE CMDR.CatMembershipId = @IdSalePackage;

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

                SET @JsonResponse =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":200,' + '"Message":"Adquisición de :' + @TypeSalePackage
                                               + ' Exitosa...!!", "ActivationCode": "' + ISNULL(@ActivationCode, '')
                                               + '" }'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)')
                                  , 1
                                  , 1
                                  , ''
                                )
                );

            END;


        END;
        ELSE IF (
                    @TypeSalePackage = 'Suscription' COLLATE Latin1_General_CI_AI
                    AND
                    (
                        (ISNULL(@StatusMembershipt, 0) > 0)
                        OR @CustomerType = 2
                    )
                )
        BEGIN


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
            )
            OUTPUT inserted.IdSubscription
            INTO @AuxNewSubscriptions
            (
                IdNewSubscriptions
            )
            SELECT IIF(@CustomerType = 2, NULL, @ActiveMembershipId)
                 , CS.IdCatSubscription
                 , @StartingStatus
                 , CS.SubscriptionCost
                 , IIF(@CustomerType = 2, NULL, @Idcustumer)
                 , IIF(@CustomerType = 2, NULL, @IdAcount)
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
                 , DATEADD(DAY, CS.SubscriptionValidity, GETDATE())
                 , 1
                 , @Token
                 , GETDATE()
                 , DAY(GETDATE())
                 , CS.CatTypeSubscriptionId
            FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
            WHERE CS.IdCatSubscription = @IdSalePackage;


            IF (EXISTS (SELECT TOP 1 1 FROM @AuxNewSubscriptions))
            BEGIN

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
                SELECT ANM2.IdNewSubscriptions
                     , CMDR.ValueTypeId
                     , CMDR.DiscountValue
                     , CMDR.DiscountLowServiceRange
                     , CMDR.DiscountTopServiceRange
                     , 1
                     , @Token
                     , GETDATE()
                FROM [DeliveryBackOffice].[dbo].[CatSubscriptionDiscountRange] CMDR WITH (NOLOCK)
                    CROSS JOIN @AuxNewSubscriptions                            ANM2
                WHERE CMDR.CatSubscriptionId = @IdSalePackage;

                ---- Log de pago de membresia
                INSERT INTO [DeliveryBackOffice].[dbo].[SubscriptionPaymentLog]
                (
                    SubscriptionId
                  , TypeOfInOutOfMoneyId
                  , [Authorization]
                  , RowStatus
                  , TokenCreated
                  , DateCreated
                )
                SELECT ANM2.IdNewSubscriptions
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
                FROM @AuxNewSubscriptions ANM2;


                /* Actualiza fecha de vigencia de las suscripciones vigentes por 180 días mas  */

                DECLARE @SubscriptionValidity INT =
                        (
                            SELECT TOP 1
                                   CS.SubscriptionValidity
                            FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
                            WHERE CS.IdCatSubscription = @IdSalePackage
                        );

                UPDATE dbo.Subscription
                SET ExpirationDate = GETDATE() + @SubscriptionValidity
                  , TokenUpdated = @Token
                  , DateUpdated = GETDATE()
                WHERE CustomerId = @Idcustumer
                      AND RowStatus = 1
                      AND CONVERT(VARCHAR(10), ExpirationDate, 20) >= CONVERT(VARCHAR(10), GETDATE(), 20)
                      AND (SubscriptionMaxServiceFixedValue - ActualServiceCount) >= 1;
                /*---------------------------------------------------------------*/


                SET @JsonResponse =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":200,' + '"Message":"Adquisición de :' + @TypeSalePackage
                                               + ' Exitosa...!!", "ActivationCode": "' + ISNULL(@ActivationCode, '')
                                               + '" }'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)')
                                  , 1
                                  , 1
                                  , ''
                                )
                );

            END;
            ELSE
            BEGIN

                SET @JsonResponse =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":"Adquisición de :' + @TypeSalePackage
                                               + ' no fue posible...!!" }'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)')
                                  , 1
                                  , 1
                                  , ''
                                )
                );
            END;

        END;
        ELSE
        BEGIN

            SET @JsonResponse =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":"Adquisición de :' + @TypeSalePackage
                                           + ' no fue posible...!!" }'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)')
                              , 1
                              , 1
                              , ''
                            )
            );
        END;

        IF (@JsonResponse IS NOT NULL)
        BEGIN
            IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;
        END;
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;

            SET @JsonResponse =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":"Adquisición de :' + @TypeSalePackage
                                           + ' no fue posible...!!"' + ISNULL(@StatusSubcription, '0') + ' }'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)')
                              , 1
                              , 1
                              , ''
                            )
            );

        END;

        SELECT ('[' + @JsonResponse + ']') JsonOutput;
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SET @JsonResponse =
        (
            SELECT STUFF((
                             SELECT '{{"IdResult":500,' + '"Message":"' + ERROR_MESSAGE() + '" }'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

    END CATCH;
END;