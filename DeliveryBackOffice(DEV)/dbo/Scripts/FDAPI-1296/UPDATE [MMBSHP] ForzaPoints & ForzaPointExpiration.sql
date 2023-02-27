DECLARE @AddedPointExpirationDate INT;

BEGIN TRANSACTION
BEGIN TRY

	SET @AddedPointExpirationDate = CAST(ISNULL((SELECT TOP 1 CP.[Value] FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP  WITH(NOLOCK) WHERE CP.[Name] = 'ForzaPointsExpirationDays'  COLLATE Latin1_General_CI_AI ), 0) AS INT);

	IF (ISNULL(@AddedPointExpirationDate, 0 ) = 0)
	BEGIN
		;THROW 50000, 'ERROR CONTROLADO - NO HAY DÍAS DE EXPIRACIÓN DE PUNTOS FORZA', 1;
	END

	UPDATE [MMBSHP]
	SET
		[MMBSHP].[AvailablePoints] = 0,
		[MMBSHP].[AccumulatedPoints] = 0,
		[MMBSHP].[PointsExpirationDate] = DATEADD(DAY, @AddedPointExpirationDate, [MMBSHP].[ExpirationDate])
	FROM
		[DeliveryBackOffice].[dbo].[Membership] MMBSHP  WITH(NOLOCK) 
	WHERE
		[MMBSHP].[AvailablePoints] IS NULL
		OR
		[MMBSHP].[PointsExpirationDate] IS NULL

	COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH