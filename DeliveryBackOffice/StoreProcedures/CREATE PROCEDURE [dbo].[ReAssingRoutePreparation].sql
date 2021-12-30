USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ReAssingRoutePreparation]    Script Date: 29/12/2021 23:49:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-12-29>
-- Description:	<Reasigna una guía en despacho de entregas.>
-- =============================================

CREATE PROCEDURE [dbo].[ReAssingRoutePreparation]
    -- Add the parameters for the stored procedure here
	@IdRoute INT,
	@Date DATE,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT = 0
	DECLARE @IdRoutePreparation INT = 0
	DECLARE @Id_Manifest INT = 0

	BEGIN TRANSACTION

		BEGIN TRY

			SELECT 
				@IdRoutePreparation = IdRoutePreparation,
				@Id_Manifest = COALESCE(DeliveryOrderBySettlementId,0)
			FROM RoutePreparation
			WHERE CatRouteId = @IdRoute AND DateRoutePreparation = @Date

			IF @Id_Manifest = 0
			BEGIN
				IF @IdRoutePreparation = 0
				BEGIN
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
					 SELECT
						   @IdRoute
						   ,@Date
						   ,1
						   ,do.Pieces_Dry
						   ,do.Pieces_Cold
						   ,1
						   ,@Token
						   ,GETDATE()
						   ,NULL
						   ,NULL
						FROM DeliveryOrder do
						WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

					SET @IdRoutePreparation = SCOPE_IDENTITY()

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1
				END
				ELSE
				BEGIN
					UPDATE rp
						SET rp.GuidesQuantity = rp.GuidesQuantity+1
							,rp.PiecesDry = rp.PiecesDry + COALESCE(do.Pieces_Dry,0)
							,rp.PiecesCold = rp.PiecesCold + COALESCE(do.Pieces_Cold,0)
							,rp.TokenUpdated = @Token
							,rp.DateUpdated = GETDATE()
					FROM RoutePreparation rp
					JOIN DeliveryOrder do
						ON do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber
					WHERE rp.IdRoutePreparation = @IdRoutePreparation

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1
				
				END

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
					VALUES (@IdRoutePreparation, @GuideSerie, @GuideNumber, 1, @Token, GETDATE(), NULL, NULL)

					IF COALESCE(@@ROWCOUNT,0) > 0
						SET @RModified = @RModified + 1
				END

				-- Deshabilitar filas si ya existieran en otra ruta
				UPDATE rpd
				SET rpd.RowStatus = 0,
					rpd.TokenUpdated = @Token,
					rpd.DateUpdated = GETDATE()
				FROM  RoutePreparationDetail rpd
				JOIN RoutePreparation rp 
					ON rpd.RoutePreparationId = rp.IdRoutePreparation
				WHERE rpd.Guide_Serie = @GuideSerie AND rpd.Guide_Number = @GuideNumber
					AND rp.DateRoutePreparation = @Date AND rp.IdRoutePreparation <> @IdRoutePreparation
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

			IF (@Id_Manifest > 0)
			BEGIN 
				SELECT			  
					0 AS 'StatusCode',
					'La ruta ya ha sido liquidada' AS 'Description', 
					0 AS 'NumTransferID'
				ROLLBACK TRANSACTION
			END
			ELSE 
			BEGIN
				IF (@RModified = 2)
				BEGIN
					SELECT			  
						1 AS 'StatusCode',
						'Registros guardados correctamente' AS 'Description', 
						@@TRANCOUNT AS 'NumTransferID'
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
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END;
