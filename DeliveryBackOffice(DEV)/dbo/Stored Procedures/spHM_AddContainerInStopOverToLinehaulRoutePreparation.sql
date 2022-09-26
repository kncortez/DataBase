-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <31-08-2022>
-- Description:	<Add container in STOPOVER to LinehaulRoutePreparation>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_AddContainerInStopOverToLinehaulRoutePreparation]
	@LinehaulRoutePreparationId AS INT,
	@ContainerId AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_C AS INT;						-- Container
	DECLARE @EXISTING_LRP AS INT;					-- Linehaul Route Preparation
	DECLARE @EXISTING_LRPC AS INT;					-- Linehaul Route Preparation Container
	DECLARE @EXISTING_LRPC_STOPOVER AS INT;			-- Linehaul Route Preparation Container
	DECLARE @INSERTED_LRPC_ID AS INT;				-- Linehaul Route Preparation Container
	DECLARE @GENERATED_STATUS_ID AS INT;			-- Cat Linehaul Status
	DECLARE @IN_TRANSIT_STATUS_ID AS INT;			-- Cat Linehaul Status
	DECLARE @LIQUIDATED_STATUS_ID AS INT;			-- Cat Linehaul Status
	DECLARE @STOPOVER_STATUS_ID AS INT;				-- Cat Linehaul Status
	DECLARE @TRANSIT_STATUS_ORDER AS INT;			-- Status Order
	DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT;	-- Linehaul Route Preparation Container
	DECLARE @GUIDE_QUANTITY_CONTAINER AS INT;		-- Linehaul Route Preparation Container
	DECLARE @DRY_QUANTITY_CONTAINER AS INT;			-- Linehaul Route Preparation Container
	DECLARE @COLD_QUANTITY_CONTAINER AS INT;		-- Linehaul Route Preparation Container

	SET @EXISTING_LRP = (SELECT COUNT([LRP].[IdLinehaulRoutePreparation]) AS CONT
						FROM	[dbo].[LinehaulRoutePreparation] LRP
						WHERE	[LRP].[IdLinehaulRoutePreparation] =  @LinehaulRoutePreparationId);

	IF (@EXISTING_LRP = 0)
		BEGIN
			SELECT 0 [spResult], 'Manifiesto de linehaul NO existe en la base de datos' [spMessage];
			RETURN;
		END
	
	SET @EXISTING_C = (SELECT	COUNT([C].[IdContainer]) AS CONT
						FROM	[dbo].[Container] C
						WHERE	[C].[IdContainer] = @ContainerId);

	IF (@EXISTING_C = 0)
		BEGIN
			SELECT 0 [spResult], 'Contenedor ingresado NO existe en la base de datos' [spMessage];
			RETURN;
		END
	
	SET @EXISTING_LRPC = (SELECT COUNT([LRPC].[IdLinehaulRoutePreparationContainer]) AS CONT
							FROM [dbo].[LinehaulRoutePreparationContainer] LRPC
							WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								AND [LRPC].[ContainerId] = @ContainerId);
    
	IF (@EXISTING_LRPC > 0)
	BEGIN
		SELECT 0 [spResult], 'El contenedor ingresado YA se encuentra registrado en el manifiesto activo' [spMessage];
		RETURN;
	END

	SET @GENERATED_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus] 
								FROM	[dbo].[CatLinehaulStatus] CLS 
								WHERE	[CLS].[StatusName] = 'GENERATED');

	SET @IN_TRANSIT_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus] 
								 FROM	[dbo].[CatLinehaulStatus] CLS 
								 WHERE	[CLS].[StatusName] = 'IN TRANSIT');

	SET @LIQUIDATED_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus] 
								FROM	[dbo].[CatLinehaulStatus] CLS 
								WHERE	[CLS].[StatusName] = 'LIQUIDATED');
	
	SET @STOPOVER_STATUS_ID = (SELECT [CLS].[IdCatLinehaulStatus]
								FROM [dbo].[CatLinehaulStatus] CLS
								WHERE [CLS].[StatusName] = 'STOPOVER');

	SET @TRANSIT_STATUS_ORDER = (SELECT [SO].[StatusOrderId]
								FROM	[dbo].[StatusOrder] SO
								WHERE	[SO].[OrderDescription] = 'En Tránsito');

	SET @EXISTING_LRPC_STOPOVER = (SELECT	[LRPC].[IdLinehaulRoutePreparationContainer]
									FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
									WHERE	[LRPC].[CatLinehaulStatusId] = @STOPOVER_STATUS_ID
										AND	[LRPC].[ContainerId] = @ContainerId
										AND	[LRPC].[RowStatus] = 1);

	BEGIN TRANSACTION
	BEGIN TRY

		-- ADD CONTAINER TO CURRENT PROCESS
		INSERT INTO [dbo].[LinehaulRoutePreparationContainer]
					([LinehaulRoutePreparationId], 
					 [ContainerId],
					 [HubDestinyId], 
					 [CatLinehaulStatusId],
					 [GuideQuantity], 
					 [DryPieceQuantity], 
					 [ColdPieceQuantity],
					 [RowStatus], 
					 [TokenCreated], 
					 [DateCreated])
		SELECT		@LinehaulRoutePreparationId,
					[LRPC].[ContainerId],
					[LRPC].[HubDestinyId],
					@GENERATED_STATUS_ID,
					[LRPC].[GuideQuantity],
					[LRPC].[DryPieceQuantity],
					[LRPC].[ColdPieceQuantity],
					[LRPC].[RowStatus],
					@TknUser,
					SYSDATETIME()
			FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
			WHERE	[LRPC].[IdLinehaulRoutePreparationContainer] = @EXISTING_LRPC_STOPOVER;

		SET @INSERTED_LRPC_ID = SCOPE_IDENTITY();

		-- ADD CONTAINER DETAIL TO CURRENT PROCESS
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
		SELECT		@INSERTED_LRPC_ID,
					[LRPCD].[GuideSerie],
					[LRPCD].[GuideNumber],
					[LRPCD].[GuideDryPieceTotal],
					[LRPCD].[GuideColdPieceTotal],
					[LRPCD].[DryPieceQuantity],
					[LRPCD].[ColdPieceQuantity],
					[LRPCD].[IsOpenProcess],
					[LRPCD].[RowStatus], 
					@TknUser,
					SYSDATETIME()
		FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
				AND [LRPC].[IdLinehaulRoutePreparationContainer] = @EXISTING_LRPC_STOPOVER;

		-- ADD CONTAINER DETAIL PIECE TO CURRENT PROCESS
		INSERT INTO [dbo].[LinehaulRoutePreparationContainerDetailPiece]
					([LinehaulRoutePreparationContainerDetailId],
					 [CatLinehaulStatusId],
					 [PieceNumber],
					 [IsDryPiece],
					 [ActCode],
					 [RowStatus],
					 [TokenCreated],
					 [DateCreated])
		SELECT		(SELECT  [LRPCD_S].[IdLinehaulRoutePreparationContainerDetail]
					FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD_S
					WHERE	[LRPCD_S].[GuideSerie] = [LRPCD].[GuideSerie]
						AND	[LRPCD_S].[GuideNumber] = [LRPCD].[GuideNumber]
						AND [LRPCD_S].[LinehaulRoutePreparationContainerId] = @INSERTED_LRPC_ID),
					@IN_TRANSIT_STATUS_ID,
					[LRPCDP].[PieceNumber],
					[LRPCDP].[IsDryPiece],
					[LRPCDP].[ActCode],
					[LRPCDP].[RowStatus],
					@TknUser,
					SYSDATETIME()
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		[LRPC].[IdLinehaulRoutePreparationContainer] = @EXISTING_LRPC_STOPOVER;

		-- UPDATE DELIVERY ORDER STATUS
		UPDATE		DO
		SET			[StatusOrderId] = @TRANSIT_STATUS_ORDER
		FROM		[dbo].[DeliveryOrder] DO WITH (NOLOCK)
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[DO].[Guide_Serie] = [LRPCD].[GuideSerie]
			AND		[DO].[Guide_Number] = [LRPCD].[GuideNumber]
			AND		[LRPCD].[LinehaulRoutePreparationContainerId] = @INSERTED_LRPC_ID;

		-- INSERT LOG IN DELIVERY ORDER DETAIL
		INSERT INTO [dbo].[DeliveryOrderDetail]
					([Guide_Serie],
					[Guide_Number],
					[StatusOrderId],
					[UserCreated],
					[DateCreated], 
					[DateCreatedInSystem],
					[RowStatus])
		SELECT		[LRPCD].[GuideSerie],
					[LRPCD].[GuideNumber],
					@TRANSIT_STATUS_ORDER,
					@TknUser,
					SYSDATETIME(),
					SYSDATETIME(), 
					1			-- Row Status
		FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		WHERE		[LRPCD].[LinehaulRoutePreparationContainerId] = @INSERTED_LRPC_ID;

		-- UPDATE LINEHAUL ROUTE PREPARATION CONTAINER IN STOPOVER
		UPDATE	[dbo].[LinehaulRoutePreparationContainer] 
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
		WHERE	[IdLinehaulRoutePreparationContainer] = @EXISTING_LRPC_STOPOVER;

		-- UPDATE LINEHAUL ROUTE PREPARATION CONTAINER DETAIL PIECES IN STOPOVER
		UPDATE	[dbo].[LinehaulRoutePreparationContainerDetailPiece]
		SET		[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		[LRPC].[IdLinehaulRoutePreparationContainer] = @EXISTING_LRPC_STOPOVER;

		-- UPDATE LINEHAUL ROUTE PREPARATION NUMBERS

		SET @CONTAINER_QUANTITY_CONTAINER = (SELECT COUNT([LRPC].[ContainerId])
											FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
											WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
												AND [LRPC].[RowStatus] = 1);

		SET @GUIDE_QUANTITY_CONTAINER = (SELECT COALESCE(SUM([LRPC].[GuideQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
										WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
											AND [LRPC].[RowStatus] = 1);

		SET @DRY_QUANTITY_CONTAINER =	(SELECT COALESCE(SUM([LRPC].[DryPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
										WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
											AND [LRPC].[RowStatus] = 1);

		SET @COLD_QUANTITY_CONTAINER =	(SELECT COALESCE(SUM([LRPC].[ColdPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
										WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
											AND [LRPC].[RowStatus] = 1);

		UPDATE	[LinehaulRoutePreparation]
		SET		[ContainerQuantity] =			@CONTAINER_QUANTITY_CONTAINER,
				[GuideQuantity] =				@GUIDE_QUANTITY_CONTAINER,
				[DryPieceQuantity] =			@DRY_QUANTITY_CONTAINER,
				[ColdPieceQuantity] =			@COLD_QUANTITY_CONTAINER
		WHERE	[IdLinehaulRoutePreparation] =	@LinehaulRoutePreparationId;

		SELECT 1 [spResult], 'Contenedor ha sido agregado con al manifiesto de despacho actual con éxito' [spMessage], @ContainerId [containerId], @INSERTED_LRPC_ID [containerLinehaulId];

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