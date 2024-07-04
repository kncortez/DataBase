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
	DECLARE @STATUS_COD_liq AS INT;
	DECLARE @STATUS_DELIVERY_EX_ID AS INT;
	DECLARE @STATUS_DECLARE_RETURN AS INT;
	DECLARE @STATUS_DECLARE_RETURN_PROCESS AS INT;
	DECLARE @STATUS_RETURN_ORIGIN AS INT;
	DECLARE @UnvalidatedIncident AS INT;
	DECLARE @ConfirmationOfIncidence AS INT;
	DECLARE @RECEIVER_IN_EXPRESS_ID AS INT;
	DECLARE @RETURNT_IN_EXPRESS_ID AS INT;
	DECLARE @SCHEDULEDFORDELIVERY AS INT;
	DECLARE @ININVENTORY AS INT;
	DECLARE @ArrivedatTheFacilities AS INT;

	SET NOCOUNT ON;

	SET @StartDateTime = CAST(@StartDate AS DATETIME) + '00:00:00'; -- Añadimos el tiempo para incluir toda la fecha del primer día
    SET @EndDateTime = CAST(@EndDate AS DATETIME) + '23:59:59'; 

	  -- Obtener IDs de estado

	SELECT 
		@STATUS_RETURN_ORIGIN = [SO].[StatusOrderId],
		@STATUS_DELIVERY_EX_ID = [SE].[StatusOrderId],
		@STATUS_DECLARE_RETURN = [SD].[StatusOrderId],
		@STATUS_DECLARE_RETURN_PROCESS = [SR].[StatusOrderId],
		@STATUS_DELIVERED_ID = [SDel].[StatusOrderId],
		@STATUS_RETURNED_ID = [SRet].[StatusOrderId],
		@STATUS_TRANSFERED_EX_ID = [ST].[StatusOrderId],
		@STATUS_COD_PAID = [SCP].[StatusOrderId],
		@STATUS_COD_liq = [SCL].[StatusOrderId],
		@UnvalidatedIncident = [IER].[StatusOrderId],
		@ConfirmationOfIncidence = [COI].[StatusOrderId],
		@RECEIVER_IN_EXPRESS_ID = [REC].[StatusOrderId],
		@RETURNT_IN_EXPRESS_ID = [REC].[StatusOrderId],
		@SCHEDULEDFORDELIVERY  = [SFD].[StatusOrderId],
		@ININVENTORY = [II].[StatusOrderId],
		@ArrivedatTheFacilities = [AAI].[StatusOrderId]
	FROM 
		[dbo].[StatusOrder] [SO] WITH(NOLOCK)
	LEFT JOIN [dbo].[StatusOrder] [SE]   ON [SE].[OrderDescription] = 'Entregado En Express Center'
	LEFT JOIN [dbo].[StatusOrder] [SD]   ON [SD].[OrderDescription] = 'Declarado para Devolución'
	LEFT JOIN [dbo].[StatusOrder] [SR]   ON [SR].[OrderDescription] = 'Paquete Retornado para Reproceso'
	LEFT JOIN [dbo].[StatusOrder] [SDel] ON [SDel].[OrderDescription] = 'Entregado'
	LEFT JOIN [dbo].[StatusOrder] [SRet] ON [SRet].[OrderDescription] = 'Devuelto'
	LEFT JOIN [dbo].[StatusOrder] [ST]   ON [ST].[OrderDescription] = 'Traslado a Express Center'
	LEFT JOIN [dbo].[StatusOrder] [SCP]  ON [SCP].[OrderDescription] = 'COD pagado'
	LEFT JOIN [dbo].[StatusOrder] [SCL]  ON [SCL].[OrderDescription] = 'COD liquidado'
	LEFT JOIN [dbo].[StatusOrder] [IER]  ON [IER].[OrderDescription] = 'Incidencia en ruta'
	LEFT JOIN [dbo].[StatusOrder] [COI]  ON [COI].[OrderDescription] = 'Incidencia Validada'
	LEFT JOIN [dbo].[StatusOrder] [REC]  ON [REC].[OrderDescription] = 'Recibido En Express Center'
	LEFT JOIN [dbo].[StatusOrder] [REEC] ON [REEC].[OrderDescription] = 'Devuelto en Express Center'
	LEFT JOIN [dbo].[StatusOrder] [SFD]  ON [SFD].[OrderDescription] =  'Programado para entrega'
    LEFT JOIN [dbo].[StatusOrder] [II]   ON [II].[OrderDescription] =  'En Inventario'
	LEFT JOIN [dbo].[StatusOrder] [AAI]   ON [AAI].[OrderDescription] =  'Arribó a las instalaciones';
	
SELECT    MAX([DOBS].[ID] ) Settlement_Id,
          MAX([HBL].[HubAbbreviation]) Hub,
          MAX([DOBS].[Date_Dispatched]) [Date_Dispatched],
		  MAX([DOBS].[StartingKilometers]) Out_KM,
		  MAX([DOBS].[Date_Dispatched]) Time_Dispatched,
          MAX([DOBS].[Route_Received]) Time_Settlement,
		  MAX([SRE].[First_Name]) + ' ' + max([SRE].[Last_Name]) Courierman_Name,
		  MAX([CRT].[CodeRoute]) Route_Name,
		  MAX([SRE].[CUI] ) Courierman_Id,
		  MAX([TYSRE].[TypeName]) Driver_Type,
		  MAX([CVH].[UnitNumber]) Vehicle,
		  MAX([CR].[RegionName]) AS Region,
         
          MAX([DOBS].[Guides_Dispatched]) Dispatched_Guides,
          MAX([DOBS].[Pieces_Dry_Dispatched]) + MAX([DOBS].[Pieces_Cold_Dispatched]) Dispatched_Pieces,
	
	    -- Guías entregadas
		SUM(CASE WHEN DOD.StatusOrderId IN (@STATUS_DELIVERED_ID ,@STATUS_COD_PAID,@STATUS_COD_liq) AND  NotIsDelivery.DeliveryInExpressCenter  = 0 THEN 1 ELSE 0 END) AS [Delivered_Guides_Checkpoint],
		SUM(CASE WHEN DOD.StatusOrderId IN (@STATUS_DELIVERED_ID ,@STATUS_COD_PAID,@STATUS_COD_liq) AND  NotIsDelivery.DeliveryInExpressCenter  = 0 THEN DO.Pieces_Dry + DO.Pieces_Cold ELSE 0 END) AS [Delivered_Pieces_Checkpoint],

		-- Guías devueltas a origen
		SUM(CASE WHEN DOD.StatusOrderId in(  @STATUS_RETURN_ORIGIN,@STATUS_RETURNED_ID ) THEN 1 ELSE 0 END) AS Returned_Guides_Checkpoint,
		SUM(CASE WHEN DOD.StatusOrderId in(  @STATUS_RETURN_ORIGIN,@STATUS_RETURNED_ID ) THEN DO.Pieces_Dry + DO.Pieces_Cold ELSE 0 END) AS Returned_Pieces_Checkpoint,

		-- Guías Retornadas para reproceso
		SUM(CASE WHEN DOD.StatusOrderId in( @STATUS_DECLARE_RETURN_PROCESS,@ArrivedatTheFacilities,@ININVENTORY,@SCHEDULEDFORDELIVERY,@STATUS_DECLARE_RETURN,@ConfirmationOfIncidence) THEN 1 ELSE 0 END) AS Returned_Guides,
		SUM(CASE WHEN DOD.StatusOrderId in( @STATUS_DECLARE_RETURN_PROCESS,@ArrivedatTheFacilities,@ININVENTORY,@SCHEDULEDFORDELIVERY,@STATUS_DECLARE_RETURN,@ConfirmationOfIncidence) THEN DO.Pieces_Dry + DO.Pieces_Cold ELSE 0 END) AS Returned_Pieces,

		-- Guías Trasladadas, entregadas o recibidas en Express Center
		SUM(CASE WHEN DOD.StatusOrderId in(@STATUS_TRANSFERED_EX_ID,@RECEIVER_IN_EXPRESS_ID,@STATUS_DELIVERY_EX_ID,@RETURNT_IN_EXPRESS_ID ) THEN 1 ELSE 0 END) AS Transfer_Guides_Checkpoint,
		SUM(CASE WHEN DOD.StatusOrderId in(@STATUS_TRANSFERED_EX_ID,@RECEIVER_IN_EXPRESS_ID,@STATUS_DELIVERY_EX_ID,@RETURNT_IN_EXPRESS_ID ) THEN DO.Pieces_Dry + DO.Pieces_Cold ELSE 0 END) AS Transfer_Pieces_Checkpoint,

	
	 -- Guías en estados de incidencias confirmadas, pendientes de confirmar o visita fallida
		SUM(CASE WHEN  [UnvalidatedIncident].[UnvalidatedIncident] = 1
				 THEN 1 ELSE 0 END) [UnvalidatedIncident],

		SUM(CASE WHEN  [UnvalidatedIncident].[UnvalidatedIncident] = 1
				 THEN DO.Pieces_Dry + DO.Pieces_Cold  ELSE 0 END) [UnvalidatedIncidentPiece],

		--  Incidencias confirmadas reales
		SUM(CASE WHEN IncidenciasReales.RealIncidents = 1  
				 THEN IncidenciasReales.RealIncidents ELSE 0 END) AS [RealIncidents],
		SUM(CASE WHEN IncidenciasReales.RealIncidents = 1 
				 THEN DO.Pieces_Dry + DO.Pieces_Cold ELSE 0 END) AS [RealIncidentsPiece],

       --  Incidencias Confirmadas negadas por el cliente
		SUM(CASE WHEN FalseIncidents.FalseIncidents = 1  
				 THEN FalseIncidents.FalseIncidents ELSE 0 END) AS [FalseIncidents],
		
		SUM(CASE WHEN FalseIncidents.FalseIncidents = 1 
				 THEN DO.Pieces_Dry + DO.Pieces_Cold ELSE 0 END) AS [FalseIncidentsPiece]
FROM   
		[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH (NOLOCK)
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
	ON 
		 [DOBS].[ID] =[DSD].[ID_DeliveryOrderBySettlement]
	INNER JOIN
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
	ON  
		DSD.Guide_Serie = DO.Guide_Serie AND DSD.Guide_Number = DO.Guide_Number
	INNER JOIN 
		 [DeliveryBackOffice].[dbo].[SenderReceiver] SRE WITH (NOLOCK)
	ON [SRE].[ID] = [DOBS].[ID_Courier]
	INNER JOIN 
		   [DeliveryBackOffice].[dbo].[HubLogistics] HBL WITH (NOLOCK)
	ON [HBL].[IdHubLogistic] = [SRE].[HubLogisticId]
	INNER JOIN 
	   [DeliveryBackOffice].[dbo].[HubByRegion] HBR WITH (NOLOCK)
	ON [SRE].[HubLogisticId] = [HBR].[HubLogisticId]
	INNER JOIN 
	   [DeliveryBackOffice].[dbo].[CatRegion] CR WITH (NOLOCK)
	ON [HBR].[RegionId] = [CR].[IdCatRegion]
	INNER JOIN 
	   [DeliveryBackOffice].[dbo].[CatRoute] CRT WITH (NOLOCK)
	ON [DOBS].[CatRouteId] = [CRT].[IdRoute]
	INNER JOIN 
	   [DeliveryBackOffice].[dbo].[CatVehicle] CVH WITH (NOLOCK)
	 ON [DOBS].[CatVehicleId] = [CVH].[IdVehicle]
	INNER JOIN 
		[DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] TYSRE WITH (NOLOCK)
	 ON [SRE].[CatTypeSenderReceiverId] = [TYSRE].[IdCatTypeSenderReceiver]
	OUTER APPLY 
	(
	   SELECT  TOP 1
				 DOD1.StatusOrderId
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD1 WITH (NOLOCK)
			WHERE  DOD1.Guide_Serie = DSD.Guide_Serie AND
				   DOD1.Guide_Number = DSD.Guide_Number
			 AND  DOD1.DateCreated >= DATEADD(DAY, DATEDIFF(DAY, 0, [DOBS].Date_Dispatched), 0) -- Inicio del día de [DOBS].Date_Dispatched
             AND  DOD1.DateCreated < DATEADD(DAY, DATEDIFF(DAY, 0, [DOBS].Date_Dispatched) + 1, 0) -- Inicio del día siguiente
			ORDER BY DOD1.DateCreated DESC
	) DOD
		 OUTER APPLY
		(
			SELECT COUNT(1) 'FalseIncidents'
			FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
					ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
			WHERE 
					  DA.Guide_Serie  = DSD.Guide_Serie
				  AND DA.Guide_Number = DSD.Guide_Number
				  AND DA.Date_Created    BETWEEN @StartDateTime AND @EndDateTime
				  AND COI.IsConfirmed = 1 
				  AND COI.IsDenied = 1 
				  AND COI.RowStatus = 1
				  AND COI.StatusOrderId = @ConfirmationOfIncidence
				
		) FalseIncidents
		OUTER APPLY
		(
			SELECT COUNT(1) 'RealIncidents'
			FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
					ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
			WHERE 
					   DA.Guide_Serie  = DSD.Guide_Serie
				  AND  DA.Guide_Number = DSD.Guide_Number 
				  AND  DA.Date_Created    BETWEEN @StartDateTime AND @EndDateTime
				  AND  COI.IsConfirmed = 1 
				  AND  COI.IsDenied = 0
				  AND  COI.RowStatus = 1
				  AND  COI.StatusOrderId = @ConfirmationOfIncidence
				  
		) IncidenciasReales	
			 OUTER APPLY
		(
			SELECT COUNT(1) 'UnvalidatedIncident'
			FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
					ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
			WHERE 
					  DA.Guide_Serie  = DSD.Guide_Serie
				  AND DA.Guide_Number = DSD.Guide_Number
				  AND DA.Date_Created    BETWEEN @StartDateTime AND @EndDateTime
				  AND COI.IsConfirmed = 0 
				  AND COI.IsDenied = 0
				  AND COI.RowStatus = 1
				  AND COI.StatusOrderId = @UnvalidatedIncident
				
		) UnvalidatedIncident
		OUTER APPLY 
	(
	   SELECT  TOP 1 COUNT(1) DeliveryInExpressCenter
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD1 WITH (NOLOCK)
			WHERE  DOD1.Guide_Serie = DSD.Guide_Serie AND
				   DOD1.Guide_Number = DSD.Guide_Number
		           AND DOD1.StatusOrderId = @STATUS_DELIVERY_EX_ID
	) NotIsDelivery

WHERE  
    [DOBS].[Date_Dispatched] BETWEEN @StartDateTime AND @EndDateTime
	 GROUP BY [DOBS].[ID]
	

END




