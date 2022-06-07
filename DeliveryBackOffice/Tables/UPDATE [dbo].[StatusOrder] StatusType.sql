
DECLARE @InternalStatusId INT = (SELECT TOP 1 CST.IdCatStatusType FROM [DeliveryBackOffice].[dbo].[CatStatusType] CST WITH(NOLOCK) WHERE CST.StatusType = 'Interno' COLLATE Latin1_General_CI_AI);
DECLARE @ExternalStatusId INT = (SELECT TOP 1 CST.IdCatStatusType FROM [DeliveryBackOffice].[dbo].[CatStatusType] CST WITH(NOLOCK) WHERE CST.StatusType = 'Externo' COLLATE Latin1_General_CI_AI);

UPDATE
	[DeliveryBackOffice].[dbo].[StatusOrder]
SET
	CatStatusTypeId = @InternalStatusId
WHERE
	StatusOrderId IN (
		3
		,6
		,7
		,8
		,9
		,10
		,13
		,16
		,17
		,18
		,19
		,20
		,21
		,24
		,26
		,27
		,28
		,29
		,31
	)

UPDATE
	[DeliveryBackOffice].[dbo].[StatusOrder]
SET
	CatStatusTypeId = @InternalStatusId
WHERE
	StatusOrderId IN (
		1
		,2
		,4
		,5
		,11
		,12
		,14
		,15
		,22
		,23
		,25
		,30
	)