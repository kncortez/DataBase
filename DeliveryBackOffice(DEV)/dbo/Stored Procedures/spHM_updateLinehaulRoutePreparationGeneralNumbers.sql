-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <15-07-2022>
-- Description:	<Update LinehaulRoutePreparation, LinehaulRoutePreparationContainer and LinehaulRoutePreparationContainerDetail numbers>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_updateLinehaulRoutePreparationGeneralNumbers]
	@IdLinehaulRoutePreparation AS INT,
	@IdLinehaulRoutePreparationContainer AS INT,
	@IdLinehaulRoutePreparationContainerDetail AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;					-- LinehaulRoutePreparation

	DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT;	-- LinehaulRoutePreparationContainer
	DECLARE @GUIDE_QUANTITY_CONTAINER AS INT;		-- LinehaulRoutePreparationContainer
	DECLARE @DRY_QUANTITY_CONTAINER AS INT;			-- LinehaulRoutePreparationContainer
	DECLARE @COLD_QUANTITY_CONTAINER AS INT;		-- LinehaulRoutePreparationContainer

	DECLARE @GUIDE_QUANTITY_DETAIL AS INT;			-- LinehaulRoutePreparationContainerDetail
	DECLARE @DRY_PIECE_QUANTITY_DETAIL AS INT;		-- LinehaulRoutePreparationContainerDetail
	DECLARE @COLD_PIECE_QUANTITY_DETAIL AS INT;		-- LinehaulRoutePreparationContainerDetail

	DECLARE @DRY_PIECE_QUANTITY_PIECE AS INT;		-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @COLD_PIECE_QUANTITY_PIECE AS INT;		-- LinehaulRoutePreparationContainerDetailPiece

	SET @EXISTING_LRP = (SELECT COUNT([LRP].[IdLinehaulRoutePreparation]) 
						 FROM	[dbo].[LinehaulRoutePreparation] LRP
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation);

	IF (@EXISTING_LRP > 0)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				
				-- UPDATE LinehaulRoutePreparationContainerDetail
				-- DryPieceQuantity
				-- ColdPieceQuantity
				SET @DRY_PIECE_QUANTITY_PIECE =		(SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
													FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
													WHERE	[LRPCDP].[IsDryPiece] = 1
														AND	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @IdLinehaulRoutePreparationContainerDetail);

				SET @COLD_PIECE_QUANTITY_PIECE =	(SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
													FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
													WHERE	[LRPCDP].[IsDryPiece] = 0
														AND	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @IdLinehaulRoutePreparationContainerDetail);

				UPDATE	[LinehaulRoutePreparationContainerDetail]
				SET		[DryPieceQuantity] =							@DRY_PIECE_QUANTITY_PIECE,
						[ColdPieceQuantity]=							@COLD_PIECE_QUANTITY_PIECE
				WHERE	[IdLinehaulRoutePreparationContainerDetail] =	@IdLinehaulRoutePreparationContainerDetail;

				-- UPDATE LinehaulRoutePreparationContainer
				-- GuideQuantity
				-- DryPieceQuantity
				-- ColdPieceQuantity

				SET @GUIDE_QUANTITY_DETAIL =	(SELECT COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail])
												FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
												WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @IdLinehaulRoutePreparationContainer);

				SET @DRY_PIECE_QUANTITY_DETAIL =(SELECT COALESCE(SUM([LRPCD].[DryPieceQuantity]), 0)
												FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
												WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @IdLinehaulRoutePreparationContainer);

				SET @COLD_PIECE_QUANTITY_DETAIL=(SELECT COALESCE(SUM([LRPCD].[ColdPieceQuantity]), 0)
												FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
												WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @IdLinehaulRoutePreparationContainer);

				UPDATE	[LinehaulRoutePreparationContainer]
				SET		[GuideQuantity] =						@GUIDE_QUANTITY_DETAIL,
						[DryPieceQuantity] =					@DRY_PIECE_QUANTITY_DETAIL,
						[ColdPieceQuantity] =					@COLD_PIECE_QUANTITY_DETAIL
				WHERE	[IdLinehaulRoutePreparationContainer] = @IdLinehaulRoutePreparationContainer;

				-- UPDATE LinehaulRoutePreparation
				-- ContainerQuantity
				-- GuideQuantity
				-- DryPieceQuantity
				-- ColdPieceQuantity

				SET @CONTAINER_QUANTITY_CONTAINER = (SELECT COUNT([LRPC].[ContainerId])
													FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
													WHERE	[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation);

				SET @GUIDE_QUANTITY_CONTAINER = (SELECT COALESCE(SUM([LRPC].[GuideQuantity]), 0)
												FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
												WHERE	[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation);

				SET @DRY_QUANTITY_CONTAINER =	(SELECT COALESCE(SUM([LRPC].[DryPieceQuantity]), 0)
												FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
												WHERE	[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation);

				SET @COLD_QUANTITY_CONTAINER =	(SELECT COALESCE(SUM([LRPC].[ColdPieceQuantity]), 0)
												FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
												WHERE	[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation);

				UPDATE	[LinehaulRoutePreparation]
				SET		[ContainerQuantity] =			@CONTAINER_QUANTITY_CONTAINER,
						[GuideQuantity] =				@GUIDE_QUANTITY_CONTAINER,
						[DryPieceQuantity] =			@DRY_QUANTITY_CONTAINER,
						[ColdPieceQuantity] =			@COLD_QUANTITY_CONTAINER
				WHERE	[IdLinehaulRoutePreparation] =	@IdLinehaulRoutePreparation;

				SELECT 1 [spResult], 'Success' [spMessage];

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
END