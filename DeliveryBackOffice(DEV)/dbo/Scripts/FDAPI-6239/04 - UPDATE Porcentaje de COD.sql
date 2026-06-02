BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @IdCommiCODDef INT =(SELECT ConfigParamsId FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK) WHERE [Name] = 'CODRateDef' AND IdCountry ='SV'),
			@IdCommiCOD    INT =(SELECT ConfigParamsId FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK) WHERE [Name] = 'MinCODCommissionAmount' AND IdCountry ='SV'),
			@IdRate        INT =(SELECT RheId FROM DeliveryBackOffice.dbo.RateHeader WITH(NOLOCK) WHERE RheName = 'Tarifario de servicio estandar' AND CountryId ='SV'),
			@IdRateEXC     INT =(SELECT RheId FROM DeliveryBackOffice.dbo.RateHeader WITH(NOLOCK) WHERE RheName = 'Tarifario destinos express center' AND CountryId ='SV');
 
	UPDATE CF
		SET CF.[Value] = '3.00'
	FROM DeliveryBackOffice.dbo.ConfigParams CF
	WHERE ConfigParamsId IN(@IdCommiCODDef,@IdCommiCOD)
 
	UPDATE C
	SET C.CODRate =  '3.00',
		C.TokenUpdated ='SYS-BPEDROZA',
		C.DateUpdated  = GETDATE()
	FROM DeliveryBackOffice.dbo.RateCOD C
	WHERE C.RateId IN (@IdRate,@IdRateEXC)
	COMMIT TRANSACTION;
	PRINT 'Actualización completada exitosamente.';
 
END TRY
BEGIN CATCH
 
	ROLLBACK TRANSACTION;
	PRINT 'ERROR: ' + ERROR_MESSAGE();
	THROW;
 
END CATCH;