-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <25-07-2022>
-- Description:	<Check and set driver, tag number and status -> 'IN TRANSIT' to an active Linehaul process>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_setInTransitToLinehaulRoutePreparation] 
	@IdLinehaulRoutePreparation AS INT,
	@SenderReceiverCUI AS NVARCHAR(50) = NULL,
	@CatVehicleId AS INT = NULL,
	@VehicleKms AS INT = 0,
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
	@TknUser AS NVARCHAR(50)

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

	SET @STATUS_GENERATED = (SELECT [CLS].[IdCatLinehaulStatus]
							FROM	[dbo].[CatLinehaulStatus] CLS
							WHERE	[CLS].[StatusName] = 'GENERATED');

	SET @STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
							FROM	[dbo].[StatusOrder] SO
							WHERE	[SO].[OrderDescription] = 'En Tránsito');

	SET @STATUS_LINEHAUL_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'IN TRANSIT');

	-- Vehicle validations
	IF (@CatVehicleId IS NOT NULL)
		BEGIN

			SELECT	@AUX_VEHICLE_COUNT = [CV].[IdVehicle],
					@AUX_VEHICLE_KMS = ISNULL([CV].[Kms], 0)
			FROM	[dbo].[CatVehicle] CV
			WHERE	[CV].[IdVehicle] = @CatVehicleId;

			IF (@AUX_VEHICLE_COUNT IS NULL)
				BEGIN
					SELECT 0 [spResult], 'El vehículo seleccionado NO existe en la base de datos, intente nuevamente o comuníquese con soporte técnico.' [spMessage];
					RETURN;
				END

			IF (@VehicleKms IS NULL OR @VehicleKms = 0)
				BEGIN
					SELECT 0 [spResult], 'El kilometraje ingresado NO es válido.' [spMessage];
					RETURN;
				END

			IF (@AUX_VEHICLE_KMS > @VehicleKms)
				BEGIN
					SELECT 0 [spResult], 'Datos incorrectos: El kilometraje ingresado es menor al último registro.' [spMessage];
					RETURN;
				END

			IF (@AUX_VEHICLE_KMS > 0 AND (@VehicleKms - @AUX_VEHICLE_KMS) > 1000)
				BEGIN
					SELECT 0 [spResult], 'El kilometraje ingresado supera el rango autorizado para transitar, comuníquese con el administrador de flota.' [spMessage];
					RETURN;
				END

		END

	-- Check if there is an active record in LinehaulRoutePreparation
	SET @EXISTING_LRP = (SELECT	COUNT([LRP].[IdLinehaulRoutePreparation]) AS IdLinehaulRoutePreparation
						 FROM	[dbo].[LinehaulRoutePreparation] LRP
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
							AND	[LRP].[CatLinehaulStatusId] = @STATUS_GENERATED);

	-- Check if there is an 'IN TRANSIT' record in LinehaulRoutePreparation
	SET @EXISTING_LRP_TRANSIT = (SELECT	COUNT([LRP].[IdLinehaulRoutePreparation]) AS IdLinehaulRoutePreparation
								 FROM	[dbo].[LinehaulRoutePreparation] LRP
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
			FROM	[dbo].[LinehaulRoutePreparation] LRP
			WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation;

			RETURN;
		END

	SET @EXISTING_TAG = (SELECT COUNT([LCM].[IdLinehaulRoutePreparationCustomsMark]) AS IdLinehaulRoutePreparationCustomsMark
						 FROM	[dbo].[LinehaulRoutePreparationCustomsMark] LCM
						 WHERE	[LCM].[CustomsMarkSerie] = @Tag
							AND [LCM].[RowStatus] = 1);

	SET @EXISTING_SR = (SELECT COUNT([SR].[ID]) AS ID
						FROM [dbo].[SenderReceiver] SR
						WHERE [SR].[CUI] = @SenderReceiverCUI);

	IF (@EXISTING_SR = 0 AND @IsInternal = 1)
		BEGIN
			SELECT 0 [spResult], 'CUI de piloto ingresado NO válido' [spMessage];
			RETURN;
		END

	IF (@EXISTING_SR > 0)
		BEGIN
			SET @EXISTING_SR = (SELECT [SR].[ID]
								FROM [dbo].[SenderReceiver] SR
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
									  FROM		[dbo].[LinehaulRoutePreparationContainer] LRPC
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
			FROM		[dbo].[LinehaulRoutePreparationContainer] LRPC
			INNER JOIN	[dbo].[Container] C
				ON		[LRPC].[ContainerId] = [C].[IdContainer]
			INNER JOIN	[dbo].[CatTypeContainer] CTC
				ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
			WHERE		[LRPC].[GuideQuantity] = 0
					AND	[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
					AND	[LRPC].[RowStatus] = 1;

			RETURN;
		END

	BEGIN TRANSACTION
	BEGIN TRY

		IF (@CatVehicleId IS NOT NULL)
			BEGIN
				-- Insert log for vehicles
				INSERT INTO [dbo].[VehicleLog] ([Unidad],
												[Kms],
												[Observacion],
												[TokenCreate],
												[DateCreate])
				VALUES						(	@CatVehicleId,
												@VehicleKms,
												'setInTransitToLinehaulRoutePreparation',
												@TknUser,
												SYSDATETIME());

				UPDATE	[dbo].[CatVehicle]
				SET		[Kms] = @VehicleKms
				WHERE	[IdVehicle] = @CatVehicleId;
			END

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
				[VehicleKms] = @VehicleKms,
				[DriverCUI] = @DriverCUI,
				[DriverName] = @DriverName,
				[DriverPhone] = @DriverPhone,
				[VehicleID] = @VehicleID,
				[VehicleDescription] = @VehicleDescription,
				[SecurityManName] = @SecurityManName,
				[SecurityManPhone] = @SecurityManPhone,
				[SecurityManCUI] =  @SecurityManCUI,
				[CatLinehaulStatusId] = @STATUS_LINEHAUL_ID,
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation;

		UPDATE	[LinehaulRoutePreparationContainer]
		SET		[CatLinehaulStatusId] = @STATUS_LINEHAUL_ID
		WHERE	[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
			AND [RowStatus] = 1;

		-- UPDATE STATUS IN DELIVERY ORDER
		UPDATE		[DO]
		SET			[DO].[StatusOrderId] = @STATUS_ORDER_ID
		FROM		[dbo].[DeliveryOrder] DO
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[DO].[Guide_Serie] = [LRPCD].[GuideSerie]
			AND		[DO].[Guide_Number] = [LRPCD].[GuideNumber]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		[LRPCD].[RowStatus] = 1
		INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
			ON		[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation;

		-- UPDATE STATUS IN DELIVERY ORDER PIECE
		UPDATE		[DOP]
		SET			[DOP].[StatusOrderId] = @STATUS_ORDER_ID
		FROM		[dbo].[DeliveryOrderPiece] DOP
		INNER JOIN	[dbo].[DeliveryOrder] DO
			ON		[DOP].[GuideSerie] = [DO].[Guide_Serie]
			AND		[DOP].[GuideNumber] = [DO].[Guide_Number]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[DO].[Guide_Serie] = [LRPCD].[GuideSerie]
			AND		[DO].[Guide_Number] = [LRPCD].[GuideNumber]
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		[LRPCD].[RowStatus] = 1
		INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
			ON		[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation;
		
		-- INSERT CHECKPOINT IN DELIVERY ORDER DETAIL
		INSERT INTO [dbo].[DeliveryOrderDetail]
					([Guide_Serie], 
					 [Guide_Number], 
					 [StatusOrderId], 
					 [UserCreated],
					 [DateCreated], 
					 [DateCreatedInSystem],
					 [RowStatus])
		(SELECT		 [LRPCD].[GuideSerie], 
					 [LRPCD].[GuideNumber], 
					 @STATUS_ORDER_ID, 
					 @TknUser,
					 SYSDATETIME(),
					 SYSDATETIME(),
					 1
		FROM		 [dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		INNER JOIN	 [dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		 [LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
			AND		 [LRPCD].[RowStatus] = 1
		INNER JOIN	 [dbo].[LinehaulRoutePreparation] LRP
			ON		 [LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
			AND		 [LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation);

		-- UPDATE LINEHAUL ROUTE PREPARATION CONTAINER DETAIL
		UPDATE	[LRPCDP]
		SET		[LRPCDP].[CatLinehaulStatusId] = @STATUS_LINEHAUL_ID
		FROM	[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
			ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
			AND		[LRPCD].[RowStatus] = 1
		INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
			ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
			ON		[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
		WHERE		[LRPCDP].[RowStatus] = 1;

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
		FROM	[dbo].[LinehaulRoutePreparation] LRP
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