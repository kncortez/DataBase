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
	@TknUser AS NVARCHAR(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;	-- LinehaulRoutePreparation
	DECLARE @EXISTING_LCM AS INT;	-- LinehaulRoutePreparationCustomsMark
	DECLARE @EXISTING_SR AS INT;	-- Sender Receiver
	DECLARE @EXISTING_TAG AS INT;	-- CustomMarks

	-- Check if there is an active record in LinehaulRoutePreparation
	SET @EXISTING_LRP = (SELECT	COALESCE([LRP].[IdLinehaulRoutePreparation], 0) AS IdLinehaulRoutePreparation
						 FROM	[dbo].[LinehaulRoutePreparation] LRP
						 WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
							AND	[LRP].[CatLinehaulStatusId] = (SELECT [CLS].[IdCatLinehaulStatus]
																FROM [dbo].[CatLinehaulStatus] CLS
																WHERE [CLS].[StatusName] = 'GENERATED'));

	SET @EXISTING_TAG = (SELECT COUNT([LCM].[IdLinehaulRoutePreparationCustomsMark]) AS IdLinehaulRoutePreparationCustomsMark
						 FROM	[dbo].[LinehaulRoutePreparationCustomsMark] LCM
						 WHERE	[LCM].[CustomsMarkSerie] = @Tag
							AND [LCM].[RowStatus] = 1);

	IF (@EXISTING_LRP > 0) 
		-- There is an active record that can be processed
		BEGIN
			IF (@EXISTING_TAG = 0)
				BEGIN
					SET @EXISTING_SR = (SELECT COALESCE([SR].[ID], 0) AS ID
										FROM [dbo].[SenderReceiver] SR
										WHERE [SR].[CUI] = @SenderReceiverCUI);

					BEGIN
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
									ERROR_MESSAGE() AS [ErrorMessage];

							ROLLBACK TRANSACTION
						END CATCH
					END
				
				END
			ELSE 
				-- No active record, it was already processed or it doesn't exist
				BEGIN
					SELECT 2 [spResult], 'Custom mark serie already exists' [spMessage];
				END
		END
	ELSE 
		BEGIN
			SELECT 0 [spResult], 'No active record, it was already processed or it doesn''t exist' [spMessage];
		END
END