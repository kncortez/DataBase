	INSERT INTO [DeliveryBackOffice].[dbo].[CustomerCODLog]
	(
		[CustomerId]
	  , [VisitPointId]
	  , [isCOD]
	  , [CODExcludePriceShipping]
	  , [CODExcludeComission]
	  , [CODIdBank]
	  , [CODAccountName]
	  , [CODAccountNumber]
	  , [CODAccountTypeId]
	  , [CODCurrencyId]
	  , [CODCatBatchType]
	  , [CODCatBatchFrequency]
	  , [CODBillingTimeId]
	  , [CODBillingVolumeId]
	  , [CODBillingCutOfDate]
	  , [DateRegister]
	  , [TokenRegister]
	  , [DateUpdated]
	  , [TokenUpdated]
	)
	SELECT cs.IdCustomer, NULL, cs.IsCOD, cs.ExcludePriceShippingCOD, cs.ExcludeCommissionCOD
	  , cs.CODAccountBankID, cs.CODAccountName, cs.CODAccountNumber, cs.CODAccountTypeID, cs.CODCurrencyID
	  , cs.CatBatchTypeCODId, cs.CatBatchFrequencyCODId, cs.CatBillingTimeId, cs.CatBillingVolumeId
	  , cs.BillingCut_offDate, GETDATE(), 'SYS-ADMIN', NULL, NULL
	FROM [DeliveryBackOffice].[dbo].[Customer] cs WITH(NOLOCK)
	WHERE cs.IdCustomerType = 1
	ORDER BY cs.IdCustomer;



	INSERT INTO [DeliveryBackOffice].[dbo].[CustomerCODLog]
	(
		[CustomerId]
	  , [VisitPointId]
	  , [isCOD]
	  , [CODExcludePriceShipping]
	  , [CODExcludeComission]
	  , [CODIdBank]
	  , [CODAccountName]
	  , [CODAccountNumber]
	  , [CODAccountTypeId]
	  , [CODCurrencyId]
	  , [CODCatBatchType]
	  , [CODCatBatchFrequency]
	  , [CODBillingTimeId]
	  , [CODBillingVolumeId]
	  , [CODBillingCutOfDate]
	  , [DateRegister]
	  , [TokenRegister]
	  , [DateUpdated]
	  , [TokenUpdated]
	)
	SELECT cs.IdCustomer, vpcf.VisitPointID, cs.IsCOD, NULL, NULL, vpcf.CODAccountBankID, vpcf.CODAccountName
	  , vpcf.CODAccountNumber, vpcf.CODAccountBankTypeID, vpcf.CODAccountCurrencyID, NULL, NULL
	  , NULL, NULL
	  , IIF(YEAR( vpcf.BillingCut_offDate) <= 1753 or YEAR( vpcf.BillingCut_offDate) >=9999
	  , NULL,CONVERT(DATETIME, vpcf.BillingCut_offDate)), GETDATE(), 'SYS-ADMIN', NULL, NULL
	FROM [DeliveryBackOffice].[dbo].[VisitPointConfiguration] vpcf WITH(NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH(NOLOCK) ON vpcf.VisitPointID = vpc.CodeOfReference
	INNER JOIN [DeliveryBackOffice].[dbo].[Customer] AS cs WITH(NOLOCK) ON cs.IdCustomer = vpc.CustomerID
	WHERE cs.IdCustomerType = 1
	ORDER BY cs.IdCustomer, vpcf.VisitPointID;
