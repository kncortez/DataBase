--CLONAR PARA TARIFARIO ALTERNATIVO
SELECT * FROM DeliveryBackOffice.dbo.RateData
where RateId = 2286

DECLARE @RateId INT
DECLARE @TypeServiceId INT
DECLARE @TypeSegmentId INT
DECLARE @HubSourceId INT
DECLARE @HubDestinyId INT
DECLARE @ArticleId INT
DECLARE @RateValue DECIMAL(14,2)
DECLARE @RowStatus BIT
DECLARE @TokenCreated VARCHAR(50)
DECLARE @DateCreated DATETIME
DECLARE @TokenUpdated VARCHAR(50)
DECLARE @DateUpdated DATETIME
DECLARE @LimitHourDelivery TIME(7)
DECLARE @LimitHourPickup TIME(7)
DECLARE @WeightFrom DECIMAL(12,2)
DECLARE @WeightTo DECIMAL(12,2)
DECLARE @PackagesFrom INT
DECLARE @PackagesTo INT

DECLARE cur CURSOR FOR
SELECT [RateId]
      ,[TypeServiceId]
      ,[TypeSegmentId]
      ,[HubSourceId]
      ,[HubDestinyId]
      ,[ArticleId]
      ,[RateValue]
      ,[RowStatus]
      ,[TokenCreated]
      ,[DateCreated]
      ,[TokenUpdated]
      ,[DateUpdated]
      ,[LimitHourDelivery]
      ,[LimitHourPickup]
      ,[WeightFrom]
      ,[WeightTo]
      ,[PackagesFrom]
      ,[PackagesTo]
FROM RateData
WHERE RateId = 2286

OPEN cur

FETCH NEXT FROM cur INTO @RateId, @TypeServiceId, @TypeSegmentId, @HubSourceId, @HubDestinyId, @ArticleId, @RateValue, @RowStatus, @TokenCreated, @DateCreated, @TokenUpdated, @DateUpdated, @LimitHourDelivery, @LimitHourPickup, @WeightFrom, @WeightTo, @PackagesFrom, @PackagesTo

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Aquí puedes modificar los valores de las variables según tus necesidades
    SET @RateId = 3676  -- Ejemplo de modificación
    SET @RateValue = @RateValue * 3  -- Ejemplo de modificación
    SET @TokenCreated = 'SYS-WOROZCO'
    SET @DateCreated = '2024-06-13 12:15:00.000'
    SET @TokenUpdated = NULL
    SET @DateUpdated = NULL

    -- Insertar en la tabla
    INSERT INTO [dbo].[RateData]
           ([RateId]
           ,[TypeServiceId]
           ,[TypeSegmentId]
           ,[HubSourceId]
           ,[HubDestinyId]
           ,[ArticleId]
           ,[RateValue]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[LimitHourDelivery]
           ,[LimitHourPickup]
           ,[WeightFrom]
           ,[WeightTo]
           ,[PackagesFrom]
           ,[PackagesTo])
     VALUES
           (@RateId
           ,@TypeServiceId
           ,@TypeSegmentId
           ,@HubSourceId
           ,@HubDestinyId
           ,@ArticleId
           ,@RateValue
           ,@RowStatus
           ,@TokenCreated
           ,@DateCreated
           ,@TokenUpdated
           ,@DateUpdated
           ,@LimitHourDelivery
           ,@LimitHourPickup
           ,@WeightFrom
           ,@WeightTo
           ,@PackagesFrom
           ,@PackagesTo)

    FETCH NEXT FROM cur INTO @RateId, @TypeServiceId, @TypeSegmentId, @HubSourceId, @HubDestinyId, @ArticleId, @RateValue, @RowStatus, @TokenCreated, @DateCreated, @TokenUpdated, @DateUpdated, @LimitHourDelivery, @LimitHourPickup, @WeightFrom, @WeightTo, @PackagesFrom, @PackagesTo
END

CLOSE cur
DEALLOCATE cur

SELECT TypeSegmentId FROM DeliveryBackOffice.dbo.RateData
where RateId = 3676

SELECT * FROM DeliveryBackOffice.dbo.CatRateSegment

-- Actualiza los valores de TypeSegmentId
UPDATE DeliveryBackOffice.dbo.RateData
SET TypeSegmentId = 
    CASE 
        WHEN TypeSegmentId = 1 THEN 14
        WHEN TypeSegmentId = 2 THEN 15
        WHEN TypeSegmentId = 3 THEN 16
        WHEN TypeSegmentId = 4 THEN 17
        WHEN TypeSegmentId = 5 THEN 18
        WHEN TypeSegmentId = 6 THEN 19
        WHEN TypeSegmentId = 7 THEN 20
        WHEN TypeSegmentId = 8 THEN 21
        WHEN TypeSegmentId = 9 THEN 22
        WHEN TypeSegmentId = 10 THEN 23
        WHEN TypeSegmentId = 11 THEN 24
        WHEN TypeSegmentId = 12 THEN 25
        WHEN TypeSegmentId = 13 THEN 26
        ELSE TypeSegmentId -- En caso de que no coincida, mantener el valor original
    END
WHERE TypeSegmentId IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)
AND RateId = 3676;




