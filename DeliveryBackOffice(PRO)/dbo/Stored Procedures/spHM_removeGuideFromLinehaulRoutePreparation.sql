-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <05-09-2022>
-- Description:	<Remove a guide from Linehaul Route Preparation>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_removeGuideFromLinehaulRoutePreparation]
	@LinehaulRoutePreparationId AS INT,
	@GuideSerie AS NVARCHAR(5),
	@GuideNumber AS NVARCHAR(25),
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @GENERATED_STATUS_ID AS INT;			-- Cat Linehaul Status
	DECLARE @EXISTING_LRP AS INT;					-- Linehaul Route Preparation
	DECLARE @EXISTING_LRPC AS INT;					-- Linehaul Route Preparation Container
	DECLARE @EXISTING_LRPCD AS INT;					-- Linehaul Route Preparation Container Detail
	DECLARE @EXISTING_DOD AS INT;					-- Delivery Order Detail
	DECLARE @STATUS_ORDER_ID AS INT;				-- Status Order
	DECLARE @DRY_PIECE_QUANTITY_PIECE AS INT;		-- Linehaul Route Preparation Container Detail Piece
	DECLARE @COLD_PIECE_QUANTITY_PIECE AS INT;		-- Linehaul Route Preparation Container Detail Piece
	DECLARE @GUIDE_QUANTITY_DETAIL AS INT;			-- Linehaul Route Preparation Container Detail
	DECLARE @COLD_PIECE_QUANTITY_DETAIL AS INT;		-- Linehaul Route Preparation Container Detail
	DECLARE @DRY_PIECE_QUANTITY_DETAIL AS INT;		-- Linehaul Route Preparation Container Detail
	DECLARE @CONTAINER_QUANTITY_CONTAINER AS INT;	-- Linehaul Route Preparation Container
	DECLARE @GUIDE_QUANTITY_CONTAINER AS INT;		-- Linehaul Route Preparation Container
	DECLARE @DRY_QUANTITY_CONTAINER AS INT;			-- Linehaul Route Preparation Container
	DECLARE @COLD_QUANTITY_CONTAINER AS INT;		-- Linehaul Route Preparation Container

	SET @GENERATED_STATUS_ID = (SELECT  [CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'GENERATED');

	SET @EXISTING_LRP = (SELECT COUNT([LRP].[IdLinehaulRoutePreparation]) AS CONT
						 FROM	[dbo].[LinehaulRoutePreparation] LRP
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
							AND [LRP].[RowStatus] = 1
							AND	[LRP].[CatLinehaulStatusId] = @GENERATED_STATUS_ID);

	IF (@EXISTING_LRP = 0)
		BEGIN
			SELECT 0 [spResult], 'No se ha encontrado ningún manifiesto de despacho ACTIVO según los datos proporcionados, intente nuevamente o comuníquese con soporte técnico.' [spMessage];
			RETURN;
		END

	SET @EXISTING_LRPCD = (SELECT		COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail]) AS CONT
							FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
							INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
								ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
								AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
							WHERE		[LRPCD].[GuideSerie] = @GuideSerie
								AND		[LRPCD].[GuideNumber] = @GuideNumber
								AND		[LRPCD].[RowStatus] = 1);

	IF (@EXISTING_LRPCD = 0)
		BEGIN
			SELECT 0 [spResult], 'No se ha encontrado la guía escaneada en el manifiesto de despacho actual.' [spMessage];
			RETURN;
		END


	BEGIN TRANSACTION
	BEGIN TRY

		-- Get count StatusOrder in DeliveryOrder and DeliveryOrderDetail
		SET @EXISTING_DOD = (SELECT COUNT([DOD].[StatusOrderId]) AS CONT
							FROM	[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
							WHERE	[DOD].[Guide_Serie] = @GuideSerie
								AND [DOD].[Guide_Number] = @GuideNumber
								AND [DOD].[RowStatus] = 1);

		-- Update StatusOrder in DeliveryOrder, DeliveryOrderDetail
		IF (@EXISTING_DOD < 2)
			BEGIN
				SET @STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
										FROM	[dbo].[StatusOrder] SO
										WHERE	[SO].[OrderDescription] = 'Generado');

				UPDATE	[dbo].[DeliveryOrder] 
				SET		[StatusOrderId] = @STATUS_ORDER_ID
				WHERE	[Guide_Serie] = @GuideSerie
					AND	[Guide_Number] = @GuideNumber;

				UPDATE	[dbo].[DeliveryOrderDetail]
				SET		[RowStatus] = 0
				WHERE	[Guide_Serie] = @GuideSerie
					AND	[Guide_Number] = @GuideNumber;
			END
		ELSE
			BEGIN
				SET @STATUS_ORDER_ID = (SELECT TOP 1 [DOD].[StatusOrderId]
										FROM		[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
										WHERE		[DOD].[Guide_Serie] = @GuideSerie
											AND		[DOD].[Guide_Number] = @GuideNumber
											AND		[DOD].[RowStatus] = 1
										ORDER BY	[DOD].[DateCreated] DESC);

				UPDATE	[dbo].[DeliveryOrder]
				SET		[StatusOrderId] = @STATUS_ORDER_ID
				WHERE	[Guide_Serie] = @GuideSerie
					AND	[Guide_Number] = @GuideNumber;

				WITH [DOD] AS 
				(SELECT [Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [RowStatus]
				FROM	[dbo].[DeliveryOrderDetail] WITH (NOLOCK)
				WHERE	[Guide_Serie] = @GuideSerie
					AND [Guide_Number] = @GuideNumber
					AND [RowStatus] = 1)
				UPDATE DOD SET [RowStatus] = 0;

			END

		-- Get Linehaul Route Preparation Container Detail Id
		SET @EXISTING_LRPCD = (SELECT		[LRPCD].[IdLinehaulRoutePreparationContainerDetail]
								FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
								INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
									ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
									AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								WHERE		[LRPCD].[GuideSerie] = @GuideSerie
									AND		[LRPCD].[GuideNumber] = @GuideNumber
									AND		[LRPCD].[RowStatus] = 1);

		SET @EXISTING_LRPC = (SELECT		[LRPCD].[LinehaulRoutePreparationContainerId]
								FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
								INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
									ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
									AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								WHERE		[LRPCD].[GuideSerie] = @GuideSerie
									AND		[LRPCD].[GuideNumber] = @GuideNumber
									AND		[LRPCD].[RowStatus] = 1);

		-- Remove guide in Linehaul Route Preparation Container Detail
		UPDATE		[LRPCD]
		SET			[LRPCD].[RowStatus] = 0,
					[LRPCD].[TokenUpdated] = @TknUser,
					[LRPCD].[DateUpdated] = SYSDATETIME()
		FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
		WHERE		[LRPCD].[GuideSerie] = @GuideSerie
			AND		[LRPCD].[GuideNumber] = @GuideNumber;

		-- Remove guide pieces in Linehaul Route Preparation Container Detail Piece
		UPDATE		[LRPCDP]
		SET			[LRPCDP].[RowStatus] = 0, 
					[LRPCDP].[TokenUpdated] = @TknUser,
					[LRPCDP].[DateUpdated] = SYSDATETIME()
		FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
		WHERE		[LRPCD].[GuideSerie] = @GuideSerie
			AND		[LRPCD].[GuideNumber] = @GuideNumber;

		-- UPDATE GENERAL NUMBERS
		-- UPDATE LinehaulRoutePreparationContainerDetail
		SET @DRY_PIECE_QUANTITY_PIECE =		(SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
											FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
											WHERE	[LRPCDP].[IsDryPiece] = 1
												AND	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
												AND [LRPCDP].[RowStatus] = 1
												AND	[LRPCDP].[ActCode] IS NULL);

		SET @COLD_PIECE_QUANTITY_PIECE =	(SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
											FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
											WHERE	[LRPCDP].[IsDryPiece] = 0
												AND	[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = @EXISTING_LRPCD
												AND [LRPCDP].[RowStatus] = 1
												AND	[LRPCDP].[ActCode] IS NULL);

		UPDATE	[LinehaulRoutePreparationContainerDetail]
		SET		[DryPieceQuantity] =							@DRY_PIECE_QUANTITY_PIECE,
				[ColdPieceQuantity] =							@COLD_PIECE_QUANTITY_PIECE
		WHERE	[IdLinehaulRoutePreparationContainerDetail] =	@EXISTING_LRPCD;

		-- UPDATE LinehaulRoutePreparationContainer

		SET @GUIDE_QUANTITY_DETAIL =	(SELECT COUNT([LRPCD].[IdLinehaulRoutePreparationContainerDetail])
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_LRPC
											AND [LRPCD].[RowStatus] = 1);

		SET @DRY_PIECE_QUANTITY_DETAIL =(SELECT COALESCE(SUM([LRPCD].[DryPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_LRPC
											AND [LRPCD].[RowStatus] = 1);

		SET @COLD_PIECE_QUANTITY_DETAIL=(SELECT COALESCE(SUM([LRPCD].[ColdPieceQuantity]), 0)
										FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
										WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @EXISTING_LRPC
											AND [LRPCD].[RowStatus] = 1);

		UPDATE	[LinehaulRoutePreparationContainer]
		SET		[GuideQuantity] =						@GUIDE_QUANTITY_DETAIL,
				[DryPieceQuantity] =					@DRY_PIECE_QUANTITY_DETAIL,
				[ColdPieceQuantity] =					@COLD_PIECE_QUANTITY_DETAIL
		WHERE	[IdLinehaulRoutePreparationContainer] = @EXISTING_LRPC;

		-- UPDATE LinehaulRoutePreparation

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

		SELECT 1 [spResult], 'Guía ha sido removida del listado actual con éxito' [spMessage];

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