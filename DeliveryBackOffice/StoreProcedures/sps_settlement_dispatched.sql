USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_deliveryorder_settlement]    Script Date: 20/09/2020 18:45:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




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
		@Token NVARCHAR(50)
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
				   ,[Route_Received])
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
				   ,NULL)

			SET @ID_Manifest = SCOPE_IDENTITY()

			IF (@ID_Manifest > 0)
			BEGIN
				-- Convertir la lista de guías separadas por coma en una tabla
				INSERT @GuidesTable
				SELECT CAST(Item AS INT) FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@GuideNumbers,',')

				-- Actualizar todas las guías al manifiesto recién creado
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryAttempt] SET ID_DeliveryOrderBySettlement = @ID_Manifest WHERE 
				CONVERT(VARCHAR, Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)
				AND ID_Courier = @IdCourier
				AND Guide_Serie = @GuideSerie 
				AND Guide_Number IN (
					SELECT Guide_Number FROM @GuidesTable
				)

				-- Insertar información histórica (para propósito de bitácora)
				INSERT INTO [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ([ID_DeliveryOrderBySettlement],[Guide_Serie],[Guide_Number])
				SELECT @ID_Manifest,@GuideSerie,Guide_Number
				FROM @GuidesTable
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
GO


