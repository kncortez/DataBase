USE [DeliveryBackOffice]
GO

DECLARE @IdCatSubscription varchar(100) =(Select TOP 1 IdCatSubscription From dbo.CatSubscription Where SubscriptionName = 'Plan Básico' And RowStatus=1)
DECLARE @IdNewSubscriptions INT =0
DECLARE @Token varchar(100)='sys-admin'
DECLARE @StartingStatus INT = (
                                      SELECT TOP 1
                                          CSPS.IdCatSalesPackageStatus
                                      FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                                      WHERE CSPS.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI
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
         
            SELECT 
			       M.IdMembership
                 , @IdCatSubscription
                 , @StartingStatus
                 , 0
                 , M.CustomerId
                 , M.AccountId
                 , NULL -- agregar columna en insert para codigo de membresia 
                 , NULL                                         -- Si es corporativo y tiene credito o si esta pagando con tarjeta asociada
                 , 0
                 , 0
                 , 0
                 , 0
                 , M.ExpirationDate
                 , 1
                 , @Token
                 , GETDATE()
                 , DAY(GETDATE())
                 , 1
            FROM (
					SELECT
						IdMembership,
						CustomerId,
						AccountId,
						ExpirationDate,
						ROW_NUMBER() OVER (PARTITION BY AccountId ORDER BY IdMembership) AS RowNum
					FROM [DeliveryBackOffice].[dbo].[Membership] WITH (NOLOCK)
					WHERE RowStatus = 1 
						AND Cast(ExpirationDate As Date) > Cast(GETDATE() As Date)
				) AS M
			WHERE M.RowNum = 1

			SET @IdNewSubscriptions = SCOPE_IDENTITY();
            IF (@IdNewSubscriptions>0)
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
                SELECT @IdNewSubscriptions
                     , CMDR.ValueTypeId
                     , CMDR.DiscountValue
                     , CMDR.DiscountLowServiceRange
                     , CMDR.DiscountTopServiceRange
                     , 1
                     , @Token
                     , GETDATE()
                FROM [DeliveryBackOffice].[dbo].[CatSubscriptionDiscountRange] CMDR WITH (NOLOCK)
                WHERE CMDR.CatSubscriptionId = @IdCatSubscription;

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
                SELECT @IdNewSubscriptions
                     , 7
                     , NULL
                     , 1
                     , @Token
                     , GETDATE();
END




             
       