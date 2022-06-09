



-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-09-16>
-- Description:	<Guarda información para generar manifiesto de despacho>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_dispatched]
		@GuideSerie NVARCHAR(2),
		@GuideNumbers NVARCHAR(MAX),
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
	-- control de guías a manipular
	DECLARE @GuidesTable AS TABLE (Guide_Number INT)

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
				-- Convertir la lista de guías separadas por coma en una tabla
				INSERT @GuidesTable
				SELECT CAST(Item AS INT) FROM DeliveryBackOffice.dbo.SplitUnlimited(@GuideNumbers,',')

				-- Actualizar todas las guías al manifiesto recién creado
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryAttempt] SET ID_DeliveryOrderBySettlement = @ID_Manifest WHERE 
				CONVERT(VARCHAR, Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)
				AND ID_Courier = @IdCourier
				AND Guide_Serie = @GuideSerie 
				AND Guide_Number IN (
					SELECT Guide_Number FROM @GuidesTable
				)

				-- Deshabilitar filas si ya existieran en otro Manifiesto
				UPDATE dsd
				SET dsd.RowStatus = 0,
					dsd.TokenUpdated = @Token,
					dsd.DateUpdated = GETDATE()
				FROM  DeliverySettlementDetail dsd
				JOIN DeliveryOrderBySettlement dobs 
					ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
				WHERE dsd.RowStatus = 1
					AND Guide_Serie = @GuideSerie AND Guide_Number IN (
						SELECT Guide_Number FROM @GuidesTable
					)
					AND CONVERT(date,dobs.Date_Dispatched) = CONVERT(date, GETDATE())

				-- Insertar información histórica (para propósito de bitácora)
				INSERT INTO [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ([ID_DeliveryOrderBySettlement],[Guide_Serie],[Guide_Number],[DateCreated],[TokenCreated])
				SELECT @ID_Manifest,@GuideSerie,Guide_Number,GETDATE(),@Token
				FROM @GuidesTable

				--establecer fecha de ruta de las guías
				UPDATE do 
				SET do.Dispatched_Date = @RouteDispatched
				FROM DeliveryOrder do
				WHERE do.Guide_Serie = @GuideSerie 
				AND do.Guide_Number IN (
					SELECT Guide_Number FROM @GuidesTable
				)

				--Revalorizar guías collect con priceshipment 0
				DECLARE @GuideNumberRevalue INT
				DECLARE @RevalueGuides AS TABLE(
					GuideNumber INT
				)
				DECLARE @CatModuleId INT = (SELECT ModIdModule FROM CatModule WHERE ModPath = 'frmCheckpoint')

				INSERT INTO @RevalueGuides
					SELECT
						gt.Guide_Number
					FROM @GuidesTable gt
					INNER JOIN DeliveryOrder do WITH (NOLOCK)
						ON do.Guide_Serie = @GuideSerie
							AND do.Guide_Number = gt.Guide_Number
					WHERE do.PriceShippment = 0
					AND do.IsCollect = 1


				WHILE EXISTS (SELECT TOP 1 1 FROM @RevalueGuides)
				BEGIN
					SELECT TOP 1
					   @GuideNumberRevalue = GuideNumber
					FROM @RevalueGuides

					EXECUTE DeliveryBackOffice.dbo.spws_revalue_guide
						@GuideSerie = @GuideSerie,
						@GuideNumber = @GuideNumberRevalue,
						@CodeApp = '',
						@Format = 'Non',
						@CalculateTaxes = 'true',
						@IdModule = @CatModuleId,
						@SetUpdate = 'true',
						@Token = @Token,
						@IsReturn = 'false'

					DELETE FROM @RevalueGuides
					WHERE GuideNumber = @GuideNumberRevalue
				END
				--Termina revalorziar guías

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