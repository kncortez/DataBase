UPDATE
	SO
SET
	SO.StatusOrderTrackingDescription = 'Su envío ya fué generado pero aún no ha sido entregado a forza',
	SO.TokenUpdated = 'SYS-ARUIZ',
	SO.DateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
WHERE
	SO.OrderDescription = 'Generado' COLLATE Latin1_General_CI_AI