BEGIN TRANSACTION
BEGIN TRY
	DECLARE @AllDestiny INT = (SELECT IdTypeRate FROM CatTypeRate WHERE Name = 'Todo Destino')
	DECLARE @TypeSDD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'SDD')
	DECLARE @TypeNDD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'NDD')
	DECLARE @TypeTDA INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'TDA')
	DECLARE @TypeSTD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'STD')
	DECLARE @TypeCOD INT = (SELECT CtsId FROM CatTypeService WHERE CtsShortName = 'COD')

	-- Desactivar registros SDD y TDA
	UPDATE rd 
	SET RowStatus = 0
		,TokenUpdated = 'SYS-OMORALES'
		,DateUpdated = GETDATE()
	FROM RateHeader rh 
	INNER JOIN RateData rd
	ON rh.RheId = rd.RateId
	WHERE rh.RateTypeId = @AllDestiny 
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
	WHERE rh.RateTypeId = @AllDestiny 
	AND rd.TypeServiceId IN (@TypeNDD)
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
	WHERE rh.RateTypeId = @AllDestiny 
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
	WHERE rh.RateTypeId = @AllDestiny
	AND rc.TypeServiceId IN (@TypeSDD, @TypeTDA)
	AND rh.RheRowStatus = 1
	AND rc.RowStatus = 1

	-- Cambiar tarifario COD NDD a COD
	UPDATE rc
	SET TypeServiceId = @TypeCOD
	FROM RateCOD rc
	INNER JOIN RateHeader rh
		ON rc.RateId = rh.RheId
	WHERE rh.RateTypeId = @AllDestiny
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

