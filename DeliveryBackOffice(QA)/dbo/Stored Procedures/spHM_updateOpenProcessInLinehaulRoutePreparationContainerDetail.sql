-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <21-07-2022>
-- Description:	<UPDATE an Open process in LinehaulRoutePreparationContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_updateOpenProcessInLinehaulRoutePreparationContainerDetail]
	@LinehaulRoutePreparationContainerId AS INT,
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50),
	@OpenProcess AS INT,
	@RowStatus AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;					-- Linehaul Route Preparation 
	DECLARE @EXISTING_LRPCD AS INT;					-- Linehaul Route Preparation Container Detail
	DECLARE @DRY_PIECE_QUANTITY_PIECE AS INT;		-- Linehaul Route Preparation Container Detail Piece
	DECLARE @COLD_PIECE_QUANTITY_PIECE AS INT;		-- Linehaul Route Preparation Container Detail Piece
	DECLARE @GUIDE_QUANTITY_DETAIL AS INT;			-- Linehaul Route Preparation Container Detail
	DECLARE @COLD_PIECE_QUANTITY_DETAIL AS INT;		-- Linehaul Route Preparation Container Detail
	DECLARE @DRY_PIECE_QUANTITY_DETAIL AS INT;		-- Linehaul Route Preparation Container Detail
	DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT;	-- Linehaul Route Preparation Container
	DECLARE @GUIDE_QUANTITY_CONTAINER AS INT;		-- Linehaul Route Preparation Container
	DECLARE @DRY_QUANTITY_CONTAINER AS INT;			-- Linehaul Route Preparation Container
	DECLARE @COLD_QUANTITY_CONTAINER AS INT;		-- Linehaul Route Preparation Container

	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE	[LinehaulRoutePreparationContainerDetailPiece]
		SET		[RowStatus] = @RowStatus
		FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
			AND		[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND		[GuideSerie] = @GuideSerie
			AND		[GuideNumber] = @GuideNumber;

		UPDATE	[LinehaulRoutePreparationContainerDetail]
		SET		[IsOpenProcess] = @OpenProcess,
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME(),
				[RowStatus] = @RowStatus
		WHERE	[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND [GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber;

		SELECT	[LRPCD].[IdLinehaulRoutePreparationContainerDetail],
				[LRPCD].[LinehaulRoutePreparationContainerId],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[IsOpenProcess]
		FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND [LRPCD].[GuideSerie] = @GuideSerie
			AND [LRPCD].[GuideNumber] = @GuideNumber;

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
											WHERE		[LRPCDP].[IsDryPiece] = 1
												AND		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
												AND		[LRPCDP].[RowStatus] = 1
												AND		[LRPCDP].[ActCode] IS NULL);

		SET @COLD_PIECE_QUANTITY_PIECE =	(SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
											FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH (NOLOCK)
											INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
												ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
												AND		[LRPCD].[RowStatus] = 1
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
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
											AND [LRPCD].[RowStatus] = 1);

		SET @DRY_PIECE_QUANTITY_DETAIL =(SELECT COALESCE(SUM([LRPCD].[DryPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
											AND [LRPCD].[RowStatus] = 1);

		SET @COLD_PIECE_QUANTITY_DETAIL=(SELECT COALESCE(SUM([LRPCD].[ColdPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
											AND [LRPCD].[RowStatus] = 1);

		UPDATE	[LinehaulRoutePreparationContainer]
		SET		[GuideQuantity] =						@GUIDE_QUANTITY_DETAIL,
				[DryPieceQuantity] =					@DRY_PIECE_QUANTITY_DETAIL,
				[ColdPieceQuantity] =					@COLD_PIECE_QUANTITY_DETAIL
		WHERE	[IdLinehaulRoutePreparationContainer] = @LinehaulRoutePreparationContainerId;

		-- UPDATE LinehaulRoutePreparation

		SET @CONTAINER_QUANTITY_CONTAINER = (SELECT COUNT([LRPC].[ContainerId])
											FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
											WHERE	[LRPC].[LinehaulRoutePreparationId] = @EXISTING_LRP
												AND [LRPC].[RowStatus] = 1);

		SET @GUIDE_QUANTITY_CONTAINER = (SELECT COALESCE(SUM([LRPC].[GuideQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC  WITH (NOLOCK)
										WHERE	[LRPC].[LinehaulRoutePreparationId] = @EXISTING_LRP
											AND [LRPC].[RowStatus] = 1);

		SET @DRY_QUANTITY_CONTAINER =	(SELECT COALESCE(SUM([LRPC].[DryPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
										WHERE	[LRPC].[LinehaulRoutePreparationId] = @EXISTING_LRP
											AND [LRPC].[RowStatus] = 1);

		SET @COLD_QUANTITY_CONTAINER =	(SELECT COALESCE(SUM([LRPC].[ColdPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
										WHERE	[LRPC].[LinehaulRoutePreparationId] = @EXISTING_LRP
											AND [LRPC].[RowStatus] = 1);

		UPDATE	[LinehaulRoutePreparation]
		SET		[ContainerQuantity] =			@CONTAINER_QUANTITY_CONTAINER,
				[GuideQuantity] =				@GUIDE_QUANTITY_CONTAINER,
				[DryPieceQuantity] =			@DRY_QUANTITY_CONTAINER,
				[ColdPieceQuantity] =			@COLD_QUANTITY_CONTAINER
		WHERE	[IdLinehaulRoutePreparation] =	@EXISTING_LRP;

		
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

		 INSERT INTO dbo.RoutePreparationLogError
        (
            ErrorDescription,
            ErrorNumber,
            ErrorProcedure,
            ErrorLine,
            GuideSerie,
            GuideNumber,
            TokenCreated,
            DateCreated
        )
        VALUES
        (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)), ERROR_LINE(),
         @GuideSerie  , @GuideNumber, 'spHM_updateOpenProcessInLinehaulRoutePreparationContainerDetail', GETDATE());
	END CATCH
END