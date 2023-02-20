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
				CEP.NameExternalPlatform = 'MsmTransfer' COLLATE Latin1_General_CI_AI
		) 
	)
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatExternalPlatform]
			(NameExternalPlatform, RowStatus, DateCreated, TokenCreated)
		OUTPUT inserted.IdExternalPlatform INTO @TargetExternalPlatformId (IdExternalPlatform)
		VALUES
			('MsmTransfer', 1, GETDATE(), 'SYS-ARUIZ')

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
			CEP.NameExternalPlatform = 'MsmTransfer' COLLATE Latin1_General_CI_AI

	END

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] CEP WITH(NOLOCK) WHERE CEP.ConfigParameterName = 'MsmReturnMessage' COLLATE Latin1_General_CI_AI) )
	BEGIN

		SET @ExpectedConfigs = ISNULL(@ExpectedConfigs, 0) + 1;

		INSERT INTO [DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
			(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, RowStatus, DateCreated, TokenCreated)
		OUTPUT inserted.IdConfigExternalPlatform INTO @InsertedConfigs (IdConfigExternalPlatform)
		SELECT
			TOP 1
				IdExternalPlatform, 'MsmReturnMessage', 'Estimado <DESTINY>, te saludamos de Forza Delivery. Nuestro Express Center <EXC> ha recibido un paquete para su devolución. Tienes un lapso de <DAYS> días para recolectarlo.', 1, GETDATE(), 'SYS-ARUIZ'
		FROM
			@TargetExternalPlatformId

	END
	

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] CEP WITH(NOLOCK) WHERE CEP.ConfigParameterName = 'MsmDeliveryMessage' COLLATE Latin1_General_CI_AI) )
	BEGIN

		SET @ExpectedConfigs = ISNULL(@ExpectedConfigs, 0) + 1;

		INSERT INTO [DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
			(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, RowStatus, DateCreated, TokenCreated)
		OUTPUT inserted.IdConfigExternalPlatform INTO @InsertedConfigs (IdConfigExternalPlatform)
		SELECT
			TOP 1
				IdExternalPlatform, 'MsmDeliveryMessage', 'Estimado <DESTINY>, te saludamos de Forza Delivery. Nuestro Express Center <EXC> ha recibido un paquete que te ha enviado <ORIGIN>. Tienes un lapso de <DAYS> días para recolectarlo.', 1, GETDATE(), 'SYS-ARUIZ'
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
