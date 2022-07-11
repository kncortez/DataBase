-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <08-07-2022>
-- Description:	<Add or get a container in existing linehaul route preparation process>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_addContainerToLinehaulRoutePreparation]
	@LinehaulRoutePreparationId AS INT,
	@ContainerId AS INT,
	@TknUser AS VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;		-- Linehaul Route Preparation document
	DECLARE @EXISTING_LPC AS INT;		-- Linehaul Route Preparation Container document
	DECLARE @EXISTING_LPC_DIF AS INT;	-- Linehaul Route Preparation Container active in diferent document
	DECLARE @INSERTED_DOC AS INT;		-- Last doc ID inserted

	-- Check if there is a record in Linehaul Route Preparation Table
	SET @EXISTING_LRP = (SELECT COUNT([LRP].[IdLinehaulRoutePreparation]) AS CONT
						 FROM [dbo].[LinehaulRoutePreparation] LRP
						 WHERE [LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId);

	IF (@EXISTING_LRP > 0) 
		BEGIN
			-- Check if there is a record in Linehaul Route Preparation Container Table IN Active document
			SET @EXISTING_LPC = (SELECT COUNT([LPC].[IdLinehaulRoutePreparationContainer]) AS CONT
								FROM [dbo].[LinehaulRoutePreparationContainer] LPC
								WHERE	[LPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
									AND [LPC].[ContainerId] = @ContainerId);

			-- Check if there is a record in a diferent Linehaul Route Preparation Container process with ACTIVE OR IN TRANSIT status
			SET @EXISTING_LPC_DIF = (SELECT COUNT([LPC].[IdLinehaulRoutePreparationContainer]) AS CONT
									FROM [dbo].[LinehaulRoutePreparationContainer] LPC
									INNER JOIN [dbo].[LinehaulRoutePreparation] LRP
										ON [LPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
											AND [LRP].[CatLinehaulStatusId] != (SELECT [CLS].[IdCatLinehaulStatus]
																				FROM [dbo].[CatLinehaulStatus] CLS
																				WHERE [CLS].[StatusName] = 'LIQUIDATED')
											AND [LPC].[ContainerId] = @ContainerId
											AND [LPC].[LinehaulRoutePreparationId] != @LinehaulRoutePreparationId);

			IF (@EXISTING_LPC_DIF > 0) 
				BEGIN
					-- There is an active doc with the same container ID
					SET @EXISTING_LPC = 0;
					SELECT 0 [spResult], 'Container is in other process' as [spDescription];
				END
			
			IF (@EXISTING_LPC > 0)
				BEGIN
					-- Return existing doc
					SELECT	[LRPC].[IdLinehaulRoutePreparationContainer],
							[LRPC].[LinehaulRoutePreparationId],
							[LRPC].[ContainerId],
							[LRPC].[GuideQuantity],
							[LRPC].[DryPieceQuantity],
							[LRPC].[ColdPieceQuantity],
							[LRPC].[RowStatus],
							[LRPC].[TokenCreated],
							[LRPC].[DateCreated]
					FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
					WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
						AND [LRPC].[ContainerId] = @ContainerId;
				END
		
			IF (@EXISTING_LPC = 0 AND @EXISTING_LPC_DIF = 0)
				-- Generate and return a new doc
				BEGIN
					BEGIN TRANSACTION
					BEGIN TRY
						INSERT INTO [dbo].[LinehaulRoutePreparationContainer]
									([LinehaulRoutePreparationId],
									 [ContainerId],
									 [GuideQuantity],
									 [DryPieceQuantity],
									 [ColdPieceQuantity],
									 [RowStatus],
									 [TokenCreated],
									 [DateCreated])
							VALUES ( @LinehaulRoutePreparationId,
									 @ContainerId,
									 0,
									 0,
									 0,
									 1,
									 @TknUser,
									 SYSDATETIME());
						SET @INSERTED_DOC = SCOPE_IDENTITY();

						SELECT	[LRPC].[IdLinehaulRoutePreparationContainer],
								[LRPC].[LinehaulRoutePreparationId],
								[LRPC].[ContainerId],
								[LRPC].[GuideQuantity],
								[LRPC].[DryPieceQuantity],
								[LRPC].[ColdPieceQuantity],
								[LRPC].[RowStatus],
								[LRPC].[TokenCreated],
								[LRPC].[DateCreated]
						FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
						WHERE	[LRPC].[IdLinehaulRoutePreparationContainer] = @INSERTED_DOC;

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
END