
------------------------------------------------------------------------------------------------
-------------------------------------------!IMPORTANTE------------------------------------------
------------------------------------------------------------------------------------------------
/*
Los datos insertados en l tabla ratedata son de prueba, verificar los valores a insertar
Los datos de la rateheader si seran los correcto
*/

------------------------------------------------------------------------------------------------
--CLONAR PARA TARIFARIO
--SELECT * FROM DeliveryBackOffice.dbo.RateData
--where RateId = 2285 --EJEMPLO DEVELOP GT

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE @IdRateGT INT;
	DECLARE @IdRateHN INT;

	SELECT @IdRateGT = RheId FROM DeliveryBackOffice.dbo.RateHeader
	WHERE RheName = 'Tarifario de servicio estandar' AND CountryId = 'GT'

	SELECT @IdRateHN = RheId FROM DeliveryBackOffice.dbo.RateHeader
	WHERE RheName = 'Tarifario de servicio estandar' AND CountryId = 'HN'

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
		-- Aqu� puedes modificar los valores de las variables seg�n tus necesidades
		SET @RateId = @IdRateHN 
		SET @RateValue = @RateValue * 3 --le aumentamos 3 por la equivalencia 1Q = 3L
		SET @TokenCreated = 'SYS-WOROZCO'
		SET @DateCreated = '2024-08-13 11:15:00.000'
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
