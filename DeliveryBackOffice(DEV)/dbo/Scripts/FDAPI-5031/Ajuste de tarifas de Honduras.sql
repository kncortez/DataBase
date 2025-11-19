/* =================================================
   Script:    Ajuste de tarifas de Honduras
   Propósito: Script para modificar las tarifas de envios en los portales en Honduras, por cambio de jerarquia.
   Autor:     Walter Orozco
   Historia:  FDAPI-4781 [FDAPI-5031]
   Fecha:     2025-11-19
=================================================*/

BEGIN TRY
    BEGIN TRANSACTION;
    
    DECLARE @IdRate INT = (SELECT RheId FROM RateHeader WITH(NOLOCK) WHERE RheName ='Tarifario de servicio estandar' AND CountryId = 'HN')
    DECLARE @IdRateEXC INT = (SELECT RheId FROM RateHeader WITH(NOLOCK) WHERE RheName ='Tarifario destinos express center' AND CountryId = 'HN')
	DECLARE @TownSPS INT = (SELECT IdTownship FROM DeliveryBackOffice.dbo.Township WITH(NOLOCK) WHERE TownshipName = 'SAN PEDRO SULA')  --San pedro sula
	DECLARE @TownDC INT = (SELECT IdTownship FROM DeliveryBackOffice.dbo.Township WITH(NOLOCK) WHERE TownshipName = 'DISTRITO CENTRAL' ) --Tegucigalpa , Comayaguela
	DECLARE @SegmentTypeMetro INT = (SELECT CrsId FROM DeliveryBackOffice.dbo.CatRateSegment WITH(NOLOCK) WHERE CrsName = 'METRO HN')

	--Actualizar clasificación de NACIONAL HN a METRO HN
	UPDATE  RTC
	SET SegmentTypeId = @SegmentTypeMetro
	FROM DeliveryBackOffice.dbo.RateTownshipCoverage RTC WITH(NOLOCK)
	WHERE RateId = @IdRate AND RowStatus = 1 AND (TownshipSourceId = @TownDC AND TownshipDestinyId = @TownSPS)

	UPDATE  RTC
	SET SegmentTypeId = @SegmentTypeMetro
	FROM DeliveryBackOffice.dbo.RateTownshipCoverage RTC WITH(NOLOCK)
	WHERE RateId = @IdRate AND RowStatus = 1 AND (TownshipSourceId = @TownSPS AND TownshipDestinyId = @TownDC)

	UPDATE  RTC
	SET SegmentTypeId = @SegmentTypeMetro
	FROM DeliveryBackOffice.dbo.RateTownshipCoverage RTC WITH(NOLOCK)
	WHERE RateId = @IdRateEXC AND RowStatus = 1 AND (TownshipSourceId = @TownDC AND TownshipDestinyId = @TownSPS)

	UPDATE  RTC
	SET SegmentTypeId = @SegmentTypeMetro
	FROM DeliveryBackOffice.dbo.RateTownshipCoverage RTC WITH(NOLOCK)
	WHERE RateId = @IdRateEXC AND RowStatus = 1 AND (TownshipSourceId = @TownSPS AND TownshipDestinyId = @TownDC)

    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
