
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-09-23>
-- Description:	<Modificacion del metodo original para guardar información para generar manifiesto de despacho, incluyendo orden de servicios>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_dispatched_simpli]
		@GuideSerie NVARCHAR(2),
		@GuidesTable TblGuideServiceOrder READONLY,
		@GuideQuantity INT,
		@IdCourier INT,
		@PiecesDryDispatched INT,
		@PiecesColdDispatched INT,
		@RouteDispatched DATETIME,
		@Token NVARCHAR(50),
		@StationId INT = NULL
AS
BEGIN
	
	-- control de inserción de manifiesto de despacho
	DECLARE @ID_Manifest INT

	BEGIN TRANSACTION

		BEGIN TRY
			
			-- inicializar variable para control de transacción y resultado
			SET @ID_Manifest = 0

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
				   ,[DispatchedStationId])
			 VALUES
				   (NULL
				   ,@Token
				   ,GETDATE()
				   ,@PiecesDryDispatched
				   ,@PiecesColdDispatched
				   ,@GuideQuantity
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,NULL
				   ,@IdCourier
				   ,@RouteDispatched
				   ,NULL
				   ,IIF( ISNULL(@StationId,0) > 0, @StationId, NULL))

			SET @ID_Manifest = SCOPE_IDENTITY()

			IF (@ID_Manifest > 0)
			BEGIN

				-- Actualizar todas las guías al manifiesto recién creado
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryAttempt] SET ID_DeliveryOrderBySettlement = @ID_Manifest WHERE 
				CONVERT(VARCHAR, Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)
				AND ID_Courier = @IdCourier
				AND Guide_Serie = @GuideSerie 
				AND Guide_Number IN (
					SELECT GuideNumber FROM @GuidesTable
				)

				-- Insertar información histórica (para propósito de bitácora)
				INSERT INTO [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ([ID_DeliveryOrderBySettlement],[Guide_Serie],[Guide_Number], [GuideOrder])
				SELECT @ID_Manifest,@GuideSerie,GT.[GuideNumber], GT.[Order]
				FROM @GuidesTable GT
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
			IF (@ID_Manifest > 0)
				SELECT			  
					@ID_Manifest AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END
