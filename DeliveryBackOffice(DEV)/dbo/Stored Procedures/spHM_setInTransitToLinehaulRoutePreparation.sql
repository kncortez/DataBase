-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <25-07-2022>
-- Description:	<Check and set driver, tag number and status -> 'IN TRANSIT' to an active Linehaul process>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_setInTransitToLinehaulRoutePreparation] 
	@IdLinehaulRoutePreparation AS INT,
	@SenderReceiverCUI AS NVARCHAR(50) = NULL,
	@CatVehicleId AS INT = NULL,
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

	-- Check if there is an active record in LinehaulRoutePreparation
	SET @EXISTING_LRP = (SELECT	COUNT([LRP].[IdLinehaulRoutePreparation]) AS IdLinehaulRoutePreparation
						 FROM	[dbo].[LinehaulRoutePreparation] LRP
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
							AND	[LRP].[CatLinehaulStatusId] = (SELECT [CLS].[IdCatLinehaulStatus]
																FROM [dbo].[CatLinehaulStatus] CLS
																WHERE [CLS].[StatusName] = 'GENERATED'));

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
				[DriverCUI] = @DriverCUI,
				[DriverName] = @DriverName,
				[DriverPhone] = @DriverPhone,
				[VehicleID] = @VehicleID,
				[VehicleDescription] = @VehicleDescription,
				[SecurityManName] = @SecurityManName,
				[SecurityManPhone] = @SecurityManPhone,
				[SecurityManCUI] =  @SecurityManCUI,
				[CatLinehaulStatusId] = (SELECT [CLS].[IdCatLinehaulStatus]
										FROM [dbo].[CatLinehaulStatus] CLS
										WHERE [CLS].[StatusName] = 'IN TRANSIT'),
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME()
		WHERE	[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation;

		UPDATE	[LinehaulRoutePreparationContainer]
		SET		[CatLinehaulStatusId] = (SELECT [CLS].[IdCatLinehaulStatus]
										FROM [dbo].[CatLinehaulStatus] CLS
										WHERE [CLS].[StatusName] = 'IN TRANSIT')
		WHERE	[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
			AND [RowStatus] = 1;

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