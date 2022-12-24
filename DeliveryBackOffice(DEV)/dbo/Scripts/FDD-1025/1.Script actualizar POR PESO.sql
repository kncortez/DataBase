BEGIN TRANSACTION
BEGIN TRY
	DECLARE @Weight INT = (SELECT IdTypeRate FROM CatTypeRate WHERE Name = 'Por Peso' AND RowStatus = 1)
	DECLARE @TypeSDD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'SDD' AND CtsRowStatus = 1)
	DECLARE @TypeNDD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'NDD' AND CtsRowStatus = 1)
	DECLARE @TypeTDA INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'TDA' AND CtsRowStatus = 1)
	DECLARE @TypeSTD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'STD' AND CtsRowStatus = 1)
	DECLARE @TypeCOD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'COD' AND CtsRowStatus = 1)
	DECLARE @FOR INT = (SELECT CrsId FROM CatRateSegment WHERE CrsShortName = 'FOR' AND CrsRowStatus = 1)
	DECLARE @ESP INT = (SELECT CrsId FROM CatRateSegment WHERE CrsShortName = 'ESP' AND CrsRowStatus = 1)

	-- Desactivar registros SDD y TDA
	UPDATE rd 
	SET RowStatus = 0
		,TokenUpdated = 'SYS-OMORALES'
		,DateUpdated = GETDATE()
	FROM RateHeader rh 
	INNER JOIN RateData rd
	ON rh.RheId = rd.RateId
	WHERE rh.RateTypeId = @Weight 
	AND rd.TypeServiceId IN (@TypeSDD, @TypeTDA)
	AND rh.RheRowStatus = 1
	AND rd.RowStatus = 1

	-- Actualizar NDD a STD
	UPDATE rd 
	SET TypeServiceId = @TypeSTD
		,TokenUpdated = 'SYS-OMORALES'
		,DateUpdated = GETDATE()
	FROM RateHeader rh 
	INNER JOIN RateData rd
	ON rh.RheId = rd.RateId
	WHERE rh.RateTypeId = @Weight 
	AND rd.TypeServiceId IN (@TypeNDD)
	AND rh.RheRowStatus = 1
	AND rd.RowStatus = 1

	-- Insertar STD ESP
	INSERT INTO RateData ([RateId]
	, [TypeServiceId]
	, [TypeSegmentId]
	, [HubSourceId]
	, [HubDestinyId]
	, [ArticleId]
	, [RateValue]
	, [RowStatus]
	, [TokenCreated]
	, [DateCreated]
	, [LimitHourDelivery]
	, [LimitHourPickup]
	, [WeightFrom]
	, [WeightTo])
	SELECT 
		rd.RateId
		,@TypeSTD
		,@ESP
		,rd.HubSourceId
		,rd.HubDestinyId
		,rd.ArticleId
		,rd.RateValue
		,rd.RowStatus
		,'SYS-OMORALES'
		,GETDATE()
		,rd.LimitHourDelivery
		,rd.LimitHourPickup
		,rd.WeightFrom
		,rd.WeightTo
	FROM RateHeader rh 
	INNER JOIN RateData rd
	ON rh.RheId = rd.RateId
	WHERE rh.RateTypeId = @Weight 
	AND rd.TypeServiceId IN (@TypeSTD)
	AND rd.TypeSegmentId = @FOR
	AND rh.RheRowStatus = 1
	AND rd.RowStatus = 1

	-- Clonar 
	INSERT INTO RateData ([RateId]
	, [TypeServiceId]
	, [TypeSegmentId]
	, [HubSourceId]
	, [HubDestinyId]
	, [ArticleId]
	, [RateValue]
	, [RowStatus]
	, [TokenCreated]
	, [DateCreated]
	, [LimitHourDelivery]
	, [LimitHourPickup]
	, [WeightFrom]
	, [WeightTo])
	SELECT 
		rd.RateId
		,@TypeCOD
		,rd.TypeSegmentId
		,rd.HubSourceId
		,rd.HubDestinyId
		,rd.ArticleId
		,rd.RateValue
		,rd.RowStatus
		,'SYS-OMORALES'
		,GETDATE()
		,rd.LimitHourDelivery
		,rd.LimitHourPickup
		,rd.WeightFrom
		,rd.WeightTo
	FROM RateHeader rh 
	INNER JOIN RateData rd
	ON rh.RheId = rd.RateId
	WHERE rh.RateTypeId = @Weight 
	AND rd.TypeServiceId IN (@TypeSTD)
	AND rh.RheRowStatus = 1
	AND rd.RowStatus = 1

	-- Eliminar tarifario COD SDD Y TDA
	UPDATE rc
	SET RowStatus = 0
	   ,TokenUpdated = 'SYS-OMORALES'
	   ,DateUpdated = GETDATE()
	FROM RateCOD rc
	INNER JOIN RateHeader rh
		ON rc.RateId = rh.RheId
	WHERE rh.RateTypeId = @Weight
	AND rc.TypeServiceId IN (@TypeSDD, @TypeTDA)
	AND rh.RheRowStatus = 1
	AND rc.RowStatus = 1

	-- Cambiar tarifario COD NDD a COD
	UPDATE rc
	SET TypeServiceId = @TypeCOD
	FROM RateCOD rc
	INNER JOIN RateHeader rh
		ON rc.RateId = rh.RheId
	WHERE rh.RateTypeId = @Weight
	AND rc.TypeServiceId IN (@TypeNDD)
	AND rh.RheRowStatus = 1
	AND rc.RowStatus = 1

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT
		'0' 'StatusOrder'
	   ,ERROR_MESSAGE() 'Description'
END CATCH

