
UPDATE [DeliveryBackOffice].[dbo].[CatTypeContainer]
SET
	[SubtypeContainerId] = 
	(
		SELECT 
				TOP (1) 
					[CCS].IdCatContainerSubtype 
			FROM 
				[DeliveryBackOffice].[dbo].[CatContainerSubtype] CCS  WITH(NOLOCK) 
			WHERE
				[CCS].ContainerSubtypeName = 'PISO'  COLLATE Latin1_General_CI_AI 
	)
WHERE
	[TypeContainerName] LIKE '%PISO%'


UPDATE [DeliveryBackOffice].[dbo].[CatTypeContainer]
SET
	[SubtypeContainerId] = 
	(
		SELECT 
				TOP (1) 
					[CCS].IdCatContainerSubtype 
			FROM 
				[DeliveryBackOffice].[dbo].[CatContainerSubtype] CCS  WITH(NOLOCK) 
			WHERE
				[CCS].ContainerSubtypeName = 'VIRTUAL'  COLLATE Latin1_General_CI_AI 
	)
WHERE
	[TypeContainerName] LIKE '%VIRTUAL%'