-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <18-07-2022>
-- Description:	<Set Hub Destination to LinehaulRoutePreparationContainer>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_setHubToLinehaulRoutePreparationContainer]
	@IdLinehaulRoutePreparationContainer AS INT, 
	@IdHub AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CONTAINER_HUB AS INT;

	SET @CONTAINER_HUB = (SELECT COALESCE([LRPC].[HubDestinyId], 0) AS HubDestiny
						  FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
						  WHERE	[LRPC].[IdLinehaulRoutePreparationContainer] = @IdLinehaulRoutePreparationContainer);

	IF (@CONTAINER_HUB = 0)
		-- UPDATE HUB DESTINY
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				
				UPDATE [LinehaulRoutePreparationContainer]
				SET [HubDestinyId] = @IdHub
				WHERE [IdLinehaulRoutePreparationContainer] = @IdLinehaulRoutePreparationContainer;

				SELECT	[LRPC].[IdLinehaulRoutePreparationContainer],
						[LRPC].[LinehaulRoutePreparationId],
						[LRPC].[ContainerId],
						[LRPC].[HubDestinyId],
						[HL].[HubAbbreviation],
						[LRPC].[GuideQuantity], 
						[LRPC].[DryPieceQuantity],
						[LRPC].[ColdPieceQuantity]
				FROM	[DBO].[LinehaulRoutePreparationContainer] LRPC,
						[dbo].[HubLogistics] HL
				WHERE	[HL].[IdHubLogistic] = [LRPC].[HubDestinyId]
					AND [LRPC].[IdLinehaulRoutePreparationContainer] = @IdLinehaulRoutePreparationContainer;

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
	ELSE 
		BEGIN
			SELECT	[LRPC].[IdLinehaulRoutePreparationContainer],
					[LRPC].[LinehaulRoutePreparationId],
					[LRPC].[ContainerId],
					[LRPC].[HubDestinyId],
					[HL].[HubAbbreviation],
					[LRPC].[GuideQuantity], 
					[LRPC].[DryPieceQuantity],
					[LRPC].[ColdPieceQuantity]
			FROM	[DBO].[LinehaulRoutePreparationContainer] LRPC,
					[dbo].[HubLogistics] HL
			WHERE	[HL].[IdHubLogistic] = [LRPC].[HubDestinyId]
				AND [LRPC].[IdLinehaulRoutePreparationContainer] = @IdLinehaulRoutePreparationContainer;
		END
END