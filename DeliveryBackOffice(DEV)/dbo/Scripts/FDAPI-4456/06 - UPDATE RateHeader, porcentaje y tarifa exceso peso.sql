BEGIN TRY
BEGIN TRANSACTION
        DECLARE @IdRateIND INT =(SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario de servicio estandar' AND CountryId = 'SV'),
                @IdRateEXC INT =(SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario destinos express center' AND CountryId = 'SV');

        DECLARE @IdPaquetePeque INT = (SELECT AbcId FROM ArticleByCustomer with(nolock) WHERE AbcIdArticle = (SELECT ArtId FROM CatArticle with(nolock) WHERE ArtName = 'Paquete pequeño'  AND IdCountry = 'SV'));

        DECLARE @IdPaqueteMedia INT = (SELECT AbcId FROM ArticleByCustomer with(nolock) WHERE AbcIdArticle = (SELECT ArtId FROM CatArticle with(nolock) WHERE ArtName = 'Paquete mediano'  AND IdCountry = 'SV'));

        DECLARE @IdPaqueteGrand INT = (SELECT AbcId FROM ArticleByCustomer with(nolock) WHERE AbcIdArticle = (SELECT ArtId FROM CatArticle with(nolock) WHERE ArtName = 'Paquete grande'  AND IdCountry = 'SV'));

        DECLARE @IdPaqueteExtraG INT = (SELECT AbcId FROM ArticleByCustomer with(nolock) WHERE AbcIdArticle = (SELECT ArtId FROM CatArticle with(nolock) WHERE ArtName = 'Paquete extra grande'  AND IdCountry = 'SV'));

        DECLARE @IdPaqueteSobreDi INT = (SELECT AbcId FROM ArticleByCustomer with(nolock) WHERE AbcIdArticle = (SELECT ArtId FROM CatArticle with(nolock) WHERE ArtName = 'Paquete sobredimensionado'  AND IdCountry = 'SV'));


		--actualiza datos de tarifario portal web y express center
        UPDATE RateHeader
        SET AdditionalWeightRate = '0.13',WeightLimit = '30.00', CollectRate = '0.50',PickupRate = '0.50', InsuranceRate = '1.80', InsuranceExempt = '100.00'
        WHERE RheId IN(@IdRateIND,@IdRateEXC);


        -- Actualiza CatArticle
        UPDATE CAT
        SET ArtMassWeight = 30.00
        FROM CatArticle CAT WITH(NOLOCK)
        WHERE CAT.ArtName = 'Paquete sobredimensionado' AND CAT.IdCountry = 'SV';


        --deshabilita los articulos que no deben mostrarse
        UPDATE ArticleByCustomer 
        SET AbcRowStatus = 0
        WHERE AbcId IN (@IdPaqueteMedia,@IdPaqueteGrand,@IdPaqueteExtraG)


        --actualiza el valor del paquete sobredimensionado
        UPDATE ArticleByCustomer
        SET [Height]	= 30.00,
            [Width]		= 30.00,
            [Length]	= 30.00,
            [MassWeight]	= 30.00,
            [AbcTokenUpdated] = 'SYS-BPEDROZA',
            [AbcDateUpdated] = GETDATE()
        WHERE AbcId = @IdPaqueteSobreDi;

        COMMIT TRANSACTION
        PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH