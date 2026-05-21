/* =================================================
   SP:        [dbo].[spHM_setInTransitToLinehaulRoutePreparation]
   Propósito: <Check and set driver, tag number and status -> 'IN TRANSIT' to an active Linehaul process>
   Autor:     <Ochoa, Jerson>
   Historia:  <>  
   Fecha:     <25-07-2022>

=== CHANGELOG ================================

--  2024-06-11 | Historia/épica: FDAPI-5925   | Autor: Brandon Pedroza | Inactivacion de inventario al despachar ruta

=========================================== */
CREATE PROCEDURE [dbo].[spHM_setInTransitToLinehaulRoutePreparation] 
	@IdLinehaulRoutePreparation AS INT,
	@SenderReceiverCUI AS NVARCHAR(50) = NULL,
	@CatVehicleId AS INT = NULL,
	--@VehicleKms AS INT = 0,
	@DriverCUI AS NVARCHAR(25),
	@DriverName AS NVARCHAR(100),
	@DriverPhone AS NVARCHAR(25),
	@VehicleID AS NVARCHAR(25),
	@VehicleDescription AS NVARCHAR(100),
	@SecurityManName AS NVARCHAR(100),
	@SecurityManPhone AS NVARCHAR(25),
	@SecurityManCUI AS NVARCHAR(25),
	@Tag AS NVARCHAR(25),
	@IsInternal AS INT,
	@TknUser AS NVARCHAR(50),
	@IdStation INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;				-- Linehaul Route Preparation
	DECLARE @EXISTING_LCM AS INT;				-- Linehaul Route Preparation Customs Mark
	DECLARE @EXISTING_SR AS INT;				-- Sender Receiver
	DECLARE @EXISTING_TAG AS INT;				-- Custom Marks
	DECLARE @EXISTING_EMPTY_CONTAINERS AS INT;	-- Linehaul Route Preparation Container Detail
	DECLARE @STATUS_ORDER_ID AS INT;			-- StatusOrder
	DECLARE @STATUS_LINEHAUL_ID AS INT;			-- CatLinehaulStatus
	DECLARE @STATUS_GENERATED AS INT;			-- CatLinehaulStatus
	DECLARE @EXISTING_LRP_TRANSIT AS INT;		-- Linehaul Route Preparation
	DECLARE @AUX_VEHICLE_COUNT AS INT;			-- CatVehicle
	DECLARE @AUX_VEHICLE_KMS AS INT;			-- CatVehicle
    DECLARE @TYPECHECKPOINTFINAL AS INT=(SELECT IdCatCheckpointType FROM [dbo].[CatCheckpointType] WITH (NOLOCK) WHERE CheckpointTypeDescription = 'Checkpoint final')


	SET @STATUS_GENERATED = (SELECT [CLS].[IdCatLinehaulStatus]
							FROM	[dbo].[CatLinehaulStatus] CLS WITH (NOLOCK)
							WHERE	[CLS].[StatusName] = 'GENERATED');

	SET @STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
							FROM	[dbo].[StatusOrder] SO WITH (NOLOCK)
							WHERE	[SO].[OrderDescription] = 'En Tránsito');

	SET @STATUS_LINEHAUL_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS WITH (NOLOCK)
								WHERE	[CLS].[StatusName] = 'IN TRANSIT');

	-- Check if there is an active record in LinehaulRoutePreparation
	SET @EXISTING_LRP = (SELECT	COUNT([LRP].[IdLinehaulRoutePreparation]) AS IdLinehaulRoutePreparation
						 FROM	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
							AND	[LRP].[CatLinehaulStatusId] = @STATUS_GENERATED);

	-- Check if there is an 'IN TRANSIT' record in LinehaulRoutePreparation
	SET @EXISTING_LRP_TRANSIT = (SELECT	COUNT([LRP].[IdLinehaulRoutePreparation]) AS IdLinehaulRoutePreparation
								 FROM	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
								 WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
									AND	[LRP].[CatLinehaulStatusId] = @STATUS_LINEHAUL_ID);

	IF (@EXISTING_LRP_TRANSIT > 0)
		BEGIN
			SELECT	[LRP].[IdLinehaulRoutePreparation],
					[LRP].[StationDispatchedId],
					[LRP].[CatLinehaulStatusId],
					[LRP].[CatRouteId],
					COALESCE([LRP].[SenderReceiverId], 0) AS SenderReceiverId,
					COALESCE([LRP].[CatVehicleId], 0) AS CatVehicleId,
					COALESCE([LRP].[DriverCUI], '') AS DriverCUI,
					COALESCE([LRP].[DriverName], '') AS DriverName,
					COALESCE([LRP].[DriverPhone], '') AS DriverPhone,
					COALESCE([LRP].[VehicleID], '') AS VehicleID,
					COALESCE([LRP].[VehicleDescription], '') AS VehicleDescription,
					COALESCE([LRP].[SecurityManName], '') AS SecurityManName,
					COALESCE([LRP].[SecurityManPhone], '') AS SecurityManPhone,
					COALESCE([LRP].[SecurityManCUI], '') AS SecurityManCUI,
					[LRP].[DateLinehaulRoutePreparation],
					[LRP].[ContainerQuantity],
					[LRP].[GuideQuantity],
					[LRP].[DryPieceQuantity],
					[LRP].[ColdPieceQuantity],
					[LRP].[RowStatus],
					[LRP].[TokenCreated],
					[LRP].[DateCreated]
			FROM	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
			WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation;

			RETURN;
		END

	SET @EXISTING_TAG = (SELECT COUNT([LCM].[IdLinehaulRoutePreparationCustomsMark]) AS IdLinehaulRoutePreparationCustomsMark
						 FROM	[dbo].[LinehaulRoutePreparationCustomsMark] LCM WITH (NOLOCK)
						 WHERE	[LCM].[CustomsMarkSerie] = @Tag
							AND [LCM].[RowStatus] = 1);

	SET @EXISTING_SR = (SELECT COUNT([SR].[ID]) AS ID
						FROM [dbo].[SenderReceiver] SR WITH (NOLOCK)
						WHERE [SR].[CUI] = @SenderReceiverCUI);

	IF (@EXISTING_SR = 0 AND @IsInternal = 1)
		BEGIN
			SELECT 0 [spResult], 'CUI de piloto ingresado NO válido' [spMessage];
			RETURN;
		END

	IF (@EXISTING_SR > 0)
		BEGIN
			SET @EXISTING_SR = (SELECT TOP 1 [SR].[ID]
								FROM [dbo].[SenderReceiver] SR WITH (NOLOCK)
								WHERE [SR].[CUI] = @SenderReceiverCUI);
		END
	ELSE 
		BEGIN
			SET @EXISTING_SR = NULL;
		END

	IF (@EXISTING_LRP = 0) 
		BEGIN
			SELECT 0 [spResult], 'No existe ningún registro de despacho de linehaul con los datos ingresados' [spMessage];
			RETURN;
		END

	IF (@EXISTING_TAG > 0) 
		-- No active record, it was already processed or it doesn't exist
		BEGIN
			SELECT 2 [spResult], 'Marchamo ya ha sido registrado en otro proceso de linehaul.' [spMessage];
			RETURN;
		END

	SET @EXISTING_EMPTY_CONTAINERS = (SELECT	COUNT([LRPC].[IdLinehaulRoutePreparationContainer]) AS CONT
									  FROM		[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
									  WHERE		[LRPC].[GuideQuantity] = 0
										AND		[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
										AND		[LRPC].[RowStatus] = 1);

	IF (@EXISTING_EMPTY_CONTAINERS > 0)
		BEGIN
			SELECT		2 [spResult],
						'Se encontraron contenedores vacíos en el despacho de linehaul, debe removerlos antes de finalizar el proceso.' [spMessage],
						[LRPC].[IdLinehaulRoutePreparationContainer], 
						[LRPC].[ContainerId],
						[CTC].[TypeContainerSerie] AS ContainerSerie,
						[C].[ContainerNumber]
			FROM		[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
			INNER JOIN	[dbo].[Container] C WITH (NOLOCK)
				ON		[LRPC].[ContainerId] = [C].[IdContainer]
			INNER JOIN	[dbo].[CatTypeContainer] CTC WITH (NOLOCK)
				ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
			WHERE		[LRPC].[GuideQuantity] = 0
					AND	[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
					AND	[LRPC].[RowStatus] = 1;

			RETURN;
		END

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
				[CatVehicleId] = @CatVehicleId,
				--[VehicleKms] = @VehicleKms,
				[DriverCUI] = @DriverCUI,
				[DriverName] = @DriverName,
				[DriverPhone] = @DriverPhone,
				[VehicleID] = @VehicleID,
				[VehicleDescription] = @VehicleDescription,
				[SecurityManName] = @SecurityManName,
				[SecurityManPhone] = @SecurityManPhone,
				[SecurityManCUI] =  @SecurityManCUI,
				[CatLinehaulStatusId] = @STATUS_LINEHAUL_ID,
				[EndDateLinehaulRoutePreparation] = SYSDATETIME(),
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation;

		UPDATE	[LinehaulRoutePreparationContainer]
		SET		[CatLinehaulStatusId] = @STATUS_LINEHAUL_ID
		WHERE	[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
			AND [RowStatus] = 1;

    --Validar que guía no esta en estado final
	

 DECLARE @TblGuideUpdate TABLE (
    GuideSerie  NVARCHAR(2),
	GuideNumber  INT
 )
  INSERT INTO @TblGuideUpdate
 SELECT  Distinct Guide_Serie,Guide_Number FROM [dbo].[DeliveryOrderDetail]  DOD WITH (NOLOCK)
			                               INNER JOIN [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
											ON [DOD].[Guide_Serie] = [LRPCD].[GuideSerie]
											   AND [DOD].[Guide_Number] = [LRPCD].[GuideNumber]
											    INNER JOIN [dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
                                            ON [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
											   OUTER APPLY
											   (
														SELECT COUNT(*) CONT FROM DELIVERYORDERDETAIL CD WITH (NOLOCK)
														WHERE CD.Guide_Serie =DOD.Guide_Serie 
														AND CD.Guide_Number = DOD.Guide_Number
														AND DOD.StatusOrderId  NOT  IN(SELECT StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder]  WITH (NOLOCK) WHERE CatCheckpointTypeId = @TYPECHECKPOINTFINAL)
	
													)TBLTMP
													WHERE TBLTMP.CONT=0
											        And  [LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation 
													AND [LRPCD].[RowStatus] = 1
           BEGIN
		-- UPDATE STATUS IN DELIVERY ORDER
		UPDATE		[DO]
		SET			[DO].[StatusOrderId] = @STATUS_ORDER_ID
		FROM		[dbo].[DeliveryOrder] DO WITH (NOLOCK)
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
			ON		[DO].[Guide_Serie] = [LRPCD].[GuideSerie]
			AND		[DO].[Guide_Number] = [LRPCD].[GuideNumber]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
			ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].IdLinehaulRoutePreparation 
		WHERE NOT EXISTS (
			SELECT 1 
			FROM @TblGuideUpdate TGU
			WHERE TGU.GuideSerie  = [DO].[Guide_Serie] 
			AND  TGU.GuideNumber = [DO].[Guide_Number]
		)
		AND	   [LRPCD].[RowStatus] = 1
		AND [LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation; 

		-- UPDATE STATUS IN DELIVERY ORDER PIECE
		UPDATE		[DOP]
		SET			[DOP].[StatusOrderId] = @STATUS_ORDER_ID
		FROM		[dbo].[DeliveryOrderPiece] DOP
		INNER JOIN	[dbo].[DeliveryOrder] DO WITH (NOLOCK)
			ON		[DOP].[GuideSerie] = [DO].[Guide_Serie]
			AND		[DOP].[GuideNumber] = [DO].[Guide_Number]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
			ON		[DO].[Guide_Serie] = [LRPCD].[GuideSerie]
			AND		[DO].[Guide_Number] = [LRPCD].[GuideNumber]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
			ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].IdLinehaulRoutePreparation 
			WHERE NOT EXISTS (
				SELECT 1 
				FROM @TblGuideUpdate TGU
				WHERE TGU.GuideSerie  = [DO].[Guide_Serie] 
				AND  TGU.GuideNumber = [DO].[Guide_Number]
			)
			  AND  [LRPCD].[RowStatus] = 1
			  AND [LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation;
		
		-- INSERT CHECKPOINT IN DELIVERY ORDER DETAIL
		INSERT INTO [dbo].[DeliveryOrderDetail]
					([Guide_Serie], 
					 [Guide_Number], 
					 [StatusOrderId], 
					 [UserCreated],
					 [DateCreated], 
					 [DateCreatedInSystem],
					 [RowStatus],
					 [StationId])
		(SELECT		 [LRPCD].[GuideSerie], 
					 [LRPCD].[GuideNumber], 
					 @STATUS_ORDER_ID, 
					 @TknUser,
					 SYSDATETIME(),
					 SYSDATETIME(),
					 1,
					 @IdStation
		FROM		 [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
		INNER JOIN	 [dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
			ON		 [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		INNER JOIN	 [dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
			ON		 [LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
			WHERE NOT EXISTS (
				SELECT 1 
				FROM @TblGuideUpdate TGU
				WHERE TGU.GuideSerie  = [LRPCD].[GuideSerie] 
				AND  TGU.GuideNumber = [LRPCD].[GuideNumber]
			)
			AND   [LRPCD].[RowStatus] = 1 
			AND   [LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation);

		-- UPDATE LINEHAUL ROUTE PREPARATION CONTAINER DETAIL
		UPDATE	[LRPCDP]
		SET		[LRPCDP].[CatLinehaulStatusId] = @STATUS_LINEHAUL_ID
		FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH (NOLOCK)
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
			ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].IdLinehaulRoutePreparation 
			WHERE NOT EXISTS (
							SELECT 1 
							FROM @TblGuideUpdate TGU
							WHERE TGU.GuideSerie  = [LRPCD].[GuideSerie] 
							AND  TGU.GuideNumber = [LRPCD].[GuideNumber]
					)
				  AND 
		          [LRPCDP].[RowStatus] = 1
				  AND		
				  [LRPCD].[RowStatus] = 1
				  AND 
				  [LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation;

		--SACAR DE INVENTARIO
		UPDATE WH
		SET WH.Active = 0,
			WH.UserUpdated = @TknUser,
			WH.DateUpdated = GETDATE()
		FROM DeliveryBackOffice.[dbo].Warehouse WH WITH(NOLOCK)
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
			ON		[WH].[Guide_Serie] = [LRPCD].[GuideSerie]
			AND		[WH].[Guide_Number] = [LRPCD].[GuideNumber]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
			ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].IdLinehaulRoutePreparation --[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
			WHERE NOT EXISTS (
					SELECT 1 
					FROM @TblGuideUpdate TGU
					WHERE TGU.GuideSerie  = [WH].[Guide_Serie] 
					AND  TGU.GuideNumber = [WH].[Guide_Number]
			)
			  AND  [LRPCD].[RowStatus] = 1
			  AND [LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation;

	END
		SELECT	[LRP].[IdLinehaulRoutePreparation],
				[LRP].[StationDispatchedId],
				[LRP].[CatLinehaulStatusId],
				[LRP].[CatRouteId],
				COALESCE([LRP].[SenderReceiverId], 0) AS SenderReceiverId,
				COALESCE([LRP].[CatVehicleId], 0) AS CatVehicleId,
				COALESCE([LRP].[DriverCUI], '') AS DriverCUI,
				COALESCE([LRP].[DriverName], '') AS DriverName,
				COALESCE([LRP].[DriverPhone], '') AS DriverPhone,
				COALESCE([LRP].[VehicleID], '') AS VehicleID,
				COALESCE([LRP].[VehicleDescription], '') AS VehicleDescription,
				COALESCE([LRP].[SecurityManName], '') AS SecurityManName,
				COALESCE([LRP].[SecurityManPhone], '') AS SecurityManPhone,
				COALESCE([LRP].[SecurityManCUI], '') AS SecurityManCUI,
				[LRP].[DateLinehaulRoutePreparation],
				[LRP].[ContainerQuantity],
				[LRP].[GuideQuantity],
				[LRP].[DryPieceQuantity],
				[LRP].[ColdPieceQuantity],
				[LRP].[RowStatus],
				[LRP].[TokenCreated],
				[LRP].[DateCreated]
		FROM	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
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
				ERROR_MESSAGE() AS [spMessage];

		ROLLBACK TRANSACTION
	END CATCH
END