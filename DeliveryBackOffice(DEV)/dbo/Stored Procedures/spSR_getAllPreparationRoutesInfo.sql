-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <27-04-2023>
-- Description:	<Generate and return all preparation routes by itinerary info>
-- =============================================
CREATE PROCEDURE [dbo].[spSR_getAllPreparationRoutesInfo]
	@DayOfVisit INT
AS
BEGIN
	SET NOCOUNT ON;
	-- Manejo de configuraciones
	DECLARE @ExternalPlatformId INT = 0;
	DECLARE @CatConfigurableServiceId INT = 0;
	DECLARE @SimpliRouteType NVARCHAR(50);
	DECLARE @DateToProcess DATE = CAST(DATEADD(DAY, 1, GETDATE()) AS DATE); -- SERVICIOS PROGRAMADOS PARA EL DIA SIGUIENTE
	DECLARE @SimpliRoutePlatformId INT = 0;
	DECLARE @CatTypeVehicleId INT = 0;
	DECLARE @CatSetvicesStatusId INT = 0;
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
										[Longitude] NVARCHAR(25));

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

		SET @SimpliRoutePlatformId = (	SELECT	[SysIdSystem]
										FROM	[dbo].[CatSystem] CS
										WHERE	[CS].[SysNameSystem] = 'SimplirouteConnect');

		SET @CatTypeVehicleId = (	SELECT	[CTV].[IdTypeVehicle]
									FROM	[dbo].[CatTypeVehicle] CTV
									WHERE	[CTV].[Name] = 'Panel');

		SET @CatSetvicesStatusId = (SELECT	[CSS].[IdServiceStatus]
									FROM	[dbo].[CatServiceStatus] CSS
									WHERE	[CSS].[Name] = 'Creado');


		-- INSERTAR EN SCHEDULE PICKUP
		INSERT INTO SchedulePickup (	[AccountId],
										[StartDate],
										[EndDate],
										[EstimatedWeight],
										[IsLargePackage],
										[QuantityRegularPackages],
										[QuantityOverDimensionedPackage],
										[SpecialInstructions],
										[RowStatus],
										[TokenCreated],
										[DateCreated],
										[SenderId],
										[SenderName],
										[SenderPhone],
										[IdHubLogistics],
										[AmountPickup],
										[IdSourcePlataform],
										[AddressPickup],
										[TownshipId],
										[SchedulePickupStatus],
										[TypeVehicleId],
										[IsScheduled] )
		SELECT							[A].[AccIdAccount],
										CAST(CONCAT(@DateToProcess , ' ' , [VPI].[InitializationTimeOfVisit]) AS DATETIME) [StartDate],
										CAST(CONCAT(@DateToProcess , ' ' , [VPI].[FinalizationTimeOfVisit]) AS DATETIME) [EndDate],
										0,		-- EstimatedWeight
										0,		-- IsLargePackage
										0,		-- QuantityRegularPackages
										0,		-- QuantityOverDimensionedPackage
										'',		-- SpecialInstructions
										0,		-- RowStatus
										'spSR_getAllPreparationRoutesInfo',
										SYSDATETIME(),
										[VP].[CodeOfReference],
										[VP].[DescriptionOfClient] Name,
										[VP].[Phone],
										[THL].[IdHublogistic],
										0,		-- AmountPickup
										@SimpliRoutePlatformId,
										[VP].[Address],
										[VP].[IdTownship],
										1,		-- SchedulePickupStatus
										@CatTypeVehicleId,
										1		-- IsScheduled
		FROM		[dbo].[VisitPointItinerary] VPI WITH (NOLOCK)
		INNER JOIN	[dbo].[VisitPointFrequency] FQ WITH(NOLOCK)
			ON		[FQ].[IdVPFrequency] = [VPI].[VPFrequencyID]
			AND		[FQ].[RowStatus] = 1
		INNER JOIN	[dbo].[VisitPointConfiguration] CF WITH(NOLOCK)
			ON		[CF].[IdVPConfiguration] = [FQ].[VPConfigurationID]
			AND		[CF].[RowStatus] = 1
		INNER JOIN	[dbo].[VisitPointClient] VP WITH(NOLOCK)
			ON		[VP].[CodeOfReference] = [CF].[VisitPointID]
			AND		[VP].[StatusClient] = 1
		INNER JOIN	[dbo].[TownshipByHubLogistic] THL
			ON		[VP].[IdTownship] = [THL].[IdTownship]
			AND		[THL].[StatusTownshipHub] = 1
		INNER JOIN	[dbo].[HubLogistics] HL
			ON		[THL].[IdHublogistic] = [HL].[IdHubLogistic]
		INNER JOIN	[dbo].[Account] A
			ON		[VP].[CustomerID] = [A].[IdCustomer]
			AND		[A].[AccRowStatus] = 1
		LEFT JOIN	[dbo].[SchedulePickup] SP
			ON		[SP].[AccountId] = [A].[AccIdAccount]
			AND		[SP].[StartDate] = CAST(CONCAT(@DateToProcess , ' ' , [VPI].[InitializationTimeOfVisit]) AS DATETIME)
			AND		[SP].[EndDate] = CAST(CONCAT(@DateToProcess , ' ' , [VPI].[FinalizationTimeOfVisit]) AS DATETIME)
			AND		[SP].[SenderId] = [VP].[CodeOfReference]
			AND		[SP].[IdHubLogistics] = [THL].[IdHublogistic]
			AND		[SP].[IdSourcePlataform] = @SimpliRoutePlatformId
			AND		[SP].[TownshipId] = [VP].[IdTownship]
			AND		[SP].[SchedulePickupStatus] = 1
			AND		[SP].[TypeVehicleId] = @CatTypeVehicleId
		WHERE		[VPI].[DayOfVisit] = @DayOfVisit
			AND		[VPI].[RowStatus] = 1
			AND		[VPI].[InitializationTimeOfVisit] IS NOT NULL 
			AND		[VPI].[InitializationTimeOfVisit] NOT IN ('__:__','0','',' ')
			AND		[VPI].[FinalizationTimeOfVisit] IS NOT NULL 
			AND		[VPI].[FinalizationTimeOfVisit] NOT IN ('__:__','0','',' ')
			AND		[SP].[SchedulePickupId] IS NULL
		GROUP BY	[A].[AccIdAccount],
					[VPI].[InitializationTimeOfVisit],
					[VPI].[FinalizationTimeOfVisit],
					[VP].[CodeOfReference],
					[VP].[DescriptionOfClient],
					[VP].[Department],
					[VP].[Town],
					[VP].[Address],
					[VP].[Phone],
					[VP].[IdTownship],
					[THL].[IdHublogistic],
					[HL].[HubAbbreviation],
					[VP].[Latitude],
					[VP].[Longitude];
		
		-- INSERTAR EN SERVICE MANAGEMENT

		INSERT INTO ServiceManagement ( [IdSchedulePickup],
										[RowStatus],
										[TokenCreated],
										[DateCreated],
										[ServiceStatusId],
										[IdHubDestination],
										[Order],
										[Amount],
										[IsActiveService])
		SELECT							[SP].[SchedulePickupId],
										1,
										'spSR_getAllPreparationRoutesInfo',
										SYSDATETIME(),
										1,		-- RowStatus
										[SP].[IdHubLogistics],
										1,		-- Order
										0,		-- Amount
										0		-- IsActiveService
		FROM							[dbo].[SchedulePickup] SP
		LEFT JOIN						[dbo].[ServiceManagement] SM
			ON							[SM].[IdSchedulePickup] = [SP].[SchedulePickupId]
			AND							[SM].[RowStatus] = 1
			AND							[SM].[ServiceStatusId] = 1
			AND							[SM].[IdHubDestination] = [SP].[IdHubLogistics]
		WHERE							[SM].[IdServiceManagement] IS NULL
			AND							[SP].[IdSourcePlataform] = @SimpliRoutePlatformId
			AND							[SP].[SchedulePickupStatus] = 1
			AND							[SP].[TypeVehicleId] = @CatTypeVehicleId
			;

		-- INSERT INTO ACCEPTED SERVICES
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
																'spSR_getAllPreparationRoutesInfo',
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