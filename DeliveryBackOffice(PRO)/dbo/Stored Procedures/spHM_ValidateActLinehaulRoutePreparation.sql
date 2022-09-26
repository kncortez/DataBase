-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <26-08-2022>
-- Description:	<Validate and add ActCodes for missing pieces in LinehaulRoutePreparationContainerDetailPiece>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_ValidateActLinehaulRoutePreparation]
	@CatRouteId AS INT,
	@LinehaulRoutePreparationId AS INT,
	@LinehaulRoutePreparationContainerId AS INT,
	@DateRoute AS DATE,
	@GuideSerie AS NVARCHAR(5),
	@GuideNumber AS NVARCHAR(25),
	@PieceNumber AS INT,
	@ActCode AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ACT_TYPE_DISPATCH AS INT;		-- CatTypeAct
	DECLARE @EXISTING_ACT AS INT;			-- Act
	DECLARE @EXISTING_LRPCD AS INT;			-- LinehaulRoutePreparationContainerDetail
	DECLARE @EXISTING_LRPCDP AS INT;		-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @STATUS_MISSING AS INT;			-- CatLinehaulStatus
	DECLARE @IS_DRY AS INT;					-- DeliveryOrder

	SET @ACT_TYPE_DISPATCH = (SELECT	[CTA].[IdCatTypeAct]
								FROM	[dbo].[CatTypeAct] CTA
								WHERE	[CTA].[ActName] = 'LINEHAUL_DISPATCH');

	SET @EXISTING_ACT = (SELECT		COUNT([A].[IdAct]) AS CONT
						FROM		[dbo].[ActDetailPiece] ADP
						INNER JOIN	[dbo].[ActDetail] AD
							ON		[ADP].[ActDetailId] = [AD].[IdActDetail]
							AND		[AD].[GuideSerie] = @GuideSerie
							AND		[AD].[GuideNumber] = @GuideNumber
						INNER JOIN	[dbo].[Act] A
							ON		[AD].[ActId] = [A].[IdAct]
							AND		[A].[CatRouteId] = @CatRouteId
							AND		[A].[DateOfRoute] = @DateRoute
							AND		[A].[CatTypeActId] = @ACT_TYPE_DISPATCH
							AND		[A].[RowStatus] = 1
						WHERE		[ADP].[RowStatus] = 1
							AND		[ADP].[PieceNumber] = @PieceNumber);

	IF (@EXISTING_ACT = 0)
		BEGIN
			SELECT 0 [spResult], 'No act for missing pieces was found' [spMessage];
			RETURN;
		END

	SET @EXISTING_LRPCD = (SELECT		COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail]) AS CONT
								FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
								INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
									ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
								INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
									ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
									AND		[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
								WHERE		[LRPCD].[GuideSerie] = @GuideSerie
									AND		[LRPCD].[GuideNumber] = @GuideNumber);

	SET @EXISTING_LRPCDP = (SELECT		COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]) AS CONT
								FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
								INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
									ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
									AND		[LRPCD].[GuideSerie] = @GuideSerie
									AND		[LRPCD].[GuideNumber] = @GuideNumber
								INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
									ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
								INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
									ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
									AND		[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
								WHERE		[LRPCDP].[PieceNumber] = @PieceNumber);

	SET @STATUS_MISSING = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'MISSING');

	SET @IS_DRY = (SELECT	[DO].[IsDry]
					FROM	[dbo].[DeliveryOrderPiece] DO WITH (NOLOCK)
					WHERE	[DO].[GuideSerie] = @GuideSerie
						AND [DO].[GuideNumber] = @GuideNumber
						AND [DO].[NoPiece] = @PieceNumber);

	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
		-- IF DETAIL IS NOT IN LINEHAUL THEN ADD
		IF (@EXISTING_LRPCD = 0)
			BEGIN
				INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetail] 
							([LinehaulRoutePreparationContainerId],
							[GuideSerie],
							[GuideNumber],
							[GuideDryPieceTotal],
							[GuideColdPieceTotal],
							[DryPieceQuantity],
							[ColdPieceQuantity],
							[IsOpenProcess],
							[UserProcess],
							[RowStatus],
							[TokenCreated],
							[DateCreated])
				SELECT		@LinehaulRoutePreparationContainerId,
							@GuideSerie,
							@GuideNumber,
							[DO].[Pieces_Dry],
							[DO].[Pieces_Cold],
							0,					-- DryPiecesQuantity
							0,					-- ColdPiecesQuantity
							1,					-- IsOpenProcess
							@TknUser,
							1,					-- RowStatus
							@TknUser,
							SYSDATETIME()
				FROM		[dbo].[DeliveryOrder] DO WITH (NOLOCK)
				WHERE		[DO].[Guide_Serie] = @GuideSerie
					AND		[DO].[Guide_Number] = @GuideNumber;

				SET @EXISTING_LRPCD = SCOPE_IDENTITY();
			END
		ELSE
			BEGIN
				SET @EXISTING_LRPCD = (SELECT		[LRPCD].[IdLinehaulRoutePreparationContainerDetail]

										FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
										INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
											ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
										INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
											ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
											AND		[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
										WHERE		[LRPCD].[GuideSerie] = @GuideSerie
											AND		[LRPCD].[GuideNumber] = @GuideNumber)
			END
		
		-- IF PIECE IS NOT IN LINEHAUL THEN ADD WITH ACT CODE, ELSE UPDATE ACT CODE
		IF (@EXISTING_LRPCDP = 0)
			BEGIN
				INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetailPiece]
							([LinehaulRoutePreparationContainerDetailId],
							[CatLinehaulStatusId],
							[PieceNumber],
							[IsDryPiece],
							[ActCode],
							[RowStatus],
							[TokenCreated],
							[DateCreated])
				VALUES		(@EXISTING_LRPCD,
							@STATUS_MISSING,
							@PieceNumber,
							@IS_DRY,
							@ActCode,
							1,
							@TknUser,
							SYSDATETIME());
			END
		ELSE
			BEGIN
				UPDATE	[dbo].[LinehaulRoutePreparationContainerDetailPiece]
				SET		[ActCode] = @ActCode,
						[CatLinehaulStatusId] = @STATUS_MISSING
				WHERE	[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
					AND	[PieceNumber] = @PieceNumber;
			END

		SELECT 1 [spResult], 'Act added succesfully' [spMessage];
			
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
    
END