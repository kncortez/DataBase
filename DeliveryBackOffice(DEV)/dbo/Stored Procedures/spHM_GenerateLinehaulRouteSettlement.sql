-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <08-08-2022>
-- Description:	<Get or insert a new Linehaul Route Settlement >
-- =============================================
-- Author:		<Ochoa, Jerson>
-- Date:		<14-02-2023>
-- Update:		<Add log for vehicles mileage value>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GenerateLinehaulRouteSettlement]
	@LinehaulRoutePreparationId AS INT,
	@DateSelected AS DATE,
	@HubID AS INT,
	@UserName as  NVARCHAR(20),
	@VehicleKms AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_LRP AS INT;		-- Linehaul Route Preparation
	DECLARE @EXISTING_LRS AS INT;		-- Linehaul Route Settlement
	DECLARE @INSERTED_DOC AS INT;		-- Last inserted doc
	DECLARE @VEHICLE_ID AS INT;			-- LinehaulRoutePreparation
	DECLARE @VEHICLE_LAST_KMS AS INT;	-- CatVehicle

	-- Check if there is a valid record in Linehaul Route Preparation
	SET @EXISTING_LRP = (SELECT	COUNT([LRP].[IdLinehaulRoutePreparation]) AS CONTEO
						FROM	[dbo].[LinehaulRoutePreparation] LRP
						WHERE	[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
							AND [LRP].[CatLinehaulStatusId] = (SELECT	[CLS].[IdCatLinehaulStatus]
																FROM	[dbo].[CatLinehaulStatus] CLS
																WHERE	[CLS].[StatusName] = 'IN TRANSIT'));

	SET @VEHICLE_ID = (	SELECT	[LRP].[CatVehicleId]
						FROM	[dbo].[LinehaulRoutePreparation] LRP
						WHERE	[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId);

	SET @VEHICLE_LAST_KMS = (SELECT	ISNULL([CV].[Kms], 0)
							FROM	[dbo].[CatVehicle] CV
							WHERE	[CV].[IdVehicle] = @VEHICLE_ID);

	IF (@EXISTING_LRP > 0) 
		BEGIN
		-- Check if there is an existing Linehaul Route Settlement
		SET @EXISTING_LRS = (SELECT	COUNT([LRS].[IdLinehaulRouteSettlement]) AS CONT
							FROM	[dbo].[LinehaulRouteSettlement] LRS
							WHERE	[LRS].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
								AND [LRS].[HubID] = @HubID
								AND [LRS].[DateReceived] = @DateSelected
								AND [LRS].[CatLinehaulStatusId] = (SELECT	[CLS].[IdCatLinehaulStatus]
																	FROM	[dbo].[CatLinehaulStatus] CLS
																	WHERE	[CLS].[StatusName] = 'GENERATED')
								AND [LRS].[RowStatus] = 1);

		IF (@EXISTING_LRS > 0) 
			BEGIN
				-- RETURN EXISTING DOC
				SELECT		[LRS].[IdLinehaulRouteSettlement],
							[LRS].[LinehaulRoutePreparationId], 
							[LRS].[HubID],
							[HL].[HubAbbreviation],
							[HL].[HubName],
							[LRS].[CatLinehaulStatusId],
							[CLS].[StatusName],
							[LRS].[UserReceived],
							[LRS].[DateReceived],
							[LRS].[ContainersReceived],
							[LRS].[ToolsReceived],
							[LRS].[GuidesReceived],
							[LRS].[GuidePiecesReceived],
							[LRS].[GuidePiecesMissing]
				FROM		[dbo].[LinehaulRouteSettlement] LRS
				INNER JOIN	[dbo].[HubLogistics] HL
					ON		[LRS].[HubID] = [HL].[IdHubLogistic]
				INNER JOIN	[dbo].[CatLinehaulStatus] CLS
					ON		[LRS].[CatLinehaulStatusId] = [CLS].[IdCatLinehaulStatus]
				WHERE	[LRS].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
					AND [LRS].[HubID] = @HubID
					AND [LRS].[CatLinehaulStatusId] = (SELECT	[CLS].[IdCatLinehaulStatus]
														FROM	[dbo].[CatLinehaulStatus] CLS
														WHERE	[CLS].[StatusName] = 'GENERATED')
					AND [LRS].[DateReceived] = @DateSelected
					AND [LRS].[RowStatus] = 1;
			END
		ELSE
			BEGIN
				-- INSERT NEW DOC
				BEGIN TRANSACTION
				BEGIN TRY

					IF (@VehicleKms < @VEHICLE_LAST_KMS)
						BEGIN
							SELECT 0 [spResult], 'El kilometraje ingresado NO es válido.' [spMessage];
							RETURN;
						END
					
					INSERT INTO [LinehaulRouteSettlement]
								([LinehaulRoutePreparationId], 
								 [HubID],
								 [CatLinehaulStatusId],
								 [UserReceived],
								 [DateReceived],
								 [ContainersReceived],
								 [ToolsReceived],
								 [GuidesReceived],
								 [GuidePiecesReceived],
								 [GuidePiecesMissing],
								 [VehicleKms],
								 [RowStatus],
								 [TokenCreated],
								 [DateCreated])
						VALUES	(@LinehaulRoutePreparationId,
								 @HubID,
								 (SELECT [CLS].[IdCatLinehaulStatus] FROM [dbo].[CatLinehaulStatus] CLS WHERE [CLS].[StatusName] = 'GENERATED'),
								 @userName,
								 @DateSelected, 
								 0,		-- ContainersReceived
								 0,		-- ToolsReceived
								 0,		-- GuidesReceived
								 0,		-- GuidePiecesReceived
								 0,		-- GuidePiecesMissing,
								 @VehicleKms,
								 1,		-- RowStatus,
								 @TknUser,
								 SYSDATETIME());

					SET @INSERTED_DOC = SCOPE_IDENTITY();

					-- VEHICLE LOG
					UPDATE	[dbo].[CatVehicle]
					SET		[Kms] = @VehicleKms,
							[TokenUpdated] = @TknUser,
							[DateUpdated] = SYSDATETIME()
					WHERE	[IdVehicle] = @VEHICLE_ID;

					INSERT INTO [dbo].[VehicleLog] ([Unidad],
													[Kms],
													[Observacion],
													[TokenCreate],
													[DateCreate])
					VALUES							(@VEHICLE_ID,
													@VehicleKms,
													'spHM_EndLinehaulRouteSettlement',
													@TknUser,
													SYSDATETIME());

					SELECT		[LRS].[IdLinehaulRouteSettlement],
								[LRS].[LinehaulRoutePreparationId], 
								[LRS].[HubID],
								[HL].[HubAbbreviation],
								[HL].[HubName],
								[LRS].[CatLinehaulStatusId],
								[CLS].[StatusName],
								[LRS].[UserReceived],
								[LRS].[DateReceived],
								[LRS].[ContainersReceived],
								[LRS].[ToolsReceived],
								[LRS].[GuidesReceived],
								[LRS].[GuidePiecesReceived],
								[LRS].[GuidePiecesMissing]
					FROM		[dbo].[LinehaulRouteSettlement] LRS
					INNER JOIN	[dbo].[HubLogistics] HL
						ON		[LRS].[HubID] = [HL].[IdHubLogistic]
					INNER JOIN	[dbo].[CatLinehaulStatus] CLS
						ON		[LRS].[CatLinehaulStatusId] = [CLS].[IdCatLinehaulStatus]
					WHERE	[LRS].[IdLinehaulRouteSettlement] = @INSERTED_DOC;

					IF(@@TRANCOUNT > 0)
						COMMIT TRANSACTION
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
		BEGIN
			-- INVALID LinehaulRoutePreparation
			SELECT 1 [spResult], 'Invalid LinehaulRoutePreparation' [spMessage];
		END
END