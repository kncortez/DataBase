-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <11-08-2022>
-- Description:	<Add a guide into LinehaulRouteSettlementContainerDetail and LinehaulRouteSettlementContainerDetailPiece>
-- =============================================

CREATE PROCEDURE [dbo].[spHM_addGuideToLinehaulSettlement] 
	@LinehaulRouteSettlementId AS INT,
	@LinehaulRoutePreparationId AS INT,
	@LinehaulRouteSettlementContainerId AS INT,
	@ContainerId AS INT,
	@HubId AS INT,
	@GuideSerie AS NVARCHAR(10),
	@GuideNumber AS NVARCHAR(25),
	@GuidePiece AS INT,
	@IsOpenProcess AS INT,
	@GuideReceived AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRPC AS INT;				-- LinehaulRoutePreparationContainer
	DECLARE @EXISTING_LRPCDP AS INT;			-- LinehaulRoutePreparationContainerDetailPiece
	DECLARE @EXISTING_LRSC AS INT;				-- LinehaulRouteSettlementContainer;
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
	DECLARE @DOP_PIECES AS INT;					-- DeliveryOrderPiece
	DECLARE @GUIDE_IS_OPEN_PROCESS AS INT;		-- LinehaulRouteSettlementContainerDetail
	DECLARE @OPEN_PROCESS_TKN AS VARCHAR(50);	-- LinehaulRouteSettlementContainerDetail
	DECLARE @OPEN_PROCESS_USER AS VARCHAR(50);	-- TokenLog
	DECLARE @IS_OPEN_PROCESS AS INT;			-- Configuration
	DECLARE @LIQUIDATED_STATUS_ID AS INT;		-- CatLinehaulStatus
	DECLARE @SETTLEMENT_STATUS_ORDER_ID AS INT; -- StatusOrderId

	SET @EXISTING_LRPC = (	SELECT	COUNT([LRPC].[IdLinehaulRoutePreparationContainer]) AS CONT
							FROM	[dbo].[LinehaulRoutePreparationContainer] LRPC
							WHERE	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								AND	[LRPC].[ContainerId] = @ContainerId
								AND [LRPC].[RowStatus] = 1 );

	SET @EXISTING_LRPCDP = (SELECT	COUNT([LRPCDP].[IdLinehaulRoutePreparationContainerDetailPiece])
							FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP,
									[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD,
									[dbo].[LinehaulRoutePreparationContainer] LRPC
							WHERE	[LRPCDP].[PieceNumber] = @GuidePiece 
								AND [LRPCD].[IdLinehaulRoutePreparationContainerDetail] = [LRPCDP].[LinehaulRoutePreparationContainerDetailId]
								AND [LRPCD].[GuideSerie] = @GuideSerie
								AND [LRPCD].[GuideNumber] = @GuideNumber
								AND [LRPCD].[RowStatus] = 1
								AND [LRPC].[IdLinehaulRoutePreparationContainer] = [LRPCD].[LinehaulRoutePreparationContainerId]
								AND [LRPC].[ContainerId] = @ContainerId
								AND [LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								AND [LRPC].[RowStatus] = 1);

	SET @DOP_PIECES = (SELECT	COUNT([DOP].[NoPiece]) AS CONT
						FROM	[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
						WHERE	[DOP].[GuideSerie] = @GuideSerie
							AND [DOP].[GuideNumber] = @GuideNumber);

	SET @EXISTING_LRSC = (SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
							FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
							WHERE	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
								AND [LRSC].[ContainerId] = @ContainerId
								AND [LRSC].[HubId] = @HubId
								AND [LRSC].[RowStatus] = 1);

	SET @LIQUIDATED_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'LIQUIDATED');

	IF (@EXISTING_LRPC = 0)
		BEGIN
			-- LinehaulRoutePreparationContainer doesn't exist
			SELECT 0 [spResult], 'Contenedor NO existe en despacho de ruta' [errorMessage];
			RETURN;
		END

	IF (@EXISTING_LRPCDP = 0)
		-- PIECE DOESN'T EXIST IN LINEHAUL ROUTE PREPARATION
		BEGIN
			-- HERE SEND A MESSAGE TO USER
			SELECT 0 [spResult], 'Pieza NO existe en contenedor seleccionado' [errorMessage];
			RETURN;
		END

	IF (@EXISTING_LRSC = 0)
		BEGIN
		-- CONTAINER DOESN'T EXIST IN SETTLEMENT
			SELECT 0 [spResult], 'Contenedor NO existe en liquidación de ruta' [errorMessage]
			RETURN;
		END

	-- CHECK IF GUIDE IS IN SETTLEMENT
	SET @EXISTING_LRSCD = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
							FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
							WHERE		[LRSCD].[GuideSerie] = @GuideSerie
								AND		[LRSCD].[GuideNumber] = @GuideNumber
								AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId);

	SET @EXISTING_LRSCD_ACTIVE = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
								FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
								WHERE		[LRSCD].[GuideSerie] = @GuideSerie
									AND		[LRSCD].[GuideNumber] = @GuideNumber
									AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
									AND		[LRSCD].[GuideReceived] = 1
									AND		[LRSCD].[RowStatus] = 1 );

	IF (@EXISTING_LRSCD_ACTIVE > 0)
		BEGIN
			SELECT 5 [spResult], 'Guía ya se ha registrado en el proceso actual' [errorMessage];
			RETURN;
		END

	-- CONTAINER IS ADDED IN SETTLEMENT
	BEGIN TRANSACTION
	BEGIN TRY
	-- ADD OR UPDATE CONTAINER DETAIL IN SETTLEMENT
		-- GET STATUS ORDER ID FOR SETTLEMENT
		SET @SETTLEMENT_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
											FROM	[dbo].[StatusOrder] SO
											WHERE	[SO].[OrderDescription] = 'Trasladado a Hub');

		-- CHECK IF PIECE EXISTS IN SETTLEMENT
		SET @EXISTING_LRSCDP = (SELECT	COUNT([LRSCDP].[IdLinehaulRouteSettlementContainerDetailPiece]) AS CONT
								FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
								INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
									ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
									AND		[LRSCD].[GuideSerie] = @GuideSerie
									AND		[LRSCD].[GuideNumber] = @GuideNumber
									AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
								WHERE		[LRSCDP].[PieceNumber] = @GuidePiece);

		IF (@EXISTING_LRSCD = 0)
		-- CONTAINER DETAIL IN SETTLEMENT DOESN'T EXIST, INSERT
			BEGIN
				SET @IS_OPEN_PROCESS = 0;
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
					VALUES	(@LinehaulRouteSettlementContainerId,
								@GuideSerie,
								@GuideNumber,
								0,					-- PiecesReceived
								0,					-- PiecesMissing
								@GuideReceived,
								@IS_OPEN_PROCESS,
								@TknUser,
								1,					-- RowStatus,
								@TknUser,
								SYSDATETIME());

				SET @EXISTING_LRSCD = SCOPE_IDENTITY();
			END

		BEGIN
			IF (@DOP_PIECES > 1)
				BEGIN
					-- MULTIPLE PIECES
					SET @GUIDE_IS_OPEN_PROCESS = (SELECT	[LRSCD].[IsOpenProcess]
													FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
													WHERE	[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
														AND [LRSCD].[GuideSerie] = @GuideSerie
														AND [LRSCD].[GuideNumber] = @GuideNumber);

					IF (@GUIDE_IS_OPEN_PROCESS = 1)
						BEGIN
						-- GUIDE IS OPEN PROCESS, CHECK USER
							SET @OPEN_PROCESS_TKN = (SELECT	[LRSCD].[UserProcess]
													FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
													WHERE	[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
														AND [LRSCD].[GuideSerie] = @GuideSerie
														AND [LRSCD].[GuideNumber] = @GuideNumber);

							SET @OPEN_PROCESS_USER = (SELECT		[IU].[Username]
														FROM		[dbo].[TokenLog] TL WITH(NOLOCK)
														INNER JOIN	[dbo].[InternalUser] IU
															ON		[TL].[TknIdUser] = [IU].[RegisterUserID]
														WHERE		[TL].[TknIdToken] = @OPEN_PROCESS_TKN);

							IF (@OPEN_PROCESS_TKN = @TknUser)
								BEGIN
								-- SAME USER IN OPEN PROCESS
									IF (@IsOpenProcess = 1)
										BEGIN
											-- USER HAS OPEN PROCESS, ADD PIECE TO LINEHAUL
											-- CONTAINER DETAIL IN SETTLEMENT EXISTS, UPDATE
											UPDATE	[LinehaulRouteSettlementContainerDetail]
											SET		[RowStatus] = 0,
													[TokenUpdated] = @TknUser,
													[DateUpdated] = SYSDATETIME(),
													[IsOpenProcess] = @IsOpenProcess,
													[GuideReceived] = @GuideReceived,
													[UserProcess] = @TknUser
											WHERE	[GuideSerie] = @GuideSerie
												AND	[GuideNumber] = @GuideNumber
												AND [LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId;
										
											IF (@EXISTING_LRSCDP > 0)
												BEGIN
												-- PIECE EXISTS IN SETTLEMENT, UPDATE
													UPDATE	[LinehaulRouteSettlementContainerDetailPiece] 
													SET		[RowStatus] = 1,
															[TokenUpdated] = @TknUser,
															[DateUpdated] = SYSDATETIME()
													WHERE	[LinehaulRouteSettlementContainerDetailId]  = (SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail]
																											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
																											WHERE		[LRSCD].[GuideSerie] = @GuideSerie
																												AND		[LRSCD].[GuideNumber] = @GuideNumber
																												AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId)
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
													WHERE	[LRPCDP].[PieceNumber] = @GuidePiece;

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
														AND		[LRSCD].[IsOpenProcess] = 1
													WHERE		[LRSCDP].[RowStatus] = 1;

												END
											ELSE
												BEGIN
												-- PIECE DOESN'T EXIST IN SETTLEMENT, INSERT
													INSERT INTO	[dbo].[LinehaulRouteSettlementContainerDetailPiece]
																([LinehaulRouteSettlementContainerDetailId],
																	[PieceNumber],
																	[IsDryPiece],
																	[RowStatus],
																	[TokenCreated],
																	[DateCreated])
														VALUES	((SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail]
																	FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
																	WHERE		[LRSCD].[GuideSerie] = @GuideSerie
																		AND		[LRSCD].[GuideNumber] = @GuideNumber
																		AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId),
																@GuidePiece,
																(SELECT		[LRPCDP].[IsDryPiece]
																FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
																INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
																	ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
																	AND		[LRPCD].[GuideSerie] = @GuideSerie
																	AND		[LRPCD].[GuideNumber] = @GuideNumber
																	AND		[LRPCD].[RowStatus] = 1
																INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
																	ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
																	AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
																WHERE		[LRPCDP].[PieceNumber] = @GuidePiece),
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
													INSERT INTO [dbo].[DeliveryOrderDetail]
																([Guide_Serie],
																	[Guide_Number],
																	[StatusOrderId],
																	[UserCreated],
																	[DateCreated],
																	[DateCreatedInSystem])
													SELECT		[LRPCD].[GuideSerie],
																[LRPCD].[GuideNumber],
																@SETTLEMENT_STATUS_ORDER_ID,
																@TknUser,
																SYSDATETIME(),
																SYSDATETIME()
														FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRPCD
														WHERE	[LRPCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementId;

													-- RETURN PIECE DATA
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
														AND		[LRSCD].[IsOpenProcess] = 1
													WHERE		[LRSCDP].[RowStatus] = 1;

												END
										END
									ELSE
										BEGIN
											-- USER DOESN'T HAS OPEN PROCES, ASK FOR COMPLETE PIECES
											SELECT 1 [spResult], 'Guide has multiple pieces' [errorMessage];
										END
								END
							ELSE
								BEGIN
								-- OPEN PROCESS WITH DIFFERENT USER, SEND ALERT TO CLIENT
									SELECT 2 [spResult], @OPEN_PROCESS_USER [errorMessage];
								END
						END
					ELSE
						IF (@IsOpenProcess = 1)
							BEGIN
							-- CONTAINER DETAIL IN SETTLEMENT EXISTS, UPDATE
								UPDATE	[LinehaulRouteSettlementContainerDetail]
								SET		[RowStatus] = 0,
										[TokenUpdated] = @TknUser,
										[DateUpdated] = SYSDATETIME(),
										[IsOpenProcess] = @IsOpenProcess,
										[GuideReceived] = @GuideReceived,
										[UserProcess] = @TknUser
								WHERE	[GuideSerie] = @GuideSerie
									AND	[GuideNumber] = @GuideNumber
									AND [LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId;
										
								IF (@EXISTING_LRSCDP > 0)
									BEGIN
									-- PIECE EXISTS IN SETTLEMENT, UPDATE
										UPDATE	[LinehaulRouteSettlementContainerDetailPiece] 
										SET		[RowStatus] = 1,
												[TokenUpdated] = @TknUser,
												[DateUpdated] = SYSDATETIME()
										WHERE	[LinehaulRouteSettlementContainerDetailId]  = (SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail]
																								FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
																								WHERE		[LRSCD].[GuideSerie] = @GuideSerie
																									AND		[LRSCD].[GuideNumber] = @GuideNumber
																									AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId)
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
										WHERE	[LRPCDP].[PieceNumber] = @GuidePiece;

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
											AND		[LRSCD].[IsOpenProcess] = 1
										WHERE		[LRSCDP].[RowStatus] = 1;

									END
								ELSE
									BEGIN
									-- PIECE DOESN'T EXIST IN SETTLEMENT, INSERT
										INSERT INTO	[dbo].[LinehaulRouteSettlementContainerDetailPiece]
													([LinehaulRouteSettlementContainerDetailId],
														[PieceNumber],
														[IsDryPiece],
														[RowStatus],
														[TokenCreated],
														[DateCreated])
											VALUES	((SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail]
														FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
														WHERE		[LRSCD].[GuideSerie] = @GuideSerie
															AND		[LRSCD].[GuideNumber] = @GuideNumber
															AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId),
													@GuidePiece,
													(SELECT		[LRPCDP].[IsDryPiece]
													FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
													INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
														ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
														AND		[LRPCD].[GuideSerie] = @GuideSerie
														AND		[LRPCD].[GuideNumber] = @GuideNumber
														AND		[LRPCD].[RowStatus] = 1
													INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
														ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
														AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
													WHERE	[LRPCDP].[PieceNumber] = @GuidePiece),
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
										WHERE		[LRPCDP].[PieceNumber] = @GuidePiece;

										-- UPDATE STATUS IN DELIVERY ORDER
										UPDATE	[DeliveryOrder]
										SET		[StatusOrderId] = @SETTLEMENT_STATUS_ORDER_ID,
												[TokenUpdated] = @TknUser,
												[DateUpdated] = SYSDATETIME()
										WHERE	[Guide_Serie] = @GuideSerie
											AND [Guide_Number] = @GuideNumber;
						
										-- INSERT LOG IN DELIVERY ORDER DETAIL
										INSERT INTO [dbo].[DeliveryOrderDetail]
													([Guide_Serie],
														[Guide_Number],
														[StatusOrderId],
														[UserCreated],
														[DateCreated],
														[DateCreatedInSystem])
										SELECT		[LRPCD].[GuideSerie],
													[LRPCD].[GuideNumber],
													@SETTLEMENT_STATUS_ORDER_ID,
													@TknUser,
													SYSDATETIME(),
													SYSDATETIME()
											FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRPCD
											WHERE	[LRPCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementId;

										-- RETURN PIECE DATA
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
											AND		[LRSCD].[IsOpenProcess] = 1
										WHERE		[LRSCDP].[RowStatus] = 1;

									END
							END
						ELSE
							BEGIN
								-- USER DOESN'T HAS OPEN PROCES, ASK FOR COMPLETE PIECES
								UPDATE	[LinehaulRouteSettlementContainerDetail]
								SET		[RowStatus] = 0,
										[TokenUpdated] = @TknUser,
										[DateUpdated] = SYSDATETIME(),
										[IsOpenProcess] = @IsOpenProcess,
										[GuideReceived] = @GuideReceived,
										[UserProcess] = @TknUser
								WHERE	[GuideSerie] = @GuideSerie
									AND	[GuideNumber] = @GuideNumber
									AND [LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId;

								SELECT 1 [spResult], 'Guide has multiple pieces' [errorMessage];
								--RETURN;
							END
				END
			ELSE
				BEGIN
					-- ONE PIECE, ADD TO SETTLEMENT
					-- CONTAINER DETAIL IN SETTLEMENT EXISTS, UPDATE
					UPDATE	[LinehaulRouteSettlementContainerDetail]
					SET		[RowStatus] = 1,
							[TokenUpdated] = @TknUser,
							[DateUpdated] = SYSDATETIME(),
							[IsOpenProcess] = @IsOpenProcess,
							[GuideReceived] = @GuideReceived,
							[UserProcess] = @TknUser
					WHERE	[GuideSerie] = @GuideSerie
						AND	[GuideNumber] = @GuideNumber
						AND [LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId;
										
					IF (@EXISTING_LRSCDP > 0)
						BEGIN
						-- PIECE EXISTS IN SETTLEMENT, UPDATE
							UPDATE	[LinehaulRouteSettlementContainerDetailPiece] 
							SET		[RowStatus] = 1,
									[TokenUpdated] = @TknUser,
									[DateUpdated] = SYSDATETIME()
							WHERE	[LinehaulRouteSettlementContainerDetailId]  = (SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail]
																					FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
																					WHERE		[LRSCD].[GuideSerie] = @GuideSerie
																						AND		[LRSCD].[GuideNumber] = @GuideNumber
																						AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId)
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
							INSERT INTO	[dbo].[LinehaulRouteSettlementContainerDetailPiece]
										([LinehaulRouteSettlementContainerDetailId],
											[PieceNumber],
											[IsDryPiece],
											[RowStatus],
											[TokenCreated],
											[DateCreated])
								VALUES	((SELECT		[LRSCD].[IdLinehaulRouteSettlementContainerDetail]
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											WHERE		[LRSCD].[GuideSerie] = @GuideSerie
												AND		[LRSCD].[GuideNumber] = @GuideNumber
												AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId),
										@GuidePiece,
										(SELECT		[LRPCDP].[IsDryPiece]
										FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
										INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
											ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
											AND		[LRPCD].[GuideSerie] = @GuideSerie
											AND		[LRPCD].[GuideNumber] = @GuideNumber
											AND		[LRPCD].[RowStatus] = 1
										INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
											ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
											AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
										WHERE	[LRPCDP].[PieceNumber] = @GuidePiece),
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
							INSERT INTO [dbo].[DeliveryOrderDetail]
										([Guide_Serie],
										 [Guide_Number],
										 [StatusOrderId],
										 [UserCreated],
										 [DateCreated],
										 [DateCreatedInSystem])
							SELECT		[LRPCD].[GuideSerie],
										[LRPCD].[GuideNumber],
										@SETTLEMENT_STATUS_ORDER_ID,
										@TknUser,
										SYSDATETIME(),
										SYSDATETIME()
								FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRPCD
								WHERE	[LRPCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
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
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
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
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
										WHERE		[LRSCDP].[ActCode] IS NOT NULL
											AND		[LRSCDP].[RowStatus] = 1);

			UPDATE	[LinehaulRouteSettlementContainerDetail]
			SET		[PiecesReceived] = @COUNT_RECEIVED_PIECES,
					[PiecesMissing] = @COUNT_MISSING_PIECES
			WHERE	[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
				AND [GuideSerie] = @GuideSerie
				AND [GuideNumber] = @GuideNumber;

			-- UPDATE SETTLEMENT CONTAINER COUNTERS
			SET @COUNT_DRY_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[IsDryPiece] = 1
											AND		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);

			SET @COUNT_COLD_QUANTITY = (SELECT		COUNT([LRSCDP].[PieceNumber]) AS CONT
										FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
										INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
											AND		[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
											AND		[LRSCD].[RowStatus] = 1
											AND		[LRSCD].[IsOpenProcess] = 0
										WHERE		[LRSCDP].[IsDryPiece] = 0
											AND		[LRSCDP].[ActCode] IS NULL
											AND		[LRSCDP].[RowStatus] = 1);
									
			SET @COUNT_GUIDE_QUANTITY = (SELECT  COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
										FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
										WHERE	[LRSCD].[RowStatus] = 1
											AND	[LRSCD].[IsOpenProcess] = 0
											AND [LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId);
									
			UPDATE	[LinehaulRouteSettlementContainer]
			SET		[GuideQuantity] = @COUNT_GUIDE_QUANTITY,
					[DryPiecesQuantity] = @COUNT_DRY_QUANTITY,
					[ColdPiecesQuantity] = @COUNT_COLD_QUANTITY
			WHERE	[IdLinehaulRouteSettlementContainer] = @LinehaulRouteSettlementContainerId;

			-- UPDATE SETTLEMENT HEADER COUNTERS
			SET @COUNT_CONTAINERS_RECEIVED = (SELECT	COUNT([LRSC].[IdLinehaulRouteSettlementContainer]) AS CONT
												FROM	[dbo].[LinehaulRouteSettlementContainer] LRSC
												WHERE	[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
													AND [LRSC].[RowStatus] = 1);

			SET @COUNT_GUIDES_RECEIVED = (SELECT		COUNT([LRSCD].[IdLinehaulRouteSettlementContainerDetail]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
											WHERE		[LRSCD].[RowStatus] = 1);

			SET @COUNT_PIECES_RECEIVED = (SELECT		SUM([LRSCD].[PiecesReceived]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
												AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId);

			SET @COUNT_PIECES_MISSING = (SELECT		SUM([LRSCD].[PiecesMissing]) AS CONT
											FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
											INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
												ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
												AND		[LRSC].[RowStatus] = 1
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