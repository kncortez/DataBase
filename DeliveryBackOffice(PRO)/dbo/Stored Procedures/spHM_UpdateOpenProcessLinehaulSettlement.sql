-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <18-08-2022>
-- Description:	<Update open process field in LinehaulRouteSettlementContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_UpdateOpenProcessLinehaulSettlement] 
	@LinehaulRouteSettlementContainerId AS INT,
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(25),
	@OpenProcess AS INT,
	@GuideReceived AS INT,
	@RowStatus AS INT,
	@TknUser AS NVARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SETTLEMENT_STATUS_ORDER_ID AS INT; -- StatusOrderId
	DECLARE @EXISTING_LRS AS INT;				-- LinehaulRouteSettlement
	DECLARE @EXISTING_LRSCD AS INT;				-- LinehaulRouteSettlementContainer
	DECLARE @COUNT_RECEIVED_PIECES AS INT;		-- LinehaulRouteSettlementContainerDetailPiece
	DECLARE @COUNT_MISSING_PIECES AS INT;		-- LinehaulRouteSettlementContainerDetailPiece
	DECLARE @COUNT_DRY_QUANTITY AS INT;			-- LinehaulRouteSettlementContainerDetailPiece
	DECLARE @COUNT_COLD_QUANTITY AS INT;		-- LinehaulRouteSettlementContainerDetailPiece
	DECLARE @COUNT_GUIDE_QUANTITY AS INT;		-- LinehaulRouteSettlementContainerDetailPiece
	DECLARE @COUNT_CONTAINERS_RECEIVED AS INT;	-- LinehaulRouteSettlementContainer
	DECLARE @COUNT_GUIDES_RECEIVED AS INT;		-- LinehaulRouteSettlementContainerDetail
	DECLARE @COUNT_PIECES_RECEIVED AS INT;		-- LinehaulRouteSettlementContainerDetail
	DECLARE @COUNT_PIECES_MISSING AS INT
	BEGIN TRANSACTION
	BEGIN TRY

		SET @EXISTING_LRS = (SELECT [LRSC].[LinehaulRouteSettlementId]
							FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
							WHERE	[LRSC].[IdLinehaulRouteSettlementContainer] = @LinehaulRouteSettlementContainerId);

		SET @SETTLEMENT_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
											FROM	[dbo].[StatusOrder] SO
											WHERE	[SO].[OrderDescription] = 'Trasladado a Hub');

		UPDATE		[LRSCDP] 
		SET			[LRSCDP].[RowStatus] = @RowStatus
		FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
		INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
			ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
			AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
			AND		[LRSCD].[GuideSerie] = @GuideSerie
			AND		[LRSCD].[GuideNumber] = @GuideNumber;

		UPDATE	[LinehaulRouteSettlementContainerDetail]
		SET		[IsOpenProcess] = @OpenProcess,
				[UserProcess] = @TknUser,
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME(),
				[RowStatus] = @RowStatus,
				[GuideReceived] = @GuideReceived
		WHERE	[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
			AND [GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber;

		-- UDPATE SETTLEMENT COUNTERS
		BEGIN
			-- UPDATE SETTLEMENT DETAIL COUNTERS
			SET @COUNT_RECEIVED_PIECES =			(SELECT  COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]	
											AND		[LRSCD].[GuideSerie] = @GuideSerie
											AND		[LRSCD].[GuideNumber] = @GuideNumber
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);

			SET @COUNT_MISSING_PIECES =	(SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]	
											AND		[LRSCD].[GuideSerie] = @GuideSerie
											AND		[LRSCD].[GuideNumber] = @GuideNumber
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
										WHERE		[LRSCDP].[ActCode] IS NOT NULL
											AND		[LRSCDP].[RowStatus] = 1);

			UPDATE	[LinehaulRouteSettlementContainerDetail]
			SET		[PiecesReceived] = @COUNT_RECEIVED_PIECES,
					[PiecesMissing] = @COUNT_MISSING_PIECES
			WHERE	[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
				AND [GuideSerie] = @GuideSerie
				AND [GuideNumber] = @GuideNumber;

			-- UPDATE SETTLEMENT CONTAINER COUNTERS
			SET @COUNT_DRY_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[IsDryPiece] = 1
											AND		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);

			SET @COUNT_COLD_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[IsDryPiece] = 0
											AND		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);
									
			SET @COUNT_GUIDE_QUANTITY = (SELECT  COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
										FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										WHERE	[LRSCD].[RowStatus] = 1
											AND	[LRSCD].[IsOpenProcess] = 0
											AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId);
									
			UPDATE	[LinehaulRouteSettlementContainer]
			SET		[GuideQuantity] = @COUNT_GUIDE_QUANTITY,
					[DryPiecesQuantity] = @COUNT_DRY_QUANTITY,
					[ColdPiecesQuantity] = @COUNT_COLD_QUANTITY
			WHERE	[IdLinehaulRouteSettlementContainer] = @LinehaulRouteSettlementContainerId;

			-- UPDATE SETTLEMENT HEADER COUNTERS
			SET @COUNT_CONTAINERS_RECEIVED = (SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
												FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
												WHERE	[LRSC].[LinehaulRouteSettlementId] = @EXISTING_LRS
													AND [LRSC].[RowStatus] = 1);

			SET @COUNT_GUIDES_RECEIVED = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[LinehaulRouteSettlementId] = @EXISTING_LRS
											WHERE		[LRSCD].[RowStatus] = 1);

			SET @COUNT_PIECES_RECEIVED = (SELECT		SUM([LRSCD].[PiecesReceived]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[LinehaulRouteSettlementId] = @EXISTING_LRS);

			SET @COUNT_PIECES_MISSING = (SELECT		SUM([LRSCD].[PiecesMissing]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[LinehaulRouteSettlementId] = @EXISTING_LRS);

			UPDATE	[LinehaulRouteSettlement]
			SET		[ContainersReceived] = @COUNT_CONTAINERS_RECEIVED,
					[GuidesReceived] = @COUNT_GUIDES_RECEIVED,
					[GuidePiecesReceived] = @COUNT_PIECES_RECEIVED,
					[GuidePiecesMissing] = @COUNT_PIECES_MISSING
			WHERE	[IdLinehaulRouteSettlement] = @EXISTING_LRS;

		END

		SELECT	[LRSCD].[IdLinehaulRouteSettlementContainerDetail],
				[LRSCD].[LinehaulRouteSettlementContainerId],
				[LRSCD].[GuideSerie],
				[LRSCD].[GuideNumber],
				[LRSCD].[IsOpenProcess],
				[LRSCD].[GuideReceived]
		FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
		WHERE	[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
			AND [LRSCD].[GuideSerie] = @GuideSerie
			AND [LRSCD].[GuideNumber] = @GuideNumber;

		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION;
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