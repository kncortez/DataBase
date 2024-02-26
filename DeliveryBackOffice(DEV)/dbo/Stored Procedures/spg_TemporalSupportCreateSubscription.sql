CREATE PROCEDURE [dbo].[spg_TemporalSupportCreateSubscription]
@OrderNumber AS NVARCHAR(500) --= 'SP000623090445'
,@Ammount AS DECIMAL(18,2)  --= 1450
,@Email AS NVARCHAR(200) --'ludwingfigueroa80@gmail.com'
,@Token AS NVARCHAR(50) = ''
AS
BEGIN
    BEGIN
	DECLARE @IdTransaction BIGINT = 0	
	DECLARE @IdSubscription INT = 0
	DECLARE @IdMembership INT = 0
	DECLARE @CustomerId INT = 0	
	DECLARE @AccIdAccount BIGINT= 0
	DECLARE @EmailValidate AS NVARCHAR(200) 
	DECLARE @IdCustomerPaymentValue INT
	DECLARE @SubscriptionMaxServiceFixedValue INT
	DECLARE @SubscriptionValidity INT

	DECLARE @IdCatSubscription AS INT
	--Verificar si la transacción es válida
		SELECT @IdTransaction = IdTransaction FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
		WHERE OrderNumber = @OrderNumber-- 'SP000623090445'
		AND Ammount = @Ammount
		AND ReasonDescription = 'Transaction is approved'

	--La transacción fue exitosa
	IF (@IdTransaction > 0)
	BEGIN
		--verificar si no hay suscripción activa		
		SELECT @EmailValidate = A1.UsrEmail,@IdSubscription = A4.IdSubscription, @IdMembership = A5.IdMembership 
		,@CustomerId = A3.IdCustomer,@AccIdAccount = A3.AccIdAccount FROM dbo.RegisterUser A1 WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A2 WITH(NOLOCK)
			ON A1.UsrIdUser = A2.RuaIdUser
		INNER JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
			ON A3.AccIdAccount = A2.RuaIdAccount
		LEFT JOIN DeliveryBackOffice.dbo.Subscription A4 WITH(NOLOCK)
			ON A4.CustomerId = A3.IdCustomer
			AND A4.RowStatus = 1
			AND CAST(A4.ExpirationDate AS DATE) >= CAST(GETDATE() AS DATE)
		LEFT JOIN DeliveryBackOffice.dbo.Membership A5 WITH(NOLOCK)
		 ON A5.AccountId = A3.AccIdAccount AND A5.RowStatus = 1
		WHERE A1.UsrEmail = @Email

		--En caso no se encuentran registros crear la suscripción
		IF (@EmailValidate IS NULL)
		BEGIN
		 print 'El usuario no existe'
		END
		ELSE
		IF (@IdSubscription > 0)
		BEGIN
		 print 'El usuario no existe'
		END
		ELSE 
		BEGIN
		PRINT 'Insertar registros de suscripción'
		PRINT  @IdMembership

		SELECT @IdCatSubscription = IdCatSubscription,@SubscriptionMaxServiceFixedValue = SubscriptionMaxServiceFixedValue 
		,@SubscriptionValidity = SubscriptionValidity 
		FROM DeliveryBackOffice.dbo.CatSubscription
		WHERE RowStatus = 1 AND SubscriptionCost = @Ammount

		SELECT SubscriptionValidity FROM DeliveryBackOffice.dbo.CatSubscription
		WHERE RowStatus = 1 AND SubscriptionCost = @Ammount
		
		--Mejorable porque no se sabe que registro usar de todas las tarjetas que tenga el cliente
		SELECT TOP 1 @IdCustomerPaymentValue = IdCustomerPaymentValue 
		FROM DeliveryBackOffice.dbo.CustomerPaymentValue
		WHERE CustomerId = @CustomerId AND RowStatus = 1
		
		 --Insertar registros de suscripción
		 INSERT INTO DeliveryBackOffice.dbo.Subscription
		 (
		     MembershipId,
		     CatSubscriptionId,
		     CatSubscriptionStatusId,
		     SubscriptionCode,
		     SubscriptionCost,
		     CustomerId,
		     AccountId,
		     VisitPointClientId,
		     CustomerPaymentId,
		     IsAutoRenewable,
		     SubscriptionFixedValue,
		     SubscriptionMaxServiceFixedValue,
		     ActualServiceCount,
		     ExpirationDate,
		     RowStatus,
		     TokenCreated,
		     DateCreated,
		     TokenUpdated,
		     DateUpdated,
		     LastPaymentDate,
		     RenewalFixedDay,
		     RateHeaderId,
		     AlternativeRateHeaderId
		 )
		 VALUES
		 (
		 --SELECT 
		    @IdMembership,      -- MembershipId - int
		     @IdCatSubscription,         -- CatSubscriptionId - int
		     2,  --ACTIVA       -- CatSubscriptionStatusId - int 
		     NULL,      -- SubscriptionCode - nvarchar(50)
		     @Ammount,      -- SubscriptionCost - decimal(18, 2)
		     @CustomerId,      -- CustomerId - int
		     @AccIdAccount,      -- AccountId - bigint
		     NULL,      -- VisitPointClientId - int
		     @IdCustomerPaymentValue,      -- CustomerPaymentId - int
		     0,   -- IsAutoRenewable - bit
		     0,         -- SubscriptionFixedValue - int
		     @SubscriptionMaxServiceFixedValue,         -- SubscriptionMaxServiceFixedValue - int
		     0,         -- ActualServiceCount - int
		     GETDATE()+@SubscriptionValidity, -- ExpirationDate - datetime
		     1,   -- RowStatus - bit
		     @Token,       -- TokenCreated - nvarchar(50)
		     GETDATE(), -- DateCreated - datetime
		     NULL,      -- TokenUpdated - nvarchar(50)
		     NULL,      -- DateUpdated - datetime
		     NULL,      -- LastPaymentDate - datetime
		     NULL,      -- RenewalFixedDay - int
		     NULL,      -- RateHeaderId - int
		     NULL       -- AlternativeRateHeaderId - int
		     )


		END






		PRINT 'La transacción fue exitosa'

    END
	ELSE
    BEGIN
		PRINT 'No se encontró registro válido'
	END


	
	END
END