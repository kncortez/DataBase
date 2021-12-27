USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetRoutePreparation]    Script Date: 27/12/2021 10:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-12-26>
-- Description:	<Guarda información de la preparación de entregas.>
-- =============================================

CREATE PROCEDURE [dbo].[SetRoutePreparation]
    -- Add the parameters for the stored procedure here
	@IdRoute INT,
	@Date DATE,
	@GuidesQuantity INT,
	@PiecesDry SMALLINT,
	@PiecesCold SMALLINT,
    @ListGuides TblGuides READONLY,
	@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @IdRoutePreparation INT

	BEGIN TRANSACTION

		BEGIN TRY

			INSERT INTO [dbo].[RoutePreparation]
					   ([CatRouteId]
					   ,[DateRoutePreparation]
					   ,[GuidesQuantity]
					   ,[PiecesDry]
					   ,[PiecesCold]
					   ,[RowStatus]
					   ,[TokenCreated]
					   ,[DateCreated]
					   ,[TokenUpdated]
					   ,[DateUpdated])
				 VALUES
					   (@IdRoute
					   ,@Date
					   ,@GuidesQuantity
					   ,@PiecesDry
					   ,@PiecesCold
					   ,1
					   ,@Token
					   ,GETDATE()
					   ,NULL
					   ,NULL)
			SET @IdRoutePreparation = SCOPE_IDENTITY()
			SET @RModified = @@ROWCOUNT

			IF @IdRoutePreparation > 0
			BEGIN

				INSERT INTO [dbo].[RoutePreparationDetail]
						   ([RoutePreparationId]
						   ,[Guide_Serie]
						   ,[Guide_Number]
						   ,[RowStatus]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[TokenUpdated]
						   ,[DateUpdated])
					SELECT @IdRoutePreparation, lg.Guide_Serie, lg.Guide_Number, 1, @Token, GETDATE(), NULL, NULL
					FROM @ListGuides lg

				SET @RModified = @RModified+@@ROWCOUNT

				-- Deshabilitar filas si ya existieran en otra ruta
				UPDATE rpd
				SET rpd.RowStatus = 0,
					rpd.TokenUpdated = @Token,
					rpd.DateUpdated = GETDATE()
				FROM  RoutePreparationDetail rpd
				JOIN RoutePreparation rp 
					ON rpd.RoutePreparationId = rp.IdRoutePreparation
				JOIN @ListGuides lg
					ON rpd.Guide_Serie = lg.Guide_Serie AND rpd.Guide_Number = lg.Guide_Number
				WHERE rp.DateRoutePreparation = @Date AND rp.IdRoutePreparation <> @IdRoutePreparation
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
			IF (@RModified >= 2)
				SELECT			  
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registros no guardados' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END;
