
-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <19/01/2024>
-- Description:	<Obtener información de productos para envío de correos>
-- =============================================
CREATE PROCEDURE [dbo].[MKRetrieveProductInformationForShippingEmails]
@TransactionId VARCHAR (100),
@Telemarketing BIT 
AS

BEGIN

     DECLARE  @URL_USER_LOGIN VARCHAR (200) = 'https://portal.forzadelivery.com/design/individual/centro-canje';
	 DECLARE  @URL_USER_NOT_LOGIN VARCHAR (200)='https://portal.forzadelivery.com';

	
		IF(@Telemarketing = 0)
	BEGIN 
		--PRINT 'USUARIO LOGUEADO'
		IF EXISTS(SELECT UsrEmail from RegisterUser WHERE UsrEmail = (SELECT Top 1 InvoiceEmail FROM RegistrationofTransactionProcessStates WHERE OrderNumber = @TransactionId))
		BEGIN 
		
			SELECT TBL.[UsrEmail],TBL.[IdProduct],TBL.[Email],TBL.[ClientName],TBL.[ProductType],TBL.[ProductName],TBL.[ActivationCode],TBL.[ProductCost],TBL.[OrderMail],
			IIF(TBL.[ActivationCode]='ACTIVADO',@URL_USER_LOGIN,@URL_USER_NOT_LOGIN) [URL]
			FROM
			(
			SELECT InvoiceEmail [UsrEmail], 
			--COALESCE(A5.UsrEmail,RT.InvoiceEmail) [UsrEmail], 
			A2.IdSubscription [IdProduct], 
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL', A5.UsrEmail,ProductGiftShippingEmail)  [Email],
			IIF(A6.PerFirstName IS NULL,RT.NameTax, COALESCE(A6.PerFirstName,'') + IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'')) [ClientName],
			'S' [ProductType],
			A7.SubscriptionName [ProductName],
			IIF(A5.UsrEmail IS NOT NULL AND (LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL'),'ACTIVADO',IIF( A5.UsrEmail IS NOT NULL AND (LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 OR A2.ProductGiftShippingEmail != 'NULL') /*AND A5.UsrEmail != A2.ProductGiftShippingEmail*/ AND EXISTS(SELECT UsrEmail FROM RegisterUser WHERE UsrEmail = A2.ProductGiftShippingEmail ),'ACTIVADO',A2.ActivationCode)) [ActivationCode],
			A2.SubscriptionCost [ProductCost],
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [OrderMail]
			FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog A1 WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Subscription A2 WITH(NOLOCK)
			 ON A1.SubscriptionId = A2.IdSubscription --AND A2.RowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
				ON A3.AccIdAccount = A2.AccountId
				AND A3.AccRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
				ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
				ON A5.UsrIdUser = A4.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
				ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatSubscription A7 WITH(NOLOCK)
				ON A7.IdCatSubscription = A2.CatSubscriptionId
			OUTER APPLY (
			 SELECT top 1 InvoiceEmail,NameTax 
			 FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates RT
			 WHERE RT.OrderNumber = @TransactionId	) RT
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			UNION
			SELECT COALESCE(A5.UsrEmail,RT.InvoiceEmail) [UsrEmail],
			A2.IdMembership [IdProduct], 
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,A5.UsrEmail,ProductGiftShippingEmail)  [Email],
			IIF(A6.PerLastName IS NULL,RT.NameTax,  COALESCE(A6.PerFirstName,'') + IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'')) [ClientName],
			'M' [ProductType],	 
			A7.MembershipName [ProductName],
			IIF(A5.UsrEmail IS NOT NULL AND (LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL'),'ACTIVADO',IIF( A5.UsrEmail IS NOT NULL AND (LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 OR A2.ProductGiftShippingEmail != 'NULL') /*AND A5.UsrEmail != A2.ProductGiftShippingEmail*/ AND EXISTS(SELECT UsrEmail FROM RegisterUser WHERE UsrEmail = A2.ProductGiftShippingEmail ),'ACTIVADO',A2.ActivationCode)) [ActivationCode],
			A2.MembershipCost [ProductCost],
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [OrderMail]
			FROM DeliveryBackOffice.dbo.MembershipPaymentLog A1 WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Membership A2 WITH(NOLOCK)
			 ON A2.IdMembership = A1.MembershipId --AND A2.RowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
				ON A3.AccIdAccount = A2.AccountId
				AND A3.AccRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
				ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
				ON A5.UsrIdUser = A4.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
				ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatMembership A7 WITH(NOLOCK)
				ON A7.IdCatMembership = A2.CatMembershipId
			OUTER APPLY (
			 SELECT top 1 InvoiceEmail,NameTax
			 FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates RT
			 WHERE RT.OrderNumber = @TransactionId	
			) RT
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			)TBL
			ORDER BY TBL.OrderMail DESC

			SELECT DISTINCT A2.ProductGiftShippingEmail [Email] 	
			FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog A1 WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Subscription A2 WITH(NOLOCK)
			 ON A1.SubscriptionId = A2.IdSubscription --AND A2.RowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
				ON A3.AccIdAccount = A2.AccountId
				AND A3.AccRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
				ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
				ON A5.UsrIdUser = A4.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
				ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatSubscription A7 WITH(NOLOCK)
				ON A7.IdCatSubscription = A2.CatSubscriptionId
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			AND  LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 
			AND A2.ProductGiftShippingEmail <> 'NULL' 
			UNION
			SELECT DISTINCT A2.ProductGiftShippingEmail  [Email] 		 
			FROM DeliveryBackOffice.dbo.MembershipPaymentLog A1 WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Membership A2 WITH(NOLOCK)
			 ON A2.IdMembership = A1.MembershipId --AND A2.RowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
				ON A3.AccIdAccount = A2.AccountId
				AND A3.AccRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
				ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
				ON A5.UsrIdUser = A4.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
				ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatMembership A7 WITH(NOLOCK)
				ON A7.IdCatMembership = A2.CatMembershipId
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			AND  LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 
			AND A2.ProductGiftShippingEmail <> 'NULL' 
		END
		ELSE -- PARA ENVIAR CORREOS QUE NO TIENEN CUENTA
		BEGIN
			--PRINT 'USUARIO NO LOGUEADO'
			SELECT TBL.[UsrEmail],TBL.[IdProduct],TBL.[Email],TBL.[ClientName],TBL.[ProductType],TBL.[ProductName],TBL.[ActivationCode],TBL.[ProductCost],TBL.[OrderMail],
			IIF(TBL.[ActivationCode]='ACTIVADO',@URL_USER_LOGIN,@URL_USER_NOT_LOGIN) [URL]
			FROM
			(
			SELECT A3.InvoiceEmail [UsrEmail], 
			A2.IdSubscription [IdProduct], 
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,NULL,A2.ProductGiftShippingEmail)  [Email],
			A3.NameTax [ClientName],
			'S' [ProductType],
			A4.SubscriptionName [ProductName],
			IIF( EXISTS(SELECT UsrEmail FROM RegisterUser WHERE UsrEmail = COALESCE(A2.ProductGiftShippingEmail, '') ),'ACTIVADO',A2.ActivationCode) [ActivationCode],
			A2.SubscriptionCost [ProductCost],
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [OrderMail]
			FROM [dbo].[SubscriptionPaymentLog] A1 WITH(NOLOCK)
			INNER JOIN [dbo].[Subscription] A2 WITH(NOLOCK)
			 ON A1.SubscriptionId = A2.IdSubscription
			LEFT JOIN [dbo].[RegistrationofTransactionProcessStates] A3 WITH(NOLOCK)
				ON A1.[Authorization] = A3.[OrderNumber] 
			LEFT JOIN [dbo].[CatSubscription] A4 WITH(NOLOCK)
				ON A4.IdCatSubscription = A2.CatSubscriptionId
			OUTER APPLY (
				SELECT top 1 InvoiceEmail,NameTax, ProductGiftShippingEmail 
				from DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates RT
				WHERE RT.OrderNumber = @TransactionId	
				) RT
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			UNION
			SELECT A3.InvoiceEmail [UsrEmail],
			A2.IdMembership [IdProduct], 
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,NULL,A2.ProductGiftShippingEmail)  [Email],
			A3.NameTax  [ClientName],
			'M' [ProductType],	 
			A4.MembershipName [ProductName],
			IIF( (LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 OR A2.ProductGiftShippingEmail != 'NULL') AND EXISTS(SELECT UsrEmail FROM RegisterUser WHERE UsrEmail = A2.ProductGiftShippingEmail ),'ACTIVADO',A2.ActivationCode) [ActivationCode],
			A2.MembershipCost [ProductCost],
			IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [OrderMail]
			FROM [dbo].[MembershipPaymentLog] A1 WITH(NOLOCK)
			INNER JOIN [dbo].[Membership] A2 WITH(NOLOCK)
			 ON A2.IdMembership = A1.MembershipId --AND A2.RowStatus = 1
			LEFT JOIN [dbo].[RegistrationofTransactionProcessStates] A3 WITH(NOLOCK)
				ON A1.[Authorization] = A3.[OrderNumber] 
			LEFT JOIN [dbo].[CatMembership] A4 WITH(NOLOCK)
				ON A4.IdCatMembership = A2.CatMembershipId
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			)TBL
			order by TBL.OrderMail desc 

			SELECT DISTINCT A2.ProductGiftShippingEmail [Email] 	
			FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog A1 WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Subscription A2 WITH(NOLOCK)
				ON A1.SubscriptionId = A2.IdSubscription --AND A2.RowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
				ON A3.AccIdAccount = A2.AccountId
				AND A3.AccRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
				ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
				ON A5.UsrIdUser = A4.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
				ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatSubscription A7 WITH(NOLOCK)
				ON A7.IdCatSubscription = A2.CatSubscriptionId
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			AND  LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 
			AND A2.ProductGiftShippingEmail <> 'NULL' 
			UNION
			SELECT DISTINCT A2.ProductGiftShippingEmail  [Email] 		 
			FROM DeliveryBackOffice.dbo.MembershipPaymentLog A1 WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.Membership A2 WITH(NOLOCK)
				ON A2.IdMembership = A1.MembershipId --AND A2.RowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
				ON A3.AccIdAccount = A2.AccountId
				AND A3.AccRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
				ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
				ON A5.UsrIdUser = A4.RuaIdUser
			LEFT JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
				ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatMembership A7 WITH(NOLOCK)
				ON A7.IdCatMembership = A2.CatMembershipId
			WHERE [Authorization] = @TransactionId--'SP00024113083'
			AND  LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 
			AND A2.ProductGiftShippingEmail <> 'NULL' 
			
			/*LISTADO DE CORREOS PARA REGALOS*//*
			SELECT RTPS.ProductGiftShippingEmail [Email] 	 
			FROM [dbo].[RegistrationofTransactionProcessStates] RTPS WITH(NOLOCK)
			WHERE OrderNumber = @TransactionId
			AND  LEN(COALESCE(RTPS.ProductGiftShippingEmail,'')) > 0 
			AND RTPS.ProductGiftShippingEmail <> 'NULL'*/
		END
	END
	ELSE   -- SI FUERA UN CORREO GENERADO POR TELEMARKETING
	BEGIN
	    --PRINT 'USUARIO TELEMARKETING'
		select TBL.[UsrEmail],TBL.[IdProduct],TBL.[Email],TBL.[ClientName],TBL.[ProductType],TBL.[ProductName],TBL.[ActivationCode],TBL.[ProductCost],TBL.[OrderMail],
		IIF(TBL.[ActivationCode]='ACTIVADO',@URL_USER_LOGIN,@URL_USER_NOT_LOGIN) [URL]
		from
		(
		SELECT COALESCE(A5.UsrEmail,A3.InvoiceEmail) [UsrEmail],
		A2.IdSubscription [IdProduct],
		IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,NULL,A2.ProductGiftShippingEmail)  [Email]
		, IIF(A6.PerFirstName IS NULL,A3.NameTax, COALESCE(A6.PerFirstName,'')
		 + IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'')) [ClientName]
		 ,'S' [ProductType]
		 ,A4.SubscriptionName [ProductName]
		 ,IIF(A2.RowStatus = 1,'ACTIVADO',A2.ActivationCode) [ActivationCode]
		 ,A2.SubscriptionCost [ProductCost]
		 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [OrderMail]
		FROM [dbo].[SubscriptionPaymentLog] A1 WITH(NOLOCK)
		INNER JOIN [dbo].[Subscription] A2 WITH(NOLOCK)
		 ON A1.SubscriptionId = A2.IdSubscription
		LEFT JOIN [dbo].[RegistrationofTransactionProcessStates] A3 WITH(NOLOCK)
			ON A1.[Authorization] = A3.[OrderNumber] 
		LEFT JOIN [dbo].[CatSubscription] A4 WITH(NOLOCK)
			ON A4.IdCatSubscription = A2.CatSubscriptionId
		LEFT JOIN [dbo].[RegisterUser] A5 WITH(NOLOCK)
			ON A5.UsrEmail = A3.InvoiceEmail
		LEFT JOIN [dbo].[Person] A6 WITH(NOLOCK)
			ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
			OUTER APPLY (
		 SELECT top 1 InvoiceEmail,NameTax, ProductGiftShippingEmail from DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates RT
		 WHERE RT.OrderNumber = @TransactionId	) RT
		WHERE [Authorization] = @TransactionId--'SP00024113083'
		UNION
		SELECT COALESCE(A5.UsrEmail,A3.InvoiceEmail) [UsrEmail],
		A2.IdMembership [IdProduct], 
		IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,A5.UsrEmail,A2.ProductGiftShippingEmail)  [Email]
		,IIF(A6.PerLastName IS NULL,A3.NameTax,  COALESCE(A6.PerFirstName,'')
		 +IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'')) [ClientName]
		 ,'M' [ProductType]	 
		 ,A4.MembershipName [ProductName]
		 ,IIF(A2.RowStatus = 1,'ACTIVADO',ActivationCode) [ActivationCode] 
		 ,A2.MembershipCost [ProductCost]
		 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [OrderMail]
		FROM [dbo].[MembershipPaymentLog] A1 WITH(NOLOCK)
		INNER JOIN [dbo].[Membership] A2 WITH(NOLOCK)
		 ON A2.IdMembership = A1.MembershipId --AND A2.RowStatus = 1
		LEFT JOIN [dbo].[RegistrationofTransactionProcessStates] A3 WITH(NOLOCK)
			ON A1.[Authorization] = A3.[OrderNumber] 
		LEFT JOIN [dbo].[CatMembership] A4 WITH(NOLOCK)
			ON A4.IdCatMembership = A2.CatMembershipId
		LEFT JOIN [dbo].[RegisterUser] A5 WITH(NOLOCK)
			ON A5.UsrEmail = A3.InvoiceEmail
		LEFT JOIN [dbo].[Person] A6 WITH(NOLOCK)
			ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
		WHERE [Authorization] = @TransactionId--'SP00024113083'
		)TBL
		order by TBL.OrderMail desc 

		/*LISTADO DE CORREOS PARA REGALOS*/
		SELECT  MAX(RTPS.[OrderNumber]) [OrderNumber], RTPS.[ProductGiftShippingEmail] [Email] 	 
		FROM [dbo].[RegistrationofTransactionProcessStates] RTPS WITH(NOLOCK)
		WHERE RTPS.[OrderNumber] = @TransactionId
		AND  LEN(COALESCE(RTPS.ProductGiftShippingEmail,'')) > 0 
		AND RTPS.ProductGiftShippingEmail <> 'NULL' 
		GROUP BY RTPS.[ProductGiftShippingEmail]

	END 

END