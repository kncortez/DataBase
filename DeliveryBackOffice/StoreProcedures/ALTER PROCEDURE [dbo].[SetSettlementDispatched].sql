USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetSettlementDispatched]    Script Date: 3/01/2022 12:38:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-12-29>
-- Description:	<Guarda información del despacho de entregas.>
-- =============================================

ALTER PROCEDURE [dbo].[SetSettlementDispatched]
    -- Add the parameters for the stored procedure here
	@IdRoute INT,
	@IdRoutePreparation INT,
	@Date DATE,
	@DateTime DATETIME,
	@GuidesQuantity INT,
	@PiecesDry SMALLINT,
	@PiecesCold SMALLINT,
    @ListGuides TblGuides READONLY,
	@IdVehicle INT,
	@IdCourier INT,
	@CourierName NVARCHAR(200),
	@StartingKilometers NVARCHAR(50),
	@StationId INT,
	@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @ValidateOperation INT = 0
	-- control de inserción de manifiesto de despacho
	DECLARE @ID_Manifest INT

	BEGIN TRANSACTION
		BEGIN TRY
			
			--Desactivar filas en RoutePreparationDetail si no están incluídas
			UPDATE rpd
			SET rpd.RowStatus = 0
				,rpd.TokenUpdated = @Token
				,rpd.DateUpdated = GETDATE()
			FROM RoutePreparationDetail rpd
			WHERE rpd.RoutePreparationId = @IdRoutePreparation
			AND NOT EXISTS (
				SELECT 1 
				FROM @ListGuides lg
				WHERE lg.Guide_Serie = rpd.Guide_Serie AND lg.Guide_Number = rpd.Guide_Number
			)
			AND rpd.RowStatus = 1

			--Actualizar el registros para la piezas que deseamos reubicar
			UPDATE wh
			SET wh.Active = 0
				,wh.UserCreated = @Token
				,wh.DateCreated = GETDATE()
			FROM Warehouse wh
			JOIN @ListGuides lg
				ON wh.Guide_Serie = lg.Guide_Serie AND wh.Guide_Number = lg.Guide_Number
			WHERE wh.Active = 1  
				
			-- Actualizar registro de guía a estado 4
			UPDATE do
			SET StatusOrderId = 4
				,Courier_Name = @courierName
				,Dispatched_Date = GETDATE()
				,TokenUpdated = @Token
				,DateUpdated = GETDATE()
			FROM DeliveryOrder do
			JOIN @ListGuides lg
				ON do.Guide_Serie = lg.Guide_Serie AND do.Guide_Number = lg.Guide_Number
			
			--operation 1
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

			-- Activar bandera de proceso de SMS
			IF((select top 1 ue.UpdateStatus
						from [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue
						where ue.RowStatus=1
						and ue.ElementId=1001)=0)
			BEGIN
				update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
				set UpdateStatus=1, UpdateDateTime=GETDATE()
				where RowStatus=1
				and ElementId=1001
			END

			-- Insertar nuevo estado de guía en tabla histórica
			INSERT INTO DeliveryOrderDetail (
				[Guide_Serie]
				,[Guide_Number]
				,[StatusOrderId]
				,[UserCreated]
				,[DateCreated]
				,[DateCreatedInSystem])
			SELECT Guide_Serie, Guide_Number, 4, @Token, GETDATE(), GETDATE()
			FROM @ListGuides

			--operation 2
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1
			

			-- Insertar registro en control de manifiestos de despacho
			INSERT INTO [dbo].[DeliveryOrderBySettlement]
				   ([Date_Printed]
				   ,[User_Dispatched]
				   ,[Date_Dispatched]
				   ,[Pieces_Dry_Dispatched]
				   ,[Pieces_Cold_Dispatched]
				   ,[Guides_Dispatched]
				   ,[User_Received]
				   ,[Date_Received]
				   ,[Pieces_Dry_Received]
				   ,[Pieces_Cold_Received]
				   ,[Guides_Received]
				   ,[ID_Courier]
				   ,[Route_Dispatched]
				   ,[Route_Received]
				   ,[DispatchedStationId]
				   ,[CatVehicleId]
				   ,[CatRouteId]
				   ,[StartingKilometers])
			 VALUES
				   (NULL
				   ,@Token
				   ,GETDATE()
				   ,@PiecesDry
				   ,@PiecesCold
				   ,@GuidesQuantity
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@IdCourier
				   ,@DateTime
				   ,NULL
				   ,IIF( ISNULL(@StationId,0) > 0, @StationId, NULL)
				   ,@IdVehicle
				   ,@IdRoute
				   ,@StartingKilometers)

			SET @ID_Manifest = SCOPE_IDENTITY()

			--operation 3
			IF (@ID_Manifest > 0)
				SET @ValidateOperation = @ValidateOperation + 1

			-- registrar nuevo intento de entrega
			INSERT INTO DeliveryAttempt (
				[Guide_Serie]
				,[Guide_Number]
				,[Dry]
				,[Cold]
				,[Latitude]
				,[Longitude]
				,[Delivered]
				,[ID_Courier]
				,[ID_DeliveryOrderBySettlement]
				,[User_Created]
				,[Date_Created]
				,[Guide_Piece]) 
			--VALUES (@GuideSerie,@GuideNumber,@Dry,@Cold,0,@IDCourier,NULL,@UserCreated,GETDATE(),@GuidePiece)
			SELECT lg.Guide_Serie, lg.Guide_Number, 
				COALESCE(dop.IsDry,1), CASE WHEN dop.IsDry IS NULL THEN 0 ELSE 1-dop.IsDry END,
				'','',0, @IdCourier, @ID_Manifest, @Token, GETDATE(), dop.NoPiece
			FROM @ListGuides lg
			JOIN DeliveryOrderPiece dop
				ON lg.Guide_Serie = dop.GuideSerie AND lg.Guide_Number = dop.GuideNumber

			--operation 4
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

			-- Deshabilitar filas si ya existieran en otro Manifiesto
			UPDATE dsd
			SET dsd.RowStatus = 0,
				dsd.TokenUpdated = @Token,
				dsd.DateUpdated = GETDATE()
			FROM  DeliverySettlementDetail dsd
			JOIN DeliveryOrderBySettlement dobs 
				ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
			WHERE dsd.RowStatus = 1
				AND Guide_Serie = Guide_Serie AND Guide_Number IN (
					SELECT Guide_Number FROM @ListGuides
				)
				AND CONVERT(date,dobs.Route_Dispatched) = @Date

			-- Insertar información histórica (para propósito de bitácora)
			INSERT INTO DeliverySettlementDetail (
				[ID_DeliveryOrderBySettlement]
				,[Guide_Serie]
				,[Guide_Number])
			SELECT @ID_Manifest,Guide_Serie,Guide_Number
			FROM @ListGuides

			--operation 5
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

			--Actualizar manifiesto en RoutePreparation
			UPDATE RoutePreparation
			SET DeliveryOrderBySettlementId = @ID_Manifest
				,TokenUpdated = @Token
				,DateUpdated = GETDATE()
			WHERE IdRoutePreparation = @IdRoutePreparation

			--operation 6
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation + 1

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
			IF (@ValidateOperation = 6)
			BEGIN
				COMMIT TRANSACTION
				SELECT			  
					@ID_Manifest AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SELECT			  
					0 AS 'StatusCode',
					'Registros no guardados' AS 'Description', 
					0 AS 'NumTransferID'
			END		
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END;