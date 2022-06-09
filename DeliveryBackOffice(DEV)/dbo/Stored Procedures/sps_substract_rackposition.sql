


-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-26>
-- Description:	<Liberar la ubicación en rack de una guía>
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-01-17>
-- Description:	<Modificación para guardar token y fecha de actualziación posición de Guía en el Rack.>
-- =============================================
CREATE PROCEDURE [dbo].[sps_substract_rackposition]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@PiecesDry BIT,
		@PiecesCold BIT,
		@UserCreated nvarchar(50),
		@GuidePiece INT = 0 -- parameter not used, safe delete after removing it from FreeGuideRackPosition method on Hermes Desktop
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Id BIGINT

	BEGIN TRANSACTION

		BEGIN TRY
			

			-- devolver el registro activo mas antiguo para la pieza seca o fría que deseamos reubicar
			SET @Id = (
				SELECT TOP 1 Id FROM [DeliveryBackOffice].[dbo].[Warehouse] 
				WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND Active = 1 AND Dry = @PiecesDry AND Cold = @PiecesCold
				ORDER BY DateCreated ASC)

			UPDATE [DeliveryBackOffice].[dbo].[Warehouse] SET Active = 0, UserUpdated = @UserCreated, DateUpdated = GETDATE() WHERE Id = @Id
			

			SET @RModified = @@ROWCOUNT
			
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Id AS 'RowID'
			ROLLBACK TRANSACTION
		END CATCH;

		--print @@TRANCOUNT
		--print @@ROWCOUNT
		--print @RModified
		--print @RInserted

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Id AS 'RowID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Id AS 'RowID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Id AS 'RowID'
END
