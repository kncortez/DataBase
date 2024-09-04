BEGIN TRY
    BEGIN TRANSACTION;
    --SCRIPT PARA ACTUALIZAR LOS ARTICULOS DE HN CON LOS TARIFARIOS

	DECLARE @ArticleIdGT INT;
	DECLARE @ArticleIdHN INT;
	DECLARE @TypeSegmentId INT;
	DECLARE @TypeServiceIdSTD INT;
	DECLARE @TypeServiceIdCOD INT;
	DECLARE @IdRate INT;

	SELECT @IdRate = RheId FROM DeliveryBackOffice.dbo.RateHeader WITH(NOLOCK)
	WHERE RheName = 'Tarifario destinos express center' AND CountryId = 'HN'

	SELECT @TypeSegmentId = CrsId FROM DeliveryBackOffice.dbo.CatRateSegment WITH(NOLOCK)
	WHERE CrsName = 'LOCAL'

	SELECT @TypeServiceIdSTD = CtsId FROM DeliveryBackOffice.dbo.CatTypeService WITH(NOLOCK)
	WHERE CtsShortName = 'STD' 

	SELECT @TypeServiceIdCOD = CtsId FROM DeliveryBackOffice.dbo.CatTypeService WITH(NOLOCK)
	WHERE CtsShortName = 'COD' 

	SELECT @ArticleIdGT = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXP076'

	SELECT @ArticleIdHN = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXPHN076'

	UPDATE DeliveryBackOffice.dbo.RateData
	SET ArticleId = @ArticleIdHN
	WHERE TypeSegmentId = @TypeSegmentId AND RowStatus = 'true'
	AND TypeServiceId IN (@TypeServiceIdSTD,@TypeServiceIdCOD) 
	AND RateId = @IdRate AND ArticleId = @ArticleIdGT 

	SELECT @ArticleIdGT = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXP077'

	SELECT @ArticleIdHN = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXPHN077'

	UPDATE DeliveryBackOffice.dbo.RateData
	SET ArticleId = @ArticleIdHN
	WHERE TypeSegmentId = @TypeSegmentId AND RowStatus = 'true'
	AND TypeServiceId IN (@TypeServiceIdSTD,@TypeServiceIdCOD) 
	AND RateId = @IdRate AND ArticleId = @ArticleIdGT 

	SELECT @ArticleIdGT = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXP078'

	SELECT @ArticleIdHN = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXPHN078'

	UPDATE DeliveryBackOffice.dbo.RateData
	SET ArticleId = @ArticleIdHN
	WHERE TypeSegmentId = @TypeSegmentId AND RowStatus = 'true'
	AND TypeServiceId IN (@TypeServiceIdSTD,@TypeServiceIdCOD) 
	AND RateId = @IdRate AND ArticleId = @ArticleIdGT 

	SELECT @ArticleIdGT = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXP079'

	SELECT @ArticleIdHN = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXPHN079'

	UPDATE DeliveryBackOffice.dbo.RateData
	SET ArticleId = @ArticleIdHN
	WHERE TypeSegmentId = @TypeSegmentId AND RowStatus = 'true'
	AND TypeServiceId IN (@TypeServiceIdSTD,@TypeServiceIdCOD) 
	AND RateId = @IdRate AND ArticleId = @ArticleIdGT 

	SELECT @ArticleIdGT = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXP080'

	SELECT @ArticleIdHN = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
	where Code = 'EXPHN080'

	UPDATE DeliveryBackOffice.dbo.RateData
	SET ArticleId = @ArticleIdHN
	WHERE TypeSegmentId = @TypeSegmentId AND RowStatus = 'true'
	AND TypeServiceId IN (@TypeServiceIdSTD,@TypeServiceIdCOD) 
	AND RateId = @IdRate AND ArticleId = @ArticleIdGT 

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
