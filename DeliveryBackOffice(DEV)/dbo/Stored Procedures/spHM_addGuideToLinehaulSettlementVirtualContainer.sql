-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <13-03-2023>
-- Description:	<Add guide into virtual container - Linehaul Settlement>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_addGuideToLinehaulSettlementVirtualContainer] 
	@LinehaulRouteSettlementId AS INT,
	@LinehaulRoutePreparationId AS INT,
	@HubId AS INT,
	@GuideSerie AS NVARCHAR(10),
	@GuideNumber AS NVARCHAR(25),
	@GuidePiece AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VBX_ID AS INT;						-- Container
	DECLARE @EXISTING_LRPCDP AS INT;			-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @EXISTING_PIECE AS INT;				-- DeliveryOrderPiece
	DECLARE @EXISTING_LRSCD AS INT;				-- LinehaulRouteSettlementContainerDetail
	DECLARE @EXISTING_LRSCD_ACTIVE AS INT;		-- LinehaulRouteSettlementContainerDetail
	DECLARE @EXISTING_LRSCDP AS INT;			-- LinehaulRouteSettlementContainerDetailPiece
	DECLARE @INSERTED_DOC AS INT;				-- Last inserted doc
	DECLARE @COUNT_RECEIVED_PIECES AS INT;		-- Update LinehaulRouteSettlementContainerDetail
	DECLARE @COUNT_MISSING_PIECES AS INT;		-- Update LinehaulRouteSettlementContainerDetail
	DECLARE @COUNT_GUIDE_QUANTITY AS INT;		-- Update LinehaulRouteSettlementContainer
	DECLARE @COUNT_DRY_QUANTITY AS INT;			-- Update LinehaulRouteSettlementContainer
	DECLARE @COUNT_COLD_QUANTITY AS INT;		-- Update LinehaulRouteSettlementContainer
	DECLARE @COUNT_CONTAINERS_RECEIVED AS INT;	-- Update LinehaulRouteSettlement
	DECLARE @COUNT_GUIDES_RECEIVED AS INT;		-- Update LinehaulRouteSettlement
	DECLARE @COUNT_PIECES_RECEIVED AS INT;		-- Update LinehaulRouteSettlement
	DECLARE @COUNT_PIECES_MISSING AS INT;		-- Update LinehaulRouteSettlement
	DECLARE @GUIDE_IS_OPEN_PROCESS AS INT;		-- LinehaulRouteSettlementContainerDetail
	DECLARE @OPEN_PROCESS_TKN AS VARCHAR(50);	-- LinehaulRouteSettlementContainerDetail
	DECLARE @OPEN_PROCESS_USER AS VARCHAR(50);	-- TokenLog
	DECLARE @LIQUIDATED_STATUS_ID AS INT;		-- CatLinehaulStatus
	DECLARE @SETTLEMENT_STATUS_ORDER_ID AS INT; -- StatusOrderId
	DECLARE @EXISTING_LRSC AS INT;				-- LinehaulRouteSettlementContainer
	DECLARE @IS_DRY_PIECE AS BIT;				-- DeliveryOrderPiece

	SET @VBX_ID = (	SELECT		TOP 1 [C].[IdContainer]
					FROM		[dbo].[Container] C
					INNER JOIN	[dbo].[CatTypeContainer] CTC
						ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
						AND		[CTC].[TypeContainerSerie] = 'VBX'
					WHERE		[C].[RowStatus] = 1);

	SET @EXISTING_LRSC = (	SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer])
							FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
							WHERE	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
								AND	[LRSC].[ContainerId] = @VBX_ID
								AND [LRSC].[RowStatus] = 1);
	
	IF (@EXISTING_LRSC > 0)
		BEGIN
			SET @EXISTING_LRSC = (	SELECT	[LRSC].[IdLinehaulRouteSettlementContainer]
									FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
									WHERE	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
										AND	[LRSC].[ContainerId] = @VBX_ID
										AND [LRSC].[RowStatus] = 1);
		END

	SET @EXISTING_PIECE = (SELECT	COUNT([DOP].[NoPiece])
							FROM	[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
							WHERE	[DOP].[NoPiece] = @GuidePiece 
								AND	[DOP].[GuideSerie] = @GuideSerie
								AND [DOP].[GuideNumber] = @GuideNumber);

	SET @IS_DRY_PIECE = (SELECT	[DOP].[IsDry]
						FROM	[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
						WHERE	[DOP].[NoPiece] = @GuidePiece 
							AND	[DOP].[GuideSerie] = @GuideSerie
							AND [DOP].[GuideNumber] = @GuideNumber);

	SET @EXISTING_LRPCDP = (SELECT		COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
							FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
							INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
								ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
								AND		[LRPCD].[GuideSerie] = @GuideSerie
								AND		[LRPCD].[GuideNumber] = @GuideNumber
								AND		[LRPCD].[RowStatus] = 1
							INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
								ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
								AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								AND		[LRPC].[RowStatus] = 1
							WHERE		[LRPCDP].[PieceNumber] = @GuidePiece );

	SET @LIQUIDATED_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'LIQUIDATED');
	
	IF (@EXISTING_PIECE = 0)
		-- PIECE DOESN'T EXIST
		BEGIN
			-- HERE SEND A MESSAGE TO USER
			SELECT 0 [spResult], 'Pieza NO existe en la base de datos, intente nuevamente.' [errorMessage];
			RETURN;
		END

	IF (@EXISTING_LRPCDP > 0)
		BEGIN
			-- Si la pieza existe en el manifiesto de despacho rechazar proceso, debe ser agregada en el forma estándar.
			SELECT 0 [spResult], 'La pieza escaneada NO puede ser agregada a contenedor virtual, debe ser liquidada bajo el esquema estándar.' [errorMessage];
			RETURN;
		END

	-- CHECK IF GUIDE IS IN SETTLEMENT
	SET @EXISTING_LRSCD = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
							FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
							WHERE		[LRSCD].[GuideSerie] = @GuideSerie
								AND		[LRSCD].[GuideNumber] = @GuideNumber);

	SET @EXISTING_LRSCD_ACTIVE = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
								FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
								WHERE		[LRSCD].[GuideSerie] = @GuideSerie
									AND		[LRSCD].[GuideNumber] = @GuideNumber
									AND		[LRSCD].[GuideReceived] = 1
									AND		[LRSCD].[RowStatus] = 1 );

	-- CHECK IF PIECE EXISTS IN SETTLEMENT
	SET @EXISTING_LRSCDP = (SELECT	COUNT([LRSCDP].[IdLinehaulRouteSettlementContainerDetailPiece]) AS CONT
							FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
							INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
								ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
								AND		[LRSCD].[GuideSerie] = @GuideSerie
								AND		[LRSCD].[GuideNumber] = @GuideNumber
							WHERE		[LRSCDP].[PieceNumber] = @GuidePiece);

	IF (@EXISTING_LRSCD_ACTIVE > 0 AND @EXISTING_LRSCDP > 0)
		BEGIN
			SELECT 5 [spResult], 'Pieza ya se ha registrado en el proceso actual' [errorMessage];
			RETURN;
		END

	BEGIN TRANSACTION
	BEGIN TRY
	-- ADD OR UPDATE CONTAINER DETAIL IN SETTLEMENT
		-- GET STATUS ORDER ID FOR SETTLEMENT
		SET @SETTLEMENT_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
											FROM	[dbo].[StatusOrder] SO
											WHERE	[SO].[OrderDescription] = 'Trasladado a Hub');

		-- IF VIRTUAL CONTAINER DOESNT EXIST, THEN ADD IT
		IF (@EXISTING_LRSC = 0)
			BEGIN
				INSERT INTO [dbo].[LinehaulRouteSettlementContainer](	[LinehaulRouteSettlementId],
																		[ContainerId],
																		[HubId],
																		[GuideQuantity],
																		[DryPiecesQuantity],
																		[ColdPiecesQuantity],
																		[RowStatus],
																		[TokenCreated],
																		[DateCreated])
				VALUES												(	@LinehaulRouteSettlementId,
																		@VBX_ID,
																		@HubId,
																		0, -- Guide Quantity
																		0, -- DryPiecesQuantity
																		1, -- ColdPiecesQuantity
																		1, -- Row Status
																		@TknUser,
																		SYSDATETIME());

				SET @EXISTING_LRSC = SCOPE_IDENTITY();
			END

		IF (@EXISTING_LRSCD = 0)
		-- CONTAINER DETAIL IN SETTLEMENT DOESN'T EXIST, INSERT
			BEGIN
				INSERT INTO [LinehaulRouteSettlementContainerDetail]
							([LinehaulRouteSettlementContainerId],
								[GuideSerie],
								[GuideNumber],
								[PiecesReceived],
								[PiecesMissing],
								[GuideReceived],
								[IsOpenProcess],
								[UserProcess],
								[RowStatus],
								[TokenCreated],
								[DateCreated])
					VALUES	(	@EXISTING_LRSC,
								@GuideSerie,
								@GuideNumber,
								0,					-- PiecesReceived
								0,					-- PiecesMissing
								1,					-- GuideReceived
								0,					-- IsOpenProcess
								@TknUser,
								1,					-- RowStatus,
								@TknUser,
								SYSDATETIME());

				SET @EXISTING_LRSCD = SCOPE_IDENTITY();
			END
		ELSE 
			BEGIN
				SET @EXISTING_LRSCD = (	SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail] AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										WHERE		[LRSCD].[GuideSerie] = @GuideSerie
											AND		[LRSCD].[GuideNumber] = @GuideNumber);
			END

		BEGIN
			-- ONE PIECE, ADD TO SETTLEMENT
			-- CONTAINER DETAIL IN SETTLEMENT EXISTS, UPDATE
			UPDATE	[LinehaulRouteSettlementContainerDetail]
			SET		[RowStatus] = 1,
					[TokenUpdated] = @TknUser,
					[DateUpdated] = SYSDATETIME(),
					[IsOpenProcess] = 0,
					[GuideReceived] = 1,
					[UserProcess] = @TknUser
			WHERE	[GuideSerie] = @GuideSerie
				AND	[GuideNumber] = @GuideNumber
				AND [LinehaulRouteSettlementContainerId] = @EXISTING_LRSC;
										
			IF (@EXISTING_LRSCDP > 0)
				BEGIN
				-- PIECE EXISTS IN SETTLEMENT, UPDATE
					UPDATE	[LinehaulRouteSettlementContainerDetailPiece] 
					SET		[RowStatus] = 1,
							[TokenUpdated] = @TknUser,
							[DateUpdated] = SYSDATETIME()
					WHERE	[LinehaulRouteSettlementContainerDetailId]  = @EXISTING_LRSCD
						AND [PieceNumber] = @GuidePiece;

				-- UPDATE PIECE IN LINEHAUL ROUTE PREPARATION
					UPDATE		[LinehaulRoutePreparationContainerDetailPiece]
					SET			[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
					FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
					INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
						ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
						AND		[LRPCD].[GuideSerie] = @GuideSerie
						AND		[LRPCD].[GuideNumber] = @GuideNumber
						AND		[LRPCD].[RowStatus] = 1
					INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
						ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
						AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
					WHERE		[LRPCDP].[PieceNumber] = @GuidePiece;

				-- RETURN DATA
					SELECT		[LRSCD].[GuideSerie],
								[LRSCD].[GuideNumber],
								[LRSCD].[UserProcess],
								[LRSCD].[IsOpenProcess],
								[LRSCDP].[IdLinehaulRouteSettlementContainerDetailPiece],
								[LRSCDP].[LinehaulRouteSettlementContainerDetailId],
								[LRSCDP].[PieceNumber],
								[LRSCDP].[IsDryPiece],
								COALESCE([LRSCDP].[ActCode], 0) AS ActCode
					FROM		[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
					INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
						ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
						AND		[LRSCD].[GuideSerie] = @GuideSerie
						AND		[LRSCD].[GuideNumber] = @GuideNumber
						AND		[LRSCD].[UserProcess] = @TknUser
					WHERE		[LRSCDP].[RowStatus] = 1;
				END
			ELSE
				BEGIN
					-- PIECE DOESN'T EXIST IN SETTLEMENT, INSERT
					INSERT INTO	[dbo].[LinehaulRouteSettlementContainerDetailPiece]([LinehaulRouteSettlementContainerDetailId],
																					[PieceNumber],
																					[IsDryPiece],
																					[RowStatus],
																					[TokenCreated],
																					[DateCreated])
						VALUES													(	@EXISTING_LRSCD,
																					@GuidePiece,
																					@IS_DRY_PIECE,
																					1,		-- RowStatus
																					@TknUser,
																					SYSDATETIME());

					SET @INSERTED_DOC = SCOPE_IDENTITY();

					-- UPDATE PIECE IN LINEHAUL ROUTE PREPARATION
					UPDATE		[LinehaulRoutePreparationContainerDetailPiece]
					SET			[CatLinehaulStatusId] = @LIQUIDATED_STATUS_ID
					FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
					INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
						ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
						AND		[LRPCD].[GuideSerie] = @GuideSerie
						AND		[LRPCD].[GuideNumber] = @GuideNumber
						AND		[LRPCD].[RowStatus] = 1
					INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
						ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
						AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
					WHERE	[LRPCDP].[PieceNumber] = @GuidePiece;

					-- UPDATE STATUS IN DELIVERY ORDER
					UPDATE	[DeliveryOrder]
					SET		[StatusOrderId] = @SETTLEMENT_STATUS_ORDER_ID,
							[TokenUpdated] = @TknUser,
							[DateUpdated] = SYSDATETIME()
					WHERE	[Guide_Serie] = @GuideSerie
						AND [Guide_Number] = @GuideNumber;
						
					-- INSERT LOG IN DELIVERY ORDER DETAIL
					INSERT INTO [dbo].[DeliveryOrderDetail]([Guide_Serie],
															[Guide_Number],
															[StatusOrderId],
															[UserCreated],
															[DateCreated],
															[DateCreatedInSystem])
					SELECT									[LRPCD].[GuideSerie],
															[LRPCD].[GuideNumber],
															@SETTLEMENT_STATUS_ORDER_ID,
															@TknUser,
															SYSDATETIME(),
															SYSDATETIME()
						FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRPCD
						WHERE	[LRPCD].[LinehaulRouteSettlementContainerId] = @EXISTING_LRSC
							AND [LRPCD].[GuideNumber] = @GuideNumber
							AND [LRPCD].[GuideSerie] = @GuideSerie
							AND [LRPCD].[RowStatus] = 1;

					-- RETURN DATA
					SELECT		[LRSCD].[GuideSerie],
								[LRSCD].[GuideNumber],
								[LRSCD].[UserProcess],
								[LRSCD].[IsOpenProcess],
								[LRSCDP].[IdLinehaulRouteSettlementContainerDetailPiece],
								[LRSCDP].[LinehaulRouteSettlementContainerDetailId],
								[LRSCDP].[PieceNumber],
								[LRSCDP].[IsDryPiece],
								COALESCE([LRSCDP].[ActCode], 0) AS ActCode
					FROM		[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
					INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
						ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
						AND		[LRSCD].[GuideSerie] = @GuideSerie
						AND		[LRSCD].[GuideNumber] = @GuideNumber
						AND		[LRSCD].[UserProcess] = @TknUser
					WHERE		[LRSCDP].[RowStatus] = 1;
				END
		END

		-- UDPATE SETTLEMENT COUNTERS
		BEGIN
			-- UPDATE SETTLEMENT DETAIL COUNTERS
			SET @COUNT_RECEIVED_PIECES =			(SELECT  COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]	
											AND		[LRSCD].[GuideSerie] = @GuideSerie
											AND		[LRSCD].[GuideNumber] = @GuideNumber
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_LRSC
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);

			SET @COUNT_MISSING_PIECES =	(SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]	
											AND		[LRSCD].[GuideSerie] = @GuideSerie
											AND		[LRSCD].[GuideNumber] = @GuideNumber
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_LRSC
										WHERE		[LRSCDP].[ActCode] IS NOT NULL
											AND		[LRSCDP].[RowStatus] = 1);

			UPDATE	[LinehaulRouteSettlementContainerDetail]
			SET		[PiecesReceived] = @COUNT_RECEIVED_PIECES,
					[PiecesMissing] = @COUNT_MISSING_PIECES
			WHERE	[LinehaulRouteSettlementContainerId] = @EXISTING_LRSC
				AND [GuideSerie] = @GuideSerie
				AND [GuideNumber] = @GuideNumber;

			-- UPDATE SETTLEMENT CONTAINER COUNTERS
			SET @COUNT_DRY_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_LRSC
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[IsDryPiece] = 1
											AND		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);

			SET @COUNT_COLD_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_LRSC
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[IsDryPiece] = 0
											AND		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);
									
			SET @COUNT_GUIDE_QUANTITY = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										WHERE		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @EXISTING_LRSC);
									
			UPDATE	[LinehaulRouteSettlementContainer]
			SET		[GuideQuantity] = @COUNT_GUIDE_QUANTITY,
					[DryPiecesQuantity] = @COUNT_DRY_QUANTITY,
					[ColdPiecesQuantity] = @COUNT_COLD_QUANTITY
			WHERE	[IdLinehaulRouteSettlementContainer] = @EXISTING_LRSC;

			-- UPDATE SETTLEMENT HEADER COUNTERS
			SET @COUNT_CONTAINERS_RECEIVED = (SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
												FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
												WHERE	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
													AND	[LRSC].[ContainerId] != @VBX_ID
													AND [LRSC].[RowStatus] = 1);

			SET @COUNT_GUIDES_RECEIVED = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
												AND		[LRSC].[ContainerId] != @VBX_ID
											WHERE		[LRSCD].[RowStatus] = 1);

			SET @COUNT_PIECES_RECEIVED = (SELECT		SUM([LRSCD].[PiecesReceived]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[ContainerId] != @VBX_ID
												AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId);

			SET @COUNT_PIECES_MISSING = (SELECT		SUM([LRSCD].[PiecesMissing]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[ContainerId] != @VBX_ID
												AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId);

			UPDATE	[LinehaulRouteSettlement]
			SET		[ContainersReceived] = @COUNT_CONTAINERS_RECEIVED,
					[GuidesReceived] = @COUNT_GUIDES_RECEIVED,
					[GuidePiecesReceived] = @COUNT_PIECES_RECEIVED,
					[GuidePiecesMissing] = @COUNT_PIECES_MISSING
			WHERE	[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId;

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