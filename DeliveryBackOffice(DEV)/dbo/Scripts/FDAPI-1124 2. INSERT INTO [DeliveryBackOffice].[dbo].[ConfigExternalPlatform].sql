DECLARE @WhatsappPlatformId INT = (SELECT TOP 1 CEP.IdExternalPlatform FROM [DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK) WHERE CEP.NameExternalPlatform = 'Whatsapp' COLLATE Latin1_General_CI_AI AND CEP.RowStatus = 1);

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfigEP WITH(NOLOCK) WHERE ConfigEP.ConfigParameterName = 'WhatsappGuideRequest' COLLATE Latin1_General_CI_AI AND ConfigEP.ExternalPlatformId = @WhatsappPlatformId))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
		(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		(@WhatsappPlatformId, 'WhatsappGuideRequest', '1', 1, 'SYS-ARUIZ', GETDATE())

END

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfigEP WITH(NOLOCK) WHERE ConfigEP.ConfigParameterName = 'WhatsappGuideEXCTransfer' COLLATE Latin1_General_CI_AI AND ConfigEP.ExternalPlatformId = @WhatsappPlatformId))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
		(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		(@WhatsappPlatformId, 'WhatsappGuideEXCTransfer', '1', 1, 'SYS-ARUIZ', GETDATE())

END

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfigEP WITH(NOLOCK) WHERE ConfigEP.ConfigParameterName = 'WhatsappGuideDispatch' COLLATE Latin1_General_CI_AI AND ConfigEP.ExternalPlatformId = @WhatsappPlatformId))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
		(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, RowStatus, TokenCreated, DateCreated)
	VALUES
		(@WhatsappPlatformId, 'WhatsappGuideDispatch', '1', 1, 'SYS-ARUIZ', GETDATE())

END
