-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-31>
-- Description:	<Marca un marchamo como despachado en módulo del detalle ingreso de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_SetSpecialRouteDeliveryDispatch]
	-- Add the parameters for the stored procedure here
	@CustomMark NVARCHAR(50),
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @TSERoutePreparationHeaderId INT = 0
		DECLARE @CourierId INT
		DECLARE @CourierName NVARCHAR(201)
		DECLARE @CatVehicleId INT
		DECLARE @CatRouteId INT
		DECLARE @CodeRoute VARCHAR(100)
		DECLARE @GuidesCount INT
		DECLARE @PiecesDryCount INT
		DECLARE @PiecesColdCount INT
		DECLARE @Id_Manifest INT

		SELECT
			@TSERoutePreparationHeaderId = trph.IDTSERoutePreparationHeader
		   ,@CourierId = sr.ID
		   ,@CourierName = CONCAT(sr.First_Name, ' ', sr.Last_Name)
		   ,@CatVehicleId = trph.IdCatVehicle
		   ,@CatRouteId = trph.IdCatRoute
		   ,@CodeRoute = cr.CodeRoute
		FROM TSERoutePreparationHeader trph WITH (NOLOCK)
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
			ON sr.ID = trph.SenderReceiverId
		INNER JOIN CatRoute cr WITH (NOLOCK)
			ON cr.IdRoute = trph.IdCatRoute
		WHERE trph.TSECustomsMark = @CustomMark
		AND trph.HasFirstPickupProcess = 1
		AND trph.HasFirstArrivalProcess = 1
		AND trph.HasFirstDispatchProcess = 0

		IF @TSERoutePreparationHeaderId > 0
		BEGIN

			DECLARE @StatusOrderId TINYINT = ( SELECT
					StatusOrderId
				FROM StatusOrder
				WHERE OrderDescription = 'En ruta')

			SELECT
				@GuidesCount = COUNT(1)
			   ,@PiecesDryCount = SUM(ISNULL(do.Pieces_Dry, 0))
			   ,@PiecesColdCount = SUM(ISNULL(do.Pieces_Cold, 0))
			FROM TSERoutePreparationHeader trph WITH (NOLOCK)
			INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
				ON trph.IDTSERoutePreparationHeader = trpd.TSERoutePreparationHeaderID
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON trpd.GuideSerie = do.Guide_Serie
					AND trpd.GuideNumber = do.Guide_Number
			WHERE trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
			AND trph.RowStatus = 1
			AND trpd.RowStatus = 1

			UPDATE do
			SET do.StatusOrderId = @StatusOrderId
			   ,do.Courier_Name = @CourierName
			   ,do.TokenUpdated = @Token
			   ,do.DateUpdated = GETDATE()
			   ,do.Dispatched_Date = GETDATE()
			   ,do.Courier_Route = @CodeRoute
			FROM DeliveryOrder do
			INNER JOIN TSERoutePreparationDetail trpd
				ON do.Guide_Serie = trpd.GuideSerie
				AND do.Guide_Number = trpd.GuideNumber
			INNER JOIN TSERoutePreparationHeader trph
				ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
				AND trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
			WHERE trpd.RowStatus = 1
			AND trph.RowStatus = 1

			INSERT INTO DeliveryOrderDetail ([Guide_Serie],
			[Guide_Number],
			[StatusOrderId],
			[UserCreated],
			[DateCreated],
			[DateCreatedInSystem],
			[Observations],
			[Temperature_Celsius],
			[PieceId])
				SELECT
					trpd.GuideSerie
				   ,trpd.GuideNumber
				   ,@StatusOrderId
				   ,@Token
				   ,GETDATE()
				   ,GETDATE()
				   ,NULL
				   ,NULL
				   ,NULL
				FROM TSERoutePreparationDetail trpd
				INNER JOIN TSERoutePreparationHeader trph
					ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
						AND trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
				WHERE trpd.RowStatus = 1
				AND trph.RowStatus = 1
			
			-- Insertar registro en control de manifiestos de despacho
			INSERT INTO [dbo].[DeliveryOrderBySettlement] ([Date_Printed]
			, [User_Dispatched]
			, [Date_Dispatched]
			, [Pieces_Dry_Dispatched]
			, [Pieces_Cold_Dispatched]
			, [Guides_Dispatched]
			, [User_Received]
			, [Date_Received]
			, [Pieces_Dry_Received]
			, [Pieces_Cold_Received]
			, [Guides_Received]
			, [ID_Courier]
			, [Route_Dispatched]
			, [Route_Received]
			, [DispatchedStationId]
			, [CatVehicleId]
			, [CatRouteId]
			, [StartingKilometers])
				VALUES (NULL, @Token, GETDATE(), @PiecesDryCount, @PiecesColdCount, @GuidesCount, NULL, NULL, NULL, NULL, NULL, @CourierId, GETDATE(), NULL, NULL, @CatVehicleId, @CatRouteId, NULL)

			SET @ID_Manifest = SCOPE_IDENTITY()

			-- registrar nuevo intento de entrega
			INSERT INTO DeliveryAttempt ([Guide_Serie]
			, [Guide_Number]
			, [Dry]
			, [Cold]
			, [Latitude]
			, [Longitude]
			, [Delivered]
			, [ID_Courier]
			, [ID_DeliveryOrderBySettlement]
			, [User_Created]
			, [Date_Created]
			, [Guide_Piece])
				SELECT
					trpd.GuideSerie
				   ,trpd.GuideNumber
				   ,COALESCE(dop.IsDry, 1)
				   ,CASE
						WHEN dop.IsDry IS NULL THEN 0
						ELSE 1 - dop.IsDry
					END
				   ,''
				   ,''
				   ,0
				   ,@CourierId
				   ,@ID_Manifest
				   ,@Token
				   ,GETDATE()
				   ,dop.NoPiece
				FROM DeliveryOrderPiece dop WITH (NOLOCK)
				INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
					ON trpd.GuideSerie = dop.GuideSerie
						AND trpd.GuideNumber = dop.GuideNumber
				INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
					ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
						AND trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
				WHERE trpd.RowStatus = 1
				AND trph.RowStatus = 1

			-- Insertar información histórica (para propósito de bitácora)
			INSERT INTO DeliverySettlementDetail ([ID_DeliveryOrderBySettlement]
			, [Guide_Serie]
			, [Guide_Number]
			, [GuideOrder]
			, [GuideETA]
			, [DateCreated]
			, [TokenCreated])
				SELECT
					@ID_Manifest
				   ,trpd.GuideSerie
				   ,trpd.GuideNumber
				   ,NULL
				   ,NULL
				   ,GETDATE()
				   ,@Token
				FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
				INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
					ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
						AND trph.IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
				WHERE trpd.RowStatus = 1
				AND trph.RowStatus = 1
				

			UPDATE TSERoutePreparationHeader
			SET HasFirstDispatchProcess = 1
				,TokenUpdated = @Token
				,DateUpdated = GETDATE()
			WHERE IDTSERoutePreparationHeader = @TSERoutePreparationHeaderId
			AND RowStatus = 1

			COMMIT TRANSACTION;

			SELECT
				'1' 'ResultCode'
			   ,'Registros actualizados correctamente.' 'Description'
		END
		ELSE
		BEGIN

			SELECT
			'-1' 'ResultCode'
		   ,'No se encontraron registroso o no se encuentra en un flujo válido.' 'Description'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'

	END CATCH
END