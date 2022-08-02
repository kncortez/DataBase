-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <05-07-2022>
-- Description:	<Insert a new Linehaul Route Preparation Document>
-- =============================================

CREATE PROCEDURE [DBO].[spHM_GenerateLinehaulRoutePreparation] 
	@StationId AS INT,
	@RouteId AS INT,
	@UserName AS VARCHAR(25),
	@DateSelected AS DATETIME,
	@TknUsr AS VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @EXISTING_DOC AS INT;
	DECLARE @INSERTED_DOC AS INT;

	-- Check if there is a record with the entered parameters
	SET @EXISTING_DOC = (SELECT [LRP].[IdLinehaulRoutePreparation] AS ID 
						 FROM [dbo].[LinehaulRoutePreparation] LRP
						 WHERE [LRP].[StationDispatchedId] = @StationId
							AND [LRP].[CatRouteId] = @RouteId
							AND DAY([LRP].[DateLinehaulRoutePreparation]) = DAY(@DateSelected) 
							AND MONTH([LRP].[DateLinehaulRoutePreparation]) = MONTH(@DateSelected) 
							AND YEAR([LRP].[DateLinehaulRoutePreparation]) = YEAR(@DateSelected));

	IF (@EXISTING_DOC > 0) 
		-- Return existing doc
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
		FROM [dbo].[LinehaulRoutePreparation] LRP
		WHERE [LRP].[IdLinehaulRoutePreparation] = @EXISTING_DOC;
	ELSE
		-- Generate and return a new doc
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT INTO [dbo].[LinehaulRoutePreparation]
							([StationDispatchedId],
							 [CatLinehaulStatusId],
							 [CatRouteId],
							 [DateLinehaulRoutePreparation],
							 [ContainerQuantity],
							 [GuideQuantity],
							 [DryPieceQuantity],
							 [ColdPieceQuantity],
							 [RowStatus],
							 [TokenCreated],
							 [DateCreated])
					VALUES ( @StationId, 
							 (SELECT [CLS].[IdCatLinehaulStatus] 
							  FROM [dbo].[CatLinehaulStatus] CLS
							  WHERE [CLS].[StatusName] = 'GENERATED'), 
							 @RouteId, 
							 @DateSelected, 
							 0, 
							 0, 
							 0, 
							 0, 
							 1, 
							 @TknUsr,
							 SYSDATETIME());

				SET @INSERTED_DOC = SCOPE_IDENTITY();

				SELECT	[LRP].[IdLinehaulRoutePreparation], 
						[LRP].[StationDispatchedId],
						[LRP].[CatLinehaulStatusId], 
						[LRP].[CatRouteId],
						COALESCE([LRP].[SenderReceiverId], 0) AS SenderReceiverId,
						COALESCE([LRP].[CatVehicleId], 0) AS CatVehicleId,
						COALESCE([LRP].[DriverCUI], 0) AS DriverCUI,
						COALESCE([LRP].[DriverName], 0) AS DriverName,
						COALESCE([LRP].[DriverPhone], 0) AS DriverPhone,
						COALESCE([LRP].[VehicleID], 0) AS VehicleID,
						COALESCE([LRP].[VehicleDescription], 0) AS VehicleDescription,
						COALESCE([LRP].[SecurityManName], 0) AS SecurityManName,
						COALESCE([LRP].[SecurityManPhone], 0) AS SecurityManPhone,
						COALESCE([LRP].[SecurityManCUI], 0) AS SecurityManCUI,
						[LRP].[DateLinehaulRoutePreparation],
						[LRP].[ContainerQuantity],
						[LRP].[GuideQuantity],
						[LRP].[DryPieceQuantity],
						[LRP].[ColdPieceQuantity],
						[LRP].[RowStatus],
						[LRP].[TokenCreated],
						[LRP].[DateCreated]
				FROM [dbo].[LinehaulRoutePreparation] LRP
				WHERE [LRP].[IdLinehaulRoutePreparation] = @INSERTED_DOC;


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