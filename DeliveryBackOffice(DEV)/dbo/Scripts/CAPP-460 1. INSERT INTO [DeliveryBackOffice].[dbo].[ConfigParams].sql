
IF (NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'GuideRegex' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		(Name, Description, Value, Status, CreateDate)
	VALUES
		('GuideRegex', 'Expresión regular de formato de guías actual', '^([0-9]{6,10})(-([0-9]{1,3}))?$', 1, GETDATE())

END