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
				[CCC].[Symbol] [TrxCurrency],
				ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) [TrxDate],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_numberFEL]) ELSE [IH].[inv_certificationFEL]  END [TrxStringFEL],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_serieFEL])  ELSE ''   END [TrxString2FEL],
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
	INNER JOIN	[dbo].[CreditCardTransactionByCustomer] CCTC WITH(NOLOCK)
		ON		CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) = [CCTC].[OrderNumber]
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[DO].[Guide_Serie] = [ID].[dti_fk_orderSerie]
		AND		[DO].[Guide_Number] = [ID].[dti_fk_orderNumber]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN	[dbo].[MembershipSubscriptionLog] MSL
		ON		[DO].[Guide_Serie] = [MSL].[LogGuideSerie]
		AND		[DO].[Guide_Number] = [MSL].[LogGuideNumber]
	LEFT JOIN   [dbo].[DeliveryCurrency] DC WITH(NOLOCK)
		ON		([DO].[SenderCountryId] = [DC].[Currency_IdCountry] OR ([DO].[SenderCountryId] IS NULL AND [DC].[Currency_IdCountry] ='GT'))
		AND		[DC].[DefaultPerCountry] = 1 
	LEFT JOIN	[dbo].CatCurrencyCOD CCC WITH(NOLOCK)
		ON		[DC].[IdCurrencyCOD] = [CCC].[IdCatCurrencyCOD]
	WHERE [A].[AccIdAccount] = @AccountId
	AND		ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) BETWEEN @DateStart AND @DateEnd
	ORDER BY	[CCTC].[DateCreated] DESC;

	-- APUNTA A CREDIT CARD TRANSACTION BY CUSTOMER DETAIL

	SELECT		CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [TrxService],
				[DO].[PriceShippment] [TrxPrice],
				[CCC].[Symbol] [TrxCurrency],
				ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) [TrxDate],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_numberFEL]) ELSE [IH].[inv_certificationFEL]  END [TrxStringFEL],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_serieFEL])  ELSE ''   END [TrxString2FEL],
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
	INNER JOIN	[dbo].[CreditCardTransactionByCustomerDetail] CCTCD WITH(NOLOCK)
		ON		[DO].[Guide_Serie] = [CCTCD].[SerieNumber]
		AND		[DO].[Guide_Number] = [CCTCD].[ProductNumber]
	INNER JOIN	[dbo].[CreditCardTransactionByCustomer] CCTC WITH(NOLOCK)
		ON		[CCTCD].[OrderNumber] = [CCTC].[OrderNumber]
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[DO].[Guide_Serie] = [ID].[dti_fk_orderSerie]
		AND		[DO].[Guide_Number] = [ID].[dti_fk_orderNumber]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN	[dbo].[MembershipSubscriptionLog] MSL
		ON		[DO].[Guide_Serie] = [MSL].[LogGuideSerie]
		AND		[DO].[Guide_Number] = [MSL].[LogGuideNumber]
	LEFT JOIN   [dbo].[DeliveryCurrency] DC WITH(NOLOCK)
		ON		([DO].[SenderCountryId] = [DC].[Currency_IdCountry] OR ([DO].[SenderCountryId] IS NULL AND [DC].[Currency_IdCountry] ='GT'))
		AND		[DC].[DefaultPerCountry] = 1 
	LEFT JOIN	[dbo].CatCurrencyCOD CCC WITH(NOLOCK)
		ON		[DC].[IdCurrencyCOD] = [CCC].[IdCatCurrencyCOD]
	WHERE  [A].[AccIdAccount] = @AccountId
	AND		ISNULL([CCTC].[DateUpdated], [CCTC].[DateCreated]) BETWEEN @DateStart AND @DateEnd
	ORDER BY	[CCTC].[DateCreated] DESC;

	-- Membresías
	SELECT		[IH].inv_pk_id,
				ISNULL(IH.IdCountry,'GT') IdCountry,
				[M].[IdMembership] [TrxService],
				[M].[MembershipCost] [TrxPrice],
				[CCC].[Symbol] [TrxCurrency],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDate],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_numberFEL]) ELSE [IH].[inv_certificationFEL]  END [TrxStringFEL],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_serieFEL])  ELSE ''   END [TrxString2FEL],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDateFEL],
				1 [TrxIsMembershipSubscription],
				[M].[IdMembership] [TrxMembershipId],
				0 [TrxSubscriptionId],
				[CM].[MembershipName] [TrxMembershipName],
				'' [SubscriptionName],
				CASE WHEN [MPL].[TypeOfInOutOfMoneyId] = 6  THEN '' ELSE [MPL].[Authorization] END [TrxOrderNumber],
				ISNULL([MPL].[PaymentImageURL],[RTPS].[PaymentImageURL]) [TrxPaymentUrl]
	FROM		[dbo].[Membership] M     WITH(NOLOCK)
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[M].[IdMembership] = [ID].[MembershipId]
	INNER JOIN	[dbo].[CatMembership] CM WITH(NOLOCK)
		ON		[M].[CatMembershipId] = [CM].[IdCatMembership]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN   [dbo].[MembershipPaymentLog] MPL WITH(NOLOCK)
		ON		[M].[IdMembership] = [MPL].[MembershipId] 
	LEFT JOIN	[dbo].[CatCurrencyCOD] CCC WITH(NOLOCK)	
		ON		[CM].[IdCatCurrencyCOD] = [CCC].[IdCatCurrencyCOD] OR ([CM].[IdCatCurrencyCOD] IS NULL AND [CCC].[IdCatCurrencyCOD] = 1)
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
	SELECT		ISNULL(IH.IdCountry,'GT') IdCountry,
				[S].[IdSubscription] [TrxService],
				[S].[SubscriptionCost] [TrxPrice],
				[CCC].[Symbol] [TrxCurrency],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDate],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_numberFEL]) ELSE [IH].[inv_certificationFEL]  END [TrxStringFEL],
				CASE WHEN ISNULL(IH.IdCountry,'GT') = 'HN' THEN ([IH].[inv_serieFEL])  ELSE ''   END [TrxString2FEL],
				ISNULL([IH].[inv_dateFEL], [IH].[inv_date]) [TrxDateFEL],
				1 [TrxIsMembershipSubscription],
				0 [TrxMembershipId],
				[S].[IdSubscription] [TrxSubscriptionId],
				'' [TrxMembershipName],
				[CS].[SubscriptionName] [TrxSubscriptionName],
				CASE WHEN [SPL].[TypeOfInOutOfMoneyId] = 6  THEN '' ELSE [SPL].[Authorization] END [TrxOrderNumber],
				ISNULL([SPL].[PaymentImageURL],[RTPS].[PaymentImageURL])  [TrxPaymentUrl]
	FROM		[dbo].[Subscription] S   WITH(NOLOCK)
	INNER JOIN	[dbo].[invoiceDetail] ID WITH(NOLOCK)
		ON		[S].[IdSubscription] = [ID].[SubscriptionId]
	INNER JOIN	[dbo].[CatSubscription] CS WITH(NOLOCK)
		ON		[S].[CatSubscriptionId] = [CS].[IdCatSubscription]
	INNER JOIN	[dbo].[invoiceHeader] IH WITH(NOLOCK)
		ON		[ID].[dti_fk_header] = [IH].[inv_pk_id]
	LEFT JOIN   [dbo].[SubscriptionPaymentLog] SPL WITH(NOLOCK)
		ON      [S].[IdSubscription] = [SPL].[SubscriptionId]
	LEFT JOIN	[dbo].[CatCurrencyCOD] CCC WITH(NOLOCK)	
		ON		[CS].[IdCatCurrencyCOD] = [CCC].[IdCatCurrencyCOD] OR ([CS].[IdCatCurrencyCOD] IS NULL AND [CCC].[IdCatCurrencyCOD] = 1)
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