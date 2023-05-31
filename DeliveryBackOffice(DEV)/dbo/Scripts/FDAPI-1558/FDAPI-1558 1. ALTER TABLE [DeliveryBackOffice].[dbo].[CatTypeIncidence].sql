USE [DeliveryBackOffice];
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[CatTypeIncidence]
ADD IsForcedIncidence BIT NOT NULL DEFAULT 0

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicativo si la incidencia esta forzada a ser incidencia en ruta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeIncidence', @level2type=N'COLUMN',@level2name=N'IsForcedIncidence'
GO

UPDATE
	[DeliveryBackOffice].[dbo].[CatTypeIncidence]
SET
	[IsForcedIncidence] = 1
	,[TokenUpdated] = 'SYS-ARUIZ'
	,[DateUpdated] = GETDATE()
WHERE
	[NameIncidence]  COLLATE Latin1_General_CI_AI  IN 
	(
		'Paquete perdido',
		'Paquete dañado',
		'Paquete fuera de ruta',
		'Remitente solicita recolección',
		'No dio tiempo a realizar entrega',
		'otro'
	)
	AND
	[ServiceType] = 'DELIVERY'  COLLATE Latin1_General_CI_AI 