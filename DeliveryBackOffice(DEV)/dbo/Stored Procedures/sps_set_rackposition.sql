

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-22>
-- Description:	<Cambiar la ubicación en rack de una guía>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_rackposition]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@RackPosition AS NVARCHAR(30),
		@PiecesDry BIT,
		@PiecesCold BIT,
		@Relocation BIT,
		@UserCreated nvarchar(50),
		@GuidePiece SMALLINT,
		@IsReturn BIT = 0
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @RInserted INT
	DECLARE @StatusOrderId INT = 10
	DECLARE @TerminalStatusGuide INT = (
		SELECT
			TOP 1
				CCT.IdCatCheckpointType
		FROM
			[DeliveryBackOffice].[dbo].[CatCheckpointType] CCT WITH(NOLOCK)
		WHERE
			CCT.CheckpointTypeDescription = 'Checkpoint final'
	);
	DECLARE @ActualStatusGuide INT = NULL;
	DECLARE @ActualStatusGuideName NVARCHAR(50) = '';


		SELECT
			@ActualStatusGuide = DO.StatusOrderId,
			@ActualStatusGuideName = SO.OrderDescription
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
				ON
					DO.StatusOrderId = SO.StatusOrderId
		WHERE
			DO.Guide_Serie = @GuideSerie
			AND
			DO.Guide_Number = @GuideNumber

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
							SELECT TOP 1 Id FROM [DeliveryBackOffice].[dbo].[Warehouse]  WITH(NOLOCK)
							WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND Active = 1 AND Dry = @PiecesDry AND Cold = @PiecesCold AND IsReturn = 1 --AND Guide_Piece = @GuidePiece
							ORDER BY DateCreated ASC)
					END
					ELSE
					BEGIN
						SET @Id = (
							SELECT TOP 1 Id FROM [DeliveryBackOffice].[dbo].[Warehouse]  WITH(NOLOCK)
							WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND Active = 1 AND Dry = @PiecesDry AND Cold = @PiecesCold AND (IsReturn IS NULL OR IsReturn = 0) --AND Guide_Piece = @GuidePiece
							ORDER BY DateCreated ASC)
					END

					UPDATE [DeliveryBackOffice].[dbo].[Warehouse] SET Active = 0, UserUpdated = @UserCreated, DateUpdated = GETDATE() WHERE Id = @Id

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

					--Actualizar En Invetario estado de las piezas
					UPDATE DeliveryOrderPiece
					SET StatusOrderId = @StatusOrderId
					WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber

					-- Actualizar En Inventario al último estado de la guía
					UPDATE DeliveryBackOffice.dbo.DeliveryOrder
					SET StatusOrderId = @StatusOrderId
					WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
			
					-- Insertar En Inventario nuevo estado de guía en tabla histórica
					INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem],[Observations])
					VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @UserCreated, GETDATE(), GETDATE(),'') 
					SET @RInserted = @@ROWCOUNT

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

			--print @@TRANCOUNT
			--print @@ROWCOUNT
			--print @RModified
			--print @RInserted

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
