DECLARE @AddedDaysToPointsExpiration INT = CAST((SELECT TOP 1 CP.[Value] FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH(NOLOCK) WHERE CP.[Name] = 'ForzaPointsExpirationDays' COLLATE Latin1_General_CI_AI) AS INT)

UPDATE [DeliveryBackOffice].[dbo].[Membership]
SET
	PointsExpirationDate = DATEADD(DAY, @AddedDaysToPointsExpiration, ExpirationDate)
	,AccumulatedPoints = ISNULL(AccumulatedPoints, 0)
	,AvailablePoints = ISNULL(AvailablePoints, 0)
WHERE
	RowStatus = 1