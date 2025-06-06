-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-04-01>
-- Description:	<Description,Nuevo Reporte de Guías Última Milla>
-- =============================================

CREATE PROCEDURE [dbo].[RptLastMileRoutesReport_BNHL] 
    @StartDate DATE,
    @EndDate DATE
	
AS
BEGIN
     
				DECLARE @StartDateTime AS DATETIME;
				DECLARE @EndDateTime AS DATETIME;
  

				SET @StartDateTime = CAST(@StartDate AS DATETIME) + '00:00:00'; -- Añadimos el tiempo para incluir toda la fecha del primer día
				SET @EndDateTime = CAST(@EndDate AS DATETIME) + '23:59:59'; 



			-- CTE para Incidents
			WITH Incidents AS (
				SELECT
					MAX(DSD.Guide_Serie) Guide_Serie,
					MAX(DSD.Guide_Number) Guide_Number ,
					COUNT(DISTINCT DA.Guide_Number) AS UnvalidatedIncidentCount,
					COUNT(DOP.GuidePiece) AS UnvalidatedIncidentPieceCount
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
					ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					ON DA.Guide_Serie = DSD.Guide_Serie AND DA.Guide_Number = DSD.Guide_Number
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
					ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
				LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
					ON  DA.Guide_Serie =  DOP.GuideSerie    AND DA.Guide_Number = DOP.GuideNumber 
				WHERE
					COI.IsConfirmed = 0 
					AND COI.IsDenied = 0 
					AND COI.RowStatus = 1 
					AND COI.StatusOrderId = 45
					AND DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime
					AND DA.Date_Created BETWEEN @StartDateTime AND @EndDateTime
					AND COI.DateCreated BETWEEN @StartDateTime AND @EndDateTime
		
				GROUP BY 
				 DOBS.ID
			),

			-- CTE para IncidentsReal
			IncidentsReal AS (
				SELECT
					MAX(DSD.Guide_Serie) Guide_Serie,
					MAX(DSD.Guide_Number) Guide_Number ,
					COUNT(DISTINCT DSD.Guide_Number) AS [RealIncidentsCount],
					 COUNT(DOP.GuidePiece) AS [RealIncidentsPieceCount]
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
					ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					ON DA.Guide_Serie = DSD.Guide_Serie AND DA.Guide_Number = DSD.Guide_Number
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
					ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
				LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
					ON DOP.GuideNumber = DA.Guide_Number
				WHERE
					COI.IsConfirmed = 1 
					AND COI.IsDenied = 0 
					AND COI.RowStatus = 1 
					AND COI.StatusOrderId = 50
					AND DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime
					AND DA.Date_Created BETWEEN @StartDateTime AND @EndDateTime
					AND COI.DateCreated BETWEEN @StartDateTime AND @EndDateTime
				GROUP BY 
					DSD.Guide_Serie, DSD.Guide_Number
			),
			-- CTE para IncidentsFalse
			IncidentsFalse AS (
				SELECT
					MAX(DSD.Guide_Serie) Guide_Serie,
					MAX(DSD.Guide_Number) Guide_Number ,
					COUNT(DISTINCT DSD.Guide_Number) AS [FalseIncidentsCount],
					 COUNT(DOP.GuidePiece) AS [FalseIncidentsPieceCount]
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
					ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					ON DA.Guide_Serie = DSD.Guide_Serie AND DA.Guide_Number = DSD.Guide_Number
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
					ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
				LEFT JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
					ON DOP.GuideNumber = DA.Guide_Number
				WHERE
					COI.IsConfirmed = 1 
					AND COI.IsDenied = 1 
					AND COI.RowStatus = 1 
					AND COI.StatusOrderId = 50
					AND DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime
					AND DA.Date_Created BETWEEN @StartDateTime AND @EndDateTime
					AND COI.DateCreated BETWEEN @StartDateTime AND @EndDateTime
				GROUP BY 
				  DOBS.ID 
			)
			
			-- Consulta principal
			SELECT 
				DOBS.ID,
				MAX(HBL.HubAbbreviation) AS Hub,
				MAX(DOBS.Date_Dispatched) AS Date_Dispatched,
				MAX(DOBS.StartingKilometers) AS Out_KM,
				MAX(DOBS.Date_Dispatched) AS Time_Dispatched,
				MAX(DOBS.Route_Received) AS Time_Settlement,
				MAX(SRE.First_Name) + ' ' + MAX(SRE.Last_Name) AS Courierman_Name,
				MAX(CRT.CodeRoute) AS Route_Name,
				MAX(SRE.CUI) AS Courierman_Id,
				MAX(TYSRE.TypeName) AS Driver_Type,
				MAX(CVH.UnitNumber) AS Vehicle,
				MAX(CR.RegionName) AS Region,
				  -- Guías y Piezas despachadas
				MAX(DOBS.Guides_Dispatched) AS Dispatched_Guides,
				MAX(DOBS.Pieces_Dry_Dispatched) + MAX(DOBS.Pieces_Cold_Dispatched) AS Dispatched_Pieces,
				  -- Guías entregadas
				SUM(CASE WHEN DOD.StatusOrderId = 5 THEN 1 ELSE 0 END) AS Delivered_Guides_Checkpoint,
				SUM(CASE WHEN DOD.StatusOrderId = 5 THEN DOP.NoPiece ELSE 0 END) AS Delivered_Pieces_Checkpoint,
				  -- Guías devueltas a origen
				SUM(CASE WHEN DOD.StatusOrderId = 14 THEN 1 ELSE 0 END) AS Returned_Guides_Checkpoint,
				SUM(CASE WHEN DOD.StatusOrderId = 14 THEN DOP.NoPiece ELSE 0 END) AS Returned_Pieces_Checkpoint,
				 -- Guías Retornadas para reproceso
				SUM(CASE WHEN DOD.StatusOrderId = 11 THEN 1 ELSE 0 END) AS Returned_Guides,
				SUM(CASE WHEN DOD.StatusOrderId = 11 THEN DOP.NoPiece ELSE 0 END) AS Returned_Pieces,
				 -- Guías Trasladadas a Express Center
				SUM(CASE WHEN DOD.StatusOrderId = 20 THEN 1 ELSE 0 END) AS Transfer_Guides_Checkpoint,
				SUM(CASE WHEN DOD.StatusOrderId = 20 THEN DOP.NoPiece ELSE 0 END) AS Transfer_Pieces_Checkpoint,
                 -- Guías en estados de incidencia pendientes de confirmar o visita fallida	
				MAX(ISNULL(I.UnvalidatedIncidentCount, 0)) AS UnvalidatedIncident,
				MAX(ISNULL(I.UnvalidatedIncidentPieceCount, 0)) AS UnvalidatedIncidentPiece,
				-- Incidencias confirmadas reales
				MAX(ISNULL(IR.RealIncidentsCount, 0)) AS RealIncidents,
				MAX(ISNULL(IR.RealIncidentsPieceCount, 0)) AS RealIncidentsPiece,
				 -- Incidencias Confirmadas negadas por el cliente
				MAX(ISNULL(FI.FalseIncidentsCount, 0)) AS FalseIncidents,
				MAX(ISNULL(FI.FalseIncidentsPieceCount, 0)) AS RealIncidentsPiece
	
			FROM 
				[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
				ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
				ON DOD.Guide_Serie = DSD.Guide_Serie AND DOD.Guide_Number = DSD.Guide_Number
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[SenderReceiver] SRE WITH (NOLOCK)
				ON SRE.ID = DOBS.ID_Courier
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[HubLogistics] HBL WITH (NOLOCK)
				ON HBL.IdHubLogistic = SRE.HubLogisticId
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[HubByRegion] HBR WITH (NOLOCK)
				ON SRE.HubLogisticId = HBR.HubLogisticId
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[CatRegion] CR WITH (NOLOCK)
				ON HBR.RegionId = CR.IdCatRegion
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[CatRoute] CRT WITH (NOLOCK)
				ON DOBS.CatRouteId = CRT.IdRoute
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[CatVehicle] CVH WITH (NOLOCK)
				ON DOBS.CatVehicleId = CVH.IdVehicle
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] TYSRE WITH (NOLOCK)
				ON SRE.CatTypeSenderReceiverId = TYSRE.IdCatTypeSenderReceiver
			LEFT JOIN 
				Incidents I
				ON DSD.Guide_Serie = I.Guide_Serie AND DSD.Guide_Number = I.Guide_Number
			LEFT JOIN 
				IncidentsReal IR
				ON DSD.Guide_Serie = IR.Guide_Serie AND DSD.Guide_Number = IR.Guide_Number
			LEFT JOIN 
				IncidentsFalse FI
				ON DSD.Guide_Serie = FI.Guide_Serie AND DSD.Guide_Number = FI.Guide_Number
			OUTER APPLY (
				SELECT TOP 1 COUNT(DOP1.GuidePiece) AS NoPiece
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP1 WITH (NOLOCK)
				WHERE   DOP1.GuideSerie = DOD.Guide_Serie AND  DOP1.GuideNumber = DOD.Guide_Number
	  
			) DOP
			WHERE 
				DOBS.Date_Dispatched BETWEEN @StartDateTime AND @EndDateTime
				AND  DOD.DateCreated BETWEEN @StartDateTime AND @EndDateTime
			GROUP BY DOBS.ID,
					 DOBS.Date_Dispatched






	
	
END