IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK) WHERE CEP.NameExternalPlatform = 'VisaLink' COLLATE Latin1_General_CI_AI) )
BEGIN
	INSERT INTO [DeliveryBackOffice].[dbo].[CatExternalPlatform]
		(NameExternalPlatform, RowStatus, TokenCreated, DateCreated)
	VALUES
		('VisaLink',1,'SYS-ARUIZ',GETDATE())
END