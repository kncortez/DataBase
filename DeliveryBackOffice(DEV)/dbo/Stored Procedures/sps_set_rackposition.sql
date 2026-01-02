/* =================================================
   SP:        [dbo].[sps_set_rackposition]
   Propósito: Cambiar la ubicación en rack de una guía
   Autor:     Carlos Cano
   Historia:  <>
   Fecha:     <2020-07-22>
   === CHANGELOG ============================
2026-01-02 | Historia/épica: <FDAPI-4761> | Autor: Tito Garcia |
=========================================== */
CREATE PROCEDURE [dbo].[sps_set_rackposition]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@RackPosition AS NVARCHAR(30),
		@PiecesDry BIT,
		@PiecesCold BIT,
		@Relocation BIT,
		@UserCreated nvarchar(50),
		@GuidePiece SMALLINT,
		@IsReturn BIT = 0,
		@StationId INT = NULL
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @RInserted INT
	DECLARE @StatusOrderId INT = 10; --[StatusOrder] -> 'En Inventario' 
	DECLARE @TerminalStatusGuide INT = 3; -- [CatCheckpointType] -> 'Checkpoint final'
	DECLARE @ActualStatusGuide INT = NULL;
	DECLARE @ActualStatusGuideName NVARCHAR(50) = '';
	
	IF @StationId <= 0
		SET @StationId = NULL;

	SELECT
		@ActualStatusGuide = DO.StatusOrderId,
		@ActualStatusGuideName = SO.OrderDescription
	FROM[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
			ON DO.StatusOrderId = SO.StatusOrderId
	WHERE DO.Guide_Serie = @GuideSerie
		AND DO.Guide_Number = @GuideNumber

	IF(@ActualStatusGuide NOT IN (SELECT [SO].[StatusOrderId] FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.CatCheckpointTypeId = @TerminalStatusGuide))
	BEGIN
	
		BEGIN TRANSACTION
		BEGIN TRY
			IF (@Relocation = 1)
			BEGIN
				DECLARE @Id BIGINT

				-- devolver el registro activo mas antiguo para la pieza seca o fría que deseamos reubicar
				IF @IsReturn = 1
				BEGIN 
					SET @Id = (
						SELECT TOP 1 Id 
						FROM [DeliveryBackOffice].[dbo].[Warehouse]  WITH(NOLOCK)
						WHERE Guide_Serie = @GuideSerie 
							AND Guide_Number = @GuideNumber 
							AND Active = 1 
							AND Dry = @PiecesDry 
							AND Cold = @PiecesCold 
							AND IsReturn = 1
						ORDER BY DateCreated ASC)
				END
				ELSE
				BEGIN
					SET @Id = (
						SELECT TOP 1 Id 
						FROM [DeliveryBackOffice].[dbo].[Warehouse]  WITH(NOLOCK)
						WHERE Guide_Serie = @GuideSerie 
							AND Guide_Number = @GuideNumber 
							AND Active = 1 
							AND Dry = @PiecesDry 
							AND Cold = @PiecesCold 
							AND (IsReturn IS NULL OR IsReturn = 0)
						ORDER BY DateCreated ASC)
				END

				UPDATE [DeliveryBackOffice].[dbo].[Warehouse] SET Active = 0, UserUpdated = @UserCreated, DateUpdated = GETDATE() 
				WHERE Id = @Id

				SET @RModified = @@ROWCOUNT

				IF (@RModified > 0)
				BEGIN
					-- registrar nueva ubicación
					INSERT INTO [DeliveryBackOffice].[dbo].[Warehouse] (Rack_Position, Guide_Serie, Guide_Number, Dry, Cold, Active, UserCreated, DateCreated, Guide_Piece, IsReturn) VALUES 
					(@RackPosition, @GuideSerie, @GuideNumber, @PiecesDry, @PiecesCold, 1, @UserCreated, GETDATE(), @GuidePiece, @IsReturn)

					SET @RInserted = @@ROWCOUNT
				END
			END
			-- si el registro de la pieza se realiza por primera vez
			ELSE
			BEGIN
			
				-- registrar nueva ubicación
				INSERT INTO [DeliveryBackOffice].[dbo].[Warehouse] (Rack_Position, Guide_Serie, Guide_Number, Dry, Cold, Active, UserCreated, DateCreated, Guide_Piece, IsReturn) VALUES 
				(@RackPosition, @GuideSerie, @GuideNumber, @PiecesDry, @PiecesCold, 1, @UserCreated, GETDATE(), @GuidePiece, @IsReturn)

				--Si es una devolución, cambiar estado
				IF @IsReturn = 1
				BEGIN
					SET @StatusOrderId = 31
				END

				--Actualizar En Inventario estado de las piezas
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
				SET StatusOrderId = @StatusOrderId
				WHERE GuideSerie = @GuideSerie 
					AND GuideNumber = @GuideNumber

				-- Actualizar En Inventario al último estado de la guía
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET StatusOrderId = @StatusOrderId
				WHERE Guide_Serie = @GuideSerie 
					AND Guide_Number = @GuideNumber
		
				-- Insertar En Inventario nuevo estado de guía en tabla histórica
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem],[Observations],[StationId])
				VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @UserCreated, GETDATE(), GETDATE(),'',@StationId) 
				SET @RInserted = @@ROWCOUNT

				-----------------WEBHOOK.INI-----------------------	
			DECLARE @WebhookCustomerId INT = -1;
			DECLARE @CustomerEndpointId INT = -1;
			-- Debido a que se procesa únicamente 1 guía
			DECLARE @GuideCurrentStatus INT = -1;

			BEGIN TRY
				DECLARE @GuideStatusChangeWebhook INT = 1; -- WebhookType -> 'GuideStatusChange'

				SET @WebhookCustomerId = ISNULL(
											(
												SELECT TOP 1
													DO.IdCustomer
												FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
												WHERE DO.Guide_Number = @GuideNumber
													AND DO.Guide_Serie = @GuideSerie
											),
											-1
												);
				SET @CustomerEndpointId = ISNULL(
											(
												SELECT TOP 1
														WE.IdWebhookEndpoint
												FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
												WHERE WE.CustomerId = @WebhookCustomerId
													AND WE.WebhookTypeId = @GuideStatusChangeWebhook
											),
											-1
												);

				SET @GuideCurrentStatus =
				(
					SELECT TOP 1
							DO.StatusOrderId
					FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
					WHERE DO.Guide_Serie = @GuideSerie
							AND DO.Guide_Number = @GuideNumber
				);
				
				-- Cliente tiene webhook configurado para el tipo especificado
				-- Estado actual de la guía coincide dentro de las restricciónes por usuario
				print 'webhook';
				print @WebhookCustomerId
				print @CustomerEndpointId
				print @GuideCurrentStatus
				print 'webhook'
				IF (
						@WebhookCustomerId > 0
						AND @CustomerEndpointId > 0
						AND @GuideCurrentStatus IN
							(
								SELECT WRBU.StatusOrderId
								FROM [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH (NOLOCK)
								WHERE WRBU.CustomerId = @WebhookCustomerId
										AND WRBU.WebhookTypeId = @GuideStatusChangeWebhook
							)
					)
				BEGIN

					DECLARE @ResponseTable AS TABLE
					(
						InsertedId BIGINT
					);

		DECLARE @TypeConnect INT = 0;

		SET @TypeConnect = (SELECT top 1 TypeConnectionId 
								FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] wh WITH (NOLOCK)
								INNER JOIN [DeliveryBackOffice].[dbo].[WebhookCatTypeConnection] wc WITH (NOLOCK)
									ON wh.TypeConnectionId = wc.IdCatTypeConnection
								WHERE wh.CustomerId = @WebhookCustomerId)

			IF(@TypeConnect = 1)
					BEGIN

					INSERT INTO [DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
					(
						[GuideSerie],
						[GuideNumber],
						[CustomerId],
						[StatusOrderId],
						[WebhookEndpointId],
						[HasNotified],
						[TokenCreated],
						[DateCreated]
					)
					OUTPUT inserted.IdWebhookTrackingQueue
					INTO @ResponseTable
					(
						InsertedId
					)
					VALUES
					(@GuideSerie, @GuideNumber, @WebhookCustomerId, @GuideCurrentStatus, @CustomerEndpointId, 0,
						@UserCreated, GETDATE());

				END
			ELSE
				BEGIN
				
					-----------------------------------
					DECLARE @GuidePiecesTable AS TABLE
					(
						CustomerId INT,
						CustomerEndpointId BIGINT,
						WebhookType INT,
						GuideSerie NVARCHAR(2),
						GuideNumber INT,
						GuideStatusId TINYINT,
						NumberPieces INT,
						NumberRelatedPieces INT
						
					);

					INSERT INTO @GuidePiecesTable 
								( 
							CustomerId,
							GuideSerie,
							GuideNumber,
							GuideStatusId,
							NumberPieces
							)
							SELECT @WebhookCustomerId,
							dop.GuideSerie,dop.GuideNumber, 
							@GuideCurrentStatus,
							Count(dop.GuideNumber)
							FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH(NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
								ON do.Guide_Serie = dop.GuideSerie
									AND do.Guide_Number = dop.GuideNumber
							INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WHE WITH(NOLOCK)
								ON do.IdCustomer = WHE.CustomerId
							WHERE do.Guide_Serie = @GuideSerie
								AND do.Guide_Number = @GuideNumber
								AND WHE.TypeConnectionId = 2
							GROUP BY dop.GuideSerie,dop.GuideNumber

					DECLARE @PiecesGuideRelatedTable AS TABLE
					(
						CustomerId INT,
						CustomerEndpointId BIGINT,
						WebhookType INT,
						GuideSerie NVARCHAR(2),
						GuideNumber INT,
						GuideStatusId TINYINT,
						NumberRelatedPieces INT
						
					);

					INSERT INTO @PiecesGuideRelatedTable 
								( 
							CustomerId,
							GuideSerie,
							GuideNumber,
							GuideStatusId,
							NumberRelatedPieces
							)
							SELECT @WebhookCustomerId,
							dop.GuideSerie,dop.GuideNumber, 
							@GuideCurrentStatus,
							Count(dop.GuideNumber)
							FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH(NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
								ON do.Guide_Serie = dop.GuideSerie
									AND do.Guide_Number = dop.GuideNumber
							INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WHE WITH(NOLOCK)
								ON do.IdCustomer = WHE.CustomerId
							WHERE do.Guide_Serie = @GuideSerie
								AND do.Guide_Number = @GuideNumber
								AND dop.ExternalPieceId IS NOT NULL
								AND WHE.TypeConnectionId = 2
							GROUP BY dop.GuideSerie,dop.GuideNumber
					
						INSERT INTO WebhookTrackingQueueDetailForSFTP 
							(CustomerId,
							GuideSerie,
							GuideNumber,
							GuidePiece,
							ExternalNumber,
							ExternalPieceId,
							StatusOrderId,
							RowStatus,
							DateCreated,
							TokenCreated)
						SELECT @WebhookCustomerId,
						dop.GuideSerie,dop.GuideNumber, dop.GuidePiece, do.Ticket_Number,dop.ExternalPieceId, 
						@GuideCurrentStatus, 1 AS RowStatus, GETDATE()AS DateCreated,@UserCreated AS TokenCreated
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop WITH(NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] do WITH(NOLOCK)
								ON dop.GuideSerie = do.Guide_Serie
									AND dop.GuideNumber = do.Guide_Number
							INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WHE WITH(NOLOCK)
								ON do.IdCustomer = WHE.CustomerId
							INNER JOIN @GuidePiecesTable gpt
								ON dop.GuideSerie = gpt.GuideSerie
									AND dop.GuideNumber = gpt.GuideNumber
							INNER JOIN @PiecesGuideRelatedTable pgt
								ON gpt.GuideSerie = pgt.GuideSerie
									AND gpt.GuideNumber = pgt.GuideNumber
						WHERE gpt.NumberPieces = pgt.NumberRelatedPieces
							AND WHE.TypeConnectionId = 2
					END
				END;
			END TRY
			BEGIN CATCH

			END CATCH;
			-------------------WEBHOOK.FIN------------------------------	

			END				
		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@RackPosition AS 'RackPosition'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RInserted > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@RackPosition AS 'RackPosition'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@RackPosition AS 'RackPosition'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@RackPosition AS 'RackPosition'

	END
	ELSE
	BEGIN
		SELECT 
			2 AS 'StatusCode', 
			CONCAT('Estado: ',@ActualStatusGuideName,', no permitido para ingresar a inventario.') AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID',
			@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
			@RackPosition AS 'RackPosition'
	END
END
