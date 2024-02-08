
-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <19/01/2024>
-- Description:	<Obtener información de productos para envío de correos>
-- =============================================
CREATE PROCEDURE [dbo].[MKRetrieveProductInformationForShippingEmails]
@TransactionId VARCHAR (100)
AS

BEGIN
	select *
	from
	(
	SELECT COALESCE(A5.UsrEmail,RT.InvoiceEmail) [UsrEmail], A2.IdSubscription [IdProduct], IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,A5.UsrEmail,ProductGiftShippingEmail)  [Email]
	, IIF(A6.PerFirstName IS NULL,RT.NameTax, COALESCE(A6.PerFirstName,'')
	 + IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'')) [ClientName]
	 ,'S' [ProductType]
	 ,A7.SubscriptionName [ProductName]
	 ,IIF((LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL') AND A2.RowStatus = 1 ,'ACTIVADO',A2.ActivationCode) [ActivationCode]
	 ,A2.SubscriptionCost [ProductCost]
	 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) OrderMail
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
	 SELECT top 1 InvoiceEmail,NameTax from DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates RT
	 WHERE RT.OrderNumber = @TransactionId	) RT
	
	WHERE [Authorization] = @TransactionId--'SP00024113083'
	UNION
	SELECT COALESCE(A5.UsrEmail,RT.InvoiceEmail) [UsrEmail],A2.IdMembership [IdProduct], IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,A5.UsrEmail,ProductGiftShippingEmail)  [Email]
	,IIF(A6.PerLastName IS NULL,RT.NameTax,  COALESCE(A6.PerFirstName,'')
	 +IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'')) [ClientName]
	 ,'M' [ProductType]	 
	 ,A7.MembershipName [ProductName]
	 ,IIF((LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL') AND A2.RowStatus = 1,'ACTIVADO',ActivationCode) [ActivationCode] 
	 ,A2.MembershipCost [ProductCost]
	 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [ActivationCode]
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
	 SELECT top 1 InvoiceEmail,NameTax from DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates RT
	 WHERE RT.OrderNumber = @TransactionId	) RT
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

END