-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <14-07-2022>
-- Description:	<Add guide to LinehaulRoutePreparationContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_addGuideToLinehaulRoutePreparationContainerDetail]
	@LinehaulRoutePreparationContainerId AS INT,
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(25),
	@PiecesDryTotal AS INT,
	@PiecesColdTotal AS INT,
	@IsOpenProcess AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_DOC AS INT;	-- LinehaulRoutePreparationContainerDetail document
	DECLARE @INSERTED_DOC AS INT;	-- Last doc ID inserted

	-- Check if there is a record in LinehaulRoutePreparationContainerDetail with same data
	SET @EXISTING_DOC = (SELECT COUNT([LRPD].[IdLinehaulRoutePreparationContainerDetail])
						FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPD
						WHERE	[LRPD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
							AND	[LRPD].[GuideSerie] = @GuideSerie
							AND [LRPD].[GuideNumber] = @GuideNumber);

	IF (@EXISTING_DOC > 0)
		BEGIN
			-- Document already exists, return data, only update token created
			UPDATE	[LinehaulRoutePreparationContainerDetail]	
			SET		[TokenCreated] = @TknUser
			WHERE	[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
				AND	[GuideSerie] = @GuideSerie
				AND [GuideNumber] = @GuideNumber;

			SELECT	[LRPD].[IdLinehaulRoutePreparationContainerDetail],
					[LRPD].[LinehaulRoutePreparationContainerId],
					[LRPD].[GuideSerie],
					[LRPD].[GuideNumber],
					[LRPD].[GuideDryPieceTotal],
					[LRPD].[GuideColdPieceTotal],
					[LRPD].[DryPieceQuantity],
					[LRPD].[ColdPieceQuantity],
					[LRPD].[IsOpenProcess]
			FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPD
			WHERE	[LRPD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
				AND [LRPD].[GuideSerie] = @GuideSerie
				AND [LRPD].[GuideNumber] = @GuideNumber;
		END
	ELSE
		BEGIN
			-- Create document
			BEGIN TRANSACTION
			BEGIN TRY
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
							 0,
							 0,
							 @IsOpenProcess,
							 1,
							 @TknUser,
							 SYSDATETIME());

				SET @INSERTED_DOC = SCOPE_IDENTITY();

				SELECT	[LRPD].[IdLinehaulRoutePreparationContainerDetail],
						[LRPD].[LinehaulRoutePreparationContainerId],
						[LRPD].[GuideSerie],
						[LRPD].[GuideNumber],
						[LRPD].[GuideDryPieceTotal],
						[LRPD].[GuideColdPieceTotal],
						[LRPD].[DryPieceQuantity],
						[LRPD].[ColdPieceQuantity],
						[LRPD].[IsOpenProcess]
				FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPD
				WHERE	[LRPD].[IdLinehaulRoutePreparationContainerDetail] = @INSERTED_DOC;

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