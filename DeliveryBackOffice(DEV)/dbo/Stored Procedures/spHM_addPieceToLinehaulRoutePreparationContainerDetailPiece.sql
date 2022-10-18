-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <15-07-2022>
-- Description:	<Add guide piece into LinehaulRoutePreparationContainerDetailPiece Table>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_addPieceToLinehaulRoutePreparationContainerDetailPiece]
	@LinehaulRoutePreparationContainerDetailId AS INT,
	@PieceNumber AS INT,
	@IsDry AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRPCD AS INT;			-- LinehaulRoutePreparationContainerDetail
	DECLARE @EXISTING_LRPCDP AS INT;		-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @INSERTED_DOC AS INT;			-- Last doc ID inserted

	-- Check if there is a record in LinehaulRoutePreparationContainerDetail
	SET @EXISTING_LRPCD = (	SELECT COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail]) AS CONT
							FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
							WHERE	[LRPCD].[IdLinehaulRoutePreparationContainerDetail] = @LinehaulRoutePreparationContainerDetailId);

	IF (@EXISTING_LRPCD > 0)
		BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			-- Check if there is a record with same data in LinehaulRoutePreparationContainerDetailPiece
			SET @EXISTING_LRPCDP = (SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]) AS CONT
									FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
									WHERE	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @LinehaulRoutePreparationContainerDetailId
										AND [LRPCDP].[PieceNumber] = @PieceNumber);

			IF (@EXISTING_LRPCDP = 0) 
				BEGIN
					-- INSERT DOC
					INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetailPiece]
									([LinehaulRoutePreparationContainerDetailId],
									 [CatLinehaulStatusId],
									 [PieceNumber],
									 [IsDryPiece],
									 [RowStatus],
									 [TokenCreated],
									 [DateCreated])
							VALUES	(@LinehaulRoutePreparationContainerDetailId,
									(SELECT [CLS].[IdCatLinehaulStatus] FROM [dbo].[CatLinehaulStatus] CLS WHERE [CLS].[StatusName] = 'IN TRANSIT'),
									 @PieceNumber,
									 @IsDry,
									 1,
									 @TknUser,
									SYSDATETIME());

					SET @INSERTED_DOC = SCOPE_IDENTITY();

					SELECT	[LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece],
							[LRPCDP].[LinehaulRoutePreparationContainerDetailId],
							[LRPCDP].[PieceNumber],
							[LRPCDP].[IsDryPiece],
							COALESCE([LRPCDP].[ActCode], 0) AS ActCode,
							[LRPCDP].[RowStatus]
					FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
					WHERE	[LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece] = @INSERTED_DOC;
				END
			ELSE
				BEGIN
					SET @EXISTING_LRPCDP = (SELECT	[LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece]
											FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
											WHERE	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @LinehaulRoutePreparationContainerDetailId
												AND [LRPCDP].[PieceNumber] = @PieceNumber);

					UPDATE	[dbo].[LinehaulRoutePreparationContainerDetailPiece]
					SET		[RowStatus] = 1,
							[TokenUpdated] = @TknUser,
							[DateUpdated] = SYSDATETIME()
					WHERE	[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
								AND	[PieceNumber] = @PieceNumber;

					SELECT	[LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece],
							[LRPCDP].[LinehaulRoutePreparationContainerDetailId],
							[LRPCDP].[PieceNumber],
							[LRPCDP].[IsDryPiece],
							COALESCE([LRPCDP].[ActCode], 0) AS ActCode,
							[LRPCDP].[RowStatus]
					FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
					WHERE	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @LinehaulRoutePreparationContainerDetailId
										AND [LRPCDP].[PieceNumber] = @PieceNumber;
				END
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