
-- =============================================
-- Author:		<Michael, espinoza>
-- Create date: <2022-03-17>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================



CREATE PROCEDURE [dbo].[GetCourierPickupServices]
	@Token VARCHAR(200) ='',
	@Phone NVARCHAR(100)=''
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @jsonResult NVARCHAR(MAX);
	DECLARE @CourierData NVARCHAR(MAX);
	DECLARE @ServicesData NVARCHAR(MAX);
	DECLARE @GuidesData NVARCHAR(MAX);
	DECLARE @RaWPhone NVARCHAR(100)= (SELECT IIF( SUBSTRING(@Phone,0,5)='+502',SUBSTRING(@Phone,5,8),@Phone));
	DECLARE @IdCourier INT;
	DECLARE @CourierName NVARCHAR(100);
	DECLARE @AssignedServices BIGINT;
	DECLARE @AmountOfServices BIGINT;

	SELECT TOP 1 @IdCourier=SR.ID,@CourierName = CONCAT( ISNULL(SR.First_Name,''), ' ',ISNULL(SR.Last_Name,'')) FROM dbo.SenderReceiver sr WITH (NOLOCK) WHERE sr.Phone LIKE '%' +@RaWPhone+ '%';

	-- IF Courier exist in system
	IF (@IdCourier IS NOT NULL)

	BEGIN

	IF OBJECT_ID('tempdb.dbo.#RawServicesData', 'U') IS NOT NULL DROP TABLE #RawServicesData;

	SELECT
		srv.IdServiceManagement
		, scp.SenderName 'Sender_FirstName'
		,srv.ServiceStatusId
		, CSS.Name
		, COUNT(DISTINCT ord.Guide_Number) totalGuides
		, ISNULL(SUM(ord.Pieces_Dry + ord.Pieces_Cold),0) totalPieces
		, IIF(srv.ServiceStatusId = 3,MAX(spd.Price),0) Price
		INTO #RawServicesData
	FROM 
			dbo.SenderReceiver sr WITH (NOLOCK)
			INNER JOIN 
				dbo.SettlementPickupStation sps  WITH (NOLOCK)
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			LEFT JOIN 
				dbo.SettlementPickupStationDetail spd  WITH (NOLOCK)
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			LEFT JOIN 
				dbo.ServiceManagement srv WITH (NOLOCK)
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			LEFT JOIN 
				dbo.SchedulePickup scp WITH (NOLOCK)
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			LEFT JOIN 
				dbo.DeliveryOrderPaymentDetail dop WITH (NOLOCK)
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			LEFT JOIN 
				dbo.DeliveryOrder ord WITH (NOLOCK)
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH (NOLOCK)
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE sr.Phone LIKE '%' + @RaWPhone+ '%' 
		AND spd.SettlementDate IS NULL
		GROUP BY
			srv.IdServiceManagement
			, scp.SenderName
			, srv.ServiceStatusId
			, CSS.Name
			, spd.SettlementDate

	SET @AmountOfServices = (SELECT COUNT(1) FROM #RawServicesData);
	
	-- If Courier has Services associated to him/her route
	IF(@AmountOfServices>0)
	BEGIN 

	DECLARE @IdManifest BIGINT = (
	SELECT
			sps.IdSettlementPickupStation idManifest
		FROM 
			dbo.SenderReceiver sr WITH(NOLOCK)
			JOIN 
				dbo.SettlementPickupStation sps WITH(NOLOCK) 
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
		WHERE sr.Phone LIKE '%' + @RaWPhone+ '%' 
	)

	SET @CourierData = (SELECT STUFF(
	( 
							
		select 
		',{									
		"Courier":"' + @CourierName + '",'+
		'"ID":'+CONVERT(NVARCHAR(max),@IdCourier)+','+
		'"AssigmentDate":"'+CONVERT(NVARCHAR(max),CONVERT(DATE, GETDATE()))+'",'+
		'"AmountOfServices":'+CONVERT(NVARCHAR(max),@AmountOfServices)+','+
		'"IdManifest":'+CONVERT(NVARCHAR(max),@IdManifest)+''+
		+ '}' 			
		FOR XML PATH(''), TYPE
		).value('.', 'varchar(max)'),1,1,''
	))

	SET @ServicesData = (SELECT STUFF(
	(
	SELECT
			',
			{									
			"IdService":' + CONVERT(NVARCHAR(MAX), rsd.IdServiceManagement) + ','+
			'"Origin":"'+ISNULL(rsd.Sender_FirstName,'')+'",'+
			'"ServiceStatusID":'+CONVERT(NVARCHAR(MAX), rsd.ServiceStatusId)+','+
			'"ServiceDescription":"'+ISNULL(rsd.Name, '')+'",'+
			'"TotalGuides":'+CONVERT(NVARCHAR(MAX), rsd.totalGuides)+','+
			'"TotalPieces":'+CONVERT(NVARCHAR(MAX), rsd.totalPieces)+','+
			'"PendingToBill":'+CONVERT(NVARCHAR(MAX), rsd.Price)+''
			+ '}' 		
		FROM #RawServicesData rsd

		FOR XML PATH(''), TYPE
	).value('.', 'varchar(max)'),1,1,''
	)
	)

	SET @GuidesData = (SELECT STUFF(
	(
	SELECT
		',{									
			"Guide":"' + CONCAT (dop.GuideSerie, dop.GuideNumber, '-', ordp.NoPiece) + '",'+
			'"GuideStatus":'+CONVERT(NVARCHAR(MAX), srv.ServiceStatusId)+','+
			'"GuidePrice":'+CONVERT(NVARCHAR(MAX), ISNULL(spd.Price,0))+','+
			'"IdServiceManagement":'+CONVERT(NVARCHAR(MAX), ISNULL(srv.IdServiceManagement,0))+','+
			'"AmountPieces":'+ CONVERT(NVARCHAR(MAX),(ord.Pieces_Dry + ord.Pieces_Cold)) +''
		+ '}'
		FROM 
			dbo.SenderReceiver sr
			JOIN 
				dbo.SettlementPickupStation sps WITH (NOLOCK)
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			JOIN 
				dbo.SettlementPickupStationDetail spd WITH (NOLOCK)
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			JOIN 
				dbo.ServiceManagement srv WITH (NOLOCK)
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			JOIN 
				dbo.SchedulePickup scp  WITH (NOLOCK)
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			JOIN 
				dbo.DeliveryOrderPaymentDetail dop WITH (NOLOCK)
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			JOIN 
				dbo.DeliveryOrder ord WITH (NOLOCK)
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
			LEFT JOIN 
				DeliveryOrderPiece ordp WITH (NOLOCK)
				ON 
					ord.Guide_Number = ordp.GuideNumber
					AND 
					ord.Guide_Serie = ordp.GuideSerie
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH (NOLOCK)
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE sr.Phone LIKE '%' + @RaWPhone+ '%' 
		and
		spd.SettlementDate is null

		FOR XML PATH(''), TYPE

	).value('.', 'varchar(max)'),1,1,''
	)
	)

	SET @jsonResult = (SELECT STUFF(
	(
		select 
			',{									
			"CourierData":' + @CourierData + ','+
			'"ServicesData":['+@ServicesData+'],'+
			'"GuidesData":['+@GuidesData+'],'+
			'"Status": 200'
			+ '}' 			
			FOR XML PATH(''), TYPE
	).value('.', 'varchar(max)'),1,1,''
	)
	)

	END
	-- If there are not Services associated to courier
	ELSE

	BEGIN 

	SET @jsonResult = (SELECT STUFF(
	(
		select 
			',{									
			"Message":"No se encontraron servicios asignados.",'+
			'"Status": 400'
			+ '}' 			
			FOR XML PATH(''), TYPE
	).value('.', 'varchar(max)'),1,1,''
	)
	)

	END
	
	END
	-- IF Courier not exist in system
	ELSE
	
	BEGIN

	SET @jsonResult = (SELECT STUFF(
	(
		select 
			',{									
			"Message":"Teléfono no está asignado a un piloto, contacte soporte técnico.",'+
			'"Status": 400'
			+ '}' 			
			FOR XML PATH(''), TYPE
	).value('.', 'varchar(max)'),1,1,''
	)
	)

	END

	SELECT ('[' + @jsonResult +  ']') jsonResult

END





