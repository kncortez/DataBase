
-- =============================================
-- Author:		<Andrés Ruíz>
-- Create date: <2023-06-05>
-- Description:	< Procesa ubicaciones de vehiculos y guarda a nivel de base de datos >
-- =============================================
CREATE PROCEDURE [dbo].[spHS_SetMassVehicleLocation]
	-- Add the parameters for the stored procedure here
	@VehicleLocation TblCourierLocation READONLY
	,@Token NVARCHAR(50)

AS
BEGIN
	
	-- Tabla para procesar ubicaciones
	DECLARE @VehicleLocationToProcess AS TABLE(
		VehicleId INT,
		VehicleLatitude NVARCHAR(20),
		VehicleLongitude NVARCHAR(20),
		LocationAccuracy NVARCHAR(50),
		LastLatitude NVARCHAR(20),
		LastLongitude NVARCHAR(20)
	);

	-- Tabla de apoyo de últimas ubicaciones en bitácora
	DECLARE @LastVehicleLocationLog AS TABLE(
		IdVehicleLog BIGINT,
		VehicleId INT,
		LastLatitude NVARCHAR(20),
		LastLongitude NVARCHAR(20)
	);

	-- Verificador de garantizado de nueva ubicación registrada
	DECLARE @UpdatedLocation AS TABLE
	(
		IdVehicle INT
	);
	DECLARE @LoggedLocation AS TABLE
	(
		IdVehicle INT,
		IdVehicleLog BIGINT
	);
	DECLARE @LoggedLocationDown AS TABLE
	(
		IdVehicleLog BIGINT
	);

	BEGIN TRY
	    
		INSERT INTO @VehicleLocationToProcess
		(
		    [VehicleId],
		    [VehicleLatitude],
		    [VehicleLongitude],
		    [LocationAccuracy],
			[LastLatitude],
			[LastLongitude]
		)
		SELECT 
			DISTINCT
				COALESCE([CVUnit].[IdVehicle], [CVPlate].[IdVehicle], -1) [PossibleVehicleId]
				,[VL].[CourierLatitude]
				,[VL].[CourierLongitude]
				,NULL
				,COALESCE([CVUnit].[LastLatitude], [CVPlate].[LastLatitude], '') [LastLatitude]
				,COALESCE([CVUnit].[LastLongitude], [CVPlate].[LastLongitude], '') [LastLongitude]
		FROM
			@VehicleLocation VL
			-- Por código de unidad
			LEFT JOIN 
				[DeliveryBackOffice].[dbo].[CatVehicle] CVUnit
				ON
					[VL].[CourierPhone] = [CVUnit].[UnitNumber]  COLLATE Latin1_General_CI_AI 
			-- Por placa de vehículo
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatVehicle] CVPlate
				ON
					[VL].[VehicleTypeDescription] = [CVPlate].[Plate]  COLLATE Latin1_General_CI_AI 

		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @VehicleLocationToProcess ) )
		BEGIN
		    ;THROW 50000, 'No se tienen datos de ubicación para procesar dado a una mala relación de los datos registrados.', 1;
		END

		INSERT INTO @LastVehicleLocationLog
		(
			[IdVehicleLog],
		    [VehicleId],
		    [LastLatitude],
		    [LastLongitude]
		)
		SELECT 
			[VLL].[IdVehicleLocationLog]
			,[VLL].[VehicleId]
			,[VLL].[LocationLatitude]
			,[VLL].[LocationLongitude]
		FROM
			[DeliveryBackOffice].[dbo].[VehicleLocationLog] VLL  WITH(NOLOCK) 
		WHERE
			[VLL].[RowStatus] = 1
		ORDER BY
			[VLL].[DateCreated] DESC

		BEGIN TRANSACTION 
		BEGIN TRY

			UPDATE
				[CV]
			SET
				[CV].[LastLatitude] = [VLTP].[VehicleLatitude]
				,[CV].[LastLongitude] = [VLTP].[VehicleLongitude]
				,[CV].[DateUpdated] = GETDATE()
				,[CV].[TokenUpdated] = @Token
			OUTPUT [Inserted].[IdVehicle] INTO @UpdatedLocation ([IdVehicle])
			FROM
				[DeliveryBackOffice].[dbo].[CatVehicle] CV  WITH(NOLOCK) 
				INNER JOIN
					@VehicleLocationToProcess VLTP 
					ON
						[CV].[IdVehicle] = [VLTP].[VehicleId]
				LEFT JOIN
					@LastVehicleLocationLog LVL
					ON
						[CV].[IdVehicle] = [LVL].[VehicleId]
						AND
						[VLTP].[VehicleLatitude] = [LVL].[LastLatitude]
						AND
						[VLTP].[VehicleLongitude] = [LVL].[LastLongitude]
			WHERE
				[LVL].[IdVehicleLog] IS NULL

			IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @UpdatedLocation ) )
			BEGIN
			    ;THROW 50000, 'NO se actualizo ningun registro, todas las ubicaciones son la misma.', 1;
			END
			
			-- Inactivar aquellos cuya ubicación fue actualizada
			UPDATE
				[VLL]
			SET
				[VLL].[RowStatus] = 0
				,[VLL].[DateUpdated] = GETDATE()
				,[VLL].[TokenUpdated] = @Token
			OUTPUT [Inserted].[IdVehicleLocationLog] INTO @LoggedLocationDown ([IdVehicleLog])
			FROM
				[DeliveryBackOffice].[dbo].[VehicleLocationLog] VLL  WITH(NOLOCK) 
				INNER JOIN
					@UpdatedLocation UL
					ON
						[VLL].[VehicleId] = [UL].[IdVehicle]
			WHERE
				[VLL].[RowStatus] = 1

			INSERT INTO [DeliveryBackOffice].[dbo].[VehicleLocationLog]
			(
			    [VehicleId],
			    [LocationAccuracy],
			    [LocationLatitude],
			    [LocationLongitude],
			    [RowStatus],
			    [DateCreated],
			    [TokenCreated]
			)
			OUTPUT [Inserted].[VehicleId], [Inserted].[IdVehicleLocationLog] INTO @LoggedLocation ([IdVehicle], [IdVehicleLog])
			SELECT 
				[VLTP].[VehicleId]
				,NULL
				,[VLTP].[VehicleLatitude]
				,[VLTP].[VehicleLongitude]
				,1
				,GETDATE()
				,@Token
			FROM
				@VehicleLocationToProcess VLTP
				INNER JOIN
					@UpdatedLocation UL
					ON
						[VLTP].[VehicleId] = [UL].[IdVehicle]

			IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @LoggedLocation ) )
			BEGIN
			    ;THROW 50000, 'No se ingresaron datos historicos de ubicación', 2;
			END

			IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @LoggedLocationDown ) AND EXISTS ( SELECT TOP 1 1 FROM @LastVehicleLocationLog ))
			BEGIN
			    ;THROW 50000, 'No se dieron de baja ubicaciones historicas anteriores', 2;
			END

			COMMIT TRANSACTION;

			SELECT
				200 [ResponseCode]
				,'Datos ingresados exitosamente' [ResponseMessage]

		END TRY
		BEGIN CATCH

			-- Manejo de errores con ROLLBACK
			ROLLBACK TRANSACTION;
	
			IF ( ERROR_STATE() IN (1,3) )
			BEGIN
				SELECT
					404 [ResponseCode],
					ERROR_MESSAGE() [ResponseMessage]
			END
			ELSE IF ( ERROR_STATE() = 2 )
			BEGIN
				SELECT
					204 [ResponseCode],
					ERROR_MESSAGE() [ResponseMessage]
			END
			ELSE
			BEGIN
				SELECT
					500 [ResponseCode],
					ERROR_MESSAGE() [ResponseMessage]
			END
		    
		END CATCH

	END TRY
	BEGIN CATCH
	
		-- Manejo de errores sin ROLLBACK
		IF ( ERROR_STATE() IN (1,3) )
		BEGIN
			SELECT
				404 [ResponseCode],
				ERROR_MESSAGE() [ResponseMessage]
		END
		ELSE IF ( ERROR_STATE() = 2 )
		BEGIN
			SELECT
				204 [ResponseCode],
				ERROR_MESSAGE() [ResponseMessage]
		END
		ELSE
		BEGIN
			SELECT
				500 [ResponseCode],
				ERROR_MESSAGE() [ResponseMessage]
		END
	    
	END CATCH

END