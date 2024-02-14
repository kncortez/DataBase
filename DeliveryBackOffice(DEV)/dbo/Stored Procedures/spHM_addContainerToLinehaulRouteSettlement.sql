-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <09-08-2022>
-- Description:	<Add or get containert in existing linehaul route settlement>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_addContainerToLinehaulRouteSettlement]
	@LinehaulRouteSettlementId AS INT,
	@LinehaulRoutePreparationId AS INT,
	@ContainerId AS INT,
	@TknUser AS VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRS AS INT;	-- LinehaulRouteSettlement
	DECLARE @EXISTING_LRPC AS INT;	-- LinehaulRoutePreparacionContainer
	DECLARE @EXISTING_LRSC AS INT;	-- LinehaulRouteSettlementContainer
	DECLARE @INSERTED_DOC AS INT;	-- Last inserted doc ID

	-- Check if there is a record in Linehaul Route Settlement Table
	SET @EXISTING_LRS = (SELECT	COUNT([LRS].[IdLinehaulRouteSettlement]) AS CONT
						FROM	[dbo].[LinehaulRouteSettlement] LRS
						WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId
							AND [LRS].[RowStatus] = 1);

	IF (@EXISTING_LRS > 0)
		BEGIN
			-- Check if container is assigned to Linehaul Route Preparation 
			SET @EXISTING_LRPC =(SELECT	COUNT([LRPC].[IdLinehaulRoutePreparationContainer]) AS CONT
								FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
								WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
									AND	[LRPC].[ContainerId] = @ContainerId
									AND [LRPC].[RowStatus] = 1);

			IF (@EXISTING_LRPC > 0)
				BEGIN
					-- VALID CONTAINER
					-- Check if container is already added in Settlement
					SET @EXISTING_LRSC=(SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer])
										FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
										WHERE	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
											AND	[LRSC].[ContainerId] = @ContainerId);

					IF (@EXISTING_LRSC > 0)
						BEGIN
						-- CONTAINER IS ADDED IN SETTLEMENT, RETURN DATA
							SELECT		[LRSC].[IdLinehaulRouteSettlementContainer],
										[LRSC].[LinehaulRouteSettlementId], 
										[LRSC].[ContainerId],
										[C].[CatTypeContainerId],
										[CTC].[TypeContainerSerie],
										[C].[ContainerNumber],
										[HL].[HubAbbreviation],
										[HL].[HubName],
										[LRSC].[GuideQuantity],
										[LRSC].[DryPiecesQuantity], 
										[LRSC].[ColdPiecesQuantity]
							FROM		[dbo].[LinehaulRouteSettlementContainer] LRSC
							INNER JOIN	[dbo].[Container] C
								ON		[LRSC].[ContainerId] = [C].[IdContainer]
							INNER JOIN	[dbo].[CatTypeContainer] CTC
								ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
							INNER JOIN	[dbo].[HubLogistics] HL
								ON		[LRSC].[HubId] = [HL].[IdHubLogistic]
							WHERE		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
								AND		[LRSC].[ContainerId] = @ContainerId;
						END
					ELSE
						BEGIN
						-- ADD CONTAINER TO SETTLEMENT
							BEGIN TRANSACTION
							BEGIN TRY
								INSERT INTO [dbo].[LinehaulRouteSettlementContainer]
											([LinehaulRouteSettlementId],
											 [ContainerId],
											 [HubId],
											 [GuideQuantity],
											 [DryPiecesQuantity],
											 [ColdPiecesQuantity],
											 [RowStatus],
											 [TokenCreated],
											 [DateCreated])
									VALUES	(@LinehaulRouteSettlementId,
											 @ContainerId,
											 (	SELECT	[LRPC].[HubDestinyId]
												FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
												WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
													AND	[LRPC].[ContainerId] = @ContainerId
													AND [LRPC].[RowStatus] = 1),
											 0,				-- GuideQuantity
											 0,				-- DryPiecesQuantity
											 0,				-- ColdPiecesQuantity
											 1,				-- RowStatus
											 @TknUser,
											 SYSDATETIME());

								SET @INSERTED_DOC = SCOPE_IDENTITY();

								SELECT		[LRSC].[IdLinehaulRouteSettlementContainer],
											[LRSC].[LinehaulRouteSettlementId], 
											[LRSC].[ContainerId],
											[LRSC].[HubId],
											[HL].[HubAbbreviation],
											[HL].[HubName],
											[C].[CatTypeContainerId],
											[CTC].[TypeContainerSerie],
											[C].[ContainerNumber],
											[LRSC].[GuideQuantity],
											[LRSC].[DryPiecesQuantity], 
											[LRSC].[ColdPiecesQuantity]
								FROM		[dbo].[LinehaulRouteSettlementContainer] LRSC
								INNER JOIN	[dbo].[Container] C
									ON		[LRSC].[ContainerId] = [C].[IdContainer]
								INNER JOIN	[dbo].[CatTypeContainer] CTC
									ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
								INNER JOIN	[dbo].[HubLogistics] HL
									ON		[LRSC].[HubId] = [HL].[IdHubLogistic]
								WHERE		[LRSC].[IdLinehaulRouteSettlementContainer] = @INSERTED_DOC;

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

								INSERT INTO dbo.RoutePreparationLogError
								(
								    ErrorDescription
								  , ErrorNumber
								  , ErrorProcedure
								  , ErrorLine
								  , GuideSerie
								  , GuideNumber
								  , TokenCreated
								  , DateCreated
								)
								VALUES
								(   ERROR_MESSAGE()      -- ErrorDescription - varchar(300)
								  , ERROR_NUMBER()      -- ErrorNumber - int
								  , ERROR_PROCEDURE()      -- ErrorProcedure - varchar(100)
								  , ERROR_LINE()      -- ErrorLine - int
								  , NULL      -- GuideSerie - nvarchar(2)
								  , NULL      -- GuideNumber - int
								  , ''        -- TokenCreated - varchar(50)
								  , GETDATE() -- DateCreated - datetime
								    )
							END CATCH
						END
				END
			ELSE
				BEGIN
				-- NON VALID CONTAINER
					SELECT 1 [spResult], 'Contenedor NO válido' [spMessage];
				END
		END
	ELSE
		BEGIN
		-- NON VALID SETTLEMENT
			SELECT 2 [spResult], 'Liquidación NO existe' [spMessage];
		END
END