USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_delivery_piece]    Script Date: 15/12/2020 12:41:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <15-Diciembre-2020>
-- Description:	<Registrar categoría, peso y dimensiones de las piezas de una guía>
-- =============================================
CREATE PROCEDURE [dbo].[sps_delivery_piece]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@GuidePiece AS SMALLINT,
		@PhysicalWeight AS DECIMAL(5,2),
		@PieceCategory AS SMALLINT,
		@PieceHeight AS DECIMAL(5,2),
		@PieceWidth AS DECIMAL(5,2),
		@PieceLength AS DECIMAL(5,2),
		@PieceWeight AS DECIMAL(5,2),
		@Token AS NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @GuidePieceExist INT

	BEGIN TRANSACTION

		BEGIN TRY

			SET @GuidePieceExist = (SELECT Guide_Number FROM DeliveryBackOffice.dbo.DeliveryPiece WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND Guide_Piece = @GuidePiece)

			-- si el registro de la pieza existe
			IF (@GuidePieceExist > 0)
			BEGIN
				
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryPiece] 
				SET 
					Piece_PhysicalWeight = @PhysicalWeight, 
					Piece_Category = @PieceCategory, 
					Piece_Height = @PieceHeight, 
					Piece_Width = @PieceWidth, 
					Piece_Length = @PieceLength, 
					Piece_Weight = @PieceWeight,
					Piece_Updated = @Token,
					Date_Updated = GETDATE()
				WHERE 
				Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND Guide_Piece = @GuidePiece

				SET @RModified = @@ROWCOUNT
			END
			-- si el registro de la pieza se realiza por primera vez
			ELSE
			BEGIN
				
				-- registrar nueva pieza
				INSERT INTO [dbo].[DeliveryPiece]
				   ([Guide_Serie]
				   ,[Guide_Number]
				   ,[Guide_Piece]
				   ,[Piece_PhysicalWeight]
				   ,[Piece_Category]
				   ,[Piece_Height]
				   ,[Piece_Width]
				   ,[Piece_Length]
				   ,[Piece_Weight]
				   ,[Piece_Created]
				   ,[Date_Created]
				   ,[Piece_Updated]
				   ,[Date_Updated])
			 VALUES
				   (@GuideSerie
				   ,@GuideNumber
				   ,@GuidePiece
				   ,@PhysicalWeight
				   ,@PieceCategory
				   ,@PieceHeight
				   ,@PieceWidth
				   ,@PieceLength
				   ,@PieceWeight
				   ,@Token
				   ,GETDATE()
				   ,NULL
				   ,NULL)

				SET @RModified = @@ROWCOUNT

			END				
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@GuidePiece AS 'Piece'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@GuidePiece AS 'Piece'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@GuidePiece AS 'Piece'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@GuidePiece AS 'Piece'
END
GO


