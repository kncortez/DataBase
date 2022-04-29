


SELECT
	MAX(DCBA.DCBA_Id) 'Código Interno'
	,'Pago' 'Descripción'
	,CAST(DCBA.DCBA_Num_account AS NVARCHAR) 'Cuenta Banrural a acreditar'
	,IIF(Cu.IdCustomerType = 1, 2, 1) 'Tipo de cliente'
	,IIF(Cu.IdCustomerType = 1, '', DCBA.DCBA_Nom_account) 'Nombre completo'
	,IIF(Cu.IdCustomerType = 1, Cu.CommercialName, '') 'Nombre comercial'
FROM
	(
		SELECT
			MAX(DCBA_Id) DCBA_Id
			,DCBA_Num_account
			,DCBA_Bank_Id
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] WITH(NOLOCK)
		WHERE
			DCBA_Bank_Id = 5
			AND
			DCBA_Id_estado = 1
		GROUP BY
			DCBA_Num_account
			,DCBA_Bank_Id
	) DCBAx
	JOIN
		[DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH(NOLOCK)
		ON
			DCBAx.DCBA_Num_account = DCBA.DCBA_Num_account
			AND
			DCBAx.DCBA_Bank_Id = DCBA.DCBA_Bank_Id
			AND
			DCBAx.DCBA_Id = DCBA.DCBA_Id
			AND
			DCBA.DCBA_Id_estado = 1
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
		ON
			DCBA.DCBA_Num_account = Cu.CODAccountNumber
			AND
			DCBA.DCBA_Bank_Id = Cu.CODAccountBankID
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[VisitPointConfiguration] VPConfig WITH(NOLOCK)
		ON
			DCBA.DCBA_Num_account = VPConfig.CODAccountNumber
			AND
			DCBA.DCBA_Bank_Id = VPConfig.CODAccountBankID
WHERE
	DCBA.DCBA_Bank_Id = 5
	AND
	DCBA.DCBA_Id_estado = 1
	AND
	(
		(LEN(LTRIM(RTRIM(DCBA.DCBA_Num_account))) = 10 AND LEFT(DCBA.DCBA_Num_account,1) IN ('3','4'))
		OR
		(LEN(LTRIM(RTRIM(DCBA.DCBA_Num_account))) = 14 AND LEFT(DCBA.DCBA_Num_account,2) IN ('03','04'))
	)
GROUP BY
	DCBA.DCBA_Num_account
	,Cu.IdCustomerType
	,DCBA.DCBA_Nom_account
	,Cu.CommercialName
