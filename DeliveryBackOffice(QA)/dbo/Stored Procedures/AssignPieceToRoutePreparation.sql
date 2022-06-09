
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-18>
-- Description:	< Asignación por pieza a RoutePreparation .>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-02>
-- Description:	< Cambio para uso de Ruta sobre Unidad .>
-- =============================================

CREATE PROCEDURE [dbo].[AssignPieceToRoutePreparation]
	@IdRoute INT,
	@Date DATE,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece INT,
	@GuidePieceType BIT = 1, --- 1 = Pieza seca | 0 = Pieza fría
	@Token NVARCHAR(50)
AS
BEGIN
	--- Conteo para verificar cantidad correcta de validaciones
	DECLARE @RModified INT = 0

	--- Variables para manejo de preparación de ruta
	DECLARE @IdManifest INT;
	DECLARE @IdRoutePreparation INT;
	DECLARE @IdRoutePreparationDetail INT;
	DECLARE @IdRoutePreparationDetailPiece INT;
	
	--- Variables para manejo de piezas
	DECLARE @GuidePieceExists BIT;

	--- Variables para despliegue de errores
	DECLARE @GuidePieceDoesntExist BIT = 0;
	DECLARE @GuidePieceAlreadyExists BIT = 0;
	DECLARE @FatalError INT = 0;

	--- Variable para devolución de datos ingresados
	DECLARE @ResponseTable TABLE (
		IdRoutePreparation INT,
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		GuidePiece INT,
		GuidePieceType BIT,
		GuidePieces INT,
		GuideDryPieces INT,
		GuideColdPieces INT,
		GuideReceiverDepartment NVARCHAR(100),
		GuideReceiverTown NVARCHAR(100),
		GuideReceiverAddress NVARCHAR(600)
	);

	BEGIN TRANSACTION

		BEGIN TRY

			--- Verificar si existe la preparación de ruta y si ya fue despachada
			SELECT 
				@IdRoutePreparation = ISNULL(RP.IdRoutePreparation,0)
			FROM 
				[DeliveryBackOffice].[dbo].[RoutePreparation] RP
			WHERE 
				RP.CatRouteId = @IdRoute
				AND
				RP.DateRoutePreparation = @Date
				AND
				RP.RowStatus = 1

			--- Verificar si existe la preparación de ruta
			IF(@IdRoutePreparation IS NULL OR @IdRoutePreparation = 0)
			BEGIN

				--- No existe la preparación de ruta y debe ser generado
				INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparation]
						(
							[CatRouteId]
							,[DateRoutePreparation]
							,[GuidesQuantity]
							,[PiecesDry]
							,[PiecesCold]
							,[RowStatus]
							,[TokenCreated]
							,[DateCreated]
							,[TokenUpdated]
							,[DateUpdated]
				)
					VALUES (
						@IdRoute
						,@Date
						,1
						,IIF(@GuidePieceType = 1, 1, 0)
						,IIF(@GuidePieceType = 0, 1, 0)
						,1
						,@Token
						,GETDATE()
						,NULL
						,NULL
				)

				SET @IdRoutePreparation = SCOPE_IDENTITY()

				IF COALESCE(@@ROWCOUNT,0) > 0
					SET @RModified = @RModified + 1
			END
			ELSE
			BEGIN
				
				--- Actualizar preparación de ruta con nueva guía
				UPDATE
					[DeliveryBackOffice].[dbo].[RoutePreparation]
				SET
					GuidesQuantity = GuidesQuantity + 1
					,PiecesDry = PiecesDry + IIF(@GuidePieceType = 1, 1, 0)
					,PiecesCold = PiecesCold + IIF(@GuidePieceType = 0, 1, 0)
					,TokenUpdated = @Token
					,DateUpdated = GETDATE()
				WHERE
					IdRoutePreparation = @IdRoutePreparation
			END

			--- Verificar la preparación de ruta
			IF(@IdRoutePreparation > 0)
			BEGIN

				-- Verificar si existe la guía en el detalle de la preparación de ruta
				SELECT
					@IdRoutePreparationDetail = ISNULL(RPD.IdRoutePreparationDetail,0)
				FROM
					[DeliveryBackOffice].[dbo].[RoutePreparation] RP
					JOIN
						[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
						ON
						RP.IdRoutePreparation = RPD.RoutePreparationId
						AND
						RPD.RowStatus = 1
				WHERE
					RPD.Guide_Serie = @GuideSerie
					AND
					RPD.Guide_Number = @GuideNumber
					AND
					RP.RowStatus = 1
					AND
					RP.CatRouteId = @IdRoute
					AND
					RP.DateRoutePreparation = @Date
					
				-- Verificar si existe la guía dentro del detalle de la preparación de la ruta
				IF(@IdRoutePreparationDetail IS NULL OR @IdRoutePreparationDetail = 0)
				BEGIN
						
					--- No existe la guía dentro del detalle de la ruta

					-- Generar nuevo detalle de preparación de ruta
					INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
						(
							[RoutePreparationId]
							,[Guide_Serie]
							,[Guide_Number]
							,[RowStatus]
							,[TokenCreated]
							,[DateCreated]
							,[TokenUpdated]
							,[DateUpdated]
					)
					VALUES (
							@IdRoutePreparation
							,@GuideSerie
							,@GuideNumber
							,1
							,@Token
							,GETDATE()
							,NULL
							,NULL
					)

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1
							
					SET @IdRoutePreparationDetail = SCOPE_IDENTITY()

				END
				---ELSE No existe data que actualizar en el detalle de la preparacón de ruta

				--- Verificar el detalle de la preparación de ruta
				IF(@IdRoutePreparationDetail > 0)
				BEGIN

					--- Verificar si la pieza es real
					SELECT
						@GuidePieceExists = 1
					FROM
						[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP
					WHERE
						DOP.GuideSerie = @GuideSerie
						AND
						DOP.GuideNumber = @GuideNumber
						AND
						DOP.NoPiece = @GuidePiece

					--- Verificar si la pieza de la guía si existe
					IF(@GuidePieceExists = 1)
					BEGIN

						--- La pieza es real

						--- Verificar si existe la pieza de la guía dentro del detalle de la preparación de la ruta
						SELECT
							@IdRoutePreparationDetailPiece = RPDP.PieceNumber
						FROM
							[DeliveryBackOffice].[dbo].[RoutePreparation] RP
							JOIN
								[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
								ON
								RP.IdRoutePreparation = RPD.RoutePreparationId
							JOIN
								[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP
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
							RP.CatRouteId = @IdRoute
							AND
							RP.DateRoutePreparation = @Date
							AND
							RP.RowStatus = 1
							
						--- Verificar si la pieza de la guía ya existe dentro de las piezas registradas en la preparación de ruta
						IF(@IdRoutePreparationDetailPiece IS NULL OR @IdRoutePreparationDetailPiece = 0)
						BEGIN

							--- La pieza de la guía no existe dentro de las piezas registradas en la preparación de ruta
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
									,IIF(@GuidePieceType = 1, 1, 0)
									,1
									,@Token
									,GETDATE()
							)

							IF COALESCE(@@ROWCOUNT,0) > 0
								SET @RModified = @RModified + 1

							--- Ingresar datos a tabla para retornar datos
							INSERT INTO @ResponseTable
									(
										[IdRoutePreparation],
										[GuideSerie],
										[GuideNumber],
										[GuidePiece],
										[GuidePieceType],
										[GuidePieces],
										[GuideDryPieces],
										[GuideColdPieces],
										[GuideReceiverDepartment],
										[GuideReceiverTown],
										[GuideReceiverAddress]
							)
							SELECT
								@IdRoutePreparation
								,@GuideSerie
								,@GuideNumber
								,@GuidePiece
								,@GuidePieceType
								,(ISNULL(DO.Pieces_Dry,0) + ISNULL(DO.Pieces_Cold,0))
								,ISNULL(DO.Pieces_Dry,0)
								,ISNULL(DO.Pieces_Cold,0)
								,DO.Receiver_Department
								,DO.Receiver_Town
								,DO.Receiver_Address
							FROM
								[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
							WHERE
								DO.Guide_Serie = @GuideSerie
								AND
								DO.Guide_Number = @GuideNumber

							--- Extraer todas las piezas de la guía de las piezas registradas de otras preparaciones
							UPDATE RPDP
							SET RPDP.RowStatus = 0,
								RPDP.TokenUpdated = @Token,
								RPDP.DateUpdated = GETDATE()
							FROM
								[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP
								JOIN
									[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
									ON
									RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
									AND
									RPD.RowStatus = 1
								JOIN
									[DeliveryBackOffice].[dbo].[RoutePreparation] RP
									ON 
									RPD.RoutePreparationId = RP.IdRoutePreparation
									AND
									RP.RowStatus = 1
							WHERE 
								RPDP.RowStatus = 1
								AND
								RPD.Guide_Serie = @GuideSerie 
								AND 
								RPD.Guide_Number = @GuideNumber
								AND 
								RP.IdRoutePreparation <> @IdRoutePreparation
								AND
								RP.DateRoutePreparation = @Date
									
							--- Extraer de los demas detalles la guía ingresada
							UPDATE RPD
							SET RPD.RowStatus = 0,
								RPD.TokenUpdated = @Token,
								RPD.DateUpdated = GETDATE()
							FROM
								[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
								JOIN
									[DeliveryBackOffice].[dbo].[RoutePreparation] RP
									ON 
									RPD.RoutePreparationId = RP.IdRoutePreparation
									AND
									RP.RowStatus = 1
							WHERE 
								RPD.RowStatus = 1
								AND
								RPD.Guide_Serie = @GuideSerie 
								AND 
								RPD.Guide_Number = @GuideNumber
								AND 
								RP.IdRoutePreparation <> @IdRoutePreparation
								AND
								RP.DateRoutePreparation = @Date

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
								FROM RoutePreparationDetail
								WHERE 
									RoutePreparationId = @IdRoutePreparation
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

						END
						ELSE
						BEGIN
								
							--- La pieza de la guía ya esta dentro de las piezas registradas
							SET @GuidePieceAlreadyExists = 1
						END

					END
					ELSE
					BEGIN

						--- La pieza no es real
						SET @GuidePieceDoesntExist = 1;
					END


				END
				ELSE
				BEGIN

					--- No se pudo generar o encontrar el detalle de la preparación de ruta
					SET @FatalError = 1;
				END

			END
			ELSE
			BEGIN

				--- No se pudo generar o encontrar la preparación de ruta
				SET @FatalError = 2;
			END


		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;
	--- END TRANSACTION

	IF (@@TRANCOUNT > 0)
	BEGIN
		IF (@FatalError > 0)
		BEGIN
			IF(@FatalError = 1)
			BEGIN
				SELECT			  
					0 AS 'StatusCode',
					'Error al obtener la información del detalle de la preparación de ruta' AS 'Description', 
					0 AS 'NumTransferID'
			END
			ELSE IF (@FatalError = 2)
			BEGIN
				SELECT			  
					0 AS 'StatusCode',
					'Error al obtener la información de la preparación de ruta' AS 'Description', 
					0 AS 'NumTransferID'
			END
			ROLLBACK TRANSACTION
		END
		ELSE IF (@GuidePieceDoesntExist = 1)
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				CONCAT('Pieza ', @GuidePiece, ' no existe en la guía ', @GuideSerie, @GuideNumber) AS 'Description', 
				0 AS 'NumTransferID'
			ROLLBACK TRANSACTION;
		END
		ELSE IF (@GuidePieceAlreadyExists = 1)
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				CONCAT('Pieza ', @GuidePiece, ' ya fue escaneada para la guía ', @GuideSerie, @GuideNumber) AS 'Description', 
				0 AS 'NumTransferID'
			ROLLBACK TRANSACTION;
		END
		ELSE IF (@RModified > 0)
		BEGIN
			SELECT			  
				200 AS 'StatusCode',
				'Registros guardados correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'

			SELECT
				RT.GuideSerie 'Guide_Serie'
				,RT.GuideNumber 'Guide_Number'
				,RT.GuidePiece 'Guide_Piece'
				,RT.GuidePieces 'Pieces'
				,RT.GuideReceiverDepartment 'Department'
				,RT.GuideReceiverTown 'Town'
				,RT.GuideReceiverAddress 'Address'
				,RT.GuideDryPieces 'Pieces_Dry'
				,RT.GuideColdPieces 'Pieces_Cold'
				,RT.GuidePieceType 'Piece_Type'
				,NULL 'GuideOrder'
				,@IdRoutePreparation 'NewRoutePreparation'
			FROM
				@ResponseTable RT
			COMMIT TRANSACTION;
		END
		ELSE
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				'Registros no guardados' AS 'Description', 
				0 AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END
	END
	ELSE
	BEGIN
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END
END;
