-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <22-08-2022>
-- Description:	<Liquidate a full container in Linehaul Settlement>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_LiquidateFullContainerLinehaulSettlement]
	@LinehaulRouteSettlementId AS INT,
	@LinehaulRoutePreparationId AS INT,
	@ContainerSerie AS NVARCHAR(5),
	@ContainerNumber AS NVARCHAR(15),
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CONTAINER_SERIE_ID AS INT;				-- CatTypeContainer
	DECLARE @CONTAINER_ID AS INT;					-- Container
	DECLARE @STATUS_IN_TRANSIT AS INT;				-- CatLinehaulStatus
	DECLARE @EXISTING_CONTAINER_LRPC AS INT;		-- LinehaulRoutePreparationContainer
	DECLARE @EXISTING_CONTAINER_LRSC AS INT;		-- LinehaulRouteSettlementContainer
	DECLARE @LRPC_HUB_ID AS INT;					-- LinehaulRoutePreparationContainer
	DECLARE @COUNT_DRY_QUANTITY AS INT;				-- LinehaulRouteSettlementContainer
	DECLARE @COUNT_COLD_QUANTITY AS INT;			-- LinehaulRouteSettlementContainer
	DECLARE @COUNT_GUIDE_QUANTITY AS INT;			-- LinehaulRouteSettlementContainer
	DECLARE @COUNT_CONTAINERS_RECEIVED AS INT;		-- LinehaulRouteSettlement
	DECLARE @COUNT_GUIDES_RECEIVED AS INT;			-- LinehaulRouteSettlement
	DECLARE @COUNT_PIECES_RECEIVED AS INT;			-- LinehaulRouteSettlement
	DECLARE @COUNT_PIECES_MISSING AS INT;			-- LinehaulRouteSettlement
	DECLARE @STOPOVER_STATUS_ID AS INT;				-- CatLinehaulStatus
	DECLARE @SETTLEMENT_STATUS_ORDER_ID AS INT;		-- StatusOrder
	
	SET @CONTAINER_SERIE_ID = (SELECT	[CTC].[IdCatTypeContainer]
								FROM	[dbo].[CatTypeContainer] CTC
								WHERE	[CTC].[TypeContainerSerie] = @ContainerSerie);

	SET @CONTAINER_ID = (SELECT	[C].[IdContainer]
						FROM	[DBO].[Container] C
						WHERE	[C].[CatTypeContainerId] = @CONTAINER_SERIE_ID
							AND [C].[ContainerNumber] = @ContainerNumber);
							
	SET @STATUS_IN_TRANSIT = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'IN TRANSIT');

	SET @EXISTING_CONTAINER_LRPC = (SELECT  [LRPC].[IdLinehaulRoutePreparationContainer]
									FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
									WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
										AND	[LRPC].[ContainerId] = @CONTAINER_ID
										AND [LRPC].[RowStatus] = 1
										AND [LRPC].[CatLinehaulStatusId] = @STATUS_IN_TRANSIT);

	SET @LRPC_HUB_ID = (SELECT  [LRPC].[HubDestinyId]
						FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
						WHERE	[LRPC].[IdLinehaulRoutePreparationContainer] = @EXISTING_CONTAINER_LRPC);
	
	SET @EXISTING_CONTAINER_LRSC = (SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
									FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
									WHERE	[LRSC].[ContainerId] = @CONTAINER_ID
										AND	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId);

	SET @STOPOVER_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'STOPOVER');

	SET @SETTLEMENT_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
										FROM	[dbo].[StatusOrder] SO
										WHERE	[SO].[OrderDescription] = 'En escala');

	BEGIN TRANSACTION
	BEGIN TRY
		IF (@EXISTING_CONTAINER_LRSC = 0)
			-- INSERT CONTAINER IN SETTLEMENT
			BEGIN
				INSERT INTO [dbo].[LinehaulRouteSettlementContainer]
							([LinehaulRouteSettlementId],
							 [ContainerId],
							 [HubId],
							 [GuideQuantity],
							 [DryPiecesQuantity],
							 [ColdPiecesQuantity],
							 [RowStatus], 
							 [TokenCreated],
							 [DateCreated])
					VALUES	(@LinehaulRouteSettlementId,
							 @CONTAINER_ID,
							 @LRPC_HUB_ID,
							 0,			-- GuideQuantity
							 0,			-- DryPiecesQuantity
							 0,			-- ColdPiecesQuantity
							 1,			-- RowStatus
							 @TknUser,
							 SYSDATETIME());
			END

		SET @EXISTING_CONTAINER_LRSC = (SELECT [LRSC].[IdLinehaulRouteSettlementContainer] 
										FROM [dbo].[LinehaulRouteSettlementContainer] LRSC 
										WHERE [ContainerId] = @CONTAINER_ID AND	[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId );

		-- INSERT CONTAINER DETAIL IN SETTLEMENT
		INSERT INTO [dbo].[LinehaulRouteSettlementContainerDetail]
					([LinehaulRouteSettlementContainerId],
					 [GuideSerie],
					 [GuideNumber],
					 [PiecesReceived],
					 [PiecesMissing],
					 [GuideReceived],
					 [IsOpenProcess],
					 [UserProcess],
					 [RowStatus],
					 [TokenCreated],
					 [DateCreated])
		SELECT		 @EXISTING_CONTAINER_LRSC,		
					 [LRPCD].[GuideSerie],
					 [LRPCD].[GuideNumber],
					 ([LRPCD].[ColdPieceQuantity] + [LRPCD].[DryPieceQuantity]) AS PiecesReceveid,
					 (([LRPCD].[GuideColdPieceTotal] + [LRPCD].[GuideDryPieceTotal]) - ([LRPCD].[ColdPieceQuantity] + [LRPCD].[DryPieceQuantity])) as PiecesMissing,
					 1,	-- GuideReceived
					 0,	-- IsOpenProcess
					 NULL,
					 1,	-- RowStatus
					 @TknUser,
					 SYSDATETIME()
					 FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
					 WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_CONTAINER_LRPC;

		-- INSERT CONTAINER DETAIL PIECE IN SETTLEMENT
		INSERT INTO [dbo].[LinehaulRouteSettlementContainerDetailPiece]
					([LinehaulRouteSettlementContainerDetailId],
					 [PieceNumber],
					 [IsDryPiece],
					 [ActCode],
					 [RowStatus],
					 [TokenCreated],
					 [DateCreated])
		SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail],
					[LRPCDP].[PieceNumber],
					[LRPCDP].[IsDryPiece],
					[LRPCDP].[ActCode],
					[LRPCDP].[RowStatus],
					@TknUser,
					SYSDATETIME()
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
			AND		[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_CONTAINER_LRPC
		INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
			ON		[LRSCD].[GuideSerie] = [LRPCD].[GuideSerie]
			AND		[LRSCD].[GuideNumber] = [LRPCD].[GuideNumber]
			AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_CONTAINER_LRSC;

		-- UPDATE SETTLEMENT CONTAINER COUNTERS
		SET @COUNT_DRY_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
									FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
									INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]	
										AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_CONTAINER_LRSC
									WHERE	[LRSCDP].[IsDryPiece] = 1
										AND [LRSCDP].[ActCode] IS NULL
										AND [LRSCDP].[RowStatus] = 1);

		SET @COUNT_COLD_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
									FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
									INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										ON		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_CONTAINER_LRSC
									WHERE		[LRSCDP].[IsDryPiece] = 0
										AND		[LRSCDP].[ActCode] IS NULL
										AND		[LRSCDP].[RowStatus] = 1
										AND		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]);
									
		SET @COUNT_GUIDE_QUANTITY = (SELECT  COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
									FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
									WHERE	[LRSCD].[RowStatus] = 1
										AND [LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_CONTAINER_LRSC);
									
		UPDATE	[LinehaulRouteSettlementContainer]
		SET		[GuideQuantity] = @COUNT_GUIDE_QUANTITY,
				[DryPiecesQuantity] = @COUNT_DRY_QUANTITY,
				[ColdPiecesQuantity] = @COUNT_COLD_QUANTITY
		WHERE	[IdLinehaulRouteSettlementContainer] = @EXISTING_CONTAINER_LRSC;

		-- UPDATE SETTLEMENT HEADER COUNTERS
		SET @COUNT_CONTAINERS_RECEIVED = (SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
											FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
											WHERE	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
												AND [LRSC].[RowStatus] = 1);

		SET @COUNT_GUIDES_RECEIVED = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
											ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
											AND		[LRSC].[RowStatus] = 1
											AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId);

		SET @COUNT_PIECES_RECEIVED = (SELECT		SUM([LRSCD].[PiecesReceived]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
											ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
											AND		[LRSC].[RowStatus] = 1
											AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId);

		SET @COUNT_PIECES_MISSING = (SELECT		SUM([LRSCD].[PiecesMissing]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
											ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
											AND [LRSC].[RowStatus] = 1
											AND [LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId);

		UPDATE	[LinehaulRouteSettlement]
		SET		[ContainersReceived] = @COUNT_CONTAINERS_RECEIVED,
				[GuidesReceived] = @COUNT_GUIDES_RECEIVED,
				[GuidePiecesReceived] = @COUNT_PIECES_RECEIVED,
				[GuidePiecesMissing] = @COUNT_PIECES_MISSING
		WHERE	[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;


		-- UPDATE CONTAINER IN SETTLEMENT
		UPDATE	[dbo].[LinehaulRouteSettlementContainer]
		SET		[TokenCreated] = @TknUser,
				[DateCreated] = SYSDATETIME()
		WHERE	[ContainerId] = @CONTAINER_ID
			AND	[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId;

		-- UPDATE DELIVERY ORDER STATUS
		UPDATE		DO
		SET			[StatusOrderId] = @SETTLEMENT_STATUS_ORDER_ID
		FROM		[dbo].[DeliveryOrder] DO
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[DO].[Guide_Serie] = [LRPCD].[GuideSerie]
			AND		[DO].[Guide_Number] = [LRPCD].[GuideNumber]
			AND		[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_CONTAINER_LRPC
			AND		[LRPCD].[RowStatus] = 1 ;

		-- INSERT LOG IN DELIVERY ORDER DETAIL
		INSERT INTO [dbo].[DeliveryOrderDetail]
					([Guide_Serie],
					 [Guide_Number],
					 [StatusOrderId],
					 [UserCreated],
					 [DateCreated],
					 [DateCreatedInSystem])
		SELECT		[LRPCD].[GuideSerie],
					[LRPCD].[GuideNumber],
					@SETTLEMENT_STATUS_ORDER_ID,
					@TknUser,
					SYSDATETIME(),
					SYSDATETIME()
			FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_CONTAINER_LRPC
				AND [LRPCD].[RowStatus] = 1;
		
		-- UPDATE LINEHAUL ROUTE PREPARATION CONTAINER
		UPDATE	[dbo].[LinehaulRoutePreparationContainer]
		SET		[CatLinehaulStatusId] = @STOPOVER_STATUS_ID
		WHERE	[IdLinehaulRoutePreparationContainer] = @EXISTING_CONTAINER_LRPC;

		-- UPDATE LINEHAUL ROUTE PREPARATION CONTAINER DETAIL PIECE
		UPDATE		[LRPCDP]
		SET			[CatLinehaulStatusId] = @STOPOVER_STATUS_ID
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		[LRPC].[IdLinehaulRoutePreparationContainer] = @EXISTING_CONTAINER_LRPC;


		SELECT 1 [spResult], 'Container has been liquidated successfully' [spMessage];


		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
			ERROR_NUMBER() AS [ErrorNumber],
			ERROR_SEVERITY() AS [ErrorSeverity],
			ERROR_STATE() AS [ErrorState],
			ERROR_PROCEDURE() AS [ErrorProcedure],
			ERROR_LINE() AS [ErrorLine],
			ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION
	END CATCH 


END