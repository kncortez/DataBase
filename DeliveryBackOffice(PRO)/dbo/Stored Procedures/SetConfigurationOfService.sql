
-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2022-03-08>
-- Description:	< Guarda la configuración actual de un servicio configurable desde base de datos >
-- =============================================
CREATE PROCEDURE [dbo].[SetConfigurationOfService]
	@ServiceId INT = 0,
	@StartingTime TIME = NULL,
	@FinishingTime TIME = NULL,
	@TimeStep INT = NULL,
	@ProvinceIds TblExtPlatNumericParameterList READONLY,
	@TownshipIds TblExtPlatNumericParameterList READONLY,
	@TownshipZoneIds TblTownshipZone READONLY,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Variables de control de INSERT
	DECLARE @TimeServiceExists BIT = 0;

	-- Varificar existencias
	SET @TimeServiceExists = (
		SELECT
			TOP 1
				1
		FROM
			[DeliveryBackOffice].[dbo].[ServiceTimeConfiguration] STC
		WHERE
			STC.CatConfigurableServiceId = @ServiceId
			AND
			STC.RowStatus = 1
	)

	BEGIN TRANSACTION
	BEGIN TRY

		IF(@TimeServiceExists = 1)
		BEGIN
			IF(@StartingTime IS NOT NULL AND @FinishingTime IS NOT NULL AND @TimeStep IS NOT NULL)
			BEGIN

				UPDATE
					STC
				SET
					STC.StartingTime = @StartingTime
					,STC.FinishingTime = @FinishingTime
					,STC.TimeStep = @TimeStep
					,STC.TokenUpdated = @Token
					,STC.DateUpdated = GETDATE()
				FROM	
					[DeliveryBackOffice].[dbo].[ServiceTimeConfiguration] STC
				WHERE
					STC.CatConfigurableServiceId = @ServiceId
					AND
					STC.RowStatus = 1
					
			END
		END
		ELSE
		BEGIN
			IF(@StartingTime IS NOT NULL AND @FinishingTime IS NOT NULL AND @TimeStep IS NOT NULL)
			BEGIN

				INSERT INTO [DeliveryBackOffice].[dbo].[ServiceTimeConfiguration]
					(CatConfigurableServiceId, StartingTime, FinishingTime, TimeStep, RowStatus, TokenCreated, DateCreated)
				VALUES
					(@ServiceId, @StartingTime, @FinishingTime, @TimeStep, 1, @Token, GETDATE())

			END
		END

		-- CONFIG DE DEPARTAMENTOS
		-- Ingresar nuevos no existentes
		INSERT INTO [DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration]
			(CatConfigurableServiceId, ProvinceId, RowStatus, TokenCreated, DateCreated)
		SELECT
			@ServiceId, PIDS.NumericParameter, 1, @Token, GETDATE()
		FROM
			@ProvinceIds PIDS
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC
				ON
					PIDS.NumericParameter = SPC.ProvinceId
		WHERE
			SPC.IdServiceProvinceConfiguration IS NULL

		-- Reactivar existentes
		UPDATE
			SPC
		SET
			SPC.RowStatus = 1
			,SPC.TokenUpdated = @Token
			,SPC.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC
			LEFT JOIN
				@ProvinceIds PIDS
				ON
					SPC.ProvinceId = PIDS.NumericParameter
		WHERE
			PIDS.NumericParameter IS NOT NULL
			AND
			SPC.CatConfigurableServiceId = @ServiceId
			AND
			SPC.RowStatus = 0

		-- Desactivar anulados
		UPDATE
			SPC
		SET
			SPC.RowStatus = 0
			,SPC.TokenUpdated = @Token
			,SPC.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ServiceProvinceConfiguration] SPC
			LEFT JOIN
				@ProvinceIds PIDS
				ON
					SPC.ProvinceId = PIDS.NumericParameter
		WHERE
			PIDS.NumericParameter IS NULL
			AND
			SPC.CatConfigurableServiceId = @ServiceId

		-- CONFIG DE MUNICIPIOS
		-- Ingresar nuevos no existentes
		INSERT INTO [DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration]
			(CatConfigurableServiceId, TownshipId, RowStatus, TokenCreated, DateCreated)
		SELECT
			@ServiceId, TIDS.NumericParameter, 1, @Token, GETDATE()
		FROM
			@TownshipIds TIDS
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC
				ON
					TIDS.NumericParameter = STC.TownshipId
		WHERE
			STC.IdServiceTownshipConfiguration IS NULL

		-- Reactivar existentes
		UPDATE
			STC
		SET
			STC.RowStatus = 1
			,STC.TokenUpdated = @Token
			,STC.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC
			LEFT JOIN
				@TownshipIds TIDS
				ON
					STC.TownshipId = TIDS.NumericParameter
		WHERE
			TIDS.NumericParameter IS NOT NULL
			AND
			STC.CatConfigurableServiceId = @ServiceId
			AND
			STC.RowStatus = 0

		-- Desactivar anulados
		UPDATE
			STC
		SET
			STC.RowStatus = 0
			,STC.TokenUpdated = @Token
			,STC.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ServiceTownshipConfiguration] STC
			LEFT JOIN
				@TownshipIds TIDS
				ON
					STC.TownshipId = TIDS.NumericParameter
		WHERE
			TIDS.NumericParameter IS NULL
			AND
			STC.CatConfigurableServiceId = @ServiceId
			
		-- CONFIG DE MUNICIPIOS BAJO ZONA
		-- Ingresar nuevos no existentes
		INSERT INTO [DeliveryBackOffice].[dbo].[ServiceZoneConfiguration]
			(CatConfigurableServiceId, TownshipId, Zone, RowStatus, TokenCreated, DateCreated)
		SELECT
			@ServiceId, TZIDS.Township, TZIDS.Zone, 1, @Token, GETDATE()
		FROM
			@TownshipZoneIds TZIDS
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC
				ON
					TZIDS.Township = SZC.TownshipId
					AND
					TZIDS.Zone = SZC.Zone
		WHERE
			SZC.IdServiceZoneConfiguration IS NULL
			
		-- Reactivar existentes
		UPDATE
			SZC
		SET
			SZC.RowStatus = 1
			,SZC.TokenUpdated = @Token
			,SZC.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC
			LEFT JOIN
				@TownshipZoneIds TZIDS
				ON
					TZIDS.Township = SZC.TownshipId
					AND
					TZIDS.Zone = SZC.Zone
		WHERE
			TZIDS.Township IS NOT NULL
			AND
			SZC.CatConfigurableServiceId = @ServiceId
			AND
			SZC.RowStatus = 0

		-- Desactivar anulados
		UPDATE
			SZC
		SET
			SZC.RowStatus = 0
			,SZC.TokenUpdated = @Token
			,SZC.DateUpdated = GETDATE()
		FROM
			[DeliveryBackOffice].[dbo].[ServiceZoneConfiguration] SZC
			LEFT JOIN
				@TownshipZoneIds TZIDS
				ON
					TZIDS.Township = SZC.TownshipId
					AND
					TZIDS.Zone = SZC.Zone
		WHERE
			TZIDS.Township IS NULL
			AND
			SZC.CatConfigurableServiceId = @ServiceId

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION

		SELECT
			1 [blnResult],
			'Exito registrando nueva configuración del servicio' 'Description'

	END TRY
	BEGIN CATCH
	
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION

	END CATCH
END