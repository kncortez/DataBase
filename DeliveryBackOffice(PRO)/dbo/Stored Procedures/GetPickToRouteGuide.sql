
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-29>
-- Description:	< Obtención de vehículo al que pertenece una guía asignada en un manifiesto, con el cambio de estado a asignado >
-- =============================================

CREATE PROCEDURE [dbo].[GetPickToRouteGuide]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece INT = 1,
	@Date DATETIME = NULL,
	@IsOnlyVerify BIT = 0,
	@Token NVARCHAR(50)
AS
BEGIN
	-- Manejo de fecha 
	IF(@Date IS NULL)
	BEGIN
		SET @Date = DATEADD(HOUR,3,GETDATE()); -- A fecha actual adicionar 3 horas
	END

	--- Variables para manejo de preparación de ruta
	DECLARE @IdRoutePreparationDetail INT;
	DECLARE @IdRoutePreparationDetailPiece INT;

	DECLARE @PieceExists BIT;
	DECLARE @PieceType BIT = 1;

	DECLARE @VehicleAssigned NVARCHAR(50) = '';
	DECLARE @DateAssigned DATE = NULL;

	BEGIN TRY

		-- Verificar que exista la pieza bajo la guía
		SELECT
			@PieceExists = 1,
			@PieceType = IIF(DOP.IsDry = 1, 1, 0)
		FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
		ON
			DO.Guide_Serie = DOP.GuideSerie
			AND
			DO.Guide_Number = DOP.GuideNumber
		WHERE
			DO.Guide_Serie = @GuideSerie
			AND
			DO.Guide_Number = @GuideNumber
			AND
			DOP.NoPiece = @GuidePiece

		IF (@PieceExists IS NOT NULL AND @PieceExists = 1)
		BEGIN

			-- Proceder a realizar el cambio de estado
			DECLARE @IsAssigned BIT;
			DECLARE @LastAssignment DATE;

			SELECT TOP 1
				@IsAssigned = 1,
				@LastAssignment = RP.DateRoutePreparation 
			FROM
				[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
				JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
				ON
					RPD.RoutePreparationId = RP.IdRoutePreparation
					AND
					RP.RowStatus = 1
			WHERE
				RPD.Guide_Serie = @GuideSerie
				AND
				RPD.Guide_Number = @GuideNumber
			ORDER BY
				RP.DateRoutePreparation DESC

			IF( @IsAssigned IS NOT NULL AND @IsAssigned = 1 AND CAST(@LastAssignment AS DATE) = CAST(@Date AS DATE) )
			BEGIN

				SELECT TOP 1
					@VehicleAssigned = CR.CodeRoute,
					@DateAssigned = RP.DateRoutePreparation,
					@IdRoutePreparationDetail = RPD.IdRoutePreparationDetail
				FROM
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
					JOIN
						[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
					ON
						RPD.RoutePreparationId = RP.IdRoutePreparation
						AND
						RP.RowStatus = 1
					JOIN
						[DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
					ON
						RP.CatRouteId = CR.IdRoute
					WHERE
						RPD.Guide_Serie = @GuideSerie
						AND
						RPD.Guide_Number = @GuideNumber
						AND
						RPD.RowStatus = 1

				IF (@VehicleAssigned <> '' AND @IdRoutePreparationDetail IS NOT NULL AND @IsOnlyVerify = 0)
				BEGIN

					--- Verificar si existe la pieza de la guía dentro del detalle de la preparación de la ruta
					SELECT
						@IdRoutePreparationDetailPiece = RPDP.PieceNumber
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
						JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
							ON
							RP.IdRoutePreparation = RPD.RoutePreparationId
						JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
							ON
							RPD.IdRoutePreparationDetail = RPDP.RoutePreparationDetailId
					WHERE
						RPDP.PieceNumber = @GuidePiece
						AND
						RPDP.RowStatus = 1
						AND
						RPD.Guide_Serie = @GuideSerie
						AND
						RPD.Guide_Number = @GuideNumber
						AND
						RPD.RowStatus = 1
						AND
						RPD.IdRoutePreparationDetail = @IdRoutePreparationDetail
						AND 
						RP.RowStatus = 1
						
					BEGIN TRANSACTION
					BEGIN TRY
						IF(@IdRoutePreparationDetailPiece IS NULL OR @IdRoutePreparationDetailPiece = 0)
						BEGIN

							INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
									(
										[RoutePreparationDetailId]
										,[PieceNumber]
										,[PieceType]
										,[RowStatus]
										,[TokenCreated]
										,[DateCreated]
								)
								VALUES (
										@IdRoutePreparationDetail
										,@GuidePiece
										,IIF(@PieceType = 1, 1, 0)
										,1
										,@Token
										,GETDATE()
								)

						END

						--- Actualizar el estado de la guía
						UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
						SET
							StatusOrderId = 3 --- Programado para entrega
						WHERE
							Guide_Serie = @GuideSerie
							AND
							Guide_Number = @GuideNumber

						--- Insertar el nuevo estado a bitácora
						INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (
							[Guide_Serie], 
							[Guide_Number], 
							[StatusOrderId], 
							[UserCreated], 
							[DateCreated], 
							[DateCreatedInSystem]
						)
						SELECT 
							@GuideSerie,
							@GuideNumber,
							3,
							@Token,
							GETDATE(),
							GETDATE()
						WHERE NOT EXISTS (
							SELECT 1
							FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] WITH(NOLOCK)
							WHERE 
								StatusOrderId = 3
								AND
								Guide_Serie = @GuideSerie 
								AND
								Guide_Number = @GuideNumber
								AND
								CAST(DateCreated AS DATE) = CAST(GETDATE() AS DATE)
						)

						--- Actualziar el estado de la pieza
						UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
						SET
							StatusOrderId = 3 --- Programado para entrega
						WHERE
							GuideSerie = @GuideSerie
							AND
							GuideNumber = @GuideNumber
							AND
							NoPiece = @GuidePiece
								
						DECLARE @UpdatedWarehouseByPiece INT = 0

						--- Actualizar la posición del inventario
						UPDATE [DeliveryBackOffice].[dbo].[Warehouse] 
						SET 
							Active = 0
							,UserUpdated = @Token
							,DateUpdated = Getdate()
						Where 
							Guide_Serie = @GuideSerie
							AND
							Guide_Number = @GuideNumber
							AND
							Guide_Piece = @GuidePiece

						SET @UpdatedWarehouseByPiece = @@ROWCOUNT

						-- verificar si se actualizo a nivel de pieza
						IF ( @UpdatedWarehouseByPiece = 0)
						BEGIN
							-- No se actualizo a nivel de pieza, no existe registro en warehouse a nivel de pieza
								
							--- Actualizar la posición del inventario a nivel de guía
							UPDATE [DeliveryBackOffice].[dbo].[Warehouse] 
							SET 
								Active = 0
								,UserUpdated = @Token
								,DateUpdated = Getdate()
							Where 
								Guide_Serie = @GuideSerie
								AND
								Guide_Number = @GuideNumber
								AND
								Active = 1
						END

						COMMIT TRANSACTION
					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION
					END CATCH

					
				END

			END
			ELSE
			BEGIN
				SELECT
					404 'IdResult',
					CONCAT(@GuideSerie,@GuideNumber,' no esta asignada para el día de hoy, revise la información de las rutas.') 'Description'
				-- ROLLBACK TRANSACTION
			END

		END
		ELSE
		BEGIN
			SELECT
				404 'IdResult',
				CONCAT('Pieza: ',@GuidePiece,', no existe bajo guía proporcionada: ',@GuideSerie,@GuideNumber,'.') 'Description'
		END
	END TRY
	BEGIN CATCH
		SELECT
			0 'IdResult',
			ERROR_MESSAGE() 'Description'
	END CATCH
	IF ( @VehicleAssigned <> '' )
	BEGIN
		SELECT 
			@VehicleAssigned 'VehículoAsignado',
			CONVERT(NVARCHAR, @DateAssigned, 103) 'FechaAsignado',
			200 'IdResult',
			'Guía fue asignada.' 'Description'
	END
	ELSE
	BEGIN
		SELECT
			0 'IdResult',
			'No se pudo obtener el vehículo asignado a entregar la guía.' 'Description'
	END
END