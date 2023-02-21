IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'ForzaPointsExchangeValue' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		([Name], [Description], [Value], [Status], [CreateDate])
	VALUES
		('ForzaPointsExchangeValue', 'Valor de puntos en proceso de intercambio de puntos forza', '1', 1, GETDATE())

END

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'ForzaPointsGenerationValue' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		([Name], [Description], [Value], [Status], [CreateDate])
	VALUES
		('ForzaPointsGenerationValue', 'Valor de puntos a generar en proceso de acreditación de puntos forza', '1', 1, GETDATE())

END

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'ForzaPointsExchangeType' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		([Name], [Description], [Value], [Status], [CreateDate])
	VALUES
		('ForzaPointsExchangeType', 'Forma de utilizar puntos en intercambio de puntos forza (Monto o Servicio)', 'MONTO', 1, GETDATE())

END

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'ForzaPointsGenerationType' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		([Name], [Description], [Value], [Status], [CreateDate])
	VALUES
		('ForzaPointsGenerationType', 'Forma de generar puntos forza (Monto o Servicio)', 'SERVICIO', 1, GETDATE())

END
