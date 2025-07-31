--SELECT * FROM DeliveryBackOffice.dbo.ArticleByCustomer
--WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
--WHERE  ArtName = 'Paquete sobredimensionado' AND IdCountry IS NULL) --EJEMPLO DEVELOP

DECLARE @IdArticle INT;
DECLARE @IdArticleGT INT;
DECLARE @IdCurrency INT;
DECLARE @NewArticle INT;
DECLARE @IdRate INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SELECT @IdArticle = ArtId  FROM DeliveryBackOffice.dbo.CatArticle 
	WHERE ArtName = 'Paquete sobredimensionado' AND  IdCountry = 'SV'
	
	SELECT @IdCurrency = IdCatCurrencyCOD FROM DeliveryBackOffice.dbo.CatCurrencyCOD WITH(NOLOCK)
	WHERE Name = 'DOLAR ESTADOUNIDENSE'

	--SCRIPT AGREGAR ARTICULO POR CLIENTE DE HN EN ArticleByCustomer Paquete sobredimensionado
	INSERT INTO [dbo].[ArticleByCustomer]
		([AbcIdArticle]
		,[AbcIdCustomer]
		,[AbcRowStatus]
		,[AbcTokenCreated]
		,[AbcDateCreated]
		,[AbcTokenUpdated]
		,[AbcDateUpdated]
		,[Code]
		,[PriceDefault]
		,[Height]
		,[Width]
		,[Length]
		,[MassWeight]
		,[VolumetricWeight]
		,[ShowDefault]
		,[IdCurrency])
	VALUES
		(@IdArticle
		,NULL
		,1
		,'SYS-WOROZCO'
		,GETDATE()
		,NULL
		,NULL
		,'EXPSV080'
		,0.0
		,51.00
		,51.00
		,51.00
		,60.00
		,NULL
		,NULL
		,@IdCurrency)

	SELECT @NewArticle = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer
	WHERE  AbcIdArticle = @IdArticle AND code = 'EXPSV080'

	SELECT @IdRate = RheId  FROM DeliveryBackOffice.dbo.RateHeader WITH(NOLOCK)
	WHERE CountryId = 'SV' AND RheName = 'Tarifario de servicio estandar';

	SELECT @IdArticleGT = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer
	WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
	WHERE  ArtName = 'Paquete sobredimensionado' AND (IdCountry IS NULL OR IdCountry = 'GT'))

	--SCRIPT AGREGAR DATA PARA ARTICULOS DE HN EN RateData Paquete sobredimensionado
	INSERT INTO [dbo].[RateData]
		([RateId]
		,[TypeServiceId]
		,[TypeSegmentId]
		,[HubSourceId]
		,[HubDestinyId]
		,[ArticleId]
		,[RateValue]
		,[RowStatus]
		,[TokenCreated]
		,[DateCreated]
		,[TokenUpdated]
		,[DateUpdated]
		,[LimitHourDelivery]
		,[LimitHourPickup]
		,[WeightFrom]
		,[WeightTo]
		,[PackagesFrom]
		,[PackagesTo])
	SELECT 
		[RateId]
		,[TypeServiceId]
		,[TypeSegmentId]
		,[HubSourceId]
		,[HubDestinyId]
		,@NewArticle AS [ArticleId]
		,[RateValue]
		,[RowStatus]
		,'SYS-WOROZCO' AS [TokenCreated]
		,GETDATE() AS [DateCreated]
		,NULL AS [TokenUpdated]
		,NULL AS [DateUpdated]
		,[LimitHourDelivery]
		,[LimitHourPickup]
		,[WeightFrom]
		,[WeightTo]
		,[PackagesFrom]
		,[PackagesTo]
	FROM DeliveryBackOffice.dbo.RateData
	WHERE ArticleId = @IdArticleGT AND RateId = @IdRate;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
