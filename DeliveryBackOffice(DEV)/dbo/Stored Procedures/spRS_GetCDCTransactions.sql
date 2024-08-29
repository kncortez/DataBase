
-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-03-31>
-- Description:	<Reporte de transacciones con tarjeta de crédito/débito registradas en sistema>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-08-20>
-- Description:	<Se agrega el parametro de IdCountry y  sus filtros>
--[dbo].[spRS_GetCDCTransactions] '2024-08-01', '2024-08-19', 'GT'
-- =============================================
CREATE PROCEDURE [dbo].[spRS_GetCDCTransactions]

	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@IdCountry NVARCHAR(2) = 'GT'

AS
BEGIN

	-- Variables globales
	DECLARE @ExpressCenterVisitPointType INT = (
		SELECT 
			TOP (1)
				[KOVPC].[IdKindOfVPClient] 
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK) 
		WHERE
			[KOVPC].[KindOfVPName] = 'Express Center' AND IdCountry = @IdCountry
	)

	-- Manejo de fechas
	IF(@EndDate IS NULL)
	BEGIN

		SET @EndDate = DATEADD(DAY,-1,DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))

	END
	ELSE 
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@EndDate AS DATE) AS DATETIME)))

	END

	IF(@StartDate IS NULL)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-0,@EndDate) AS DATE) AS DATETIME)

	END
	ELSE
	BEGIN

		SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)

	END

	IF OBJECT_ID('tempdb.dbo.#TCTransaction', 'U') IS NOT NULL 
		DROP TABLE #TCTransaction;

	CREATE TABLE #TCTransaction(
		IdTransaction BIGINT,
		OrderNumber NVARCHAR(50),
		ProductSerie NVARCHAR(2),
		ProductNumber INT,
		TransactionDate DATETIME
	);

	CREATE NONCLUSTERED INDEX IDX_TMP_Transaction_Guide
	ON #TCTransaction ( [ProductSerie], [ProductNumber] )
	
	INSERT INTO #TCTransaction
	(
	    [IdTransaction],
	    [OrderNumber],
	    [ProductSerie],
	    [ProductNumber],
		[TransactionDate]
	)
	SELECT 
		[CCTBC].[IdTransaction],
		[CCTBC].[OrderNumber],
		IIF([CCTBCD].[SerieNumber] IS NULL, SUBSTRING([CCTBC].[OrderNumber],1,2), [CCTBCD].[SerieNumber]),
		CAST(IIF([CCTBCD].[ProductNumber] IS NULL, SUBSTRING([CCTBC].[OrderNumber],3, LEN([CCTBC].[OrderNumber])-1 ), [CCTBCD].[ProductNumber]) AS INT),
		[CCTBC].[DateUpdated]
	FROM
		[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC  WITH(NOLOCK) 
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomerDetail] CCTBCD  WITH(NOLOCK) 
			ON
				[CCTBCD].[OrderNumber] = [CCTBC].[OrderNumber]
	WHERE
		[CCTBC].[DateCreated] BETWEEN @StartDate AND @EndDate
		AND
		[CCTBC].[ReasonCode] = '00' 

	IF OBJECT_ID('tempdb.dbo.#TCTDatan', 'U') IS NOT NULL 
		DROP TABLE #TCTData;
		
	CREATE TABLE #TCTData(
	OriginSystem NVARCHAR(25),
	ExpressCenter NVARCHAR(50),
	TypeProduct NVARCHAR(25),
	ProductName NVARCHAR(50),
	OrderNumber NVARCHAR(50),
	PaymentDate NVARCHAR(20),
	InvoiceDate NVARCHAR(20),
	InvoiceCertification NVARCHAR(100),
	InvoiceAmount DECIMAL(8,2),
	TransactionDate DATETIME,
	CurrencySymbol NVARCHAR(2),
	IdCountryAll NVARCHAR(2),
	Correlative BIGINT
	);
	
	INSERT INTO #TCTData
	(
		OriginSystem, 
		ExpressCenter, 
		TypeProduct, 
		ProductName, 
		OrderNumber, 
		PaymentDate, 
		InvoiceDate, 
		InvoiceCertification, 
		InvoiceAmount, 
		TransactionDate, 
		CurrencySymbol, 
		IdCountryAll,
		Correlative 	
	)

	SELECT 
		DISTINCT
			(
				CASE
					WHEN [MPL].[IdMembershipPaymentLog] IS NOT NULL THEN 
						(
							CASE
								WHEN [MPL].[TokenCreated] = 'SYS-HERMESCHARGESERVICE' THEN 'Renovador de membresías'
								ELSE 'Hermes Web'
							END
						)
					WHEN [SPL].[IdSubscriptionPaymentLog] IS NOT NULL THEN 
						(
							CASE
								WHEN [SPL].[TokenCreated] = 'SYS-HERMESCHARGESERVICE' THEN 'Renovador de suscripciones'
								ELSE 'Hermes Web'
							END
						)
					WHEN [DO].[DateCreated] IS NOT NULL THEN [CSys].[SysNameSystem]
					ELSE 'Hermes Integraciones'
				END
			) [OriginSystem]
			,(
				CASE
					WHEN [VPCori].[IdKindOfVPClient] IS NOT NULL THEN [VPCori].[DescriptionOfClient]
					WHEN [VPCsend].[IdKindOfVPClient] IS NOT NULL THEN [VPCsend].[DescriptionOfClient]
					ELSE 'N/A'
				END
			) [ExpressCenter]
			,(
				CASE
					WHEN [MPL].[IdMembershipPaymentLog] IS NOT NULL THEN 'Membresía'
					WHEN [SPL].[IdSubscriptionPaymentLog] IS NOT NULL THEN 'Suscripción'
					WHEN [DO].[DateCreated] IS NOT NULL THEN 'Guía'
					ELSE 'N/A'
				END
			) [TypeProduct]
			,(
				CASE
					WHEN [MPL].[IdMembershipPaymentLog] IS NOT NULL THEN CONCAT([CM].[MembershipName], ' #', [Mem].[IdMembership])
					WHEN [SPL].[IdSubscriptionPaymentLog] IS NOT NULL THEN CONCAT([CS].[SubscriptionName], ' #', [Sub].[IdSubscription])
					WHEN [DO].[DateCreated] IS NOT NULL THEN CONCAT([DO].[Guide_Serie], [DO].[Guide_Number])
					ELSE 'N/A'
				END
			) [ProductName]
			,[TCT].[OrderNumber]
			,FORMAT([TCT].[TransactionDate], 'dd/MM/yyyy') [PaymentDate]
			,(
				CASE
					WHEN [MPL].[IdMembershipPaymentLog] IS NOT NULL AND [InHmem].[inv_pk_id] IS NOT NULL THEN FORMAT([InHmem].[inv_dateFEL], 'dd/MM/yyyy')
					WHEN [SPL].[IdSubscriptionPaymentLog] IS NOT NULL AND [InHsub].[inv_pk_id] IS NOT NULL THEN FORMAT([InHsub].[inv_dateFEL], 'dd/MM/yyyy')
					WHEN [DO].[DateCreated] IS NOT NULL AND [InHgui].[inv_pk_id] IS NOT NULL THEN FORMAT([InHgui].[inv_dateFEL], 'dd/MM/yyyy')
					ELSE NULL
				END
			) [InvoiceDate]
			,(
				CASE
					WHEN [MPL].[IdMembershipPaymentLog] IS NOT NULL AND [InHmem].[inv_pk_id] IS NOT NULL THEN [InHmem].[inv_certificationFEL]
					WHEN [SPL].[IdSubscriptionPaymentLog] IS NOT NULL AND [InHsub].[inv_pk_id] IS NOT NULL THEN [InHsub].[inv_certificationFEL]
					WHEN [DO].[DateCreated] IS NOT NULL AND [InHgui].[inv_pk_id] IS NOT NULL THEN [InHgui].[inv_certificationFEL]
					ELSE NULL
				END
			) [InvoiceCertification]
			,(
				CASE
					WHEN [MPL].[IdMembershipPaymentLog] IS NOT NULL AND [InHmem].[inv_pk_id] IS NOT NULL THEN [InHmem].[inv_amount]
					WHEN [SPL].[IdSubscriptionPaymentLog] IS NOT NULL AND [InHsub].[inv_pk_id] IS NOT NULL THEN [InHsub].[inv_amount]
					WHEN [DO].[DateCreated] IS NOT NULL AND [InHgui].[inv_pk_id] IS NOT NULL THEN [InHgui].[inv_amount]
					ELSE NULL
				END
			) [InvoiceAmount]
			,[TCT].[TransactionDate] -- Order by
			,CASE WHEN ISNULL(CM.IdCountry,'GT') = 'GT' AND ISNULL(CS.IdCountry,'GT') = 'GT' AND ISNULL(DO.SenderCountryId, 'GT') = 'GT' THEN 'Q.'
				  ELSE 'L.'
			 END AS CurrencySymbol
			,CASE WHEN CM.IdCountry IS NOT NULL THEN CM.IdCountry
				  WHEN CS.IdCountry IS NOT NULL THEN CS.IdCountry
				  WHEN DO.SenderCountryId IS NOT NULL THEN DO.SenderCountryId
			ELSE NULL
			END AS IdCountryAll
			,CASE WHEN MPL.IdMembershipPaymentLog IS NOT NULL THEN MPL.IdMembershipPaymentLog
				  WHEN SPL.IdSubscriptionPaymentLog IS NOT NULL THEN SPL.IdSubscriptionPaymentLog
				  WHEN DO.Guide_Number IS NOT NULL THEN DO.Guide_Number
			ELSE NULL
			END AS Correlative
	FROM
		[#TCTransaction] TCT
		-- Es una membresía
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[MembershipPaymentLog] MPL  WITH(NOLOCK) 
			ON
				[TCT].[OrderNumber] = [MPL].[Authorization]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Membership] Mem  WITH(NOLOCK) 
			ON
				[Mem].[IdMembership] = [MPL].[MembershipId]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatMembership] CM  WITH(NOLOCK) 
			ON
				[CM].[IdCatMembership] = [Mem].[CatMembershipId]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[invoiceDetail] InDmem  WITH(NOLOCK) 
			ON
				[InDmem].[MembershipId] = [Mem].[IdMembership]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[invoiceHeader] InHmem  WITH(NOLOCK) 
			ON
				[InDmem].[dti_fk_header] = [InHmem].[inv_pk_id]
				AND
				[InHmem].[inv_invoiceOfCreditNote] IS NULL
				AND
				[InHmem].[inv_creditNote] IS NULL
		-- Es una suscripción
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubscriptionPaymentLog] SPL  WITH(NOLOCK) 
			ON
				[TCT].[OrderNumber] = [SPL].[Authorization]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Subscription] Sub  WITH(NOLOCK) 
			ON
				[Sub].[IdSubscription] = [SPL].[SubscriptionId]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatSubscription] CS  WITH(NOLOCK) 
			ON
				[CS].[IdCatSubscription] = [Sub].[CatSubscriptionId]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[invoiceDetail] InDsub  WITH(NOLOCK) 
			ON
				[InDsub].[SubscriptionId] = [Sub].[IdSubscription]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[invoiceHeader] InHsub  WITH(NOLOCK) 
			ON
				[InDsub].[dti_fk_header] = [InHsub].[inv_pk_id]
				AND
				[InHsub].[inv_invoiceOfCreditNote] IS NULL
				AND
				[InHsub].[inv_creditNote] IS NULL
		-- Es una guía
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			ON
				[TCT].[ProductSerie] = [DO].[Guide_Serie]
				AND
				[TCT].[ProductNumber] = [DO].[Guide_Number]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatSystem] CSys  WITH(NOLOCK) 
			ON
				[CSys].[SysIdSystem] = [DO].[CatSystemId]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[invoiceDetail] InDgui  WITH(NOLOCK) 
			ON
				[InDgui].[dti_fk_orderSerie] = [DO].[Guide_Serie]
				AND
				[InDgui].[dti_fk_orderNumber] = [DO].[Guide_Number]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[invoiceHeader] InHgui  WITH(NOLOCK) 
			ON
				[InDgui].[dti_fk_header] = [InHgui].[inv_pk_id]
				AND
				[InHgui].[inv_invoiceOfCreditNote] IS NULL
				AND
				[InHgui].[inv_creditNote] IS NULL
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPCsend  WITH(NOLOCK) 
			ON
				[VPCsend].[CodeOfReference] = [DO].[Sender_ID]
				AND
				[VPCsend].[IdKindOfVPClient] = @ExpressCenterVisitPointType
				AND
				[VPCsend].[CodeOfReference] <> 0
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPCori  WITH(NOLOCK) 
			ON
				[DO].[OriginSenderId] = [VPCori].[CodeOfReference]
				AND
				[VPCori].[IdKindOfVPClient] = @ExpressCenterVisitPointType
				AND
				[VPCori].[CodeOfReference] <> 0
		ORDER BY
			[TCT].[TransactionDate] DESC

	SELECT OriginSystem,
		   ExpressCenter,
		   TypeProduct,
		   ProductName,
		   OrderNumber,
		   PaymentDate,
		   InvoiceDate,
		   InvoiceCertification,
		   InvoiceAmount,
		   TransactionDate,
		   CurrencySymbol,
		   IdCountryAll,
		   Correlative
	FROM #TCTData
	WHERE ISNULL(IdCountryAll,'GT') = @IdCountry

	IF OBJECT_ID('tempdb.dbo.#TCTData', 'U') IS NOT NULL 
		DROP TABLE #TCTData;

	IF OBJECT_ID('tempdb.dbo.#TCTransaction', 'U') IS NOT NULL 
		DROP TABLE #TCTransaction;
END