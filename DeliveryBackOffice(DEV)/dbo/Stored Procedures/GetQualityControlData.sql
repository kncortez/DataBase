-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
-- Author:	 <Brandon, Pedroza>
-- Modified: <2024-08-06>
-- Description:	<Se agrega parametro para filtrar incidencias por pais>
-- Modified: <2024-08-06>
-- Description:	<Se devuelven simbolo de moneda para precio de envio y COD>
-- Modified: <2024-08-14>
-- Description:	<Se agrega validacion para mostrar guia sin tomar en cuenta filtro del pais>
-- =============================================
-- Author:	 <Cristian Suazo>
-- Modified: <2025-01-24>
-- Description:	<Se agrega el parametro de ticketNumber para el proyecto de temu>
-- =============================================
-- Author:	 <Walter Orozco>
-- Modified: <2025-05-12>
-- Description:	<Se realizan mejoras de multimoneda para proyecto de SV.>
-- Modified: <2025-06-19>
-- Description:	<Se realiza reestructuración del SP para mejora de rendimiento.>
-- =============================================
-- Author:	 <Bilkar Morataya>
-- Modified: <2026-03-02>
-- Description:	<Se agregan incidencias del portal EXC/CNC (SystemOrigin = 5) para Control de Calidad.>
-- Description:	<Optimización de SP, se bajó de un tiempo de 10 minutos, a 1.5 segundos>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData]
    @GuideSerie											NVARCHAR(2) = ''
  , @GuideNumber										INT
  , @TblHubLogistic				TblHubLogistic			READONLY
  , @TblCustomerType			TblCustomerType			READONLY
  , @TblCustomer				TblCustomer				READONLY
  , @TblVisitPointClient		TblVisitPointClient		READONLY
  , @TblIncidenceType			TblIncidenceType		READONLY
  , @IdCountry											NVARCHAR(2) = 'GT'
  , @TicketNumber										NVARCHAR(300) = NULL

AS
BEGIN

	SET ARITHABORT ON;
    BEGIN TRY

		--VARIABLES: contadores en ruta y entregadas
        DECLARE @Pending_Counter	INT = 0,
                @Delivered_Counter	INT = 0,
				@DateToday			DATE = GETDATE(); 

		--======================================================================================================
		--======================================= TABLAS TEMPORALES ============================================
		--======================================================================================================

		--Tabla temporal guías a procesar?
        IF OBJECT_ID('tempdb.dbo.#TodaysCheckpointsDetail', 'U') IS NOT NULL
            DROP TABLE #TodaysCheckpointsDetail;
		--Tabla temporal para mostrar los datos
        IF OBJECT_ID('tempdb.dbo.#DetailGetQualityControlData ', 'U') IS NOT NULL
            DROP TABLE #DetailGetQualityControlData;

		CREATE TABLE #TodaysCheckpointsDetail
        (
            [GuideSerie]				NVARCHAR(2),
            [GuideNumber]				INT,
            [DateCheckpoint]			DATETIME,
            [DateCreatedInSystem]		DATETIME,
            [Statusorderid]				INT,
            [SystemOrigin]				INT,
            [DeliveryAttemptId]			INT,
            [UserCreated]				NVARCHAR(50),
            [SettlementID]				INT,
            [Settlement_IdCourier]		INT,
            [Settlement_CatRouteId]		INT,
            [Settlement_Date_Received]	DATETIME
        );

		CREATE NONCLUSTERED INDEX IX_TodaysCheckpointsDetail ON #TodaysCheckpointsDetail ( Guideserie, Guidenumber );
        CREATE NONCLUSTERED INDEX IX_IdStatusDetail ON #TodaysCheckpointsDetail ( StatusOrderId );
        CREATE NONCLUSTERED INDEX IX_DeliveryAttemptIdDetail ON #TodaysCheckpointsDetail ( DeliveryAttemptId );
        CREATE NONCLUSTERED INDEX IX_Settlement_IdCourierDetail ON #TodaysCheckpointsDetail ( Settlement_IdCourier );

		CREATE TABLE #DetailGetQualityControlData
        (
            [Pending]					INT,
            [Delivered]					INT,
            [ConfirmationIncidents]		INT,
            [UnConfirmationIncidents]	INT,
            [ID]						BIGINT,
            [ID_Courier]				INT,
            [Date_Received]				DATETIME,
            [IdRoute]					INT,
            [ID_Incident]				INT,
            [IdUser]					INT,
            [Username]					NVARCHAR(50),
            [RouteDescription]			NVARCHAR(200),
            [User]						NVARCHAR(100),
            [GuideSerie]				NVARCHAR(2),
            [GuideNumber]				INT,
			[Ticket_Number]				NVARCHAR(300),
            [SenderName]				NVARCHAR(150),
            [ReceiverName]				NVARCHAR(150),
            [SenderPhone]				NVARCHAR(150),
            [ReceiverPhone]				NVARCHAR(100),
            [ReceiverAddress]			NVARCHAR(600),
            [TypeOfIncident]			NVARCHAR(50),
            [Incident]					NVARCHAR(50),
            [EventDate]					DATETIME,
            [Attempts]					NVARCHAR(10),
            [PriceShippment]			DECIMAL(14, 2),
            [CollectOnDelivery]			DECIMAL(14, 2),
            [OrderDescription]			NVARCHAR(50),
            [StatusOfIncident]			NVARCHAR(50),
            [IdHubLogistic]				INT,
            [Pendiente]					INT,
            [CourierPhone]				NVARCHAR(50),
            [Customer]					INT,
            [CodeOfReference]			NVARCHAR(50),
            [CustomerType]				INT,
            [IdIncidenceType]			INT,
			[ShippmentCurrencySymbol]	NVARCHAR(2),
			[CODCurrencySymbol]			NVARCHAR(2)
        );

		CREATE NONCLUSTERED INDEX IX_DetailGetQualityControlData_ConfirmationIncidents ON #DetailGetQualityControlData ( UnConfirmationIncidents );
		CREATE NONCLUSTERED INDEX IX_ConfirmationIncidents_ControlData ON #DetailGetQualityControlData ( ConfirmationIncidents );

		IF ISNULL(@TicketNumber, '') <> ''
        BEGIN
            SELECT TOP 1
                @GuideNumber = Guide_Number,
                @GuideSerie  = Guide_Serie
            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Ticket_Number = @TicketNumber;
        END

		SELECT
			@Pending_Counter   = SUM(IIF(DO.StatusOrderId NOT IN (5,24,25,22), 1, 0)),
			@Delivered_Counter = SUM(IIF(DO.StatusOrderId IN (5,24,25,22), 1, 0))
		FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]				DSD		WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]	DS		WITH (NOLOCK)
                ON DSD.ID_DeliveryORderBYSettlement = DS.ID
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]				DO		WITH(NOLOCK)
				ON DO.Guide_Serie = DSD.Guide_Serie AND DO.Guide_Number = DSD.Guide_Number
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township]						TW		WITH (NOLOCK)
                ON TW.IdTownship = DO.ReceiverIdTownship
            OUTER APPLY
			(
				SELECT TOP 1
					HBL.IdHubLogistic
				FROM DeliveryBackOffice.dbo.DumpServiceCoverage		DUM		WITH (NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.HubLogistics	HBL		WITH (NOLOCK)
						ON DUM.Hub = HBL.HubAbbreviation
				WHERE DUM.HeaderCode = TW.HeaderCode AND HBL.HubStatus = 1
				AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic) OR HBL.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic))
			) HUbs
		WHERE 
			DSD.DateCreated >= @DateToday AND DSD.DateCreated < DATEADD(DAY, 1, @DateToday)
            AND DO.StatusOrderId NOT IN (45,50)
            AND DSD.RowStatus = 1
			AND ISNULL(DSD.Guide_Settlement,0) = 0
			AND ISNULL(DO.SenderCountryId, 'GT') = @IdCountry;

		--======================================================================================================
		--============================= INSERT TodaysCheckpointsDetail =========================================
		--======================================================================================================

		-- Primer INSERT: Guías en liquidaciones del día con incidencias (optimizado con CTE)
		;WITH FilteredSettlements AS (
			-- Paso 1: Filtrar DeliverySettlementDetail PRIMERO
			SELECT 
				DSD.Guide_Serie,
				DSD.Guide_Number,
				DS.ID AS SettlementID,
				DS.ID_Courier,
				DS.CatRouteId,
				DS.Date_Received
			FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DS WITH (NOLOCK)
				ON DSD.ID_DeliveryORderBYSettlement = DS.ID
			WHERE DSD.DateCreated >= @DateToday AND DSD.DateCreated < DATEADD(DAY, 1, @DateToday)
				AND DSD.rowstatus = 1
				AND (@GuideNumber = 0 OR (DSD.Guide_Serie = @GuideSerie AND DSD.Guide_Number = @GuideNumber))
		)
		-- Paso 2: OUTER APPLY solo sobre liquidaciones filtradas
		INSERT INTO #TodaysCheckpointsDetail
        SELECT 
			GDD.guide_serie,
			GDD.guide_number,
			GDD.datecreated,
			GDD.DateCreatedInSystem,
			GDD.statusorderid,
			GDD.SystemOrigin,
			GDD.DeliveryAttemptId,
			GDD.UserCreated,
			FS.SettlementID,
			FS.ID_Courier,
			FS.CatRouteId,
			FS.Date_Received
		FROM FilteredSettlements FS
		OUTER APPLY
		(
			SELECT TOP 1
				DOD.guide_serie,
				DOD.guide_number,
				DOD.datecreated,
				DOD.DateCreatedInSystem,
				DOD.statusorderid,
				DOD.SystemOrigin,
				DOD.DeliveryAttemptId,
				DOD.UserCreated,
				DO.SenderCountryId
			FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON DOD.Guide_Serie = DO.Guide_Serie AND DOD.Guide_Number = DO.Guide_Number 
			WHERE FS.Guide_Serie = DOD.Guide_Serie AND FS.Guide_Number = DOD.Guide_Number
			ORDER BY DateCreated DESC
		) GDD
		WHERE GDD.statusorderid IN ( 45, 50 ) --solo incidencias confirmadas y pendientes para el detalle
			AND 
				((@GuideNumber = 0 AND ISNULL(GDD.SenderCountryId, 'GT') = @IdCountry) 
				OR 
				(GDD.Guide_Serie = @GuideSerie AND GDD.guide_number = @GuideNumber));


		;WITH FilteredGuides AS (
			-- Paso 1: Filtrar guías PRIMERO para optimizar rendimiento
			SELECT 
				DOD.guide_serie,
				DOD.guide_number,
				DOD.datecreated,
				DOD.DateCreatedInSystem,
				DOD.statusorderid,
				DOD.SystemOrigin,
				DOD.DeliveryAttemptId,
				DOD.UserCreated
			FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
				ON DO.Guide_Serie = DOD.Guide_Serie AND DO.Guide_Number = DOD.Guide_Number
				AND DO.StatusOrderId = DOD.StatusOrderId
			WHERE 
				DOD.DateCreated >= @DateToday AND DOD.DateCreated < DATEADD(DAY, 1, @DateToday)
				AND DOD.StatusOrderId IN (45, 50)
				AND DOD.SystemOrigin IN (2, 5)
				AND 
					((@GuideNumber = 0 AND ISNULL(DO.SenderCountryId, 'GT') = @IdCountry) 
					OR 
					(DOD.Guide_Serie = @GuideSerie AND DOD.Guide_Number = @GuideNumber))
		)
		-- Paso 2: OUTER APPLY solo sobre guías filtradas
		INSERT INTO #TodaysCheckpointsDetail
        SELECT 
			FG.guide_serie,
			FG.guide_number,
			FG.datecreated,
			FG.DateCreatedInSystem,
			FG.statusorderid,
			FG.SystemOrigin,
			FG.DeliveryAttemptId,
			FG.UserCreated,
			AP.ID,
			AP.ID_Courier,
			AP.CatRouteId,
			AP.Date_Received
		FROM FilteredGuides FG
		OUTER APPLY (
			SELECT TOP 1 
				DS.ID,
				DS.ID_Courier,
				DS.CatRouteId,
				DS.Date_Received
			FROM DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement DS WITH (NOLOCK)
				ON DSD.ID_DeliveryORderBYSettlement = DS.ID
			WHERE 
				DSD.Guide_Serie = FG.Guide_Serie 
				AND DSD.Guide_Number = FG.Guide_Number
				AND (DSD.ID IS NULL OR DSD.DateCreated < @DateToday)
				AND DSD.RowStatus = 1
			ORDER BY FG.DateCreated DESC, DSD.DateCreated DESC
		) AS AP;

		--======================================================================================================
		--============================= INSERT DetailGetQualityControlData =====================================
		--======================================================================================================

		INSERT INTO #DetailGetQualityControlData(
			Pending, Delivered, ConfirmationIncidents, UnConfirmationIncidents,
			ID, ID_Courier, Date_Received, Id_Incident, IdRoute,
			IdUser, Username, RouteDescription, [User],
			GuideSerie, GuideNumber, Ticket_Number,
			SenderName, ReceiverName, SenderPhone, ReceiverPhone, ReceiverAddress,
			TypeOfIncident, Incident, EventDate, Attempts,
			PriceShippment, CollectOnDelivery, OrderDescription, StatusOfIncident,
			IdHubLogistic, Pendiente, CourierPhone,
			Customer, CodeOfReference, CustomerType, IdIncidenceType,
			ShippmentCurrencySymbol, CODCurrencySymbol
		)
		SELECT
			0, 0, 0, 0,  --Pending, Delivered, ConfirmationIncidents, UnConfirmationIncidents
			ISNULL(TCD.SettlementID, 0),  --ID
			ISNULL(TCD.Settlement_IdCourier, 0),  --ID_Courier
			TCD.Settlement_Date_Received,  --Date_Received
			0, --Id_Incident
			ISNULL(TCD.Settlement_CatRouteId, 0),  --IdRoute
			NULL, NULL, NULL, NULL,  --IdUser, Username, RouteDescription, [User]
			DO.Guide_Serie,  --GuideSerie
			DO.Guide_Number,  --GuideNumber
			DO.Ticket_Number,  --Ticket_Number
			CONCAT(
				CASE WHEN imp.CodeOfReference > 0 THEN imp.DescriptionOfClient + '/' ELSE '' END,
				CASE WHEN imp.CodeOfReference > 0 THEN DO.Sender_FirstName + DO.Sender_LastName ELSE vpc.DescriptionOfClient END
			),  --SenderName
			ISNULL(DO.Receiver_FirstName, '') + ' ' + ISNULL(DO.Receiver_LastName, ''),  --ReceiverName
			DO.Sender_Phone,  --SenderPhone
			DO.Receiver_Phone,  --ReceiverPhone
			DO.Receiver_Address,  --ReceiverAddress
			NULL, NULL, NULL, NULL,  --TypeOfIncident, Incident, EventDate, Attempts
			DO.PriceShippment,  --PriceShippment
			DO.Collect_OnDelivery,  --CollectOnDelivery
			SO.OrderDescription,  --OrderDescription
			NULL,  --StatusOfIncident
			HUbs.IdHubLogistic,  --IdHubLogistic
			IIF(TCD.StatusOrderId = 4, 1, 0),  --Pendiente
			SR.Phone,  --CourierPhone
			C.IdCustomer,  --Customer
			VPC.CodeOfReference,  --CodeOfReference
			C.IdCustomerType,  --CustomerType
			NULL,  --IdIncidenceType
			CCC.Symbol,  --ShippmentCurrencySymbol
			CCC2.Symbol  --CODCurrencySymbol
		FROM #TodaysCheckpointsDetail TCD
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder			DO		WITH (NOLOCK)
			ON DO.Guide_Serie = TCD.GuideSerie AND DO.Guide_Number = TCD.GuideNumber
		INNER JOIN DeliveryBackOffice.dbo.Cost					CO		WITH (NOLOCK)
			ON DO.Guide_Serie = CO.GuideSerie AND DO.Guide_Number = CO.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD			CCC		WITH (NOLOCK)
			ON ISNULL(CO.ShippingCurrency,1) = CCC.IdCatCurrencyCOD
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD			CCC2	WITH (NOLOCK)
			ON ISNULL(CO.CodCurrency,co.ShippingCurrency) = CCC2.IdCatCurrencyCOD
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient		VPC		WITH (NOLOCK)
			ON VPC.CodeOfReference = DO.Sender_ID
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient		IMP		WITH (NOLOCK)
			ON IMP.CodeOfReference = DO.OriginSenderId
		LEFT JOIN DeliveryBackOffice.dbo.Customer				C		WITH (NOLOCK)
			ON C.IdCustomer = VPC.CustomerID
		LEFT JOIN DeliveryBackOffice.dbo.Township				TW		WITH (NOLOCK)
			ON TW.IdTownship = DO.ReceiverIdTownship
		LEFT JOIN DeliveryBackOffice.dbo.StatusOrder			SO		WITH (NOLOCK)
			ON SO.StatusOrderId = TCD.StatusOrderId
		LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver			SR		WITH (NOLOCK)
			ON SR.ID = TCD.Settlement_IdCourier
		OUTER APPLY (
			SELECT TOP 1 HBL.IdHubLogistic
			FROM DeliveryBackOffice.dbo.DumpServiceCoverage		DUM		WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.HubLogistics		HBL		WITH (NOLOCK)
				ON DUM.Hub = HBL.HubAbbreviation
			WHERE DUM.HeaderCode = TW.HeaderCode AND HBL.HubStatus = 1
		) HUbs
		LEFT JOIN @TblHubLogistic tvpHL ON tvpHL.IdHubLogistics = HUbs.IdHubLogistic
		LEFT JOIN @TblCustomerType tvpCT ON tvpCT.IdCustomerType = C.IdCustomerType
		LEFT JOIN @TblVisitPointClient tvpVP ON tvpVP.IdVisitPointClient = VPC.CodeOfReference
		LEFT JOIN @TblCustomer tvpCus ON tvpCus.IdCustomer = C.IdCustomer
		WHERE DO.IsLastMileReturn = 0 --NO INCLUIR DEVOLUCIÓN
		AND (tvpHL.IdHubLogistics IS NOT NULL OR NOT EXISTS (SELECT 1 FROM @TblHubLogistic))
		AND (tvpCT.IdCustomerType IS NOT NULL OR NOT EXISTS (SELECT 1 FROM @TblCustomerType))
		AND (tvpVP.IdVisitPointClient IS NOT NULL OR NOT EXISTS (SELECT 1 FROM @TblVisitPointClient))
		AND (tvpCus.IdCustomer IS NOT NULL OR NOT EXISTS (SELECT 1 FROM @TblCustomer));

		UPDATE DQCD
		SET
			ConfirmationIncidents = IIF(DA.ID IS NOT NULL AND COI.IsConfirmed = 1, 1, 0),
			UnConfirmationIncidents = IIF(
				COI.IsConfirmed = 0 AND (
					(DA.ID IS NOT NULL AND TCD.SystemOrigin = 3)
					OR (DO.StatusOrderId = 45 AND TCD.SystemOrigin IN (2, 5))
				), 1, 0),
			Id_Incident = DA.ID_Incident,
			IdUser = IIF(TCD.SystemOrigin IN (2, 5), tk2.SSN_IdUser, NULL),
			Username = IIF(TCD.SystemOrigin IN (2, 5), ISNULL(tk2.SSN_Username, 'EXC/CNC'), ''),
			RouteDescription = CASE 
				WHEN TCD.SystemOrigin = 2 THEN 'Usuario Desktop'
				WHEN TCD.SystemOrigin = 5 THEN 'Usuario Portal'
				ELSE 'Vendedor Rutero'
			END,
			[User] = IIF(TCD.SystemOrigin IN (2, 5), ISNULL(tk2.SSN_Username, ''), CONCAT(ISNULL(SR.First_Name, ''), ' ', ISNULL(SR.Last_Name, ''))),
			TypeOfIncident = ISNULL(CIC.IncidenceTypeName, ''),
			Incident = CTI.NameIncidence,
			EventDate = TCD.DateCheckpoint,
			Attempts = CASE
				WHEN CTI.NameIncidence IS NULL THEN NULL
				ELSE CONCAT(
					CONVERT(NVARCHAR(4),
						IIF(
							ATD.GuideDeliveryAttemptCount = ATD.GuideDeliveryMaxAttemptCount,
							ATD.GuideDeliveryAttemptCount,
							IIF(CTI.IncidenceClasificationId <> 1,
								ATD.GuideDeliveryAttemptCount,
								ATD.GuideDeliveryAttemptCount + 1
							)
						)
					),
					'/', CONVERT(NVARCHAR(4), ATD.GuideDeliveryMaxAttemptCount)
				)
			END,
			StatusOfIncident = CASE
				WHEN COI.IsConfirmed IS NULL THEN NULL
				WHEN COI.IsConfirmed = 0 THEN 'Pendiente'
				ELSE IIF(COI.IsDenied = 1, 'Rechazada', 'Aprobada')
			END,
			IdIncidenceType = CTI.IdIncidenceType
		FROM #DetailGetQualityControlData DQCD
		INNER JOIN #TodaysCheckpointsDetail TCD
			ON DQCD.GuideSerie = TCD.GuideSerie AND DQCD.GuideNumber = TCD.GuideNumber
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
			ON DO.Guide_Serie = DQCD.GuideSerie AND DO.Guide_Number = DQCD.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK)
			ON DA.ID = TCD.DeliveryAttemptId
		LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk2 WITH (NOLOCK)
			ON tk2.SSN_IdToken = CONVERT(VARCHAR(50), DA.User_Created)
		LEFT JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence COI WITH (NOLOCK)
			ON COI.IdConfirmationOfIncidence = DA.ConfirmationOfIncidenceId AND COI.RowStatus = 1
		LEFT JOIN DeliveryBackOffice.dbo.CatTypeIncidence CTI WITH (NOLOCK)
			ON CTI.IdIncidenceType = CONVERT(INT, DA.ID_Incident)
		LEFT JOIN DeliveryBackOffice.dbo.CatIncidenceClasification CIC WITH (NOLOCK)
			ON CIC.IdCatIncidenceClasification = CTI.IncidenceClasificationId
		LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver SR WITH (NOLOCK)
			ON SR.ID = TCD.Settlement_IdCourier
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderAttemptData ATD WITH (NOLOCK)
			ON ATD.GuideSerie = DQCD.GuideSerie AND ATD.GuideNumber = DQCD.GuideNumber
		WHERE TCD.DeliveryAttemptId IS NOT NULL;

		--======================================================================================================
		--===================================== CONSULTA DE RESULTADOS =========================================
		--======================================================================================================
		
		SELECT 
			ISNULL(@Pending_Counter,0)				AS Pending,
			ISNULL(@Delivered_Counter,0)			AS Delivered,
			ISNULL(SUM(ConfirmationIncidents),0)	AS ConfirmationIncidents,
			ISNULL(SUM(UnConfirmationIncidents),0)	AS UnConfirmationIncidents
		FROM #DetailGetQualityControlData


		SELECT TOP 200
            Pending ,
            [Delivered] ,
            [ConfirmationIncidents] ,
            [UnConfirmationIncidents] ,
            [ID] ,
            [ID_Courier] ,
            [Date_Received] ,
            [IdRoute] ,
            [ID_Incident] ,
            [IdUser] ,
            [Username] ,
            [RouteDescription] ,
            [User] ,
            [GuideSerie] ,
            [GuideNumber],
			[Ticket_Number],
            [SenderName] ,
            [ReceiverName],
            [SenderPhone] ,
            [ReceiverPhone] ,
            [ReceiverAddress],
            [TypeOfIncident] ,
            [Incident] ,
            [EventDate],
            [Attempts] ,
            [PriceShippment] ,
            [CollectOnDelivery],
            [OrderDescription] ,
            [StatusOfIncident] ,
            [IdHubLogistic] ,
            [Pendiente] ,
            [CourierPhone] ,
            [Customer] ,
            [CodeOfReference] ,
            [CustomerType] ,
            [IdIncidenceType] ,
			[ShippmentCurrencySymbol],
			[CODCurrencySymbol]
		FROM #DetailGetQualityControlData
		WHERE UnConfirmationIncidents = 1 OR ConfirmationIncidents = 1
		ORDER BY ConfirmationIncidents ASC, EventDate ASC;


	END TRY
    BEGIN CATCH

        SELECT CAST(0 AS BIT)						AS 'boolResult',
               ERROR_MESSAGE()						AS 'DescriptionResult',
               CONVERT(BIGINT, 0)					AS 'NumTransferID',
               CONCAT(@GuideSerie, @GuideNumber)	AS 'Guide';

    END CATCH;
END;