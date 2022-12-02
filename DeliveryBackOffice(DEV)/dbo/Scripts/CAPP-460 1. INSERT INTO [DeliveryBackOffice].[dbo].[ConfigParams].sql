
IF (NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'GuideRegex' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		(Name, Description, Value, Status, CreateDate)
	VALUES
		('GuideRegex', 'Expresión regular de formato de guías actual', '^([0-9]{7,7})(-([0-9]{1,}))?$', 1, GETDATE())

END

IF (NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'GuideRegexScanner' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		(Name, Description, Value, Status, CreateDate)
	VALUES
		('GuideRegexScanner', 'Expresión regular de formato de guías actual', '^(FD)([0-9]{7,7})(-([0-9]{1,}))?$', 1, GETDATE())

END