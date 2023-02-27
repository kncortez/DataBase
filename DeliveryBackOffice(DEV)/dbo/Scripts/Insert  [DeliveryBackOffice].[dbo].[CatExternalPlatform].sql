DECLARE @TargetExternalPlatformId TABLE (
	IdExternalPlatform INT
)
DECLARE @InsertedConfigs TABLE (
	IdConfigExternalPlatform INT
)
DECLARE @ExpectedConfigs INT;

BEGIN TRANSACTION
BEGIN TRY

	IF
	( 
		NOT EXISTS 
		(
			SELECT 
				TOP 1 
					CEP.IdExternalPlatform 
			FROM 
				[DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK) 
			WHERE 
				CEP.NameExternalPlatform = 'MsmPickupRequest' COLLATE Latin1_General_CI_AI   
		) 
	)
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatExternalPlatform]
			(NameExternalPlatform, RowStatus, DateCreated, TokenCreated)
		OUTPUT inserted.IdExternalPlatform INTO @TargetExternalPlatformId (IdExternalPlatform)
		VALUES
			('MsmPickupRequest', 1, GETDATE(), 'SYS-EVASQUEZ')

	END
	ELSE
	BEGIN

		INSERT INTO @TargetExternalPlatformId
			(IdExternalPlatform)
		SELECT 
			TOP 1 
				CEP.IdExternalPlatform 
		FROM 
			[DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK) 
		WHERE 
			CEP.NameExternalPlatform = 'MsmPickupRequest' COLLATE Latin1_General_CI_AI

	END

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] CEP WITH(NOLOCK) WHERE CEP.ConfigParameterName = 'MsmPickupRequest' COLLATE Latin1_General_CI_AI) )
	BEGIN

		SET @ExpectedConfigs = ISNULL(@ExpectedConfigs, 0) + 1;

		INSERT INTO [DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
			(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, RowStatus, DateCreated, TokenCreated)
		OUTPUT inserted.IdConfigExternalPlatform INTO @InsertedConfigs (IdConfigExternalPlatform)
		SELECT
			TOP 1
				IdExternalPlatform, 'MsmPickupRequest', 'Hola <CLIENTE> necesitamos confirmes tus datos para realizar la recolección', 1, GETDATE(), 'SYS-EVASQUEZ'
		FROM
			@TargetExternalPlatformId

	END
	

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] CEP WITH(NOLOCK) WHERE CEP.ConfigParameterName = 'MsmLinkPickupRequest' COLLATE Latin1_General_CI_AI) )
	BEGIN

		SET @ExpectedConfigs = ISNULL(@ExpectedConfigs, 0) + 1;

		INSERT INTO [DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
			(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, RowStatus, DateCreated, TokenCreated)
		OUTPUT inserted.IdConfigExternalPlatform INTO @InsertedConfigs (IdConfigExternalPlatform)
		SELECT
			TOP 1
				IdExternalPlatform, 'MsmLinkPickupRequest', 'https://pickup.forzadelivery.io/landing-page?VPToken=', 1, GETDATE(), 'SYS-EVASQUEZ'
		FROM
			@TargetExternalPlatformId

	END

	COMMIT TRANSACTION;

	SELECT
		1 'resultCode',
		'todo bien :)))' 'resultMessage'

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	SELECT
		0 'resultCode',
		ERROR_MESSAGE() 'resultMessage'

END CATCH