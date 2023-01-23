-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <12-12-2022>
-- Description:	<Validate and close open process with complete pieces>
-- =============================================
CREATE PROCEDURE spHM_completeOpenProcessLinehaulDispatch
	@LinehaulRoutePreparationContainerId AS INT,
	@GuideSerie AS NVARCHAR(10),
	@GuideNumber AS NVARCHAR(15),
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @STATUS_DISPATCH AS INT;				-- StatusOrder
	DECLARE @EXISTING_LRP AS INT;					-- LinehaulRoutePreparation
	DECLARE @EXISTING_LRPCD AS INT;					-- LinehaulRoutePreparationContainerDetail
	DECLARE @DRY_PIECE_QUANTITY_PIECE AS INT;		-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @COLD_PIECE_QUANTITY_PIECE AS INT;		-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @GUIDE_QUANTITY_DETAIL AS INT;			-- LinehaulRoutePreparationContainerDetail
	DECLARE @DRY_PIECE_QUANTITY_DETAIL AS INT;		-- LinehaulRoutePreparationContainerDetail
	DECLARE @COLD_PIECE_QUANTITY_DETAIL AS INT;		-- LinehaulRoutePreparationContainerDetail
	DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT;	-- LinehaulRoutePreparationContainer
	DECLARE @GUIDE_QUANTITY_CONTAINER AS INT;		-- LinehaulRoutePreparationContainer
	DECLARE @DRY_QUANTITY_CONTAINER AS INT;			-- LinehaulRoutePreparationContainer
	DECLARE @COLD_QUANTITY_CONTAINER AS INT;		-- LinehaulRoutePreparationContainer
	DECLARE @IS_STATUS_UPDATED AS INT;				-- DeliveryOrder

	BEGIN TRANSACTION
	BEGIN TRY
		
		SET @STATUS_DISPATCH =(SELECT	[SO].[StatusOrderId]
								FROM	[dbo].[StatusOrder] SO
								WHERE	[SO].[OrderDescription] = 'En preparación de traslado');

		UPDATE	[LRPCDP]
		SET		[LRPCDP].[RowStatus] = 1
		FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
				AND	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
				AND	[LRPCD].[GuideSerie] = @GuideSerie
				AND	[LRPCD].[GuideNumber] = @GuideNumber
				AND	[LRPCD].[ColdPieceQuantity] = [LRPCD].[GuideColdPieceTotal]
				AND	[LRPCD].[DryPieceQuantity] = [LRPCD].[GuideDryPieceTotal];

		UPDATE	[LinehaulRoutePreparationContainerDetail]
		SET		[IsOpenProcess] = 0,
				[DateUpdated] = SYSDATETIME(),
				[RowStatus] = 1
		WHERE	[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND [GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber
			AND [ColdPieceQuantity] = [GuideColdPieceTotal]
			AND	[DryPieceQuantity] = [GuideDryPieceTotal];

		SET @EXISTING_LRP = (SELECT [LRPC].[LinehaulRoutePreparationId]
							FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
							WHERE	[LRPC].[IdLinehaulRoutePreparationContainer] = @LinehaulRoutePreparationContainerId);

		SET @EXISTING_LRPCD = (SELECT	[LRPCD].[IdLinehaulRoutePreparationContainerDetail]
								FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
								WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
								AND		[LRPCD].[GuideSerie] = @GuideSerie
								AND		[LRPCD].[GuideNumber] = @GuideNumber);

		-- UPDATE GENERAL NUMBERS
		-- UPDATE LinehaulRoutePreparationContainerDetail
		SET @DRY_PIECE_QUANTITY_PIECE =		(SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
											FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
											INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
												ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
												AND		[LRPCD].[RowStatus] = 1
												AND		[LRPCD].[IsOpenProcess] = 0
											WHERE		[LRPCDP].[IsDryPiece] = 1
												AND		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
												AND		[LRPCDP].[RowStatus] = 1
												AND		[LRPCDP].[ActCode] IS NULL);

		SET @COLD_PIECE_QUANTITY_PIECE =	(SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
											FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
											INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
												ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
												AND		[LRPCD].[RowStatus] = 1
												AND		[LRPCD].[IsOpenProcess] = 0
											WHERE		[LRPCDP].[IsDryPiece] = 0
												AND		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
												AND		[LRPCDP].[RowStatus] = 1
												AND		[LRPCDP].[ActCode] IS NULL);

		UPDATE	[LinehaulRoutePreparationContainerDetail]
		SET		[DryPieceQuantity] =							@DRY_PIECE_QUANTITY_PIECE,
				[ColdPieceQuantity] =							@COLD_PIECE_QUANTITY_PIECE
		WHERE	[IdLinehaulRoutePreparationContainerDetail] =	@EXISTING_LRPCD;

		-- UPDATE LinehaulRoutePreparationContainer

		SET @GUIDE_QUANTITY_DETAIL =	(SELECT COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail])
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
											AND	[LRPCD].[IsOpenProcess] = 0
											AND [LRPCD].[RowStatus] = 1);

		SELECT	@DRY_PIECE_QUANTITY_DETAIL = COALESCE(SUM([LRPCD].[DryPieceQuantity]), 0), 
				@COLD_PIECE_QUANTITY_DETAIL= COALESCE(SUM([LRPCD].[ColdPieceQuantity]), 0)
		FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND [LRPCD].[RowStatus] = 1;

		UPDATE	[LinehaulRoutePreparationContainer]
		SET		[GuideQuantity] =						@GUIDE_QUANTITY_DETAIL,
				[DryPieceQuantity] =					@DRY_PIECE_QUANTITY_DETAIL,
				[ColdPieceQuantity] =					@COLD_PIECE_QUANTITY_DETAIL
		WHERE	[IdLinehaulRoutePreparationContainer] = @LinehaulRoutePreparationContainerId;

		-- UPDATE LinehaulRoutePreparation

		SET @CONTAINER_QUANTITY_CONTAINER = (SELECT COUNT([LRPC].[ContainerId])
											FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
											WHERE	[LRPC].[LinehaulRoutePreparationId] = @EXISTING_LRP
												AND [LRPC].[RowStatus] = 1);

		SELECT	@GUIDE_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[GuideQuantity]), 0),
				@DRY_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[DryPieceQuantity]), 0),
				@COLD_QUANTITY_CONTAINER = COALESCE(SUM([LRPC].[ColdPieceQuantity]), 0)
		FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
		WHERE	[LRPC].[LinehaulRoutePreparationId] = @EXISTING_LRP
			AND [LRPC].[RowStatus] = 1;

		UPDATE	[LinehaulRoutePreparation]
		SET		[ContainerQuantity] =			@CONTAINER_QUANTITY_CONTAINER,
				[GuideQuantity] =				@GUIDE_QUANTITY_CONTAINER,
				[DryPieceQuantity] =			@DRY_QUANTITY_CONTAINER,
				[ColdPieceQuantity] =			@COLD_QUANTITY_CONTAINER
		WHERE	[IdLinehaulRoutePreparation] =	@EXISTING_LRP;

		SET @IS_STATUS_UPDATED =	(SELECT [DOD].[StatusOrderId]
									FROM	[dbo].[DeliveryOrder] DOD WITH(NOLOCK)
									WHERE	[DOD].[Guide_Serie] = @GuideSerie
										AND [DOD].[Guide_Number] = @GuideNumber);

		-- UPDATE DeliveryOrderDetail
		IF (@IS_STATUS_UPDATED != @STATUS_DISPATCH) 
			BEGIN
				INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
							([Guide_Serie],
							 [Guide_Number],
							 [StatusOrderId],
							 [UserCreated],
							 [DateCreated],
							 [DateCreatedInSystem],
							 [RowStatus])
					VALUES	(@GuideSerie,
							 @GuideNumber,
							 @STATUS_DISPATCH,
							 @TknUser,
							 SYSDATETIME(),
							 SYSDATETIME(),
							 1);

				UPDATE	[DeliveryOrder]
				SET		[StatusOrderId] = @STATUS_DISPATCH,
						[TokenUpdated] = @TknUser,
						[DateUpdated] = SYSDATETIME()
				WHERE	[Guide_Serie] = @GuideSerie
					AND [Guide_Number] = @GuideNumber;

			END

			SELECT 1 [spResult], 'Guía con proceso abierto ha sido procesada' [spMessage];

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