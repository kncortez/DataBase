-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <25-07-2022>
-- Description:	<Check and set driver, tag number and status -> 'IN TRANSIT' to an active Linehaul process>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_setInTransitToLinehaulRoutePreparation] 
	@IdLinehaulRoutePreparation AS INT,
	@SenderReceiverCUI AS NVARCHAR(50),
	@Tag AS NVARCHAR(25),
	@TknUser AS NVARCHAR(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;	-- LinehaulRoutePreparation
	DECLARE @EXISTING_LCM AS INT;	-- LinehaulRoutePreparationCustomsMark
	DECLARE @EXISTING_SR AS INT;	-- Sender Receiver
	DECLARE @EXISTING_TAG AS INT;	-- CustomMarks

	-- Check if there is an active record in LinehaulRoutePreparation
	SET @EXISTING_LRP = (SELECT	COALESCE([LRP].[IdLinehaulRoutePreparation], 0) AS IdLinehaulRoutePreparation
						 FROM	[dbo].[LinehaulRoutePreparation] LRP
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
							AND	[LRP].[CatLinehaulStatusId] = (SELECT [CLS].[IdCatLinehaulStatus]
																FROM [dbo].[CatLinehaulStatus] CLS
																WHERE [CLS].[StatusName] = 'GENERATED'));

	SET @EXISTING_TAG = (SELECT COUNT([LCM].[IdLinehaulRoutePreparationCustomsMark]) AS IdLinehaulRoutePreparationCustomsMark
						 FROM	[dbo].[LinehaulRoutePreparationCustomsMark] LCM
						 WHERE	[LCM].[CustomsMarkSerie] = @Tag
							AND [LCM].[RowStatus] = 1);

	IF (@EXISTING_LRP > 0) 
		-- There is an active record that can be processed
		BEGIN
			IF (@EXISTING_TAG = 0)
				BEGIN
					SET @EXISTING_SR = (SELECT COALESCE([SR].[ID], 0) AS ID
										FROM [dbo].[SenderReceiver] SR
										WHERE [SR].[CUI] = @SenderReceiverCUI);

					IF (@EXISTING_SR > 0)
						BEGIN
							BEGIN TRANSACTION
							BEGIN TRY

								-- Insert Tag record in LinehaulRoutePreparationCustomsMark
								INSERT INTO [LinehaulRoutePreparationCustomsMark]
											([LinehaulRoutePreparationId],
											 [CustomsMarkSerie],
											 [RowStatus],
											 [TokenCreated],
											 [DateCreated])
									VALUES	(@IdLinehaulRoutePreparation,
											 @Tag, 
											 1, 
											 @TknUser, 
											 SYSDATETIME());

								-- Update LinehaulRoutePreparation set SenderReceiver and LinehaulStatus
								UPDATE	[LinehaulRoutePreparation]
								SET		[SenderReceiverId] = @EXISTING_SR,
										[CatLinehaulStatusId] = (SELECT [CLS].[IdCatLinehaulStatus]
																FROM [dbo].[CatLinehaulStatus] CLS
																WHERE [CLS].[StatusName] = 'IN TRANSIT'),
										[TokenUpdated] = @TknUser,
										[DateUpdated] = SYSDATETIME()
								WHERE	[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation;

								SELECT	[LRP].[IdLinehaulRoutePreparation],
										[LRP].[StationDispatchedId],
										[LRP].[CatLinehaulStatusId],
										[LRP].[CatRouteId],
										[LRP].[SenderReceiverId],
										[LRP].[CatVehicleId],
										[LRP].[DateLinehaulRoutePreparation],
										[LRP].[ContainerQuantity],
										[LRP].[GuideQuantity],
										[LRP].[DryPieceQuantity],
										[LRP].[ColdPieceQuantity],
										[LRP].[RowStatus],
										[LRP].[TokenCreated],
										[LRP].[DateCreated]
								FROM	[dbo].[LinehaulRoutePreparation] LRP
								WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation;

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
					ELSE
						BEGIN
							SELECT 1 [spResult], 'No valid sender receiver' [spMessage];
						END
				END
			ELSE 
				-- No active record, it was already processed or it doesn't exist
				BEGIN
					SELECT 2 [spResult], 'Custom mark serie already exists' [spMessage];
				END
		END
	ELSE 
		BEGIN
			SELECT 0 [spResult], 'No active record, it was already processed or it doesn''t exist' [spMessage];
		END
END