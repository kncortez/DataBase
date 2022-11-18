
IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'DisplayNearestCouriers' COLLATE Latin1_General_CI_AI))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[ConfigParams]
		([Name], [Description], [Value], [Status], [CreateDate])
	VALUES
		('DisplayNearestCouriers','Bandera para desplegar componente de selección de couriers cercanos a punto de recolección',1,1,GETDATE())

END
