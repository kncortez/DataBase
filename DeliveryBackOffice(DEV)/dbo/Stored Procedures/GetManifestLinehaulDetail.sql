-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-29>
-- Description:	<Obtiene el detalle del módulo de manifiesto linehaul desktop>
-- =============================================
CREATE PROCEDURE [dbo].[GetManifestLinehaulDetail] 
	-- Add the parameters for the stored procedure here
	@IdLinehaulRoutePreparation INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Table 0 Información del manifiesto
	SELECT
		lrp.IdLinehaulRoutePreparation IdLinehaulRoutePreparation
	   ,lrp.ContainerQuantity ContainerTotal
	   ,ISNULL((SELECT
				SUM(lrpc.GuideQuantity)
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN Container c WITH (NOLOCK)
				ON lrpc.ContainerId = c.IdContainer
				AND c.RowStatus = 1
			INNER JOIN CatTypeContainer ctc WITH (NOLOCK)
				ON ctc.IdCatTypeContainer = c.CatTypeContainerId
			WHERE lrpc.LinehaulRoutePreparationId = lrp.IdLinehaulRoutePreparation
			AND ctc.TypeContainerSerie = 'BOX'
			AND lrpc.RowStatus = 1)
		, 0)
		ContainerGuideTotal
	   ,ISNULL((SELECT
				SUM(lrpc.DryPieceQuantity + lrpc.[ColdPieceQuantity])
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN Container c WITH (NOLOCK)
				ON lrpc.ContainerId = c.IdContainer
				AND c.RowStatus = 1
			INNER JOIN CatTypeContainer ctc WITH (NOLOCK)
				ON ctc.IdCatTypeContainer = c.CatTypeContainerId
			WHERE lrpc.LinehaulRoutePreparationId = lrp.IdLinehaulRoutePreparation
			AND ctc.TypeContainerSerie = 'BOX'
			AND lrpc.RowStatus = 1)
		, 0)
		ContainerPiecesTotal
	   ,ISNULL((SELECT
				SUM(lrpc.GuideQuantity)
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN Container c WITH (NOLOCK)
				ON lrpc.ContainerId = c.IdContainer
				AND c.RowStatus = 1
			INNER JOIN CatTypeContainer ctc WITH (NOLOCK)
				ON ctc.IdCatTypeContainer = c.CatTypeContainerId
			WHERE lrpc.LinehaulRoutePreparationId = lrp.IdLinehaulRoutePreparation
			AND ctc.TypeContainerSerie = 'LH'
			AND lrpc.RowStatus = 1)
		, 0)
		FloorGuideTotal
	   ,cr.CodeRoute RouteCode
	   ,IIF(sr.Id IS NULL, lrp.DriverName, CONCAT(sr.First_Name, ' ', sr.Last_Name)) CourierName
	   ,IIF(cv.IdVehicle IS NULL, CONCAT(lrp.VehicleID, ' - ', lrp.VehicleDescription), cv.Plate) Vehicle
	   ,cls.StatusName StatusName
	   ,cls.StatusDescription StatusDescription
	   ,FORMAT(ISNULL((SELECT TOP 1
				lrpcd.DateCreated
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
				ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
				AND lrpc.RowStatus = 1
			WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
			AND lrpc.RowStatus = 1
			ORDER BY lrpcd.DateCreated)
		, lrp.DateCreated), 'dd/MM/yyyy hh:mm tt') DateCreated
	   ,FORMAT(ISNULL(lrp.[EndDateLinehaulRoutePreparation]
		, (SELECT TOP 1
				lrpcd.DateCreated
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
				ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
				AND lrpc.RowStatus = 1
			WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
			AND lrpc.RowStatus = 1
			ORDER BY lrpcd.DateCreated DESC)), 'dd/MM/yyyy hh:mm tt') DateRoutePreparation
		, ISNULL(FORMAT([lrs].[DateCreated], 'dd/MM/yyyy hh:mm tt'), 'N/A') [SettlementStartDate]
		, ISNULL(FORMAT([lrs].[EndDateLinehaulRouteSettlement], 'dd/MM/yyyy hh:mm tt'), 'N/A') [SettlementEndDate]
		, ISNULL(lrpcm.CustomsMarkSerie, '') CustomMark
	FROM LinehaulRoutePreparation lrp WITH (NOLOCK)
	LEFT JOIN CatRoute cr WITH (NOLOCK)
		ON cr.IdRoute = lrp.CatRouteId
	LEFT JOIN SenderReceiver sr WITH (NOLOCK)
		ON sr.Id = lrp.SenderReceiverId
	LEFT JOIN CatVehicle cv WITH (NOLOCK)
		ON cv.IdVehicle = lrp.CatVehicleId
	INNER JOIN CatLinehaulStatus cls WITH (NOLOCK)
		ON cls.IdCatLinehaulStatus = lrp.CatLinehaulStatusId
	LEFT JOIN LinehaulRoutePreparationCustomsMark lrpcm WITH(NOLOCK)
		ON lrp.IdLinehaulRoutePreparation = lrpcm.LinehaulRoutePreparationId
		AND lrpcm.RowStatus = 1
	LEFT JOIN [dbo].[LinehaulRouteSettlement] lrs  WITH(NOLOCK) 
		ON [lrs].[LinehaulRoutePreparationId] = [lrp].[IdLinehaulRoutePreparation]
	WHERE lrp.IdLinehaulRoutePreparation = @IdLinehaulRoutePreparation
	AND lrp.RowStatus = 1

	-- Table 1 Detalle manifiesto
	SELECT 
		[DispatchedLienahul].[Guide]
		,[DispatchedLienahul].[Pieces]
		,[DispatchedLienahul].[ContainerDescription]
		,[DispatchedLienahul].[HubName]
		,[DispatchedLienahul].[HubAbbreviation]
		,[DispatchedLienahul].[Department]
		,[DispatchedLienahul].[IsParcial]
		,[DispatchedLienahul].[StatusDescription]
		,[DispatchedLienahul].[Act]
		,[DispatchedLienahul].[ActPieces]
		,[DispatchedLienahul].[IsNotInManifest]
		,[DispatchedLienahul].[IsOffRoute] 
	FROM
		(
			SELECT
				TOP 100 PERCENT
					CONCAT(lrpcd.GuideSerie, lrpcd.GuideNumber) Guide
				   ,CONCAT((lrpcd.DryPieceQuantity + lrpcd.ColdPieceQuantity), '/', (lrpcd.GuideDryPieceTotal + lrpcd.GuideColdPieceTotal)) Pieces
				   ,c.ContainerDescription ContainerDescription
				   ,hl.HubName
				   ,hl.HubAbbreviation
				   ,(SELECT TOP 1
							p.ProvinceName
						FROM DumpServiceCoverage dsc WITH (NOLOCK)
						INNER JOIN Settlement s WITH (NOLOCK)
							ON s.IdSettlement = dsc.IdSettlement
						INNER JOIN Province p WITH (NOLOCK)
							ON s.IdProvince = p.IdProvince
						WHERE dsc.Hub = hl.HubAbbreviation)
					Department
				   ,IIF((lrpcd.DryPieceQuantity + lrpcd.ColdPieceQuantity) = (lrpcd.GuideDryPieceTotal + lrpcd.GuideColdPieceTotal), 0, 1) IsParcial
				   ,so.OrderDescription StatusDescription
				   ,ad.ActId Act
				   ,CASE
						WHEN ad.ActId IS NOT NULL THEN (SELECT
									STUFF((SELECT
											', ' + CAST(adp.PieceNumber AS VARCHAR)
										FROM ActDetail ad2 WITH (NOLOCK)
										INNER JOIN ActDetailPiece adp WITH (NOLOCK)
											ON ad2.IdActDetail = adp.ActDetailId
										WHERE ad2.IdActDetail = ad.ActId
										FOR XML PATH (''))
									, 1, 2, ''))
						ELSE NULL
					END ActPieces
					,0 [IsNotInManifest]
					,lrpcd.IsOffRoute [IsOffRoute]
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
				ON lrpcd.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer
					AND lrpcd.RowStatus = 1
			INNER JOIN Container c WITH (NOLOCK)
				ON c.IdContainer = lrpc.ContainerId
			INNER JOIN HubLogistics hl WITH (NOLOCK)
				ON hl.IdHubLogistic = lrpc.HubDestinyId
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON lrpcd.GuideSerie = do.Guide_Serie
					AND lrpcd.GuideNumber = do.Guide_Number
			INNER JOIN StatusOrder so WITH (NOLOCK)
				ON do.StatusOrderId = so.StatusOrderId
			LEFT JOIN ActDetail ad WITH (NOLOCK)
				ON lrpcd.GuideSerie = ad.GuideSerie
					AND lrpcd.GuideNumber = ad.GuideNumber
					AND ad.RowStatus = 1
			WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
			AND lrpc.RowStatus = 1
			ORDER BY hl.HubName
		) DispatchedLienahul
	UNION
	SELECT 
		 [ExtraGuidesLinehaul].[Guide]
		 ,[ExtraGuidesLinehaul].[Pieces]
		 ,[ExtraGuidesLinehaul].[ContainerDescription]
		 ,[ExtraGuidesLinehaul].[HubName]
		 ,[ExtraGuidesLinehaul].[HubAbbreviation]
		 ,[ExtraGuidesLinehaul].[Department]
		 ,[ExtraGuidesLinehaul].[IsParcial]
		 ,[ExtraGuidesLinehaul].[StatusDescription]
		 ,[ExtraGuidesLinehaul].[Act]
		 ,[ExtraGuidesLinehaul].[ActPieces]
		 ,[ExtraGuidesLinehaul].[IsNotInManifest]
		 ,[ExtraGuidesLinehaul].[IsOffRoute]
	FROM
		(
			SELECT 
				TOP 100 PERCENT
					CONCAT([LRSCD].GuideSerie, [LRSCD].GuideNumber) Guide
					,CONCAT(([LRSCD].[PiecesReceived]), '/', (DO.[Pieces_Dry] + DO.[Pieces_Cold])) Pieces
					,[Ctn].ContainerDescription ContainerDescription
					,hl.HubName
					,hl.HubAbbreviation
					,(SELECT TOP 1
							p.ProvinceName
						FROM DumpServiceCoverage dsc WITH (NOLOCK)
						INNER JOIN Settlement s WITH (NOLOCK)
							ON s.IdSettlement = dsc.IdSettlement
						INNER JOIN Province p WITH (NOLOCK)
							ON s.IdProvince = p.IdProvince
						WHERE dsc.Hub = hl.HubAbbreviation)
					Department
					,0 IsParcial
					,so.OrderDescription StatusDescription
					,ad.ActId Act
					,CASE
						WHEN ad.ActId IS NOT NULL THEN (SELECT
									STUFF((SELECT
											', ' + CAST(adp.PieceNumber AS VARCHAR)
										FROM ActDetail ad2 WITH (NOLOCK)
										INNER JOIN ActDetailPiece adp WITH (NOLOCK)
											ON ad2.IdActDetail = adp.ActDetailId
										WHERE ad2.IdActDetail = ad.ActId
										FOR XML PATH (''))
									, 1, 2, ''))
						ELSE NULL
					END ActPieces
					,1 [IsNotInManifest]
					,LRSCD.IsOffRoute [IsOffRoute]
				FROM
					-- Datos de despacho de linehaul
					[dbo].[LinehaulRoutePreparation] LRP  WITH(NOLOCK) 
					INNER JOIN
						[dbo].[LinehaulRoutePreparationContainer] LRPC  WITH(NOLOCK) 
						ON
							[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
							AND
							[LRPC].[RowStatus] = 1
					-- Revisar liquidación por guías adicionales, se debe validar datos de despacho con datos de liquidación para solo mostrar datos adicionales
					INNER JOIN
						[dbo].[LinehaulRouteSettlement] LRS  WITH(NOLOCK) 
						ON
							[LRS].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
							AND
							[LRS].[RowStatus] = 1
					INNER JOIN
						[dbo].[LinehaulRouteSettlementContainer] LRSC  WITH(NOLOCK) 
						ON
							[LRSC].[LinehaulRouteSettlementId] = [LRS].[IdLinehaulRouteSettlement]
							AND
							[LRSC].[ContainerId] <> [LRPC].[ContainerId]
							AND
							[LRSC].[RowStatus] = 1
					INNER JOIN
						[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD  WITH(NOLOCK) 
						ON
							[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
							AND
							[LRSCD].[RowStatus] = 1
					INNER JOIN
						[dbo].[Container] Ctn  WITH(NOLOCK) 
						ON
							[Ctn].[IdContainer] = [LRSC].[ContainerId]
					INNER JOIN
						[dbo].[HubLogistics] HL  WITH(NOLOCK) 
						ON
							[HL].[IdHubLogistic] = [LRSC].[HubId]
					INNER JOIN
						[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
						ON
							[DO].[Guide_Serie] = [LRSCD].[GuideSerie] AND [DO].[Guide_Number] = [LRSCD].[GuideNumber]
					INNER JOIN
						[dbo].[StatusOrder] SO  WITH(NOLOCK) 
						ON
							[SO].[StatusOrderId] = [DO].[StatusOrderId]
					LEFT JOIN
						[dbo].[ActDetail] AD  WITH(NOLOCK) 
						ON
							[AD].[GuideSerie] = [LRSCD].[GuideSerie] AND [AD].[GuideNumber] = [LRSCD].[GuideNumber]
							AND
							[AD].[RowStatus] = 1
				WHERE
					[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
				ORDER BY HL.HubName
		) ExtraGuidesLinehaul
END