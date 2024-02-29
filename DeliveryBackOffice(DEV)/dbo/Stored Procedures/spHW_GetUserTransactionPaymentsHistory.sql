-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <13-01-2023>
-- Description:	<Get user transaction payments list generated in web app>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetUserTransactionPaymentsHistory] 
	@AccountId AS INT,
	@DateStart AS DATETIME = NULL,
	@DateEnd AS DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	IF (@DateEnd IS NULL)
		BEGIN 
			SET @DateEnd = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME)));
		END
	ELSE 
		BEGIN
			SET @DateEnd = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@DateEnd AS DATE) AS DATETIME)));
		END

	IF(@DateStart IS NULL)
		BEGIN
			SET @DateStart = CAST(CAST(DATEADD(DAY,-30,@DateEnd) AS DATE) AS DATETIME)
		END
	ELSE
		BEGIN
			SET @DateStart = CAST(CAST(@DateStart AS DATE) AS DATETIME)
		END

	SET NOCOUNT ON;

	-- APUNTA A CREDIT CARD TRANSACTION BY CUSTOMER

	SELECT		CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [TrxService],
				[DO].[PriceShippment] [TrxPrice],
				ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) [TrxDate],
				[IH].[inv_certificationFEL] [TrxCertificacionFEL],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDateFEL],
				ISNULL([MSL].[IdMembershipSubscriptionLog], 0) [TrxIsMembershipSubscription],
				ISNULL([MSL].[MembershipId], 0) [TrxMembershipId],
				ISNULL([MSL].[SubscriptionId], 0) [TrxSubscriptionId],
				'' [TrxMembershipName],
				'' [TrxSubscriptionName],
				'' [TrxOrderNumber],
				'' [TrxPaymentUrl]
	FROM		[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	INNER JOIN	[dbo].[Account] A
		ON		[DO].[IdCustomer] = [A].[IdCustomer]
		AND		[A].[AccIdAccount] = @AccountId
	INNER JOIN	[dbo].[CreditCardTransactionByCustomer] CCTC WITH(NOLOCK)
		ON		CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) = [CCTC].[OrderNumber]
		AND		ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) BETWEEN @DateStart AND @DateEnd
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[DO].[Guide_Serie] = [ID].[dti_fk_orderSerie]
		AND		[DO].[Guide_Number] = [ID].[dti_fk_orderNumber]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN	[dbo].[MembershipSubscriptionLog] MSL
		ON		[DO].[Guide_Serie] = [MSL].[LogGuideSerie]
		AND		[DO].[Guide_Number] = [MSL].[LogGuideNumber]
	ORDER BY	[CCTC].[DateCreated] DESC;

	-- APUNTA A CREDIT CARD TRANSACTION BY CUSTOMER DETAIL

	SELECT		CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [TrxService],
				[DO].[PriceShippment] [TrxPrice],
				ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) [TrxDate],
				[IH].[inv_certificationFEL] [TrxCertificacionFEL],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDateFEL],
				ISNULL([MSL].[IdMembershipSubscriptionLog], 0) [TrxIsMembershipSubscription],
				ISNULL([MSL].[MembershipId], 0) [TrxMembershipId],
				ISNULL([MSL].[SubscriptionId], 0) [TrxSubscriptionId],
				'' [TrxMembershipName],
				'' [TrxSubscriptionName],
				'' [TrxOrderNumber],
				'' [TrxPaymentUrl]
	FROM		[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	INNER JOIN	[dbo].[Account] A
		ON		[DO].[IdCustomer] = [A].[IdCustomer]
		AND		[A].[AccIdAccount] = @AccountId
	INNER JOIN	[dbo].[CreditCardTransactionByCustomerDetail] CCTCD WITH(NOLOCK)
		ON		[DO].[Guide_Serie] = [CCTCD].[SerieNumber]
		AND		[DO].[Guide_Number] = [CCTCD].[ProductNumber]
	INNER JOIN	[dbo].[CreditCardTransactionByCustomer] CCTC WITH(NOLOCK)
		ON		[CCTCD].[OrderNumber] = [CCTC].[OrderNumber]
		AND		ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) BETWEEN @DateStart AND @DateEnd
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[DO].[Guide_Serie] = [ID].[dti_fk_orderSerie]
		AND		[DO].[Guide_Number] = [ID].[dti_fk_orderNumber]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN	[dbo].[MembershipSubscriptionLog] MSL
		ON		[DO].[Guide_Serie] = [MSL].[LogGuideSerie]
		AND		[DO].[Guide_Number] = [MSL].[LogGuideNumber]
	ORDER BY	[CCTC].[DateCreated] DESC;

	-- Membresías
	SELECT		[M].[IdMembership] [TrxService],
				[M].[MembershipCost] [TrxPrice],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDate],
				[IH].[inv_certificationFEL] [TrxCertificacionFEL],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDateFEL],
				1 [TrxIsMembershipSubscription],
				[M].[IdMembership] [TrxMembershipId],
				0 [TrxSubscriptionId],
				[CM].[MembershipName] [TrxMembershipName],
				'' [SubscriptionName],
				CASE WHEN [MPL].[TypeOfInOutOfMoneyId] = 6  THEN '' ELSE [MPL].[Authorization] END [TrxOrderNumber],
				ISNULL([MPL].[PaymentImageURL],[RTPS].[PaymentImageURL]) [TrxPaymentUrl]
	FROM		[dbo].[Membership] M 
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[M].[IdMembership] = [ID].[MembershipId]
	INNER JOIN	[dbo].[CatMembership] CM
		ON		[M].[CatMembershipId] = [CM].[IdCatMembership]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN   [dbo].[MembershipPaymentLog] MPL WITH(NOLOCK)
		ON		[M].[IdMembership] = [MPL].[MembershipId] 
	OUTER APPLY(
				  SELECT Top 1[OrderNumber], [PaymentImageURL]
				  FROM [dbo].[RegistrationofTransactionProcessStates]
				  WHERE [OrderNumber] = [MPL].[Authorization]
				    AND [AccountId] = @AccountId
				) RTPS
	--LEFT JOIN   [dbo].[RegistrationofTransactionProcessStates] RTPS WITH(NOLOCK)
		--ON      [MPL].[Authorization]  = [RTPS].[OrderNumber]
	WHERE		[M].[AccountId] = @AccountId
		AND		[M].[DateCreated] BETWEEN @DateStart AND @DateEnd
		AND		[M].[RowStatus] = 1;

	-- Suscripciones
	SELECT		[S].[IdSubscription] [TrxService],
				[S].[SubscriptionCost] [TrxPrice],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDate],
				[IH].[inv_certificationFEL] [TrxCertificacionFEL],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDateFEL],
				1 [TrxIsMembershipSubscription],
				0 [TrxMembershipId],
				[S].[IdSubscription] [TrxSubscriptionId],
				'' [TrxMembershipName],
				[CS].[SubscriptionName] [TrxSubscriptionName],
				CASE WHEN [SPL].[TypeOfInOutOfMoneyId] = 6  THEN '' ELSE [SPL].[Authorization] END [TrxOrderNumber],
				ISNULL([SPL].[PaymentImageURL],[RTPS].[PaymentImageURL])  [TrxPaymentUrl]
	FROM		[dbo].[Subscription] S
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[S].[IdSubscription] = [ID].[SubscriptionId]
	INNER JOIN	[dbo].[CatSubscription] CS
		ON		[S].[CatSubscriptionId] = [CS].[IdCatSubscription]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN   [dbo].[SubscriptionPaymentLog] SPL WITH(NOLOCK)
		ON      [S].[IdSubscription] = [SPL].[SubscriptionId]
	OUTER APPLY(
				  SELECT Top 1 [OrderNumber], [PaymentImageURL]
				  FROM [dbo].[RegistrationofTransactionProcessStates]
				  WHERE [OrderNumber] = [SPL].[Authorization]  
					AND [AccountId] = @AccountId
				) RTPS
	WHERE		[S].[AccountId] = @AccountId
		AND		[S].[DateCreated] BETWEEN @DateStart AND @DateEnd
		AND		[S].[RowStatus] = 1;

END