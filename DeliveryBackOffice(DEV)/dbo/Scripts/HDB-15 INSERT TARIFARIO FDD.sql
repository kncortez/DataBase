
DECLARE @StandarRateType INT = (SELECT TOP 1 CTR.IdTypeRate FROM [DeliveryBackOffice].[dbo].[CatTypeRate] CTR WITH(NOLOCK) WHERE CTR.[Name] = 'Todo destino' COLLATE Latin1_General_CI_AI)

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario Fresh Delivery' COLLATE Latin1_General_CI_AI))
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
			'Tarifario Fresh Delivery'
			,''
			,'Esquema de tarifas Fresh Delivery.'
			,0
			,1
			,'SYS-OMORALES'
			,GETDATE()
			,@StandarRateType
			,0
			,0.01
			,800
			,1
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

-- Tarifario
DECLARE @RateHeaderId INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario Fresh Delivery' COLLATE Latin1_General_CI_AI);

--***Este tarifario (@RateHeaderId) debe ser asignado al cliente que usará el método SetServiceRoutes en la tabla [RatebyCustomer]

-- Tipo de servicio	
DECLARE @FDDTypeId INT = (SELECT TOP 1 CTS.CtsId FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH(NOLOCK) WHERE CTS.CtsShortName = 'FDD' COLLATE Latin1_General_CI_AI)

-- Tipo de segmento
DECLARE @LocTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'LOC' COLLATE Latin1_General_CI_AI)
DECLARE @MetTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'MET' COLLATE Latin1_General_CI_AI)
DECLARE @ForTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'FOR' COLLATE Latin1_General_CI_AI)

-- Insertar información de tarifas local, metro, foránea para FDD
INSERT INTO [DeliveryBackOffice].[dbo].[RateData]
	(RateId, TypeServiceId, TypeSegmentId, RateValue, RowStatus, TokenCreated, DateCreated)
VALUES
	(@RateHeaderId, @FDDTypeId, @LocTypeId,	29, 1, 'SYS-OMORALES', GETDATE()), -- Precio para FDD LOCAL
	(@RateHeaderId, @FDDTypeId, @MetTypeId,	34, 1, 'SYS-OMORALES', GETDATE()), -- Precio para FDD METRO
	(@RateHeaderId, @FDDTypeId, @ForTypeId, 39, 1, 'SYS-OMORALES', GETDATE()) -- Precio para FDD FORÁNEO