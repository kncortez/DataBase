
/*
Plan Básico
Plan Básico +
Plan Gold
Plan Corporativo
*/

DECLARE @InsertedRates TABLE (
	IdRate INT
);

DECLARE @ExpectedInserts TABLE (
	InsertedValue INT
);

BEGIN TRANSACTION
BEGIN TRY

	DECLARE @NombreTarifarioBase NVARCHAR(200) = 'Tarifario de servicio estandar'
	DECLARE @NombreTarifarioBaseAlterno NVARCHAR(200) = 'Tarifario destinos express center'

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Básico' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);

		INSERT INTO [DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Básico',
				'',
				'Tarifa para clientes con la suscripcion Plan Básico activa',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBase

	END
	
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Básico destinos express center' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);

		INSERT INTO [DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Básico destinos express center',
				'',
				'Tarifa para clientes con la suscripcion Plan Básico activa destinos express center',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBaseAlterno

	END

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Básico Plus' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);
		
		INSERT INTO
			[DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Básico Plus',
				'',
				'Tarifa para clientes con la suscripcion Plan Básico Plus activa',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBase

	END
	
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Básico Plus destinos express center' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);
		
		INSERT INTO
			[DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Básico Plus destinos express center',
				'',
				'Tarifa para clientes con la suscripcion Plan Básico Plus activa destinos express center',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBaseAlterno

	END

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Gold' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);
		
		INSERT INTO
			[DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Gold',
				'',
				'Tarifa para clientes con la suscripcion Plan Gold activa',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBase

	END
	
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Gold destinos express center' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);
		
		INSERT INTO
			[DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Gold destinos express center',
				'',
				'Tarifa para clientes con la suscripcion Plan Gold activa destinos express center',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBaseAlterno

	END

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Corporativo' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);
		
		INSERT INTO
			[DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Corporativo',
				'',
				'Tarifa para clientes con la suscripcion Plan Corporativo activa',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBase

	END
	
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RheName = 'Tarifa suscripción Plan Corporativo destinos express center' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO @ExpectedInserts (InsertedValue) VALUES (1);
		
		INSERT INTO
			[DeliveryBackOffice].[dbo].[RateHeader]
			(
				RheName, 
				RheShortName, 
				RheDescription, 
				RheDefault, 
				RheRowStatus, 
				RheTokenCreated, 
				RheDateCreated, 

				RateTypeId, 
				FragilRate, 
				InsuranceRate, 
				InsuranceExempt,
				AdditionalWeightRate, 
				WeightLimit, 
				CreditCardRate, 
				PickupRate, 
				Attempt, 
				CountryId, 
				CurrencyId, 

				IsTemplate, 

				RateByPiece, 
				ReturnRate, 
				CollectRate, 
				PiecesIncluded, 
				AttemptReturn
			)
		OUTPUT inserted.RheId INTO @InsertedRates (IdRate)
		SELECT
			TOP 1
				'Tarifa suscripción Plan Corporativo destinos express center',
				'',
				'Tarifa para clientes con la suscripcion Plan Corporativo activa destinos express center',
				0,
				1,
				'SYS-ARUIZ',
				GETDATE(),

				RH.RateTypeId,
				RH.FragilRate,
				RH.InsuranceRate,
				RH.InsuranceExempt,
				RH.AdditionalWeightRate,
				RH.WeightLimit,
				RH.CreditCardRate,
				RH.PickupRate,
				RH.Attempt,
				RH.CountryId,
				RH.CurrencyId,

				0,

				RH.RateByPiece,
				RH.ReturnRate,
				RH.CollectRate,
				RH.PiecesIncluded,
				RH.AttemptReturn
		FROM
			[DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		WHERE
			RH.RheName = @NombreTarifarioBaseAlterno

	END

	IF((SELECT COUNT(IR.IdRate) FROM @InsertedRates IR) != (SELECT COUNT(EI.InsertedValue) FROM @ExpectedInserts EI))
	BEGIN

		;THROW 50001, 'INSERTS INCOMPLETOS', 1;

	END

	COMMIT TRANSACTION;

	SELECT
		1 'blnResult',
		'Completado exitosamente' 'messageResult'

	SELECT 
		COUNT(IR.IdRate) 'Tarifarios insertados'
	FROM 
		@InsertedRates IR


END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	SELECT
		0 'blnResult',
		ERROR_MESSAGE() 'messageResult'

END CATCH