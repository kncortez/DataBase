
DECLARE @IncludedMembershipId INT = (SELECT TOP 1 CM.IdCatMembership FROM [DeliveryBackOffice].[dbo].[CatMembership] CM WITH(NOLOCK) WHERE CM.MembershipName = 'Club Forza' COLLATE Latin1_General_CI_AI )

DECLARE @NewSubscriptionInsert TABLE(
	CatSubscriptionId INT
)
	
DECLARE @NewSubscriptionAttributes TABLE(
	SubscriptionAttributeValue NVARCHAR(50),
	SubscriptionAttributeDescription NVARCHAR(300),
	SubscriptionAttributePosition INT
)

INSERT INTO @NewSubscriptionAttributes
	(
		SubscriptionAttributeValue,
		SubscriptionAttributeDescription,
		SubscriptionAttributePosition
	)
VALUES
	(
		'10',
		'Incluye membresía',
		1
	),
	(
		'20',
		'Incluye membresía',
		2
	),
	(
		'30',
		'500 envíos incluidos',
		3
	),
	(
		'40',
		'Envíos adicionales con 30% de descuento',
		4
	),
	(
		'50',
		'No incluye los 50 envíos de la membresía',
		5
	)
	
DECLARE @NewSubscriptionAttributesInsert TABLE(
	CatSubscriptionAttributeId INT
)
	
DECLARE @NewSubscriptionDiscountRangeInsert TABLE(
	CatSubscriptionAttributeId INT
)

BEGIN TRANSACTION
BEGIN TRY

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH(NOLOCK) WHERE CS.SubscriptionName = 'Plan Diamante' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatSubscription]
			(
				SubscriptionName,
				SubscriptionDescription,
				SubscriptionCost,
				SubscriptionFixedValue,
				SubscriptionMaxServiceFixedValue,
				SubscriptionValidity,
				SubscriptionWeight,
				RowStatus,
				TokenCreated,
				DateCreated,
				Icon,
				NextSalesPackageBanner,
				IncludedMembershipId
			)
		OUTPUT inserted.IdCatSubscription INTO @NewSubscriptionInsert(CatSubscriptionId)
		VALUES
			(
				'Plan Diamante',
				'La suscripción más exclusiva',
				12000,
				0,
				500,
				30,
				120,
				1,
				'SYS-ARUIZ',
				GETDATE(),
				'hwa-planDiamanteIcon',
				'bannerFinal.png',
				@IncludedMembershipId
			)

	END
		
	IF( NOT EXISTS(SELECT TOP 1 1 FROM @NewSubscriptionInsert))
	BEGIN

		;THROW 50000, 'ERROR CONTROLADO - NO INGRESO SUSCRIPCIÓN', 1;

	END

	INSERT INTO [DeliveryBackOffice].[dbo].[CatSubscriptionAtribute]
		(
			CatSubscriptionId,
			CatAttributeId,
			SubscriptionAttributeValue,
			SubscriptionAttributeDescription,
			SubscriptionAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated
		)
	OUTPUT inserted.CatAttributeId INTO @NewSubscriptionAttributesInsert (CatSubscriptionAttributeId)
	SELECT
		NSI.CatSubscriptionId,
		1,
		NSA.SubscriptionAttributeValue,
		NSA.SubscriptionAttributeDescription,
		NSA.SubscriptionAttributePosition,
		1,
		'SYS-ARUIZ',
		GETDATE()
	FROM
		@NewSubscriptionInsert NSI
		CROSS JOIN
			@NewSubscriptionAttributes NSA
			
	
	IF( (SELECT COUNT(1) FROM @NewSubscriptionAttributes) != (SELECT COUNT(1) FROM @NewSubscriptionAttributesInsert) )
	BEGIN

		;THROW 50000, 'ERROR CONTROLADO - NO INGRESO ATRIBUTOS SUSCRIPCIÓN', 1;

	END

	INSERT INTO [DeliveryBackOffice].[dbo].[CatSubscriptionDiscountRange]
		(
			CatSubscriptionId,
			DiscountLowServiceRange,
			DiscountTopServiceRange,
			ValueTypeId,
			DiscountValue,
			RowStatus,
			TokenCreated,
			DateCreated
		)
	OUTPUT inserted.IdCatSubscriptionDiscountRange INTO @NewSubscriptionDiscountRangeInsert(CatSubscriptionAttributeId)
	SELECT
		NSI.CatSubscriptionId,
		500,
		NULL,
		1,
		30.00,
		1,
		'SYS-ARUIZ',
		GETDATE()
	FROM
		@NewSubscriptionInsert NSI
	
	IF( NOT EXISTS(SELECT TOP 1 1 FROM @NewSubscriptionDiscountRangeInsert))
	BEGIN

		;THROW 50000, 'ERROR CONTROLADO - NO INGRESO RANGO DE DESCUENTO PARA SUSCRIPCIÓN', 1;

	END

	COMMIT TRANSACTION;

	SELECT 200 'resultCode', 'Todo bien :)' 'resultMessage'

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	SELECT 500 'resultCode', ERROR_MESSAGE() 'resultMessage'

END CATCH