-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2022-03-07>
-- Description:	< Obtiene los datos de intervalos de ejecución configurados de un servicio configurable desde base de datos >
-- =============================================
CREATE PROCEDURE [dbo].[GetConfigurableServiceExecutionTimes]
	@ConfigurableWindowsServiceId INT = -1,
	@ConfigurableWindowsServiceName NVARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Obtener ID de servicio en catálogo
	DECLARE @IdService INT = @ConfigurableWindowsServiceId;
	IF(@IdService = -1)
	BEGIN
		SET @IdService = (
			SELECT
				TOP 1
					CCS.IdCatConfigurableService
			FROM
				[DeliveryBackOffice].[dbo].[CatConfigurableService] CCS
			WHERE
				CCS.CatConfigurableServiceName = @ConfigurableWindowsServiceName 
		)
	END
	
	-- Variables de control de intervalos
	DECLARE @StartingTime TIME = '00:00:00';
	DECLARE @FinishingTime TIME = '00:00:00';
	DECLARE @TimeStep INT = 0;

	-- Variables de control de flujo de intervalos
	DECLARE @TimeDifference INT = 0;
	DECLARE @PosibleSteps INT = 0;

	-- Variable de almacenamiento de intervalos
	DECLARE @TimeStepArray AS TABLE (
		StepTime TIME NOT NULL
	)

	-- Variables de retorno de datos
	DECLARE @StepsAsString NVARCHAR(MAX) = ''

	-- Procesamiento de intervalos
	SELECT
		@StartingTime = ISNULL(STC.StartingTime,'00:00:00')
		,@FinishingTime = ISNULL(STC.FinishingTime,'00:00:00')
		,@TimeStep = ISNULL(STC.TimeStep,0)
	FROM
		[DeliveryBackOffice].[dbo].[ServiceTimeConfiguration] STC
	WHERE
		STC.CatConfigurableServiceId = @IdService
		AND
		STC.RowStatus = 1

	IF(@IdService > -1 AND @TimeStep > 0)
	BEGIN
		IF(@StartingTime <= @FinishingTime)
		BEGIN
			SET @TimeDifference = DATEDIFF(MINUTE, @StartingTime, @FinishingTime)

			IF(@TimeDifference >= @TimeStep)
			BEGIN
				SET @PosibleSteps = FLOOR(@TimeDifference / @TimeStep)
				IF(@PosibleSteps > 0)
				BEGIN
					-- Es posible añadir minimo 1 paso intermedio entre la hora de inicio y de finalización
					DECLARE @Counter INT = 1;
					-- Generar intervalos
					BEGIN TRY
			
						-- Añadir tiempo inicial del intervalo
						INSERT INTO @TimeStepArray
						SELECT @StartingTime

						DECLARE @LastStepTime TIME = @StartingTime
						DECLARE @StepTime TIME

						WHILE ( @Counter <= @PosibleSteps )
						BEGIN
							-- Generador de intervalos
							SET @StepTime = DATEADD(MINUTE, @TimeStep, @LastStepTime)
					
							INSERT INTO @TimeStepArray
							SELECT @StepTime
					
							SET @LastStepTime = @StepTime
							SET @Counter = @Counter + 1;
						END
					
						-- Añadir tiempo final del intervalo asdasdasd
						IF(NOT EXISTS (SELECT 1 FROM @TimeStepArray TSA WHERE TSA.StepTime = @FinishingTime ))
						BEGIN
							INSERT INTO @TimeStepArray
							SELECT @FinishingTime
						END

						SET @StepsAsString = 
						(
							SELECT STUFF
							(
								( 
									SELECT  
										','+ CONVERT(NVARCHAR, TSA.StepTime, 108)
									FROM @TimeStepArray TSA
									FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
							) 
						)
					END TRY
					BEGIN CATCH
						PRINT 'FAILED CREATING RANGE'
						SELECT
							@StepsAsString = CONCAT(CONVERT(NVARCHAR, @StartingTime, 108),', ',CONVERT(NVARCHAR, @FinishingTime, 108))
					END CATCH
				END
			END
			ELSE IF (@StartingTime = @FinishingTime)
			BEGIN
				SELECT 
					@StepsAsString = CONVERT(NVARCHAR, @StartingTime, 108)
			END
			ELSE
			BEGIN
				-- No es posible añadir un paso intermedio entre la hora de inicio y de finalización
				SELECT
					@StepsAsString = CONCAT(CONVERT(NVARCHAR, @StartingTime, 108),', ',CONVERT(NVARCHAR, @FinishingTime, 108))
			END
		END
	END
	
	IF(ISNULL(@StepsAsString,'') = '' OR @StartingTime = '00:00:00')
		SET @StepsAsString = '00:00:00'

	SELECT
		@StepsAsString 'Intervalos'
END

