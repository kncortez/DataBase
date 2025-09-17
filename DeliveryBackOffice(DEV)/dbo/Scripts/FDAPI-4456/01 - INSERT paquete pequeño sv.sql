--SELECT * FROM DeliveryBackOffice.dbo.ArticleByCustomer
--WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
--WHERE  ArtName = 'Paquete pequeño' AND IdCountry IS NULL) --EJEMPLO DEVELOP

DECLARE @IdArticle INT;
DECLARE @IdArticleGT INT;
DECLARE @IdCurrency INT;
DECLARE @NewArticle INT;
DECLARE @IdRate INT;

BEGIN TRY
    BEGIN TRANSACTION;

	IF NOT EXISTS(SELECT AbcId FROM ArticleByCustomer with(nolock) WHERE AbcIdArticle = (SELECT ArtId FROM CatArticle with(nolock) WHERE ArtName = 'Paquete pequeño'  AND IdCountry = 'SV'))
	BEGIN
		SELECT @IdArticle = ArtId  FROM DeliveryBackOffice.dbo.CatArticle WITH(NOLOCK)
		WHERE ArtName = 'Paquete pequeño' AND  IdCountry = 'SV'
	
		SELECT @IdCurrency = IdCatCurrencyCOD FROM DeliveryBackOffice.dbo.CatCurrencyCOD WITH(NOLOCK)
		WHERE [Name] = 'DOLAR ESTADOUNIDENSE'

		--SCRIPT AGREGAR ARTICULO POR CLIENTE DE EN ArticleByCustomer Paquete pequeño
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
			,''
			,GETDATE()
			,NULL
			,NULL
			,'EXPSV076'
			,0.0
			,28.00
			,28.00
			,28.00
			,10.00
			,NULL
			,NULL
			,@IdCurrency)

		PRINT('Articulo pequeño insertado correctamente')
	END
	ELSE
		BEGIN
		PRINT('El registro ya existe')
	END
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
