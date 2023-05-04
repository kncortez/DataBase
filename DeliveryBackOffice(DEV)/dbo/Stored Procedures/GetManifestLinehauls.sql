-- =============================================
-- Author:		<Eduardo Lòpez>
-- Create date: <04/08/2022>
-- Description:	<SP para obtener datos y pintarlos en grid de modulo de impresion y visor de manifiestos de Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[GetManifestLinehauls]

	@DateFilter AS DATE = '',
	@InternalUser AS BIGINT

AS
BEGIN

	DECLARE @RegisterUserByInternal BIGINT;
	SET @RegisterUserByInternal = 
	(
		SELECT 
			TOP (1) 
				[IU].[RegisterUserID] 
		FROM 
			[DeliveryBackOffice].[dbo].[InternalUser] IU  WITH(NOLOCK) 
		WHERE
			[IU].[IdUser] = @InternalUser
	);

	-- Linehauls origen
	SELECT 
		DISTINCT 
			LRP.IdLinehaulRoutePreparation, 
			CR.CodeRoute, 
			IIF((LRP.CatVehicleId IS NULL), LRP.VehicleID, CV.CodeName) CodeVehicle,
			IIF((LRP.SenderReceiverId IS NULL), LRP.DriverName, SR.First_Name+ ' '+SR.Last_Name) Courier,
			CLS.StatusName,
			CLS.StatusDescription,
			LRP.DateCreated, 
			LRP.[EndDateLinehaulRoutePreparation],
			LRP.ContainerQuantity,
			(
				SELECT
					SUM(LRPC2.GuideQuantity) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
						ON 
							LRPC2.ContainerId = CTN2.IdContainer 
					WHERE 
						CTN2.CatTypeContainerId = 1 
						AND 
						CONVERT(DATE, LRP2.DateCreated) = @DateFilter
						AND 
						LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
						AND 
						LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalGuideNoPiso,
			(
				SELECT 
					TOP (1) 
						((SUM(LRPC2.ColdPieceQuantity))+(SUM(LRPC2.DryPieceQuantity))) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
						ON 
							LRPC2.ContainerId = CTN2.IdContainer 
				WHERE 
					CTN2.CatTypeContainerId = 1 
					AND 
					CONVERT(DATE, LRP2.DateCreated) = @DateFilter
					AND 
					LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
					AND 
					LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalPiecesNoPiso,
			(
				SELECT 
					SUM(LRPC2.GuideQuantity) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
						ON 
							LRPC2.ContainerId = CTN2.IdContainer 
					WHERE 
						CTN2.CatTypeContainerId = 2 
						AND 
						CONVERT(DATE, LRP2.DateCreated) = @DateFilter
						AND 
						LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
						AND 
						LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalGuidePiso,
			(
				SELECT 
					TOP (1) 
						((SUM(LRPC2.ColdPieceQuantity))+(SUM(LRPC2.DryPieceQuantity))) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
					ON 
						LRPC2.ContainerId = CTN2.IdContainer 
					WHERE 
						CTN2.CatTypeContainerId = 2 
						AND 
						CONVERT(DATE, LRP2.DateCreated) = @DateFilter
						AND 
						LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
						AND 
						LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalPiecesPiso,
			(
				SELECT 
					SUM(LRPCD.GuideDryPieceTotal) - SUM(LRPCD.DryPieceQuantity)
			) AS DifPiecesDry, 
			(
				SELECT 
					SUM(LRPCD.GuideColdPieceTotal) - SUM(LRPCD.ColdPieceQuantity)
			) AS DifPiecesCold,
			MAX([LRS].[DateCreated]) [SettlementStartDate],
			MAX([LRS].[DateUpdated]) [SettlementFinishDate],
			CAST(1 AS BIT) [IsOriginLinehaul]
	FROM 
	[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[CatRoute] CR WITH (NOLOCK)
		ON 
			LRP.CatRouteId = CR.IdRoute
	INNER JOIN
		[DeliveryBackOffice].[dbo].[LinehaulCoverage] LC  WITH(NOLOCK) 
		ON
			[LC].[CatRouteId] = [CR].[IdRoute]
	INNER JOIN
		[DeliveryBackOffice].[dbo].[HubLogisticByUser] HLBU  WITH(NOLOCK) 
		ON
			[LC].[HubOriginId] = [HLBU].[HubLogisticId]
			AND
			[HLBU].[UserId] = @RegisterUserByInternal
			AND
			[HLBU].[RowStatus] = 1
	LEFT JOIN 
		[DeliveryBackOffice].[dbo].[CatVehicle] CV WITH (NOLOCK)
		ON 
			LRP.CatVehicleId = CV.IdVehicle
	LEFT JOIN 
		[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH (NOLOCK)
		ON 
			LRP.SenderReceiverId = SR.ID
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[CatLinehaulStatus] CLS WITH (NOLOCK)
		ON 
			LRP.CatLinehaulStatusId = CLS.IdCatLinehaulStatus
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
		ON 
			LRP.IdLinehaulRoutePreparation = LRPC.LinehaulRoutePreparationId
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[Container] CTN WITH (NOLOCK)
		ON 
			LRPC.ContainerId = CTN.IdContainer 
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[CatTypeContainer] CTC WITH (NOLOCK)
		ON 
			CTN.CatTypeContainerId = CTC.IdCatTypeContainer
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
		ON 
			LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
	LEFT JOIN 
		[DeliveryBackOffice].[dbo].[LinehaulRouteSettlement] LRS  WITH(NOLOCK) 
		ON 
			[LRS].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
	WHERE 
		CONVERT(DATE, LRP.DateCreated) = @DateFilter
		AND 
		LRPCD.RowStatus = 1
	GROUP BY
		LRP.IdLinehaulRoutePreparation, 
		[LRP].[StationDispatchedId],
		CR.CodeRoute, 
		LRP.CatVehicleId,
		LRP.VehicleID,
		LRP.SenderReceiverId,
		LRP.DriverName,
		CV.CodeName, 
		SR.First_Name, 
		SR.Last_Name, 
		CLS.StatusName, 
		CLS.StatusDescription,
		LRP.DateCreated, 
		LRP.[EndDateLinehaulRoutePreparation],
		LRP.ContainerQuantity,
		LRP.GuideQuantity,
		LRP.ColdPieceQuantity,
		LRP.DryPieceQuantity

	-- Linehauls destino
	SELECT 
		DISTINCT 
			LRP.IdLinehaulRoutePreparation, 
			CR.CodeRoute, 
			IIF((LRP.CatVehicleId IS NULL), LRP.VehicleID, CV.CodeName) CodeVehicle,
			IIF((LRP.SenderReceiverId IS NULL), LRP.DriverName, SR.First_Name+ ' '+SR.Last_Name) Courier,
			CLS.StatusName,
			CLS.StatusDescription,
			LRP.DateCreated, 
			LRP.[EndDateLinehaulRoutePreparation],
			LRP.ContainerQuantity,
			(
				SELECT
					SUM(LRPC2.GuideQuantity) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
						ON 
							LRPC2.ContainerId = CTN2.IdContainer 
					WHERE 
						CTN2.CatTypeContainerId = 1 
						AND 
						CONVERT(DATE, LRP2.DateCreated) = @DateFilter
						AND 
						LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
						AND 
						LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalGuideNoPiso,
			(
				SELECT 
					TOP (1) 
						((SUM(LRPC2.ColdPieceQuantity))+(SUM(LRPC2.DryPieceQuantity))) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN 
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
						ON 
							LRPC2.ContainerId = CTN2.IdContainer 
				WHERE 
					CTN2.CatTypeContainerId = 1 
					AND 
					CONVERT(DATE, LRP2.DateCreated) = @DateFilter
					AND 
					LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
					AND 
					LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalPiecesNoPiso,
			(
				SELECT 
					SUM(LRPC2.GuideQuantity) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
						ON 
							LRPC2.ContainerId = CTN2.IdContainer 
					WHERE 
						CTN2.CatTypeContainerId = 2 
						AND 
						CONVERT(DATE, LRP2.DateCreated) = @DateFilter
						AND 
						LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
						AND 
						LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalGuidePiso,
			(
				SELECT 
					TOP (1) 
						((SUM(LRPC2.ColdPieceQuantity))+(SUM(LRPC2.DryPieceQuantity))) 
				FROM 
					[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP2 WITH (NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC2 WITH (NOLOCK)
						ON 
							LRP2.IdLinehaulRoutePreparation = LRPC2.LinehaulRoutePreparationId
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Container] CTN2 WITH (NOLOCK)
					ON 
						LRPC2.ContainerId = CTN2.IdContainer 
					WHERE 
						CTN2.CatTypeContainerId = 2 
						AND 
						CONVERT(DATE, LRP2.DateCreated) = @DateFilter
						AND 
						LRP2.StationDispatchedId = [LRP].[StationDispatchedId] 
						AND 
						LRP2.IdLinehaulRoutePreparation = LRP.IdLinehaulRoutePreparation
			) AS TotalPiecesPiso,
			(
				SELECT 
					SUM(LRPCD.GuideDryPieceTotal) - SUM(LRPCD.DryPieceQuantity)
			) AS DifPiecesDry, 
			(
				SELECT 
					SUM(LRPCD.GuideColdPieceTotal) - SUM(LRPCD.ColdPieceQuantity)
			) AS DifPiecesCold,
			MAX([LRS].[DateCreated]) [SettlementStartDate],
			MAX([LRS].[DateUpdated]) [SettlementFinishDate],
			CAST(0 AS BIT) [IsOriginLinehaul]
	FROM 
	[DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[CatRoute] CR WITH (NOLOCK)
		ON 
			LRP.CatRouteId = CR.IdRoute
	INNER JOIN
		[DeliveryBackOffice].[dbo].[LinehaulCoverage] LC  WITH(NOLOCK) 
		ON
			[LC].[CatRouteId] = [CR].[IdRoute]
	LEFT JOIN 
		[DeliveryBackOffice].[dbo].[CatVehicle] CV WITH (NOLOCK)
		ON 
			LRP.CatVehicleId = CV.IdVehicle
	LEFT JOIN 
		[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH (NOLOCK)
		ON 
			LRP.SenderReceiverId = SR.ID
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[CatLinehaulStatus] CLS WITH (NOLOCK)
		ON 
			LRP.CatLinehaulStatusId = CLS.IdCatLinehaulStatus
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
		ON 
			LRP.IdLinehaulRoutePreparation = LRPC.LinehaulRoutePreparationId
	INNER JOIN
		[DeliveryBackOffice].[dbo].[HubLogisticByUser] HLBU  WITH(NOLOCK) 
		ON
			[LC].[HubDestinyId] = [HLBU].[HubLogisticId]
			AND
			[LRPC].[HubDestinyId] = [HLBU].[HubLogisticId]
			AND
			[HLBU].[UserId] = @RegisterUserByInternal
			AND
			[HLBU].[RowStatus] = 1
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[Container] CTN WITH (NOLOCK)
		ON 
			LRPC.ContainerId = CTN.IdContainer 
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[CatTypeContainer] CTC WITH (NOLOCK)
		ON 
			CTN.CatTypeContainerId = CTC.IdCatTypeContainer
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
		ON 
			LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
	LEFT JOIN 
		[DeliveryBackOffice].[dbo].[LinehaulRouteSettlement] LRS  WITH(NOLOCK) 
		ON 
			[LRS].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
	WHERE 
		CONVERT(DATE, LRP.DateCreated) = @DateFilter
		AND 
		LRPCD.RowStatus = 1
	GROUP BY
		LRP.IdLinehaulRoutePreparation, 
		[LRP].[StationDispatchedId],
		CR.CodeRoute, 
		LRP.CatVehicleId,
		LRP.VehicleID,
		LRP.SenderReceiverId,
		LRP.DriverName,
		CV.CodeName, 
		SR.First_Name, 
		SR.Last_Name, 
		CLS.StatusName, 
		CLS.StatusDescription,
		LRP.DateCreated, 
		LRP.[EndDateLinehaulRoutePreparation],
		LRP.ContainerQuantity,
		LRP.GuideQuantity,
		LRP.ColdPieceQuantity,
		LRP.DryPieceQuantity

END