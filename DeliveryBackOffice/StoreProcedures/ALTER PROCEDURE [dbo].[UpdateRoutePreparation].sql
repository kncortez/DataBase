USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[UpdateRoutePreparation]    Script Date: 30/12/2021 10:11:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-12-27>
-- Description:	<Actualiza información de la preparación de entregas.>
-- =============================================

ALTER PROCEDURE [dbo].[UpdateRoutePreparation]
    -- Add the parameters for the stored procedure here
	@IdRoutePreparation INT,
	@Date DATE,
	@GuidesQuantity INT,
	@PiecesDry SMALLINT,
	@PiecesCold SMALLINT,
    @ListGuides TblGuides READONLY,
	@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT = 0

	BEGIN TRANSACTION

		BEGIN TRY

			UPDATE [dbo].[RoutePreparation]
			   SET [GuidesQuantity] = @GuidesQuantity
				  ,[PiecesDry] = @PiecesDry
				  ,[PiecesCold] = @PiecesCold
				  ,[TokenUpdated] = @Token
				  ,[DateUpdated] = GETDATE()
			 WHERE IdRoutePreparation = @IdRoutePreparation

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @RModified = @RModified + 1

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
				lg.Guide_Serie,
				lg.Guide_Number,
				3,
				@Token,
				GETDATE(),
				GETDATE()
			FROM @ListGuides lg	
			WHERE NOT EXISTS (
				SELECT 1
				FROM RoutePreparationDetail
				WHERE RoutePreparationId = @IdRoutePreparation
					AND Guide_Serie = lg.Guide_Serie AND Guide_Number = lg.Guide_Number
			)

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
				WHERE NOT EXISTS (
					SELECT 1
					FROM RoutePreparationDetail
					WHERE RoutePreparationId = @IdRoutePreparation
						AND Guide_Serie = lg.Guide_Serie AND Guide_Number = lg.Guide_Number
						AND RowStatus = 1
				)

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @RModified = @RModified + 1

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
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END;
