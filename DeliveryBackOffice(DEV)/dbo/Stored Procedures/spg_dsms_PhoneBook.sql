-- =============================================
-- Author:		<BORJA, CESAR>
-- Create date: <2020-08-25>
-- Description:	<GET PhoneBook>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-31>
-- Description:	<Se agrega el pais a la respuesta de la consulta>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-11-20>
-- Description:	<Se agrega el nuevo estado en ruta para el envio de WhatsApp del tracking>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-08-04>
-- Description:	<Se hace la configuración para que se pueda enviar mensajes de Whatsapp mediante Concepto Móvil, se discriminan contactos CORPORATIVOS, y se separan algunos campos que estaban concatenados, manteniendo los que estaban concatenados por si son útiles en otras herramientas>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-08-06>
-- Description:	<Se agrega el campo NirPhone.>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-08-22>
-- Description:	<Se agrega el campo CODAmount.>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-08-28>
-- Description:	<Se agrega campos RegxMovilPhone y WhatsappNumber.>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-12-15>
-- Description:	<Optimización: eliminación de duplicación masiva de código, uso de CTEs para mejor rendimiento y mantenibilidad>
-- =============================================
--exec [dbo].[spg_dsms_PhoneBook] 
--@MaxDeliveryDate = '2022-03-09 17:21:42.180',@ElementId = 1001

CREATE PROCEDURE [dbo].[spg_dsms_PhoneBook] 
	@MaxDeliveryDate DATETIME = '2025-05-06',
	@ElementId INT = 1001
AS
BEGIN
	SET NOCOUNT ON;

	-- === CONFIGURACIÓN INICIAL ===
	DECLARE @CustomerCorporative INT = (
		SELECT IdCustomerType FROM CustomerType WITH(NOLOCK) WHERE Description = 'CORPORATIVO'
	);
	
	DECLARE @ConditionPayment INT = (
		SELECT IdConditionOfPayment FROM CatConditionOfPayment WITH(NOLOCK) WHERE ConditionOfPayment = 'CONTADO'
	);
	
	DECLARE @LastUpdate DATETIME = DATEADD(MINUTE, -200, @MaxDeliveryDate);
	DECLARE @DateCutoff DATE = '2025-08-01';
	DECLARE @TopBatchId BIGINT = ISNULL((SELECT MAX(Sent_Batch_Id) FROM SMS_Sent WITH(NOLOCK)), 0) + 1;

	-- === TABLA TEMPORAL PARA GUÍAS A ACTUALIZAR ===
	CREATE TABLE #ToUpdate (
		_Series NVARCHAR(50),
		_Number INT,
		_StatusOrderId INT,
		PRIMARY KEY CLUSTERED (_Series, _Number)
	);

	-- Insertar guías con StatusOrderId = 11
	INSERT INTO #ToUpdate (_Series, _Number, _StatusOrderId)
	SELECT DISTINCT 
		do.Guide_Serie,
		do.Guide_Number,
		11
	FROM DeliveryOrderDetail do WITH(NOLOCK)
	LEFT JOIN SMS_Sent ss WITH(NOLOCK) 
		ON do.Guide_Serie = ss.Sent_Guide_Series 
		AND do.Guide_Number = ss.Sent_Guide_Number
	WHERE do.DateCreatedInSystem >= @LastUpdate
		AND CAST(do.DateCreatedInSystem AS DATE) >= @DateCutoff
		AND do.StatusOrderId = 11 
		AND (@ElementId = 1001 OR @ElementId = 1002) 
		AND ISNULL(ss.SentTypeStatus, 0) = 0 
		AND ISNULL(ss.Sent, 0) = 0
		AND NOT EXISTS (
			SELECT 1 FROM DeliveryOrderDetail DOR2 WITH(NOLOCK)
			WHERE do.Guide_Serie = DOR2.Guide_Serie
				AND do.Guide_Number = DOR2.Guide_Number
				AND DOR2.StatusOrderId IN (5,7,22,30,14,24,25)
				AND do.RowStatus = 1
		)
		AND NOT EXISTS (
			SELECT 1 FROM SMS_Sent SS2 WITH(NOLOCK)
			WHERE SS2.Sent_Guide_Series = do.Guide_Serie
				AND SS2.Sent_Guide_Number = do.Guide_Number
				AND ISNULL(SS2.SentTypeStatus, 0) IN (0,1,2,3)
		);

	-- Insertar guías con StatusOrderId = 4 (solo las que no existen ya)
	INSERT INTO #ToUpdate (_Series, _Number, _StatusOrderId)
	SELECT DISTINCT
		DO.Guide_Serie,
		DO.Guide_Number,
		4
	FROM DeliveryOrder DO WITH (NOLOCK)
	INNER JOIN DeliveryOrderDetail DOD WITH(NOLOCK)
		ON DO.Guide_Serie = DOD.Guide_Serie
		AND DO.Guide_Number = DOD.Guide_Number
	WHERE DOD.DateCreatedInSystem >= @LastUpdate
		AND CAST(DOD.DateCreatedInSystem AS DATE) >= @DateCutoff
		AND DOD.StatusOrderId = 4
		AND NOT EXISTS (
			SELECT 1 FROM #ToUpdate tu 
			WHERE tu._Series = DO.Guide_Serie 
			AND tu._Number = DO.Guide_Number
		);

	-- === TABLA TEMPORAL PARA DATOS PRINCIPALES ===
	CREATE TABLE #PhoneBook (
		FirstName NVARCHAR(300),
		LastName NVARCHAR(300),
		Phone NVARCHAR(500),
		Address NVARCHAR(600),
		Town NVARCHAR(100),
		Department NVARCHAR(100),
		ReceiverID INT,
		DeliveryDate DATETIME,
		Series NVARCHAR(25),
		Number INT,
		OriginName NVARCHAR(100),
		Link NVARCHAR(100),
		LandingLink NVARCHAR(200),
		IdCountry NVARCHAR(2),
		StatusOrderId INT,
		DeliveryETA DATETIME,
		CustomerName NVARCHAR(150),
		Courier NVARCHAR(150),
		TypeVehicle NVARCHAR(200),
		InsuranceAmount NVARCHAR(300),
		Currency NVARCHAR(300),
		Amount NVARCHAR(300),
		CODAmount NVARCHAR(300),
		VehicleType NVARCHAR(300),
		VehiclePlate NVARCHAR(300),
		NirPhone NVARCHAR(3),
		RegxMovilPhone NVARCHAR(50),
		WhatsappNumber NVARCHAR(15)
	);

	-- === INSERTAR DATOS UNA SOLA VEZ ===
	INSERT INTO #PhoneBook
	SELECT DISTINCT
		IIF(do.Receiver_FirstName = '', do.Receiver_Alternant_FullName, do.Receiver_FirstName),
		do.Receiver_LastName,
		do.Receiver_Phone,
		do.Receiver_Address,
		do.Receiver_Town,
		do.Receiver_Department,
		do.Receiver_ID,
		do.Delivery_Max_Date,
		do.Guide_Serie,
		do.Guide_Number,
		RTRIM(LTRIM(ISNULL(do.Sender_FirstName + ' ' + do.Sender_LastName, ''))),
		' https://forzadelivery.com/rastreo/' + do.Guide_Serie + CONVERT(VARCHAR, do.Guide_Number),
		IIF(SDFG.GuideToken IS NOT NULL, CONCAT(' https://forzadelivery.io/', SDFG.GuideToken), ''),
		ISNULL(do.SenderCountryId, 'GT'),
		tu._StatusOrderId,
		CASE
			WHEN SO.OrderDescription = 'Entregado' THEN 
				ISNULL((SELECT TOP 1 CAST(DateCreated AS DATE) FROM DeliveryOrderDetail D WITH (NOLOCK) 
						WHERE D.Guide_Serie = DO.Guide_Serie AND D.Guide_Number = DO.Guide_Number 
						ORDER BY D.DateCreated DESC), CAST(GETDATE() AS DATE))
			WHEN SO.OrderDescription = 'En ruta' AND DO.DeliveryETA < GETDATE() THEN 
				CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)
			WHEN SO.OrderDescription = 'En ruta' THEN 
				CAST(GETDATE() AS DATE)
			WHEN SO.OrderDescription != 'En ruta' AND DO.DeliveryETA > GETDATE() THEN 
				ISNULL(CAST(DO.DeliveryETA AS DATE), CAST(GETDATE() AS DATE))
			ELSE 
				ISNULL(CAST(DO.DeliveryETA AS DATE), CAST(GETDATE() AS DATE))
		END,
		CASE 
			WHEN CS.IdCustomerType = 1 THEN COALESCE(tbl.UsrNickName, '')
			ELSE COALESCE(VPC.DescriptionOfClient, '') 
		END,
		CONCAT(SR.First_Name, ' ', SR.Last_Name),
		CONCAT('en el vehículo tipo *', CTV.Name, '* con placa *', CVE.Plate, '*.'),
		CASE
			WHEN DO.IsCollect = 1 THEN
				CONCAT('Debes cancelar el Monto *', CCU.Symbol, '.', 
					(DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)), 
					'* al recibir tu paquete o en la opción de pagar envío.')
			WHEN CS.IdCustomerType = @CustomerCorporative AND CCD.IdConditionOfPayment != @ConditionPayment THEN ' '
			WHEN (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)) > 0 THEN
				CONCAT('Debes cancelar el Monto *', CCU.Symbol, '.', 
					(DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)), 
					'* al recibir tu paquete o en la opción de pagar envío.')
			ELSE ' '
		END,
		CCU.Symbol,
		(DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)),
		CO.CODAmount,
		CTV.Name,
		CVE.Plate,
		DPC.PrefixNumber,
		DPC.RegxMovilPhone,
		DPC.WhatsappNumber
	FROM DeliveryOrder do WITH(NOLOCK)
	INNER JOIN #ToUpdate tu ON do.Guide_Serie = tu._Series AND do.Guide_Number = tu._Number
	LEFT JOIN DeliveryOrderDetail DOD WITH (NOLOCK) 
		ON tu._Series = DOD.Guide_Serie 
		AND tu._Number = DOD.Guide_Number
		AND DOD.StatusOrderId = tu._StatusOrderId
	LEFT JOIN VisitPointClient VPC WITH(NOLOCK) ON VPC.CodeOfReference = do.Sender_ID
	LEFT JOIN ServiceDataForGuide SDFG WITH(NOLOCK) 
		ON do.Guide_Serie = SDFG.GuideSerie 
		AND do.Guide_Number = SDFG.GuideNumber 
		AND SDFG.IsDelivery = 1 AND SDFG.IsInRoute = 0
	INNER JOIN StatusOrder SO WITH (NOLOCK) ON SO.StatusOrderId = DO.StatusOrderId
	LEFT JOIN DeliverySettlementDetail DSD WITH(NOLOCK)
		ON DO.Guide_Serie = DSD.Guide_Serie AND DO.Guide_Number = DSD.Guide_Number
	LEFT JOIN DeliveryOrderBySettlement DOS WITH(NOLOCK) ON DSD.ID_DeliveryOrderBySettlement = DOS.ID
	LEFT JOIN CatVehicle CVE WITH(NOLOCK) ON DOS.CatVehicleId = CVE.IdVehicle
	LEFT JOIN SenderReceiver SR WITH(NOLOCK) ON SR.ID = DOS.ID_Courier
	LEFT JOIN CatTypeVehicle CTV WITH(NOLOCK) ON CVE.IdTypeVehicle = CTV.IdTypeVehicle
	LEFT JOIN Customer CS WITH(NOLOCK) ON DO.IdCustomer = CS.IdCustomer
	LEFT JOIN CatConditionOfPayment CCD WITH (NOLOCK) ON CS.ConditionOfPaymentID = CCD.IdConditionOfPayment
	INNER JOIN DeliveryCurrency DC WITH(NOLOCK) ON DO.SenderCountryId = DC.Currency_IdCountry
	INNER JOIN CatCurrencyCOD CCU WITH(NOLOCK) ON CCU.IdCatCurrencyCOD = DC.IdCurrencyCOD
	LEFT JOIN Cost CO WITH(NOLOCK) ON DO.Guide_Serie = CO.GuideSerie AND DO.Guide_Number = CO.GuideNumber
	LEFT JOIN DefaultValuesPerCountry DPC WITH(NOLOCK) ON DO.ReceiverCountryId = DPC.IdCountry
	OUTER APPLY (
		SELECT TOP 1 UsrNickName 
		FROM Account A1 WITH(NOLOCK)
		LEFT JOIN RolByUserByAccount A2 WITH(NOLOCK) ON A1.AccIdAccount = A2.RuaIdAccount AND A2.RuaRowStatus = 1
		LEFT JOIN RegisterUser A3 WITH(NOLOCK) ON A3.UsrIdUser = A2.RuaIdUser AND A3.UsrRowStatus = 1
		WHERE A1.IdCustomer = CS.IdCustomer AND A1.AccRowStatus = 1
	) tbl
	WHERE CS.IdCustomerType <> @CustomerCorporative
		AND DC.DefaultPerCountry = 1
		AND DOD.StatusOrderId IS NOT NULL
		AND NOT EXISTS (
			SELECT 1 FROM SMS_Sent SS2 WITH(NOLOCK)
			WHERE SS2.Sent_Guide_Series = do.Guide_Serie
				AND SS2.Sent_Guide_Number = do.Guide_Number
				AND SS2.StatusOrderId = tu._StatusOrderId
		);

	-- === RESULTADO FINAL CON FORMATEO OPTIMIZADO ===
	SELECT
		pb.FirstName,
		pb.LastName,
		-- Formateo limpio del teléfono
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			LTRIM(RTRIM(pb.Phone)), '''', ';'), '"', ';'), ' ', ';'), '/', ';'), ',', ';'),
			'-', CASE WHEN CHARINDEX('-', LTRIM(RTRIM(pb.Phone))) > 8 THEN ';' ELSE '' END
		) AS Phone,
		-- Formateo optimizado de dirección usando variables derivadas
		LEFT(
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				LTRIM(RTRIM(pb.Address)), 
				'  ', ' '), ' , ', ','), ', ', ','), ' ,', ','), 'zona ', 'z'), 
				'avenida', 'Ave.'), ',' + pb.Department, ''), 'colonia', 'col.'), 
				'Residencial', 'Resid.'), 'carretera', 'ctra.'), 'manzana', 'mz.'),
			45
		) AS Address,
		pb.Town,
		pb.Department,
		pb.ReceiverID,
		pb.DeliveryDate,
		@TopBatchId AS TopBatchId,
		pb.Series,
		pb.Number,
		pb.OriginName,
		pb.Link,
		pb.LandingLink,
		pb.IdCountry,
		pb.StatusOrderId,
		pb.DeliveryETA,
		pb.CustomerName,
		pb.Courier,
		pb.TypeVehicle,
		pb.InsuranceAmount,
		pb.Currency,
		pb.Amount,
		pb.CODAmount,
		pb.VehicleType,
		pb.VehiclePlate,
		pb.NirPhone,
		pb.RegxMovilPhone,
		pb.WhatsappNumber
	FROM #PhoneBook pb;

	-- === INSERT EN SMS_SENT ===
	INSERT INTO SMS_Sent (
		Sent_Guide_Series,
		Sent_Guide_Number,
		SentTypeStatus,
		Sent_Batch_Id,
		TokenCreated,
		CreatedDatetime,
		StatusOrderId
	)
	SELECT
		Series,
		Number,
		0,
		@TopBatchId,
		'SYS-SMSService',
		GETDATE(),
		StatusOrderId
	FROM #PhoneBook;

	-- === LIMPIAR TABLAS TEMPORALES ===
	DROP TABLE #ToUpdate;
	DROP TABLE #PhoneBook;

	-- === ACTUALIZACIÓN FINAL ===
	UPDATE SMS_UpdatedElements
	SET UpdateStatus = 0
	WHERE ElementId = @ElementId;

END
go

