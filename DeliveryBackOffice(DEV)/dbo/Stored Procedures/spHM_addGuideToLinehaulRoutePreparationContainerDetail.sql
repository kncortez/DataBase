-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <14-07-2022>
-- Description:	<Add guide to LinehaulRoutePreparationContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_addGuideToLinehaulRoutePreparationContainerDetail]
	@LinehaulRoutePreparationId AS INT,
	@LinehaulRoutePreparationContainerId AS INT,
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(25),
	@PiecesDryTotal AS INT,
	@PiecesColdTotal AS INT,
	@IsOpenProcess AS INT,
	@PieceNumber AS INT,
	@IsSettlement AS INT,
	@IdHub AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;					-- LinehaulRoutePreparation
	DECLARE @EXISTING_LRPCD AS INT;					-- LinehaulRoutePreparationContainerDetail
	DECLARE @EXISTING_LRPCDP AS INT;				-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT;	-- LinehaulRoutePreparationContainer
	DECLARE @GUIDE_QUANTITY_CONTAINER AS INT;		-- LinehaulRoutePreparationContainer
	DECLARE @DRY_QUANTITY_CONTAINER AS INT;			-- LinehaulRoutePreparationContainer
	DECLARE @COLD_QUANTITY_CONTAINER AS INT;		-- LinehaulRoutePreparationContainer
	DECLARE @GUIDE_QUANTITY_DETAIL AS INT;			-- LinehaulRoutePreparationContainerDetail
	DECLARE @DRY_PIECE_QUANTITY_DETAIL AS INT;		-- LinehaulRoutePreparationContainerDetail
	DECLARE @COLD_PIECE_QUANTITY_DETAIL AS INT;		-- LinehaulRoutePreparationContainerDetail
	DECLARE @DRY_PIECE_QUANTITY_PIECE AS INT;		-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @COLD_PIECE_QUANTITY_PIECE AS INT;		-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @STATUS_ORDER_ID AS INT;				-- StatusOrder
	DECLARE @DELIVERY_ORDER_PIECE AS INT;			-- DeliveryOrderPiece
	DECLARE @IS_DRY AS INT;							-- DeliveryOrderPiece
	DECLARE @CONTAINER_HUB AS INT;					-- LinehaulRoutePreparationContainer

	SET @CONTAINER_HUB = (SELECT COALESCE([LRPC].[HubDestinyId], 0) AS HubDestiny
						  FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
						  WHERE	[LRPC].[IdLinehaulRoutePreparationContainer] = @LinehaulRoutePreparationContainerId);

	-- Check deliveryOrderPiece
	SET @IS_DRY = (SELECT	[DOP].[IsDry]
					FROM	[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					WHERE	[DOP].[GuideSerie] = @GuideSerie
						AND	[DOP].[GuideNumber] = @GuideNumber
						AND [DOP].[NoPiece] = @PieceNumber);

	IF (@IS_DRY IS NULL)
		BEGIN
			SELECT 3 [spResult], 'Pieza NO válida.' [spMessage];
			RETURN;
		END

	SET @EXISTING_LRP = (SELECT COUNT([LRP].[IdLinehaulRoutePreparation]) 
						 FROM	[dbo].[LinehaulRoutePreparation] LRP
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId);

	IF (@EXISTING_LRP = 0)
		BEGIN
			SELECT 0 [spResult], 'Preparación de ruta de linehaul NO existe' [spMessage];
			RETURN;
		END

	IF (@CONTAINER_HUB != 0 AND @CONTAINER_HUB != @IdHub)
		BEGIN
			SELECT 6 [spResult], 'Guía y contenedor tienen un HUB destino diferente' [spMessage];
			RETURN;
		END
	
	-- Check if there is a record in LinehaulRoutePreparationContainerDetail with same data
	SET @EXISTING_LRPCD = (SELECT COUNT([LRPD].[IdLinehaulRoutePreparationContainerDetail])
						FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPD
						WHERE	[LRPD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
							AND	[LRPD].[GuideSerie] = @GuideSerie
							AND [LRPD].[GuideNumber] = @GuideNumber);

	-- Get StatusOrderId
	IF (@IsSettlement = 0)
		BEGIN
			SET @STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'En preparación de traslado');
		END
	ELSE
		BEGIN
			SET @STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Arribó a las instalaciones');
		END

	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE [LinehaulRoutePreparationContainer]
		SET [HubDestinyId] = @IdHub
		WHERE [IdLinehaulRoutePreparationContainer] = @LinehaulRoutePreparationContainerId;

		IF (@EXISTING_LRPCD = 0)
			BEGIN
			-- Create document
				INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetail]
							([LinehaulRoutePreparationContainerId],
							 [GuideSerie],
							 [GuideNumber],
							 [GuideDryPieceTotal],
							 [GuideColdPieceTotal],
							 [DryPieceQuantity],
							 [ColdPieceQuantity],
							 [IsOpenProcess],
							 [RowStatus],
							 [TokenCreated],
							 [DateCreated])
					VALUES	(@LinehaulRoutePreparationContainerId,
							 @GuideSerie,
							 @GuideNumber,
							 @PiecesDryTotal,
							 @PiecesColdTotal,
							 0,				-- DryPiecesQuantity
							 0,				-- ColdPiecesQuantity
							 @IsOpenProcess,
							 1,				-- RowStatus
							 @TknUser,
							 SYSDATETIME());
			END

		SET @EXISTING_LRPCD = (SELECT	[LRPD].[IdLinehaulRoutePreparationContainerDetail]
								FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPD
								WHERE	[LRPD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
									AND	[LRPD].[GuideSerie] = @GuideSerie
									AND [LRPD].[GuideNumber] = @GuideNumber);

		-- Document already exists, return data, only update token created AND open process value
		UPDATE	[LinehaulRoutePreparationContainerDetail]	
		SET		[TokenCreated] = @TknUser, 
				[IsOpenProcess] = @IsOpenProcess,
				[RowStatus] = 1
		WHERE	[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND	[GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber;

		-- Starts Piece process -------------------------------------------------------------------------------------------------

		SET @EXISTING_LRPCDP = (SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]) AS CONT
								FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
								WHERE	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
									AND [LRPCDP].[PieceNumber] = @PieceNumber);

		IF (@EXISTING_LRPCDP = 0)
			BEGIN
				-- INSERT PIECE
				INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetailPiece]
								([LinehaulRoutePreparationContainerDetailId],
								[CatLinehaulStatusId],
								[PieceNumber],
								[IsDryPiece],
								[RowStatus],
								[TokenCreated],
								[DateCreated])
						VALUES	(@EXISTING_LRPCD,
								(SELECT [CLS].[IdCatLinehaulStatus] FROM [dbo].[CatLinehaulStatus] CLS WHERE [CLS].[StatusName] = 'PREPARATION FOR TRANSFER'),
								@PieceNumber,
								@IS_DRY,
								1,		-- Row Status
								@TknUser,
								SYSDATETIME());
			END

			SET @EXISTING_LRPCDP = (SELECT	[LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]
									FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
									WHERE	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
										AND [LRPCDP].[PieceNumber] = @PieceNumber);

			UPDATE	[dbo].[LinehaulRoutePreparationContainerDetailPiece]
			SET		[RowStatus] = 1,
					[TokenUpdated] = @TknUser,
					[DateUpdated] = SYSDATETIME()
			WHERE	[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
						AND	[PieceNumber] = @PieceNumber;

		-- End Piece process -----------------------------------------------------------------------------------------------------

		-- UPDATE DeliveryOrderPiece Status
		UPDATE	[DeliveryOrderPiece]
		SET		[StatusOrderId] = @STATUS_ORDER_ID
		WHERE	[GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber
			AND [NoPiece] = @PieceNumber;

		-- Starts Update General Numbers -----------------------------------------------------------------------------------------
		-- UPDATE LinehaulRoutePreparationContainerDetail
		SELECT		@DRY_PIECE_QUANTITY_PIECE = COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
			AND		[LRPCD].[IsOpenProcess] = 0
		WHERE		[LRPCDP].[IsDryPiece] = 1
			AND		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
			AND		[LRPCDP].[RowStatus] = 1
			AND		[LRPCDP].[ActCode] IS NULL;

		SELECT		@COLD_PIECE_QUANTITY_PIECE = COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
			AND		[LRPCD].[IsOpenProcess] = 0
		WHERE		[LRPCDP].[IsDryPiece] = 0
			AND		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
			AND		[LRPCDP].[RowStatus] = 1
			AND		[LRPCDP].[ActCode] IS NULL;

		UPDATE	[LinehaulRoutePreparationContainerDetail]
		SET		[DryPieceQuantity] =							@DRY_PIECE_QUANTITY_PIECE,
				[ColdPieceQuantity] =							@COLD_PIECE_QUANTITY_PIECE
		WHERE	[IdLinehaulRoutePreparationContainerDetail] =	@EXISTING_LRPCD;

		-- UPDATE LinehaulRoutePreparationContainer

		SET @GUIDE_QUANTITY_DETAIL =	(SELECT COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail])
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
											AND [LRPCD].[IsOpenProcess] = 0
											AND [LRPCD].[RowStatus] = 1);

		SELECT @DRY_PIECE_QUANTITY_DETAIL = COALESCE(SUM([LRPCD].[DryPieceQuantity]), 0), @COLD_PIECE_QUANTITY_DETAIL = COALESCE(SUM([LRPCD].[ColdPieceQuantity]), 0)
		FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND [LRPCD].[IsOpenProcess] = 0
			AND [LRPCD].[RowStatus] = 1;

		UPDATE	[LinehaulRoutePreparationContainer]
		SET		[GuideQuantity] =						@GUIDE_QUANTITY_DETAIL,
				[DryPieceQuantity] =					@DRY_PIECE_QUANTITY_DETAIL,
				[ColdPieceQuantity] =					@COLD_PIECE_QUANTITY_DETAIL
		WHERE	[IdLinehaulRoutePreparationContainer] = @LinehaulRoutePreparationContainerId;

		-- UPDATE LinehaulRoutePreparation

		SET @CONTAINER_QUANTITY_CONTAINER = (SELECT COUNT([LRPC].[ContainerId])
											FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
											WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
												AND [LRPC].[RowStatus] = 1);

		SELECT	@GUIDE_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[GuideQuantity]), 0), 
				@DRY_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[DryPieceQuantity]), 0), 
				@COLD_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[ColdPieceQuantity]), 0)
		FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
		WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
			AND [LRPC].[RowStatus] = 1;

		UPDATE	[LinehaulRoutePreparation]
		SET		[ContainerQuantity] =			@CONTAINER_QUANTITY_CONTAINER,
				[GuideQuantity] =				@GUIDE_QUANTITY_CONTAINER,
				[DryPieceQuantity] =			@DRY_QUANTITY_CONTAINER,
				[ColdPieceQuantity] =			@COLD_QUANTITY_CONTAINER
		WHERE	[IdLinehaulRoutePreparation] =	@LinehaulRoutePreparationId;
		-- End Update General Numbers --------------------------------------------------------------------------------------------

		SELECT		[LRPCD].[IdLinehaulRoutePreparationContainerDetail],
					[LRPCD].[LinehaulRoutePreparationContainerId],
					[LRPCD].[GuideSerie],
					[LRPCD].[GuideNumber],
					[LRPCD].[GuideDryPieceTotal],
					[LRPCD].[GuideColdPieceTotal],
					[LRPCD].[DryPieceQuantity],
					[LRPCD].[ColdPieceQuantity],
					[LRPCD].[IsOpenProcess],
					[LRPCDP].[PieceNumber],
					[LRPCDP].[IsDryPiece],
					[LRPCDP].[TokenCreated],
					[LRPCDP].[TokenUpdated]
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
			AND		[LRPCD].[GuideSerie] = @GuideSerie
			AND		[LRPCD].[GuideNumber] = @GuideNumber
			AND		[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
		WHERE		[LRPCDP].[ActCode] IS NULL
			AND		[LRPCDP].[RowStatus] = 1
			AND		([LRPCDP].[TokenCreated] = @TknUser
			OR		[LRPCDP].[TokenUpdated] = @TknUser)

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
				ERROR_MESSAGE() AS [spMessage];

		ROLLBACK TRANSACTION
	END CATCH
END
