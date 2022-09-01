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
	DECLARE @EXISTING_LRP AS INT;			-- Linehaul Route Preparation document
	DECLARE @EXISTING_C AS INT;				-- Container
	DECLARE @EXISTING_LPC AS INT;			-- Linehaul Route Preparation Container document
	DECLARE @EXISTING_LPC_DIF AS INT;		-- Linehaul Route Preparation Container active in diferent document
	DECLARE @EXISTING_LPC_STOPOVER AS INT;	-- Linehaul Route Preparation Container 
	DECLARE @GENERATED_STATUS_ID AS INT;	-- Cat Linehaul Status
	DECLARE @LIQUIDATED_STATUS_ID AS INT;	-- Cat Linehaul Status
	DECLARE @STOPOVER_STATUS_ID AS INT;		-- Cat Linehaul Status
	DECLARE @INSERTED_DOC AS INT;			-- Last doc ID inserted
	DECLARE @CONTAINER_STOPOVER AS INT;		-- Linehaul Route Preparation Container
	DECLARE @LINEHAUL_ROUTE_ID AS INT;		-- LinehaulRoutePreparation
	DECLARE @CONTAINER_STOPOVER_HUB AS INT; -- LinehaulRoutePreparationContainer
	DECLARE @IS_LINEHAUL_COVERAGE AS INT;	-- LinehaulCoverage

	-- Check if there is a record in Linehaul Route Preparation Table
	SET @EXISTING_LRP = (SELECT COUNT([LRP].[IdLinehaulRoutePreparation]) AS CONT
						 FROM [dbo].[LinehaulRoutePreparation] LRP
						 WHERE [LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId);

	IF (@EXISTING_LRP = 0) 
		BEGIN
			SELECT 0 [spResult], 'Manifiesto de despacho NO existe' [spMessage];
			RETURN;
		END

	SET @EXISTING_C = (SELECT COUNT([C].[IdContainer]) AS CONT
						FROM	[dbo].[Container] C
						WHERE	[C].[IdContainer] = @ContainerId
							AND [C].[RowStatus] = 1 );

	IF (@EXISTING_C = 0)
	BEGIN
		SELECT 0 [spResult], 'Contenedor ingresado NO existe' [spMessage];
		RETURN;
	END

	SET @GENERATED_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus] 
								FROM	[dbo].[CatLinehaulStatus] CLS 
								WHERE	[CLS].[StatusName] = 'GENERATED');

	SET @STOPOVER_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'STOPOVER');

	SET @LIQUIDATED_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'LIQUIDATED');

	-- Check if there is a record in Linehaul Route Preparation Container Table IN Active document
	SET @EXISTING_LPC = (SELECT COUNT([LPC].[IdLinehaulRoutePreparationContainer]) AS CONT
						FROM [dbo].[LinehaulRoutePreparationContainer] LPC
						WHERE	[LPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
							AND [LPC].[ContainerId] = @ContainerId);

	-- Check if there is a record in a diferent Linehaul Route Preparation Container process with ACTIVE OR IN TRANSIT status
	SET @EXISTING_LPC_DIF = (SELECT COUNT([LPC].[IdLinehaulRoutePreparationContainer]) AS CONT
							FROM		[dbo].[LinehaulRoutePreparationContainer] LPC
							WHERE		[LPC].[CatLinehaulStatusId] != @LIQUIDATED_STATUS_ID
									AND	[LPC].[CatLinehaulStatusId] != @STOPOVER_STATUS_ID
									AND [LPC].[ContainerId] = @ContainerId
									AND [LPC].[LinehaulRoutePreparationId] != @LinehaulRoutePreparationId
									AND [LPC].[RowStatus] = 1);
	
	IF (@EXISTING_LPC_DIF > 0) 
	BEGIN
		-- There is an active doc with the same container ID
		SET @EXISTING_LPC = 0;
		SELECT 0 [spResult], 'Contenedor se encuentra activo en otro proceso.' as [spMessage];
		RETURN;
	END

	SET @CONTAINER_STOPOVER = (SELECT COUNT([LPC].[IdLinehaulRoutePreparationContainer]) AS CONT
								FROM		[dbo].[LinehaulRoutePreparationContainer] LPC
								WHERE		[LPC].[CatLinehaulStatusId] = @STOPOVER_STATUS_ID
										AND [LPC].[ContainerId] = @ContainerId
										AND [LPC].[LinehaulRoutePreparationId] != @LinehaulRoutePreparationId
										AND [LPC].[RowStatus] = 1);

	IF (@CONTAINER_STOPOVER > 0)
		BEGIN
			SET @LINEHAUL_ROUTE_ID = (SELECT [LRP].[CatRouteId]
							  FROM	[dbo].[LinehaulRoutePreparation] LRP
							  WHERE [LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId);

			SET @CONTAINER_STOPOVER_HUB = (SELECT	[LPC].[HubDestinyId]
											FROM	[dbo].[LinehaulRoutePreparationContainer] LPC
											WHERE	[LPC].[CatLinehaulStatusId] = @STOPOVER_STATUS_ID
												AND [LPC].[ContainerId] = @ContainerId
												AND [LPC].[LinehaulRoutePreparationId] != @LinehaulRoutePreparationId
												AND [LPC].[RowStatus] = 1);
			
			SET @IS_LINEHAUL_COVERAGE = (SELECT COUNT([LC].[IdLinehaulCoverage]) AS CONT
										FROM	[dbo].[LinehaulCoverage] LC
										WHERE	[LC].[CatRouteId] = @LINEHAUL_ROUTE_ID
											AND [LC].[HubDestinyId] = @CONTAINER_STOPOVER_HUB
											AND [LC].[RowStatus] = 1);

			IF (@IS_LINEHAUL_COVERAGE = 0)
			BEGIN
				SELECT 0 [spResult], 'Contenedor escaneado se encuentra en ESCALA, el destino NO está cubierto por la ruta actual' [spMessage];
				RETURN;
			END

			SELECT 1 [spResult], 'Contenedor se encuentra en ESCALA' [spMessage];
			RETURN;
		END

	BEGIN TRANSACTION
	BEGIN TRY
		IF (@EXISTING_LPC = 0)
			BEGIN
				INSERT INTO [dbo].[LinehaulRoutePreparationContainer]
							([LinehaulRoutePreparationId],
								[ContainerId],
								[CatLinehaulStatusId],
								[GuideQuantity],
								[DryPieceQuantity],
								[ColdPieceQuantity],
								[RowStatus],
								[TokenCreated],
								[DateCreated])
					VALUES ( @LinehaulRoutePreparationId,
								@ContainerId,
								@GENERATED_STATUS_ID,
								0,		-- GuideQuantity
								0,		-- DryPieceQuantity
								0,		-- ColdPieceQuantity
								1,		-- RowStatus
								@TknUser,
								SYSDATETIME());
				SET @INSERTED_DOC = SCOPE_IDENTITY();
			END

			UPDATE	[LinehaulRoutePreparationContainer]
			SET		[RowStatus] = 1
			WHERE	[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
				AND [ContainerId] = @ContainerId;

			SELECT	[LRPC].[IdLinehaulRoutePreparationContainer],
					[LRPC].[LinehaulRoutePreparationId],
					[LRPC].[ContainerId],
					COALESCE([LRPC].[HubDestinyId], 0) AS HubDestinyId,
					COALESCE([HL].[HubName], '') AS HubName,
					COALESCE([HL].[HubAbbreviation], '') AS HubAbbreviation,
					[LRPC].[GuideQuantity],
					[LRPC].[DryPieceQuantity],
					[LRPC].[ColdPieceQuantity],
					[LRPC].[RowStatus],
					[LRPC].[TokenCreated],
					[LRPC].[DateCreated]
			FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
			LEFT JOIN [dbo].[HubLogistics] HL
				ON	[LRPC].[HubDestinyId] = [HL].[IdHubLogistic]
			WHERE   [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
				AND [LRPC].[ContainerId] = @ContainerId;

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