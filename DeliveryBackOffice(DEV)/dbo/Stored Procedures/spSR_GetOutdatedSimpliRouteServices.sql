-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <17-04-2023>
-- Description:	<Get outdated SimpliRoute services>
-- =============================================
CREATE PROCEDURE [dbo].[spSR_GetOutdatedSimpliRouteServices]

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CatConfigurableServiceId INT = 0;

	SET @CatConfigurableServiceId = (	SELECT	[CCS].[IdCatConfigurableService]
										FROM	[dbo].[CatConfigurableService] CCS
										WHERE	[CCS].[CatConfigurableServiceName] = 'SimplirouteConnect');

	SELECT		[EPPSL].[IdExternalPlatformPickupServiceLog], 
				[EPPSL].[CatExternalPlatformId], 
				[CEP].[NameExternalPlatform],
				[EPPSL].[ServiceManagementId],
				[EPPSL].[IsInExternalPlatform],
				[SM].[IdSchedulePickup],
				[SM].[IdPuRouteAssigment],
				[EPS].[IdService] [SimpliRouteServiceId],
				[SP].[AssigmentStatus],
				[SP].[TownshipId],
				[SP].[IdHubLogistics]
	FROM		[dbo].[ExternalPlatformPickupServiceLog] EPPSL
	INNER JOIN	[dbo].[CatExternalPlatform] CEP
		ON		[EPPSL].[CatExternalPlatformId] = [CEP].[IdExternalPlatform]
		AND		[CEP].[NameExternalPlatform] = 'Simpliroute'
		AND		[CEP].[RowStatus] = 1
	INNER JOIN	[dbo].[ServiceManagement] SM
		ON		[EPPSL].[ServiceManagementId] = [SM].[IdServiceManagement] 
		AND		[SM].[RowStatus] = 1
		AND		[SM].[IdPuRouteAssigment] IS NULL
	INNER JOIN	[dbo].[ExtPlatformService] EPS
		ON		CONVERT(NVARCHAR, [SM].[IdServiceManagement]) = [EPS].[Reference]
	INNER JOIN	[dbo].[SchedulePickup] SP
		ON		[SM].[IdSchedulePickup] = [SP].[SchedulePickupId]
		AND		[SP].[AssigmentStatus] IS NULL 
	INNER JOIN	[dbo].[Township] T
		ON		[SP].[TownshipId] = [T].[IdTownship]
	INNER JOIN	[dbo].[ServiceProvinceConfiguration] SPC
		ON		[T].[IdProvince] = [SPC].[ProvinceId]
		AND		[SPC].[CatConfigurableServiceId] = @CatConfigurableServiceId
	INNER JOIN	[dbo].[ServiceTownshipConfiguration] STC
		ON		[T].[IdTownship] = [STC].[TownshipId]
		AND		[STC].[CatConfigurableServiceId] = @CatConfigurableServiceId
	WHERE		[EPPSL].[IsInExternalPlatform] = 1 
		AND		[EPPSL].[RowStatus] = 1
		AND		([STC].[RowStatus] = 0 OR [SPC].[RowStatus] = 0 OR [SP].[SchedulePickupStatus] = 0);
    
END