DECLARE @InternalStatusId INT = (
	SELECT 
		TOP (1) 
			[CST].[IdCatStatusType]
	FROM 
		[DeliveryBackOffice].[dbo].[CatStatusType] CST  WITH(NOLOCK) 
	WHERE
		CST.[StatusType] = 'Interno'  COLLATE Latin1_General_CI_AI 
)

UPDATE
	[SO]
SET
	[SO].[CatStatusTypeId] = @InternalStatusId
FROM
	[DeliveryBackOffice].[dbo].[StatusOrder] SO 
WHERE
	SO.[OrderDescription] = 'Incidencia en ruta'  COLLATE Latin1_General_CI_AI 
