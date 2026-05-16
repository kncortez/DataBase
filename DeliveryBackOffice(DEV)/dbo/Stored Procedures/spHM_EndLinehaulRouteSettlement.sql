/* =================================================
   SP:        [<dbo>].[<spHM_EndLinehaulRouteSettlement>]
   Propósito: <End settlement process>
   Autor:     <Jerson Ochoa>
   Historia:  <>
   Fecha:     2022-08-24
============================================
=== CHANGELOG ================================
2026-03-25 | Historia/épica: <FDAPI-6009> | Autor: <Erick Hernandez> |
2026-03-25 | Historia/épica: <FDAPI-5925> | Autor: Brandon Pedroza   | Registro de inventario en liquidación
2026-05-15 | Historia/épica: <FDAPI-6096> | Autor: Brandon Pedroza   | Agrega bandera para indicar si sera preparacion automatica, no ingresar a inventario.
=========================================== */
CREATE PROCEDURE [dbo].[spHM_EndLinehaulRouteSettlement]
	@LinehaulRouteSettlementId AS INT,
	@TknUser AS NVARCHAR(50),
	@StationId AS INT = NULL,
	@IsAutomaticPreparation AS BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRS AS INT;					-- LinehaulRouteSettlement
	DECLARE @LRP_ID AS INT;							-- LinehaulRouteSettlement
	DECLARE @PIECES_MISSING_IN_SETTLEMENT AS INT;	-- LinehaulRouteSettlement
	DECLARE @LIQUIDATED_STATUS_ID AS INT;			-- CatLinehaulStatus
	DECLARE @IN_TRANSIT_STATUS_ID AS INT;			-- CatLinehaulStatus
	DECLARE @Status INT
	DECLARE @IN_TRANSIT_STATUS_ID_STATUSORDER AS INT = 19;	--StatusOrder
	DECLARE @StatusTrasladadoAHub INT = 44;

	SELECT  
		@LIQUIDATED_STATUS_ID = MAX(CASE WHEN StatusName = 'LIQUIDATED' THEN IdCatLinehaulStatus END),
		@IN_TRANSIT_STATUS_ID = MAX(CASE WHEN StatusName = 'IN TRANSIT' THEN IdCatLinehaulStatus END)
	FROM [DeliveryBackOffice].[dbo].[CatLinehaulStatus];

	SELECT 
		@EXISTING_LRS = CASE WHEN CatLinehaulStatusId <> @LIQUIDATED_STATUS_ID THEN 1 ELSE 0 END,
		@LRP_ID = LinehaulRoutePreparationId
	FROM [DeliveryBackOffice].[dbo].[LinehaulRouteSettlement] WITH (NOLOCK)
	WHERE IdLinehaulRouteSettlement = @LinehaulRouteSettlementId;

	SET @Status = 55; -- 'En Revision LH'

	SELECT @PIECES_MISSING_IN_SETTLEMENT = COUNT(1)
		FROM [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH (NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
		ON LRPCD.IdLinehaulRoutePreparationContainerDetail = LRPCDP.LinehaulRoutePreparationContainerDetailId
	INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
		ON LRPCD.LinehaulRoutePreparationContainerId = LRPC.IdLinehaulRoutePreparationContainer
	WHERE LRPCDP.ActCode IS NULL
		AND LRPCDP.CatLinehaulStatusId = @IN_TRANSIT_STATUS_ID
		AND LRPCD.RowStatus = 1
		AND LRPC.LinehaulRoutePreparationId = @LRP_ID;

	IF (@EXISTING_LRS = 0)
	-- SETTLEMENT DOESN'T EXIST
	BEGIN
		SELECT 0 [spResult], 'NO se encontró ningún manifiesto de liquidación activo con los datos ingresados.' [spMessage];
		RETURN;
	END

	BEGIN TRY
	
		CREATE TABLE #GuidesTmp (GuideSerie NVARCHAR(2), GuideNumber INT, PiecesNumber INT);

		CREATE INDEX IX_Guides_SerieNumero
		ON #GuidesTmp (GuideSerie, GuideNumber);	
		
		CREATE INDEX IX_Guides_SerieNumeroPiece
		ON #GuidesTmp (GuideSerie, GuideNumber,PiecesNumber);

		CREATE TABLE #GuidesTmpLiq (GuideSerie NVARCHAR(2), GuideNumber INT, PiecesNumber INT);

		CREATE INDEX IX_Guides_SerieNumeroLiq
		ON #GuidesTmpLiq (GuideSerie, GuideNumber);	

		CREATE INDEX IX_Guides_SerieNumeroPieceLiq
		ON #GuidesTmpLiq (GuideSerie, GuideNumber,PiecesNumber);
		
		BEGIN TRANSACTION;
		IF (@PIECES_MISSING_IN_SETTLEMENT > 0) -- PIECES MISSING IN SETTLEMENT
		BEGIN				
			-- SE PASAN A ESTADO EN REVISION LAS GUIAS MULTIPIEZAS NO ESCANEADAS
			INSERT INTO #GuidesTmp (GuideSerie, GuideNumber, PiecesNumber)
			SELECT DISTINCT
				LRPCD.GuideSerie,
				LRPCD.GuideNumber,
				LRPCDP.PieceNumber
			FROM [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
				ON LRPCDP.LinehaulRoutePreparationContainerDetailId = LRPCD.IdLinehaulRoutePreparationContainerDetail
			INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
				ON LRPCD.LinehaulRoutePreparationContainerId = LRPC.IdLinehaulRoutePreparationContainer
			WHERE LRPCDP.CatLinehaulStatusId = @IN_TRANSIT_STATUS_ID
				AND LRPCDP.ActCode IS NULL
				AND LRPCD.RowStatus = 1
				AND LRPC.LinehaulRoutePreparationId = @LRP_ID;

			--CREAMOS LOG DE CAMBIO DE ESTADO
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, RowStatus, StationId)
			SELECT DISTINCT G.GuideSerie,
				G.GuideNumber,
				@Status,
				@TknUser,
				GETDATE(),
				GETDATE(),
				1,
				@StationId
			FROM #GuidesTmp G
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
				ON DO.Guide_Serie = G.GuideSerie AND DO.Guide_Number = G.GuideNumber
			WHERE ISNULL(DO.StatusOrderId, 0) = @IN_TRANSIT_STATUS_ID_STATUSORDER;
			
			-- Se actualiza estado en la DeliveryOrder
			UPDATE DO
			SET DO.StatusOrderId = @Status
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
			INNER JOIN #GuidesTmp T
				ON DO.Guide_Serie = T.GuideSerie
				AND DO.Guide_Number = T.GuideNumber
			WHERE ISNULL(DO.StatusOrderId, 0) = @IN_TRANSIT_STATUS_ID_STATUSORDER;
		END

		--                              INICIO REGISTRO INVENTARIO
		DECLARE @RackPosition NVARCHAR(60);
		DECLARE @StatusInv INT = 10; -- En Inventario ->StatusOrder
		SELECT @RackPosition = ISNULL(RackPositionDefault,'10#DEF000#PAL001')
		FROM [DeliveryBackOffice].[dbo].[CatStation] WITH(NOLOCK)
		WHERE IdStation = @StationId;
		--si no es preparacion automatica, registrar en inventario
		IF (@IsAutomaticPreparation = 0)
		BEGIN
			--Guarda guias que no tengan piezas que esten en transito
			INSERT INTO #GuidesTmpLiq (GuideSerie, GuideNumber, PiecesNumber)
			SELECT DISTINCT
				LRPCD.GuideSerie,
				LRPCD.GuideNumber,
				LRPCDP.PieceNumber
			FROM [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
				ON LRPCDP.LinehaulRoutePreparationContainerDetailId = LRPCD.IdLinehaulRoutePreparationContainerDetail
			INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
				ON LRPCD.LinehaulRoutePreparationContainerId = LRPC.IdLinehaulRoutePreparationContainer
			WHERE 
				LRPCDP.CatLinehaulStatusId = @LIQUIDATED_STATUS_ID
				AND LRPCDP.ActCode IS NULL
				AND LRPCD.RowStatus = 1
				AND LRPC.LinehaulRoutePreparationId = @LRP_ID
				AND NOT EXISTS (
					SELECT 1
					FROM #GuidesTmp GT
					WHERE GT.GuideSerie = LRPCD.GuideSerie
					  AND GT.GuideNumber = LRPCD.GuideNumber
				);

			--CREAMOS LOG DE CAMBIO DE ESTADO
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, RowStatus, StationId)
			SELECT DISTINCT G.GuideSerie,
				G.GuideNumber,
				@StatusInv,
				@TknUser,
				GETDATE(),
				GETDATE(),
				1,
				@StationId
			FROM #GuidesTmpLiq G
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
				ON DO.Guide_Serie = G.GuideSerie AND DO.Guide_Number = G.GuideNumber
			WHERE DO.StatusOrderId = @StatusTrasladadoAHub
			
			-- Se actualiza estado en la DeliveryOrder
			UPDATE DO
			SET DO.StatusOrderId = @StatusInv
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
			INNER JOIN #GuidesTmpLiq T
				ON DO.Guide_Serie = T.GuideSerie
				AND DO.Guide_Number = T.GuideNumber
			WHERE DO.StatusOrderId = @StatusTrasladadoAHub 

			-- Se actualiza estado en la DeliveryOrderPiece 
			UPDATE DOP
			SET	DOP.StatusOrderId = @StatusInv,
				DOP.PieceUpdated = @TknUser,
				DOP.DateUpdated = GETDATE()
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
			INNER JOIN #GuidesTmpLiq T
				ON DOP.GuideSerie = T.GuideSerie
				AND DOP.GuideNumber = T.GuideNumber
				AND DOP.NoPiece = T.PiecesNumber

			--ingreso a inventario
			-- Insertar nueva ubicación
			INSERT INTO [DeliveryBackOffice].[dbo].[Warehouse] 
				(Rack_Position, Guide_Serie, Guide_Number, Dry, Cold, Active, UserCreated, DateCreated, Guide_Piece, IsReturn, HubExc, IdHubExc, StatusOrderId, StationId) 
			SELECT	@RackPosition,
					T.GuideSerie,
					T.GuideNumber,
					1,
					0,
					1,
					@TknUser,
					GETDATE(),
					T.PiecesNumber,
					0,
					'HUB',
					0,
					@StatusInv,
					@StationId
			FROM #GuidesTmpLiq T

			--                          FIN REGISTRO DE INVENTARIO
		END

		-- CLOSE DISPATCH CONTAINERS
		UPDATE	[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer]
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
		WHERE	[LinehaulRoutePreparationId] = @LRP_ID
			AND	[CatLinehaulStatusId] = @IN_TRANSIT_STATUS_ID;

		-- CLOSE DISPATCH
		UPDATE	[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation]
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID,
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdLinehaulRoutePreparation] = @LRP_ID;

		-- END SETTLEMENT 
		UPDATE	[DeliveryBackOffice].[dbo].[LinehaulRouteSettlement]
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID,
				[EndDateLinehaulRouteSettlement] = SYSDATETIME(),
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;


		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION

		SELECT 1 [spResult], 'Liquidación de linehaul ha sido finalizada con éxito.' [spMessage];

		SELECT CONCAT(LRPCD.GuideSerie, LRPCD.GuideNumber,'-', LRPCDP.PieceNumber) AS Guides
		FROM dbo.LinehaulRoutePreparationContainerDetailPiece LRPCDP WITH (NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
			ON LRPCDP.LinehaulRoutePreparationContainerDetailId = LRPCD.IdLinehaulRoutePreparationContainerDetail
		INNER JOIN [DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
			ON LRPCD.LinehaulRoutePreparationContainerId = LRPC.IdLinehaulRoutePreparationContainer
		INNER JOIN #GuidesTmp GT 
			ON LRPCD.GuideSerie = GT.GuideSerie
				AND LRPCD.GuideNumber = GT.GuideNumber			
				AND LRPCDP.PieceNumber = GT.PiecesNumber
		WHERE LRPCDP.CatLinehaulStatusId = @IN_TRANSIT_STATUS_ID
			AND LRPCDP.ActCode IS NULL
			AND LRPCD.RowStatus = 1
			AND LRPC.LinehaulRoutePreparationId = @LRP_ID;
		
	END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            0 AS spResult,
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure;
        RETURN;
    END CATCH
END