-- Tarifarios
DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
DECLARE @NewAlternativeMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);

-- Tipo de servicio	
DECLARE @StandardTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estandar' COLLATE Latin1_General_CI_AI)
DECLARE @StandardCoDTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsName = 'Estandar CoD' COLLATE Latin1_General_CI_AI)

UPDATE
	[DeliveryBackOffice].[dbo].[RateData]
SET
	RowStatus = 0,
	TokenUpdated = 'SYS-ARUIZ',
	DateUpdated = GETDATE()
WHERE
	RateId IN (@NewMainRates, @NewAlternativeMainRates)
	AND
	TypeServiceId NOT IN (@StandardTypeId, @StandardCoDTypeId)

--SELECT
--	*
--FROM
--	[DeliveryBackOffice].[dbo].[RateData]
--WHERE
--	RateId IN (@NewMainRates, @NewAlternativeMainRates)
--	AND
--	RowStatus = 1