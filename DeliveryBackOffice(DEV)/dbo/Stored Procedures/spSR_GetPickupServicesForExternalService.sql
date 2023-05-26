-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <29-03-2023>
-- Description:	<Get Pickup services for Simpli Route>
-- =============================================
CREATE PROCEDURE [dbo].[spSR_GetPickupServicesForExternalService]
	
AS
BEGIN
	SET NOCOUNT ON;
	-- Manejo de configuraciones
	DECLARE @ExternalPlatformId INT = 0;
	DECLARE @CatConfigurableServiceId INT = 0;
	DECLARE @SimpliRouteType NVARCHAR(50);
	DECLARE @DateToProcess DATE = CAST(DATEADD(DAY, 1, GETDATE()) AS DATE); -- SERVICIOS PROGRAMADOS PARA EL DIA SIGUIENTE
	DECLARE @AcceptedServices TABLE (	[CatExternalPlatformId] INT,
										[ServiceManagementId] INT,
										[SchedulePickupId] INT,
										[AccountId] INT,
										[AddressPickup] NVARCHAR(200),
										[QuantityRegularPackages] INT,
										[SenderName] NVARCHAR(100),
										[SenderPhone] NVARCHAR(50),
										[HubLogisticsId] INT,
										[HubAbbreviation] NVARCHAR(10),
										[TypeVehicleId] INT,
										[TownshipId] INT,
										[ProvinceId] INT,
										[Latitude] NVARCHAR(25),
										[Longitude] NVARCHAR(25)
	);

	BEGIN TRANSACTION
	BEGIN TRY

		SET @ExternalPlatformId = (	SELECT	[CEP].[IdExternalPlatform]
									FROM	[dbo].[CatExternalPlatform] CEP
									WHERE	[CEP].[NameExternalPlatform] = 'Simpliroute');

		SET @CatConfigurableServiceId = (	SELECT	[CCS].[IdCatConfigurableService]
											FROM	[dbo].[CatConfigurableService] CCS
											WHERE	[CCS].[CatConfigurableServiceName] = 'SimplirouteConnect');

		SET @SimpliRouteType = (SELECT	[CP].[Value]
								FROM	[dbo].[ConfigParams] CP
								WHERE	[CP].[Name] = 'SimpliRoutePickupProgrammedConstant');

		INSERT INTO @AcceptedServices (	[CatExternalPlatformId],
										[ServiceManagementId],
										[SchedulePickupId],
										[AccountId],
										[AddressPickup],
										[QuantityRegularPackages],
										[SenderName],
										[SenderPhone],
										[HubLogisticsId],
										[HubAbbreviation],
										[TypeVehicleId],
										[TownshipId],
										[ProvinceId],
										[Latitude],
										[Longitude])
		SELECT							@ExternalPlatformId,
										[SM].[IdServiceManagement],
										[SP].[SchedulePickupId],
										[SP].[AccountId],
										[SP].[AddressPickup],
										[SP].[QuantityRegularPackages],
										[SP].[SenderName],
										[SP].[SenderPhone],
										[SP].[IdHubLogistics],
										[HL].[HubAbbreviation],
										[SP].[TypeVehicleId],
										[SP].[TownshipId],
										[T].[IdProvince] ,
										[VPC].[Latitude],
										[VPC].[Longitude]
		FROM		[dbo].[SchedulePickup] SP
		INNER JOIN	[dbo].[ServiceManagement] SM
			ON		[SP].[SchedulePickupId] = [SM].[IdSchedulePickup]
			AND		[SM].[IdPuRouteAssigment] IS NULL
		INNER JOIN	[dbo].[Township] T
			ON		[SP].[TownshipId] = [T].[IdTownship]
		INNER JOIN	[dbo].[ServiceProvinceConfiguration] SPC
			ON		[T].[IdProvince] = [SPC].[ProvinceId]
			AND		[SPC].[CatConfigurableServiceId] = @CatConfigurableServiceId
			AND		[SPC].[RowStatus] = 1
		INNER JOIN	[dbo].[ServiceTownshipConfiguration] STC
			ON		[T].[IdTownship] = [STC].[TownshipId]
			AND		[STC].[CatConfigurableServiceId] = @CatConfigurableServiceId
			AND		[STC].[RowStatus] = 1
		INNER JOIN	[dbo].[VisitPointClient] VPC
			ON		[SP].[SenderId] = [VPC].[CodeOfReference]
		INNER JOIN	[dbo].[HubLogistics] HL
			ON		[SP].[IdHubLogistics] = [HL].[IdHubLogistic]
		LEFT JOIN	[dbo].[ExternalPlatformPickupServiceLog] EPPSL
			ON		[SM].[IdServiceManagement] = [EPPSL].[ServiceManagementId]
			AND		[EPPSL].[RowStatus] = 1
		WHERE		CAST([SP].[StartDate] AS DATE) = @DateToProcess
			AND		[SP].[RowStatus] = 1 
			AND		[SP].[SchedulePickupStatus] = 1
			AND		[SP].[IsScheduled] = 1 
			AND		[EPPSL].[IdExternalPlatformPickupServiceLog] IS NULL ;

		-- Agregar servicios de recolección a ExternalPlatformPickupServiceLog
		INSERT INTO [dbo].[ExternalPlatformPickupServiceLog] (	[CatExternalPlatformId],
																[ServiceManagementId],
																[IsInExternalPlatform],
																[RowStatus],
																[TokenCreated],
																[DateCreated])
		SELECT													[ASR].[CatExternalPlatformId],
																[ASR].[ServiceManagementId],
																0,	-- IsInExternalPlatform
																1,	-- RowStatus
																'spSR_GetPickupServicesForExternalService',
																@DateToProcess
		FROM													@AcceptedServices ASR;

		SELECT	CONCAT('PICKUP-',[ACS].[ServiceManagementId]) [title],
				[ACS].[AddressPickup] [address],
				@DateToProcess [planned_date],
				[ACS].[Latitude] [latitude],
				[ACS].[Longitude] [longitude],
				[ACS].[SenderName] [contact_name],
				[ACS].[SenderPhone] [contact_phone],
				[ACS].[ServiceManagementId] [reference],
				[ACS].[HubAbbreviation] [skills_required],
				4 [priority_level],
				@SimpliRouteType [visit_type]
		FROM	@AcceptedServices ACS
		UNION 
		SELECT		CONCAT('PICKUP-', [EXPS].[ServiceManagementId]) [title],
					[SP].[AddressPickup] [address],
					@DateToProcess [planned_date],
					[VPC].[Latitude] [latitude],
					[VPC].[Longitude] [longitude],
					[SP].[SenderName] [contact_name],
					[SP].[SenderPhone] [contact_phone],
					[SM].[IdServiceManagement] [reference],
					[HL].[HubAbbreviation] [skills_required],
					4 [priority_level],
					@SimpliRouteType [visit_type]
		FROM		[dbo].[ExternalPlatformPickupServiceLog] EXPS
		INNER JOIN	[dbo].[ServiceManagement] SM
			ON		[EXPS].[ServiceManagementId] = [SM].[IdServiceManagement]
		INNER JOIN	[dbo].[SchedulePickup] SP
			ON		[SP].[SchedulePickupId] = [SM].[IdSchedulePickup]
		INNER JOIN	[dbo].[VisitPointClient] VPC
			ON		[SP].[SenderId] = [VPC].[CodeOfReference]
		INNER JOIN	[dbo].[HubLogistics] HL
			ON		[SP].[IdHubLogistics] = [HL].[IdHubLogistic]
		WHERE		[EXPS].[IsInExternalPlatform] = 0
			AND		[EXPS].[RowStatus] = 1;

		IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;
	END TRY
    BEGIN CATCH

        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

        ROLLBACK TRANSACTION;
    END CATCH;
END