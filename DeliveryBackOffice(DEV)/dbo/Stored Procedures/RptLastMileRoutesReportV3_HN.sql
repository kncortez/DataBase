/* =================================================
   SP:        [dbo].[RptLastMileRoutesReportV3_HN]
   Propósito: Se agregan dos columnas al reporte RptLastMileRoutesReportV3 con las piezas por segmento B2B y B2C
   Autor:     Tito Garcia
   Historia:  <FDAPI-5441>
   Fecha:     <2026-01-27>
   === CHANGELOG ============================
   =========================================== */
CREATE PROCEDURE [dbo].[RptLastMileRoutesReportV3_HN]
    @StartDate DATE,
    @EndDate DATE,
    @IdCountry VARCHAR(3) = 'GT'
AS
BEGIN

	DECLARE @StartDateTime DATETIME = CAST(@StartDate AS DATETIME);
	DECLARE @EndDateTime   DATETIME = DATEADD(DAY, 1, CAST(@EndDate AS DATETIME));

    -- CTE para Incidents
    WITH Incidents
    AS (SELECT MAX(DA.ID_DeliveryOrderBySettlement) ID,
               COUNT(DISTINCT DA.Guide_Number) AS UnvalidatedIncidentCount
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
                ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                ON DA.ID_DeliveryOrderBySettlement = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE DOBS.Date_Dispatched >= @StartDateTime
			  AND DOBS.Date_Dispatched < @EndDateTime
			  AND DA.Date_Created >= @StartDateTime
			  AND DA.Date_Created < @EndDateTime
              AND ISNULL(COI.IdConfirmationOfIncidence, 0) > 1
              AND COI.IsConfirmed = 0
              AND COI.IsDenied = 0
              AND COI.RowStatus = 1
              AND COI.StatusOrderId = 45
        GROUP BY DA.ID_DeliveryOrderBySettlement),
	-- CTE para IncidentsReal
    IncidentsReal
    AS (SELECT MAX(DA.ID_DeliveryOrderBySettlement) ID,
               COUNT(DISTINCT DA.Guide_Number) AS RealIncidentsCount
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
                ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                ON DA.ID_DeliveryOrderBySettlement = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE DOBS.Date_Dispatched >= @StartDateTime
			  AND DOBS.Date_Dispatched < @EndDateTime
			  AND DA.Date_Created >= @StartDateTime
			  AND DA.Date_Created < @EndDateTime
              AND ISNULL(COI.IdConfirmationOfIncidence, 0) > 1
              AND COI.IsConfirmed = 1
              AND COI.IsDenied = 0
              AND COI.RowStatus = 1
              AND COI.StatusOrderId = 50
        GROUP BY DA.ID_DeliveryOrderBySettlement),
    -- CTE para IncidentsFalse
    IncidentsFalse
    AS (SELECT MAX(DA.ID_DeliveryOrderBySettlement) ID,
               COUNT(DISTINCT DA.Guide_Number) AS FalseIncidentsCount
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
                ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                ON DA.ID_DeliveryOrderBySettlement = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE DOBS.Date_Dispatched >= @StartDateTime
			  AND DOBS.Date_Dispatched < @EndDateTime
			  AND DA.Date_Created >= @StartDateTime
			  AND DA.Date_Created < @EndDateTime
              AND ISNULL(COI.IdConfirmationOfIncidence, 0) > 1
              AND COI.IsConfirmed = 1
              AND COI.IsDenied = 1
              AND COI.RowStatus = 1
              AND COI.StatusOrderId = 50
        GROUP BY DA.ID_DeliveryOrderBySettlement), 
	--CTE Incidencia en ruta
    IncidentsInRoute
    AS (SELECT MAX(DA.ID_DeliveryOrderBySettlement) ID,
               COUNT(DISTINCT DA.Guide_Number) AS [IncidentsCount]
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
                ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
                ON DA.ID_DeliveryOrderBySettlement = DSD.ID_DeliveryOrderBySettlement
            INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH (NOLOCK)
                ON DOP.GuideSerie = DA.Guide_Serie
                    AND DOP.GuideNumber = DA.Guide_Number
        WHERE COI.RowStatus = 1
              AND DOBS.Date_Dispatched >= @StartDateTime
			  AND DOBS.Date_Dispatched < @EndDateTime
			  AND DA.Date_Created >= @StartDateTime
			  AND DA.Date_Created < @EndDateTime
              AND COI.DateCreated
              BETWEEN @StartDateTime AND @EndDateTime
              AND ISNULL(ConfirmationOfIncidenceId, 0) > 1
        GROUP BY DOBS.ID)

    -- Consulta principal
    SELECT MAX(DOBS.ID) ID,
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
           MAX(DOBS.Guides_Dispatched) AS Dispatched_Guides,
           MAX(DOBS.Pieces_Dry_Dispatched) + MAX(DOBS.Pieces_Cold_Dispatched) AS Dispatched_Pieces,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 5 THEN
                          1
                      ELSE
                          0
                  END
              ) AS Delivered_Guides_Checkpoint,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 5 THEN
                          DOP.NoPiece
                      ELSE
                          0
                  END
              ) AS Delivered_Pieces_Checkpoint,
		   ISNULL(BS.B2B_Guides, 0) AS B2B_Guides,
		   ISNULL(BS.C2C_Guides, 0) AS C2C_Guides,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 14 THEN
                          1
                      ELSE
                          0
                  END
              ) AS Returned_Guides_Checkpoint,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 14 THEN
                          DOP.NoPiece
                      ELSE
                          0
                  END
              ) AS Returned_Pieces_Checkpoint,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 8 THEN
                          1
                      ELSE
                          0
                  END
              ) AS Returned_Guides,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 8 THEN
                          DOP.NoPiece
                      ELSE
                          0
                  END
              ) AS Returned_Pieces,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 20 THEN
                          1
                      ELSE
                          0
                  END
              ) AS Transfer_Guides_Checkpoint,
           SUM(   CASE
                      WHEN DSD.StatusOrderId = 20 THEN
                          DOP.NoPiece
                      ELSE
                          0
                  END
              ) AS Transfer_Pieces_Checkpoint,
           SUM(   CASE
                      WHEN ISNULL(DSD.StatusOrderId, 0) = 0 THEN
                          1
                      ELSE
                          0
                  END
              ) AS NonOperatedGuides,
           SUM(   CASE
                      WHEN ISNULL(DSD.StatusOrderId, 0) = 0 THEN
                          DOP.NoPiece
                      ELSE
                          0
                  END
              ) AS NonOperatedGuidesPiece,
           (SUM(   CASE
                       WHEN DSD.StatusOrderId = 5 THEN
                           DOP.NoPiece
                       ELSE
                           0
                   END
               ) * 100
            / NULLIF((MAX(ISNULL(DOBS.Pieces_Dry_Dispatched, 0)) + MAX(ISNULL(DOBS.Pieces_Cold_Dispatched, 0))), 0)
           ) AS Delivery_effectiveness,
           CONVERT(
                      CHAR(8),
                      DATEADD(SECOND, DATEDIFF(SECOND, MAX(DOBS.Date_Dispatched), MAX(DOBS.Route_Received)), 0),
                      108
                  ) AS Time_on_route,
           MAX(ISNULL(IIR.IncidentsCount, 0)) AS IncedenceInRounte,
           MAX(ISNULL(I.UnvalidatedIncidentCount, 0)) AS UnvalidatedIncident,
           MAX(ISNULL(IR.RealIncidentsCount, 0)) AS RealIncidents,
           MAX(ISNULL(FI.FalseIncidentsCount, 0)) AS FalseIncidents,
           MAX(ISNULL(FI.FalseIncidentsCount, 0)) + MAX(ISNULL(IR.RealIncidentsCount, 0)) AS OperatedIncidence
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
            ON DOBS.ID = DSD.ID_DeliveryOrderBySettlement
        INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] SRE WITH (NOLOCK)
            ON SRE.ID = DOBS.ID_Courier
        INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HBL WITH (NOLOCK)
            ON HBL.IdHubLogistic = SRE.HubLogisticId
        INNER JOIN [DeliveryBackOffice].[dbo].[HubByRegion] HBR WITH (NOLOCK)
            ON SRE.HubLogisticId = HBR.HubLogisticId
        INNER JOIN [DeliveryBackOffice].[dbo].[CatRegion] CR WITH (NOLOCK)
            ON HBR.RegionId = CR.IdCatRegion
        INNER JOIN [DeliveryBackOffice].[dbo].[CatRoute] CRT WITH (NOLOCK)
            ON DOBS.CatRouteId = CRT.IdRoute
        INNER JOIN [DeliveryBackOffice].[dbo].[CatVehicle] CVH WITH (NOLOCK)
            ON DOBS.CatVehicleId = CVH.IdVehicle
        INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] TYSRE WITH (NOLOCK)
            ON SRE.CatTypeSenderReceiverId = TYSRE.IdCatTypeSenderReceiver
        LEFT JOIN Incidents I
            ON I.ID = DSD.ID_DeliveryOrderBySettlement
        LEFT JOIN IncidentsReal IR
            ON IR.ID = DSD.ID_DeliveryOrderBySettlement
        LEFT JOIN IncidentsFalse FI
            ON FI.ID = DSD.ID_DeliveryOrderBySettlement
        LEFT JOIN IncidentsInRoute IIR
            ON IIR.ID = DSD.ID_DeliveryOrderBySettlement
        OUTER APPLY
		(
			SELECT TOP 1
				   COUNT(DOP1.GuidePiece) AS NoPiece
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP1 WITH (NOLOCK)
			WHERE DOP1.GuideSerie = DSD.Guide_Serie
				  AND DOP1.GuideNumber = DSD.Guide_Number
		) DOP
		OUTER APPLY
		(
			SELECT
				SUM(B2B) AS B2B_Guides,
				SUM(B2C) AS C2C_Guides
			FROM
			(
				SELECT
					CASE
						WHEN A1.IdCustomer IS NOT NULL
							 AND BS1.BusinessSegmentName IS NOT NULL
						THEN
							CASE 
								WHEN BS1.BusinessSegmentName = 'B2B' THEN DOP.NoPiece
								ELSE 0
							END
						WHEN A3.CustomerID IS NOT NULL
							 AND BS2.BusinessSegmentName IS NOT NULL
						THEN
							CASE 
								WHEN BS2.BusinessSegmentName = 'B2B' THEN DOP.NoPiece
								ELSE 0
							END
						ELSE NULL
					END AS B2B,
					CASE
						WHEN A1.IdCustomer IS NOT NULL
							 AND BS1.BusinessSegmentName IS NOT NULL
						THEN
							CASE 
								WHEN BS1.BusinessSegmentName <> 'B2B' THEN DOP.NoPiece
								ELSE 0
							END
						WHEN A3.CustomerID IS NOT NULL
							 AND BS2.BusinessSegmentName IS NOT NULL
						THEN
							CASE 
								WHEN BS2.BusinessSegmentName <> 'B2B' THEN DOP.NoPiece
								ELSE 0
							END
						ELSE NULL
					END AS B2C

				FROM DeliveryBackOffice.dbo.DeliverySettlementDetail DSD2 WITH (NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder A1 WITH (NOLOCK)
						ON A1.Guide_Serie = DSD2.Guide_Serie
							AND A1.Guide_Number = DSD2.Guide_Number
					  OUTER APPLY
					   (
						 SELECT TOP 1
						 COUNT(DOP2.GuidePiece) AS NoPiece
						 FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP2 WITH (NOLOCK)
						 WHERE DOP2.GuideSerie = A1.Guide_Serie
							AND DOP2.GuideNumber = A1.Guide_Number
					   ) DOP
					LEFT JOIN DeliveryBackOffice.dbo.Customer C1 WITH (NOLOCK)
						ON C1.IdCustomer = A1.IdCustomer
					LEFT JOIN DeliveryBackOffice.dbo.CatBusinessSegment BS1 WITH (NOLOCK)
						ON BS1.IdBusinessSegment = C1.BusinessSegmentID
					   AND BS1.RowStatus = 1
                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient A3 WITH (NOLOCK)
                        ON A1.Sender_ID = A3.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer C2 WITH (NOLOCK)
                        ON C2.IdCustomer = A3.CustomerID
					LEFT JOIN DeliveryBackOffice.dbo.CatBusinessSegment BS2 WITH (NOLOCK)
						ON BS2.IdBusinessSegment = C2.BusinessSegmentID
							AND BS2.RowStatus = 1
				WHERE DSD2.ID_DeliveryOrderBySettlement = DOBS.ID
					AND DSD2.StatusOrderId IN(5)
			) AS tbl1
		) AS BS
    WHERE DOBS.Date_Dispatched >= @StartDateTime
		AND DOBS.Date_Dispatched < @EndDateTime
        AND HBL.IdCountry = @IdCountry
    GROUP BY DOBS.ID,BS.B2B_Guides,BS.C2C_Guides;
END;
