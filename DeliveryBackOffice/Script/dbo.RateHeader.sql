
DECLARE @ByArticleTypeRateType INT = (SELECT TOP 1 CTR.IdTypeRate FROM [DeliveryBackOffice].[dbo].[CatTypeRate] CTR WITH(NOLOCK) WHERE CTR.[Name] = 'Tipo de Artículo' COLLATE Latin1_General_CI_AI)

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[RateHeader]
		(
			RheName
			,RheShortName
			,RheDescription
			,RheDefault
			,RheRowStatus
			,RheTokenCreated
			,RheDateCreated
			,RateTypeId
			,FragilRate
			,InsuranceRate
			,InsuranceExempt
			,AdditionalWeightRate
			,WeightLimit
			,CreditCardRate
			,PickupRate
			,Attempt
			,CountryId
			,CurrencyId
			,IsTemplate
			,RateByPiece
			,ReturnRate
			,CollectRate
			,PiecesIncluded
		)
	VALUES
		(
			'Tarifario de servicio estandar'
			,''
			,'Nuevo esquema de tarifas generales.'
			,0
			,1
			,'SYS-ARUIZ'
			,GETDATE()
			,@ByArticleTypeRateType
			,0
			,0.01
			,800
			,0.3
			,70
			,2
			,0
			,2
			,'GT'
			,1
			,1
			,0
			,100
			,3
			,1
		)
END

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[RateHeader]
		(
			RheName
			,RheShortName
			,RheDescription
			,RheDefault
			,RheRowStatus
			,RheTokenCreated
			,RheDateCreated
			,RateTypeId
			,FragilRate
			,InsuranceRate
			,InsuranceExempt
			,AdditionalWeightRate
			,WeightLimit
			,CreditCardRate
			,PickupRate
			,Attempt
			,CountryId
			,CurrencyId
			,IsTemplate
			,RateByPiece
			,ReturnRate
			,CollectRate
			,PiecesIncluded
		)
	VALUES
		(
			'Tarifario destinos express center'
			,''
			,'Nuevo esquema de tarifas generales con descuento a destino Express Center.'
			,0
			,1
			,'SYS-ARUIZ'
			,GETDATE()
			,@ByArticleTypeRateType
			,0
			,0.01
			,800
			,0.3
			,70
			,2
			,0
			,2
			,'GT'
			,1
			,1
			,0
			,100
			,3
			,1
		)

END