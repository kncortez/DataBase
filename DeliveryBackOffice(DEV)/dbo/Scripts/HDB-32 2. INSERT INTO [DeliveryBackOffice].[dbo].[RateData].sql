--SELECT
--	Cu.[IdCustomer] 'Identificador de cliente'
--	,ISNULL(Cu.[CommercialName], Cu.[Name]) 'Cliente corporativo'
--	,SUM(DO.PriceShippment) 'Monto de servicios'
--FROM
--	[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
--	INNER JOIN
--		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
--		ON
--			Cu.IdCustomer = DO.IdCustomer
--WHERE
--	Cu.IdCustomerType = 1
--GROUP BY
--	Cu.[IdCustomer]
--	,Cu.[Name]
--	,Cu.[CommercialName]
--HAVING
--	SUM(DO.PriceShippment) > 0
--ORDER BY
	--Cu.[IdCustomer] ASC

INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
	( RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated )
SELECT
	DISTINCT
	--ROW_NUMBER() OVER (PARTITION BY Cu.IdCustomer ORDER BY RD.TypeSegmentId DESC),
	RD.RateId, RD.TypeServiceId /*NDD = 2*/, 4 /*ESP*/, (SELECT TOP 1 RDaux.RateValue FROM [DeliveryBackOffice].[dbo].[RateData] RDaux WITH(NOLOCK) WHERE RDaux.RateId = RH.RheId AND RDaux.TypeServiceId = 3 ORDER BY RDaux.RateValue DESC), 1, 'SYS-ARUIZ', GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
	INNER JOIN
		[DeliveryBackOffice].[dbo].[RateByCustomer] RBC WITH(NOLOCK)
		ON
			RBC.RbcIdCustomer = Cu.IdCustomer
			AND
			RBC.RbcCodeOfReference IS NULL
			AND
			RBC.RbcRowStatus = 1
	INNER JOIN
		[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		ON
			RBC.RbcIdRate = RH.RheId
	LEFT JOIN
		[DeliveryBackOffice].[dbo].[RateData] RD WITH(NOLOCK)
		ON
			RH.RheId = RD.RateId
			AND
			RD.TypeServiceId = 2
WHERE
	Cu.IdCustomerType = 1
	AND
	RBC.RbcRowStatus = 1 
ORDER BY
	RateId ASC
