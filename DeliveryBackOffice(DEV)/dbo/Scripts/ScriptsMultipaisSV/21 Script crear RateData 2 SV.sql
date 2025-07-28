--CLONAR PARA TARIFARIO ALTERNATIVO
--SELECT * FROM DeliveryBackOffice.dbo.RateData
--where RateId = 2286  --EJEMPLO DEVELOP

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE @IdRateGT INT;
	DECLARE @IdRateSV INT;

	SELECT @IdRateGT = RheId FROM DeliveryBackOffice.dbo.RateHeader
	WHERE RheName = 'Tarifario destinos express center' AND CountryId = 'GT'

	SELECT @IdRateSV = RheId FROM DeliveryBackOffice.dbo.RateHeader
	WHERE RheName = 'Tarifario destinos express center' AND CountryId = 'SV'

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
	WHERE RateId = @IdRateGT

	OPEN cur

	FETCH NEXT FROM cur INTO @RateId, @TypeServiceId, @TypeSegmentId, @HubSourceId, @HubDestinyId, @ArticleId, @RateValue, @RowStatus, @TokenCreated, @DateCreated, @TokenUpdated, @DateUpdated, @LimitHourDelivery, @LimitHourPickup, @WeightFrom, @WeightTo, @PackagesFrom, @PackagesTo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Aquí puedes modificar los valores de las variables según tus necesidades
		SET @RateId = @IdRateSV  -- Ejemplo de modificación
		SET @RateValue = @RateValue / 8  -- Ejemplo de modificación
		SET @TokenCreated = 'SYS-WOROZCO'
		SET @DateCreated = GETDATE()
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

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
