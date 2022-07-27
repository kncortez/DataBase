-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <26-07-2022>
-- Description:	<Delete [LOGIC] a container from LinehaulRoutePreparationContainer>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_removeLinehaulRoutePreparationContainer]
	@LinehaulRoutePreparationId AS INT,
	@ContainerId AS INT,
	@TknUser AS VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRPC AS INT;					-- LinehaulRoutePreparationContainer
	DECLARE @EXISTING_LINKED_ORDERS AS INT;			-- LinehaulRoutePreparationContainerDetail
	DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT;	-- LinehaulRoutePreparationContainer

	-- Check if there is an existing LinehaulRoutePreparationContainer record
	SET @EXISTING_LRPC = (SELECT	[LRPC].[IdLinehaulRoutePreparationContainer]
						  FROM		[dbo].[LinehaulRoutePreparationContainer] LRPC
						  WHERE		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
							AND		[LRPC].[ContainerId] = @ContainerId
							AND		[LRPC].[RowStatus] = 1);

	SET @EXISTING_LRPC = ISNULL(@EXISTING_LRPC, 0);

	IF (@EXISTING_LRPC > 0)
		BEGIN
			-- Check if there are linked orders to the specified container
			SET @EXISTING_LINKED_ORDERS = (SELECT	COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail]) AS CONTEO
											FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
											WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_LRPC
												AND [LRPCD].[RowStatus] = 1);

			IF (@EXISTING_LINKED_ORDERS = 0)
				-- There aren't linked orders, remove container
				BEGIN
					BEGIN TRANSACTION
					BEGIN TRY

						-- Remove container from LinehaulRoutePreparationContainer
						UPDATE	[LinehaulRoutePreparationContainer]
						SET		[RowStatus] = 0,
								[TokenUpdated] = @TknUser, 
								[DateUpdated] = SYSDATETIME()
						WHERE	[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
							AND [ContainerId] = @ContainerId;

						-- Update LinehaulRoutePreparation Containers counter
						SET @CONTAINER_QUANTITY_CONTAINER = (SELECT COUNT([LRPC].[ContainerId])
															FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
															WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
																AND [LRPC].[RowStatus] = 1);

						UPDATE	[LinehaulRoutePreparation]
						SET		[ContainerQuantity] =			@CONTAINER_QUANTITY_CONTAINER
						WHERE	[IdLinehaulRoutePreparation] =	@LinehaulRoutePreparationId;

						SELECT	[LRPC].[IdLinehaulRoutePreparationContainer],
								[LRPC].[LinehaulRoutePreparationId],
								[LRPC].[ContainerId],
								COALESCE([LRPC].[HubDestinyId], 0) as HubDestinyId,
								[HL].[HubName],
								[HL].[HubAbbreviation],
								[LRPC].[GuideQuantity],
								[LRPC].[DryPieceQuantity],
								[LRPC].[ColdPieceQuantity],
								[LRPC].[TokenCreated]
						FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
						LEFT JOIN [dbo].[HubLogistics] HL
							ON	[LRPC].[HubDestinyId] = [HL].[IdHubLogistic]
						WHERE	[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
							AND	[ContainerId] = @ContainerId;

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
				-- There are linked orders, cant remove container
				BEGIN
					SELECT 1 [spResult], 'El contenedor que intenta remover tiene guías activas enlazadas, imposible eliminar.' [spMessage];
				END
		END
	ELSE
		-- LinehaulRoutePreparationContainer doesn't exist
		BEGIN
			SELECT 0 [spResult], 'El contenedor que intenta eliminar NO existe en el Linehaul actual.' [spMessage];
		END
END