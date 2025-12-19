/* =================================================
   Script:    Rollback - Descuento Navidad Honduras 2025
   Propósito: Realizar rollback de modificación por segmento de tarifarios para Hn.
   Autor:     Walter Orozco
   Historia:  FDAPI-5289[FDAPI-5288]
   Fecha:     2025-12-17
================================================= */

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE
		@TokenRollback		NVARCHAR(100)	= 'SYS-DESCUENTONAVIDAD25', --Utilizar token único para identificar tarifas afectadas por descuentos.
		@Token				NVARCHAR(100)	= 'SYS-RBDESCUENTONAVIDAD25',
		@DateCreated		DATETIME		= GETDATE();

	DECLARE 
		@IdRateEXC		INT = (SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario destinos express center' AND CountryId = 'HN'),
		@IdRate			INT = (SELECT RheId from RateHeader WITH(NOLOCK) where RheName ='Tarifario de servicio estandar' AND CountryId = 'HN'),
		@TypeServiceSTD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'STD'), --5
		@TypeServiceCOD INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'COD'); --6

		-- ========================================
		--		INHABILITAR TARIFARIOS NUEVOS
		-- ========================================
		
		UPDATE RateData 
		SET 
			RowStatus		= 0,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRate
		AND RowStatus = 1
		AND TypeServiceId = @TypeServiceSTD
		AND TokenCreated = @TokenRollback

		UPDATE RateData 
		SET 
			RowStatus		= 0,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRate
		AND RowStatus = 1
		AND TypeServiceId = @TypeServiceCOD
		AND TokenCreated = @TokenRollback

		UPDATE RateData 
		SET 
			RowStatus		= 0,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRateEXC
		AND RowStatus = 1
		AND TypeServiceId = @TypeServiceSTD
		AND TokenCreated = @TokenRollback

		UPDATE RateData 
		SET 
			RowStatus		= 0,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRateEXC
		AND RowStatus = 1
		AND TypeServiceId = @TypeServiceCOD
		AND TokenCreated = @TokenRollback

		-- ========================================
		--		HABILITAR TARIFARIOS ORIGINALES
		-- ========================================

		UPDATE RateData 
		SET 
			RowStatus		= 1,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRate
		AND RowStatus = 0
		AND TypeServiceId = @TypeServiceSTD
		AND TokenUpdated = @TokenRollback

		UPDATE RateData 
		SET 
			RowStatus		= 1,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRate
		AND RowStatus = 0
		AND TypeServiceId = @TypeServiceCOD
		AND TokenUpdated = @TokenRollback

		UPDATE RateData 
		SET 
			RowStatus		= 1,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRateEXC
		AND RowStatus = 0
		AND TypeServiceId = @TypeServiceSTD
		AND TokenUpdated = @TokenRollback

		UPDATE RateData 
		SET 
			RowStatus		= 1,
			TokenUpdated	= @Token,
			DateUpdated		= @DateCreated
		WHERE RateId = @IdRateEXC
		AND RowStatus = 0
		AND TypeServiceId = @TypeServiceCOD
		AND TokenUpdated = @TokenRollback

	COMMIT TRANSACTION;
	PRINT 'Rollback realizado correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
