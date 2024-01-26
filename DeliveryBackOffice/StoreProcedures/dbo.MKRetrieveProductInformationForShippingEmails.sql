USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[MKRetrieveProductInformationForShippingEmails]    Script Date: 25/01/2024 17:42:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <19/01/2024>
-- Description:	<Obtener información de productos para envío de correos>
-- =============================================
ALTER PROCEDURE [dbo].[MKRetrieveProductInformationForShippingEmails]
@TransactionId VARCHAR (100)
AS

BEGIN
	select *
	from
	(
	SELECT A5.UsrEmail [UsrEmail], A2.IdSubscription [IdProduct], IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,A5.UsrEmail,ProductGiftShippingEmail)  [Email]
	, COALESCE(A6.PerFirstName,'')
	 +IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'') [ClientName]
	 ,'S' [ProductType]
	 ,A7.SubscriptionName [ProductName]
	 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL','ACTIVADO',A2.ActivationCode) [ActivationCode]
	 ,A2.SubscriptionCost [ProductCost]
	 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) OrderMail
	FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog A1 WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.Subscription A2 WITH(NOLOCK)
	 ON A1.SubscriptionId = A2.IdSubscription --AND A2.RowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
		ON A3.AccIdAccount = A2.AccountId
		AND A3.AccRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
		ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
		ON A5.UsrIdUser = A4.RuaIdUser
	INNER JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
		ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.CatSubscription A7 WITH(NOLOCK)
		ON A7.IdCatSubscription = A2.CatSubscriptionId
	WHERE [Authorization] = @TransactionId--'SP00024113083'
	UNION
	SELECT A5.UsrEmail [UsrEmail],A2.IdMembership [IdProduct], IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL' ,A5.UsrEmail,ProductGiftShippingEmail)  [Email]
	,  COALESCE(A6.PerFirstName,'')
	 +IIF(A6.PerLastName IS NULL,'',' ')+ COALESCE(A6.PerLastName,'') [ClientName]
	 ,'M' [ProductType]	 
	 ,A7.MembershipName [ProductName]
	 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL','ACTIVADO',ActivationCode) [ActivationCode] 
	 ,A2.MembershipCost [ProductCost]
	 ,IIF(LEN(COALESCE(A2.ProductGiftShippingEmail,'')) = 0 OR A2.ProductGiftShippingEmail = 'NULL',1,0) [ActivationCode]
	FROM DeliveryBackOffice.dbo.MembershipPaymentLog A1 WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.Membership A2 WITH(NOLOCK)
	 ON A2.IdMembership = A1.MembershipId --AND A2.RowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
		ON A3.AccIdAccount = A2.AccountId
		AND A3.AccRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
		ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
		ON A5.UsrIdUser = A4.RuaIdUser
	INNER JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
		ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.CatMembership A7 WITH(NOLOCK)
		ON A7.IdCatMembership = A2.CatMembershipId
	WHERE [Authorization] = @TransactionId--'SP00024113083'
	)TBL
	order by TBL.OrderMail desc 

	SELECT DISTINCT A2.ProductGiftShippingEmail [Email] 	
	FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog A1 WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.Subscription A2 WITH(NOLOCK)
	 ON A1.SubscriptionId = A2.IdSubscription --AND A2.RowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
		ON A3.AccIdAccount = A2.AccountId
		AND A3.AccRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
		ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
		ON A5.UsrIdUser = A4.RuaIdUser
	INNER JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
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
	INNER JOIN DeliveryBackOffice.dbo.Account A3 WITH(NOLOCK)
		ON A3.AccIdAccount = A2.AccountId
		AND A3.AccRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A4 WITH(NOLOCK)
		ON A4.RuaIdAccount = A3.AccIdAccount AND A4.RuaRowStatus = 1
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser A5 WITH(NOLOCK)
		ON A5.UsrIdUser = A4.RuaIdUser
	INNER JOIN DeliveryBackOffice.dbo.Person A6 WITH(NOLOCK)
		ON A6.PerIdPerson = A5.UsrIdPerson AND A6.PerRowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.CatMembership A7 WITH(NOLOCK)
		ON A7.IdCatMembership = A2.CatMembershipId
		
	WHERE [Authorization] = @TransactionId--'SP00024113083'
	AND  LEN(COALESCE(A2.ProductGiftShippingEmail,'')) > 0 
	AND A2.ProductGiftShippingEmail <> 'NULL' 

END