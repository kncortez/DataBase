
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-11-12>
-- Description:	< Retorno de datos desde Simpliroute, cambiando de estado las guías procesadas y generando el manifiesto del servicio y la asociación correspondiente >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-02>
-- Description:	< Actualizado para manejo de rutas "virtuales" como vehículos >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-11>
-- Description:	< Actualizado para no insertar el estado "Programado para entrega" >
-- =============================================
CREATE PROCEDURE [dbo].[SetDispatchDataFromSimpliroute]
		@GuidesTable TblExtPlatSimplirouteVisit READONLY,
		@ExternalPlatform INT,
		@RoutePlatform NVARCHAR(50),
		@CouriermanDPI NVARCHAR(50) = '',
		@VehicleCode NVARCHAR(50), -- De lado de Simpliroute proviene el codigo de una ruta "virtual"
		@RouteDispatched NVARCHAR(50) = '',
		@GuideQuantity INT,
		@PiecesDryDispatched INT,
		@PiecesColdDispatched INT,
		@DateOfEvent DATETIME = NULL,
		@Token NVARCHAR(50) = 'SYS-HERMESROUTES',
		@StationId INT = NULL
AS
BEGIN
	IF (@DateOfEvent IS NULL)
	BEGIN
		SET @DateOfEvent = CAST(GETDATE() AS date)
	END
	-- CONTROL DE INSERCIÓN DE PREPARACIÓN DE RUTA
	DECLARE @IdRoutePreparation INT = 0;
	DECLARE @RModified INT = 0;
	DECLARE @UpdatedDetail INT = 0;
	DECLARE @ColdUpdate INT = 0;

	DECLARE @IdCourier INT = NULL
	-- DECLARE @IdVehicle INT = NULL
	DECLARE @IdRoute INT = NULL;

	DECLARE @IdExtPlatRoute INT = 0;

	-- SET @IdVehicle = (SELECT TOP 1 CV.IdVehicle FROM DeliveryBackOffice.dbo.CatVehicle CV WHERE CV.UnitNumber = @VehicleCode);
	SET @IdRoute = (SELECT TOP 1 CR.IdRoute FROM DeliveryBackOffice.dbo.CatRoute CR WHERE CR.CodeRoute = @VehicleCode);

	-- StatudId = Asignado
	-- DECLARE @StatusId INT = (SELECT TOP 1 SO.StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder SO WHERE SO.OrderDescription = 'Asignado');

	-- Variables para manejo de piezar del detalle de la preparación de ruta
	DECLARE @RoutePreparationDetails AS TABLE (
		IdRoutePreparationDetail INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT
	)


	BEGIN TRANSACTION
		BEGIN TRY
			-- REVISAR POR EXISTENCIA DE RUTA O GENERARLA

			DECLARE @RouteExists BIT;
			DECLARE @IsRouteDispatched BIT;

			SELECT 
				@RouteExists = 1,
				@IsRouteDispatched = RP.DeliveryOrderBySettlementId,
				@IdRoutePreparation = RP.IdRoutePreparation
			FROM 
				[DeliveryBackOffice].[dbo].[RoutePreparation] RP 
			WHERE 
				RP.CatRouteId = @IdRoute 
				AND 
				CAST(RP.DateCreated AS DATE) = CAST(@DateOfEvent AS DATE)
				AND
				RP.RowStatus = 1

			IF ( @RouteExists IS NULL )
			BEGIN
				-- GENERAR LA PREPARACIÓN DE RUTA
				
				INSERT INTO [dbo].[RoutePreparation]
						   ([DateRoutePreparation]
						   ,[GuidesQuantity]
						   ,[PiecesDry]
						   ,[PiecesCold]
						   ,[RowStatus]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[TokenUpdated]
						   ,[DateUpdated]
						   ,[CatRouteId]
						   ,[IsSimpliRoute])
					 VALUES
						   (CAST(@DateOfEvent AS DATE)
						   ,@GuideQuantity
						   ,@PiecesDryDispatched
						   ,@PiecesColdDispatched
						   ,1
						   ,@Token
						   ,GETDATE()
						   ,NULL
						   ,NULL
						   ,@IdRoute
						   ,1)

				SET @IdRoutePreparation = SCOPE_IDENTITY()
			
				IF COALESCE(@@ROWCOUNT,0) > 0
					SET @RModified = @RModified + 1

				IF @IdRoutePreparation > 0
				BEGIN

					INSERT INTO [dbo].[RoutePreparationDetail]
							   ([RoutePreparationId]
							   ,[Guide_Serie]
							   ,[Guide_Number]
							   ,[GuideOrder]
							   ,[RowStatus]
							   ,[TokenCreated]
							   ,[DateCreated]
							   ,[TokenUpdated]
							   ,[DateUpdated])
						OUTPUT inserted.IdRoutePreparationDetail, inserted.Guide_Serie, inserted.Guide_Number 
							INTO @RoutePreparationDetails(IdRoutePreparationDetail, GuideSerie, GuideNumber)
						SELECT @IdRoutePreparation, lg.GuideSerie, lg.GuideNumber, lg.[Order], 1, @Token, GETDATE(), NULL, NULL
						FROM @GuidesTable lg
						
					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1
				
					INSERT INTO [dbo].[RoutePreparationDetailPiece]
							([RoutePreparationDetailId]
							,[PieceNumber]
							,[PieceType]
							,[RowStatus]
							,[DateCreated]
							,[TokenCreated])
						SELECT
							RPDs.IdRoutePreparationDetail
							,DOP.NoPiece
							,IIF(DOP.IsDry = 1 ,1, 0)
							,1
							,GETDATE()
							,@Token
						FROM
							[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP
							JOIN
								@RoutePreparationDetails RPDs
								ON
									DOP.GuideSerie = RPDs.GuideSerie
									AND
									DOP.GuideNumber = RPDs.GuideNumber
							LEFT JOIN
								[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP
								ON
									RPDs.IdRoutePreparationDetail = RPDP.RoutePreparationDetailId
									AND
									DOP.NoPiece = RPDP.PieceNumber
									AND
									RPDP.RowStatus = 1
						WHERE
							RPDP.IdRoutePreparationDetailPiece IS NULL
							
					-- MODIFICAR GUIA PROGRAMADA PARA ENTREGA (PARA COINCIDIR CON LA TABLA HISTORICA)
					/*
					UPDATE DO
						SET StatusOrderId = 3
						FROM [dbo].[DeliveryOrder] DO
						JOIN @GuidesTable lg
							ON DO.Guide_Serie = lg.GuideSerie
							AND DO.Guide_Number = lg.GuideNumber

					-- INSERTAR CHECKPOINT INICIAL EN TABLA HISTÓRICA
					INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (
						[Guide_Serie], 
						[Guide_Number], 
						[StatusOrderId], 
						[UserCreated], 
						[DateCreated], 
						[DateCreatedInSystem]
					)
					SELECT 
						lg.GuideSerie,
						lg.GuideNumber,
						3,
						@Token,
						GETDATE(),
						GETDATE()
					FROM @GuidesTable lg	
					*/

					--- Actualziar el estado de las piezas de las guías por el reproceso
					UPDATE 
						DOP
					SET
						DOP.StatusOrderId = NULL --- Programado para entrega
					FROM
						@GuidesTable lg	
						JOIN
							[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP
							ON
								DOP.GuideNumber = lg.GuideNumber
								AND
								DOP.GuideSerie = lg.GuideSerie

					-- Deshabilitar filas si ya existieran en otra ruta
					UPDATE rpd
					SET rpd.RowStatus = 0,
						rpd.TokenUpdated = @Token,
						rpd.DateUpdated = GETDATE()
					FROM  RoutePreparationDetail rpd
					JOIN RoutePreparation rp 
						ON rpd.RoutePreparationId = rp.IdRoutePreparation
					JOIN @GuidesTable lg
						ON rpd.Guide_Serie = lg.GuideSerie AND rpd.Guide_Number = lg.GuideNumber
					WHERE rp.DateRoutePreparation = CAST(@DateOfEvent AS DATE) AND rp.IdRoutePreparation <> @IdRoutePreparation

					-- UPDATE DE TABLA DE SERVICIOS DE PLATAFORMA EXTERNA
					UPDATE EPS
					SET 
						EPS.[Plan] = GT.[Plan],
						EPS.[Route] = GT.[Route],
						EPS.[Order] = GT.[Order],
						EPS.[Driver] = GT.[driver],
						EPS.[Vehicle] = GT.[vehicle],
						EPS.[IsIncluded] = GT.[IsIncluded],
						EPS.[EstimatedTimeArrival] = GT.[EstimatedTimeArrival],
						EPS.[TokenUpdated] = @Token,
						EPS.[DateUpdated] = GETDATE()
					FROM DeliveryBackOffice.dbo.ExtPlatformService EPS
					JOIN
					@GuidesTable GT
					ON
					EPS.IdService = GT.IdService
				END
			END
			ELSE
			BEGIN
				-- EXISTE LA PREPARACIÓN DE RUTA
				IF( @IsRouteDispatched IS NULL )
				BEGIN
					DECLARE @NewAdded TABLE (
						IdRoutePreparationDetail INT,
						GuideSerie NVARCHAR(2),
						GuideNumber INT,
						GuideDry INT,
						GuideCold INT
					)
				
					INSERT INTO [dbo].[RoutePreparationDetail]
								([RoutePreparationId]
								,[Guide_Serie]
								,[Guide_Number]
								,[RowStatus]
								,[TokenCreated]
								,[DateCreated]
								,[TokenUpdated]
								,[DateUpdated]
								,[GuideOrder])
						OUTPUT inserted.IdRoutePreparationDetail, inserted.Guide_Serie, inserted.Guide_Number, 0, 0 INTO @NewAdded(IdRoutePreparationDetail, GuideSerie, GuideNumber, GuideDry, GuideCold)
						SELECT @IdRoutePreparation, lg.GuideSerie, lg.GuideNumber, 1, @Token, GETDATE(), NULL, NULL, lg.[Order]
						FROM @GuidesTable lg
						WHERE NOT EXISTS (
							SELECT 1
							FROM RoutePreparationDetail
							WHERE RoutePreparationId = @IdRoutePreparation
								AND Guide_Serie = lg.GuideSerie AND Guide_Number = lg.GuideNumber
								AND RowStatus = 1
						)
						
					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @UpdatedDetail = @UpdatedDetail + 1

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1

					INSERT INTO [dbo].[RoutePreparationDetailPiece]
							([RoutePreparationDetailId]
							,[PieceNumber]
							,[PieceType]
							,[RowStatus]
							,[DateCreated]
							,[TokenCreated])
						SELECT
							NA.IdRoutePreparationDetail
							,DOP.NoPiece
							,IIF(DOP.IsDry = 1 ,1, 0)
							,1
							,GETDATE()
							,@Token
						FROM
							[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP
							JOIN
								@NewAdded NA
								ON
									DOP.GuideSerie = NA.GuideSerie
									AND
									DOP.GuideNumber = NA.GuideNumber
							LEFT JOIN
								[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP
								ON
									RPDP.RoutePreparationDetailId = NA.IdRoutePreparationDetail
									AND
									DOP.NoPiece = RPDP.PieceNumber
									AND
									RPDP.RowStatus = 1
						WHERE
							RPDP.IdRoutePreparationDetailPiece IS NULL
							
					-- Reconfigurar orden por si sufrío cambíos
					UPDATE RPD
					SET
						RPD.GuideOrder = GT.[Order]
					FROM 
						[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
						JOIN @GuidesTable GT
							ON 
							RPD.Guide_Serie = GT.GuideSerie
							AND
							RPD.Guide_Number = GT.GuideNumber
							AND
							RPD.RowStatus = 1
					WHERE
						RPD.RoutePreparationId = @IdRoutePreparation

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @ColdUpdate = @ColdUpdate + 1

					IF(@UpdatedDetail > 0)
					BEGIN
					
						UPDATE @NewAdded
						SET 
							GuideDry = DO.Pieces_Dry,
							GuideCold = DO.Pieces_Cold
						FROM @NewAdded NA
						JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO
						ON DO.Guide_Serie = NA.GuideSerie
						AND DO.Guide_Number = NA.GuideNumber

						DECLARE @NewGuideQuantity INT = (SELECT COUNT(*) FROM @NewAdded);
						DECLARE @NewPiecesDryDispatched INT = (SELECT SUM(GuideDry) FROM @NewAdded);
						DECLARE @NewPiecesColdDispatched INT = (SELECT SUM(GuideCold) FROM @NewAdded);

						UPDATE [dbo].[RoutePreparation]
						SET [GuidesQuantity] = [GuidesQuantity] + @NewGuideQuantity
							  ,[PiecesDry] = [PiecesDry] + @NewPiecesDryDispatched
							  ,[PiecesCold] = [PiecesCold] + @NewPiecesColdDispatched
							  ,[TokenUpdated] = @Token
							  ,[DateUpdated] = GETDATE()
						WHERE IdRoutePreparation = @IdRoutePreparation

						IF COALESCE(@@ROWCOUNT,0) > 0
							SET @RModified = @RModified + 1

						-- MODIFICAR GUIA PROGRAMADA PARA ENTREGA (PARA COINCIDIR CON LA TABLA HISTORICA)
						/*
						UPDATE DO
							SET StatusOrderId = 3
							FROM [dbo].[DeliveryOrder] DO
							JOIN @GuidesTable lg
								ON DO.Guide_Serie = lg.GuideSerie
								AND DO.Guide_Number = lg.GuideNumber

						-- INSERTAR CHECKPOINT INICIAL EN TABLA HISTÓRICA
						INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (
							[Guide_Serie], 
							[Guide_Number], 
							[StatusOrderId], 
							[UserCreated], 
							[DateCreated], 
							[DateCreatedInSystem]
						)
						SELECT 
							lg.GuideSerie,
							lg.GuideNumber,
							3,
							@Token,
							GETDATE(),
							GETDATE()
						FROM @GuidesTable lg	
						WHERE NOT EXISTS (
							SELECT 1
							FROM RoutePreparationDetail
							WHERE RoutePreparationId = @IdRoutePreparation
								AND Guide_Serie = lg.GuideSerie AND Guide_Number = lg.GuideNumber
						)
						*/

						--- Actualziar el estado de las piezas de las guías por el reproceso
						UPDATE 
							DOP
						SET
							DOP.StatusOrderId = NULL --- Programado para entrega
						FROM
							@GuidesTable lg	
							JOIN
								[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP
								ON
									DOP.GuideNumber = lg.GuideNumber
									AND
									DOP.GuideSerie = lg.GuideSerie

						-- Deshabilitar filas si ya existieran en otra ruta
						UPDATE rpd
						SET rpd.RowStatus = 0,
							rpd.TokenUpdated = @Token,
							rpd.DateUpdated = GETDATE()
						FROM  RoutePreparationDetail rpd
						JOIN RoutePreparation rp 
							ON rpd.RoutePreparationId = rp.IdRoutePreparation
						JOIN @GuidesTable lg
							ON rpd.Guide_Serie = lg.GuideSerie AND rpd.Guide_Number = lg.GuideNumber
						WHERE rp.DateRoutePreparation = CAST(@DateOfEvent AS DATE) AND rp.IdRoutePreparation <> @IdRoutePreparation
					END

				END
			END
		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF ( @RModified >= 2 OR @ColdUpdate > 0 )
			BEGIN
				SELECT			  
					@IdRoutePreparation AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
				COMMIT TRANSACTION;		
			END
			ELSE
			BEGIN
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					@RModified AS 'NumTransferID'
				ROLLBACK TRANSACTION
			END
		END
		ELSE
		BEGIN
			SELECT 
				0 AS 'StatusCode', 
				'Transacción no se realizo correctamente' AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END
	--END TRANSACTION
END
