
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-04-01>
-- Description:	<Description,Nuevo Reporte de Guías Última Milla>
-- =============================================
CREATE PROCEDURE [dbo].[RptLastMileRoutesReport] 
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
     
	DECLARE @StartDateTime AS DATETIME;
	DECLARE @EndDateTime AS DATETIME;
    DECLARE @STATUS_DELIVERED_ID AS INT;
    DECLARE @STATUS_RETURNED_ID AS INT;
    DECLARE @STATUS_TRANSFERED_EX_ID AS INT;
    DECLARE @STATUS_COD_PAID AS INT;
	

	SET NOCOUNT ON;


	SET @StartDateTime =CAST( CAST(@StartDate AS varchar) +' '+ '00:00:00' AS datetime);
	SET @EndDateTime = CAST( CAST(@EndDate AS varchar) +' '+ '11:59:59' AS datetime);

    SET @STATUS_DELIVERED_ID =
    (
        SELECT [SO].[StatusOrderId]
        FROM [dbo].[StatusOrder] SO
        WHERE [SO].[OrderDescription] = 'Entregado'
    );

    SET @STATUS_RETURNED_ID =
    (
        SELECT [SO].[StatusOrderId]
        FROM [dbo].[StatusOrder] SO
        WHERE [SO].[OrderDescription] = 'Devuelto'
    );

    SET @STATUS_TRANSFERED_EX_ID =
    (
        SELECT [SO].[StatusOrderId]
        FROM [dbo].[StatusOrder] SO
        WHERE [SO].[OrderDescription] = 'Traslado a Express Center'
    );

    SET @STATUS_COD_PAID =
    (
        SELECT [SO].[StatusOrderId]
        FROM [dbo].[StatusOrder] SO
        WHERE [SO].[OrderDescription] = 'COD pagado'
    );


   SELECT 
           [DOBS].[Date_Dispatched],
		   [HBL].[HubAbbreviation] Hub,
		   [CR].[RegionName] AS Region,
           [SRE].[CUI] Courierman_Id,
		   [SRE].[First_Name] + ' ' + [SRE].[Last_Name] Courierman_Name,
           [TYSRE].[TypeName] Driver_Type,
		   [CRT].[CodeRoute] Route_Name,
           [CVH].[UnitNumber] Vehicle,
		   [DOBS].[StartingKilometers] Out_KM,
           [DOBS].[ID] Settlement_Id,
		   [DOBS].[Date_Dispatched] Time_Dispatched,
           [DOBS].[Route_Received] Time_Settlement,
		   -- TOTALES GENERALES
           [DOBS].[Guides_Dispatched] Dispatched_Guides,
           ([DOBS].[Pieces_Dry_Dispatched] + [DOBS].[Pieces_Cold_Dispatched]) Dispatched_Pieces,

		    -- RETORNADOS SEGÚN DELIVERY SETTLEMET DETAIL
           SUM(IIF(DSD.Guide_Returned = 1 AND DSD.RowStatus = 1  , 1, 0)) Returned_Guides,
           SUM(IIF(DSD.Guide_Returned = 1 AND DSD.RowStatus = 1  , (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Returned_Pieces,

		    -- ENTREGADOS SEGÚN DELIVERY SETTLEMET DETAIL
           SUM(IIF(DSD.Guide_Delivered = 1 AND DSD.RowStatus = 1 , 1, 0)) Delivered_Guides,
           SUM(IIF(DSD.Guide_Delivered = 1 AND DSD.RowStatus = 1 , (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Delivered_Pieces,

           -- ANULADOS SEGÚN DELIVERY SETTLEMET DETAIL
           SUM(IIF(DSD.RowStatus = 0, 1, 0)) Anulled_Guides,
           SUM(IIF(DSD.RowStatus = 0, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Anulled_Pieces,
		   
		   -- ENTREGADAS SEGÚN CHECKPOINTS
           SUM(IIF(DODdelivery.DeliveryExists = 1 AND DSD.RowStatus = 1, 1, 0)) Delivered_Guides_Checkpoint,
           SUM(IIF(DODdelivery.DeliveryExists = 1 AND DSD.RowStatus = 1, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Delivered_Pieces_Checkpoint,

           -- DEVUELTOS A REMITENTE SEGUN CHECKPOINTS
           SUM(IIF(DODreturn.ReturnExists = 1 AND DSD.RowStatus = 1, 1, 0)) Returned_Guides_Checkpoint,
           SUM(IIF(DODreturn.ReturnExists = 1 AND DSD.RowStatus = 1, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Returned_Pieces_Checkpoint,

           -- TRASLADOS SEGÚN CHECKPOINTS
           SUM(IIF(DODtransfer.TransferExists = 1, 1, 0)) Transfer_Guides_Checkpoint,
           SUM(IIF(DODtransfer.TransferExists = 1, (DO.Pieces_Dry + DO.Pieces_Cold), 0)) Transfer_Pieces_Checkpoint,

		   SUM(IncidenciasSinValidar.UnvalidatedIncident) UnvalidatedIncident,
		   SUM(FalseIncidents.FalseIncidents) FalseIncidents,
		   SUM(IncidenciasReales.[RealIncidents]) RealIncidents,
		   -- INCIDENCE PIECE
		   SUM(IncidenciasRealesPiezas.Piece_RealIncidence)  RealIncidentsPiece,
		   SUM(FalseIncidentsPiezas.Piece_FalseIncidents) FalseIncidentsPiece,
		   SUM(IncidenciasSinValidarPiezas.Piece_UnvalidatedIncident) UnvalidatedIncidentPiece
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
	    INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] SRE WITH (NOLOCK)
            ON [SRE].[ID] = [DOBS].[ID_Courier]
        INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HBL WITH (NOLOCK)
            ON [HBL].[IdHubLogistic] = [SRE].[HubLogisticId]
        INNER JOIN [DeliveryBackOffice].[dbo].[HubByRegion] HBR WITH (NOLOCK)
            ON [HBR].[HubLogisticId] = [SRE].[HubLogisticId]
        INNER JOIN [DeliveryBackOffice].[dbo].[CatRegion] CR WITH (NOLOCK)
            ON [CR].[IdCatRegion] = [HBR].[RegionId]
		 INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] TYSRE WITH (NOLOCK)
            ON [TYSRE].[IdCatTypeSenderReceiver] = [SRE].[CatTypeSenderReceiverId]
        INNER JOIN [DeliveryBackOffice].[dbo].[CatRoute] CRT WITH (NOLOCK)
            ON [CRT].[IdRoute] = [DOBS].[CatRouteId]
		INNER JOIN [DeliveryBackOffice].[dbo].[CatVehicle] CVH WITH (NOLOCK)
            ON [CVH].[IdVehicle] = [DOBS].[CatVehicleId]
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
            ON [DSD].[ID_DeliveryOrderBySettlement] = [DOBS].[ID]
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
            ON [DO].[Guide_Serie] = [DSD].[Guide_Serie]
               AND [DO].[Guide_Number] = [DSD].[Guide_Number]
		OUTER APPLY
    (
        SELECT COUNT(1) 'UnvalidatedIncident'
        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE 
               DO.Guide_Serie = DA.Guide_Serie
              AND DO.Guide_Number = DA.Guide_Number
              AND  COI.IsConfirmed =0 AND COI.IsDenied =0
			  AND COI.RowStatus = 1
    ) IncidenciasSinValidar
	   OUTER APPLY
    (
        SELECT COUNT(1) 'FalseIncidents'
        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE 
               DO.Guide_Serie = DA.Guide_Serie
              AND DO.Guide_Number = DA.Guide_Number
              AND  COI.IsConfirmed = 1 AND COI.IsDenied = 1 
			  AND COI.RowStatus = 1
    ) FalseIncidents
	    OUTER APPLY
    (
        SELECT COUNT(1) 'RealIncidents'
        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE  
               DO.Guide_Serie = DA.Guide_Serie
              AND DO.Guide_Number = DA.Guide_Number
              AND  COI.IsConfirmed = 1 AND COI.IsDenied = 0
			  AND COI.RowStatus = 1
    ) IncidenciasReales
	OUTER APPLY
	(
	  
	SELECT TOP 1 COUNT(DOP.GuidePiece) AS'Piece_RealIncidence'
	FROM [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
	INNER JOIN [dbo].[DeliveryOrderPiece] DOP
	           ON DOP.GuideSerie = DA.Guide_Serie AND DOP.GuideNumber = DA.Guide_Number
	WHERE DA.Guide_Serie = DO.Guide_Serie
              AND  DA.Guide_Number =DO.Guide_Number
	 AND  COI.IsConfirmed = 1 AND COI.IsDenied = 0
			  AND COI.RowStatus = 1
	
	) IncidenciasRealesPiezas
	OUTER APPLY
	(
	  
	SELECT TOP 1 COUNT(DOP.GuidePiece) AS'Piece_FalseIncidents'
	FROM [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
	INNER JOIN [dbo].[DeliveryOrderPiece] DOP
	           ON DOP.GuideSerie = DA.Guide_Serie AND DOP.GuideNumber = DA.Guide_Number
	WHERE DA.Guide_Serie = DO.Guide_Serie
              AND  DA.Guide_Number =DO.Guide_Number
	 AND  COI.IsConfirmed = 1 AND COI.IsDenied = 1
			  AND COI.RowStatus = 1
	
	) FalseIncidentsPiezas
	OUTER APPLY
	(
	  
	SELECT TOP 1 COUNT(DOP.GuidePiece) AS'Piece_UnvalidatedIncident'
	FROM [dbo].[DeliveryAttempt] DA WITH (NOLOCK)
	INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
	INNER JOIN [dbo].[DeliveryOrderPiece] DOP
	           ON DOP.GuideSerie = DA.Guide_Serie AND DOP.GuideNumber = DA.Guide_Number
	WHERE DA.Guide_Serie = DO.Guide_Serie
              AND  DA.Guide_Number =DO.Guide_Number
	 AND  COI.IsConfirmed = 0 AND COI.IsDenied = 0
			  AND COI.RowStatus = 1
	
	) IncidenciasSinValidarPiezas
    OUTER APPLY
    (
        SELECT TOP (1)
               1 [DeliveryExists]
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
        WHERE DO.[Guide_Serie] = [DOD].[Guide_Serie]
              AND [DO].[Guide_Number] = [DOD].[Guide_Number]
              AND [DOD].[StatusOrderId] IN ( @STATUS_DELIVERED_ID, @STATUS_COD_PAID )
			  AND [DOD].StatusOrderId NOT IN (@STATUS_TRANSFERED_EX_ID)
              AND [DOD].[RowStatus] = 1
    ) DODdelivery
        OUTER APPLY
    (
        SELECT TOP (1)
               1 [ReturnExists]
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
        WHERE DO.[Guide_Serie] = [DOD].[Guide_Serie]
              AND [DO].[Guide_Number] = [DOD].[Guide_Number]
              AND [DOD].[StatusOrderId] = @STATUS_RETURNED_ID
              AND [DOD].[RowStatus] = 1
    ) DODreturn
        OUTER APPLY
    (
        SELECT TOP (1)
               1 [TransferExists]
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
        WHERE DO.[Guide_Serie] = [DOD].[Guide_Serie]
              AND [DO].[Guide_Number] = [DOD].[Guide_Number]
              AND [DOD].[StatusOrderId] = @STATUS_TRANSFERED_EX_ID
              AND [DOD].[RowStatus] = 1
    ) DODtransfer
	WHERE [DOBS].[Date_Dispatched] >= @StartDateTime AND [DOBS].[Date_Dispatched] <=  @EndDateTime 
		AND [HBL].[HubStatus] = 1
		AND [HBR].[RowStatus] = 1
		AND [CR].[RowStatus]  = 1
		AND [CRT].[RowStatus] = 1
	   GROUP BY [DOBS].[ID],
             [DOBS].[Date_Dispatched],
             [SRE].[CUI],
             [SRE].[First_Name],
             [SRE].[Last_Name],
             [DOBS].[Guides_Dispatched],
             [DOBS].[Pieces_Dry_Dispatched],
             [DOBS].[Pieces_Cold_Dispatched],
             [DOBS].[Route_Received],
             [HBL].[HubAbbreviation],
             [CR].[RegionName],
             [TYSRE].[TypeName],
             [CRT].[CodeRoute],
             [CVH].[UnitNumber],
             [DOBS].[StartingKilometers];
END