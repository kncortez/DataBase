BEGIN TRY
BEGIN TRANSACTION
        DECLARE @IdRateIND INT =(SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario de servicio estandar' AND CountryId = 'SV'),
                @IdRateEXC INT =(SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario destinos express center' AND CountryId = 'SV');

        UPDATE RateHeader
        SET AdditionalWeightRate = '0.13',WeightLimit = '30.00', CollectRate = '0.50',PickupRate = '0.50'
        WHERE RheId IN(@IdRateIND,@IdRateEXC);

        COMMIT TRANSACTION
        PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH