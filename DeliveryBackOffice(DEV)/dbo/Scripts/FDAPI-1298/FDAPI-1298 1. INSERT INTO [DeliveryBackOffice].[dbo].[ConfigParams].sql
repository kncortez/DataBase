IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'ForzaPointsExpirationDays' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		([Name], [Description], [Value], [Status], [CreateDate])
	VALUES
		('ForzaPointsExpirationDays', 'Días adicionales para la expiración de puntos forza', '15', 1, GETDATE())

END
