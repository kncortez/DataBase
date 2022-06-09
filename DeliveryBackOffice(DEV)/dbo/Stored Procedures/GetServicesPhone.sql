


-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-16>
-- Description:	< Recupera datos de los servicios asignados a un piloto de Rabbit >
-- =============================================

CREATE PROCEDURE [dbo].[GetServicesPhone]
    @Phone NVARCHAR(50) = 'Guatemala'
AS
BEGIN

	DECLARE @Guides TABLE (
		Guide_Serie NVARCHAR(2)
	   ,Guide_Number INT
	)

	BEGIN TRY

		-- GUÍAS ASOCIADAS
		INSERT INTO @Guides
			(Guide_Serie, Guide_Number)
		SELECT 
			DISTINCT
				dop.GuideSerie
				, dop.GuideNumber
		FROM 
			dbo.SenderReceiver sr
			JOIN 
				dbo.SettlementPickupStation sps 
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			JOIN 
				dbo.SettlementPickupStationDetail spd 
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			JOIN 
				dbo.ServiceManagement srv
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			JOIN 
				dbo.SchedulePickup scp 
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			JOIN 
				dbo.DeliveryOrderPaymentDetail dop 
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			JOIN 
				dbo.DeliveryOrder ord 
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE sr.Phone LIKE '%'+@Phone +'%'

		-- TABLAS A DEVOLVER
		-- DATOS DE COURIER
		SELECT SR.ID , CONCAT( SR.First_Name, ' ',SR.Last_Name) Courier FROM dbo.SenderReceiver sr
		WHERE sr.Phone LIKE '%'+@Phone +'%'

		-- DATOS DE SERVICIOS
		SELECT
			srv.IdServiceManagement
			, ord.Sender_FirstName 
			, CSS.Name
			, spd.SettlementDate
			, COUNT(DISTINCT ord.Guide_Number) totalGuides
			, SUM(ord.Pieces_Dry + ord.Pieces_Cold) totalPieces
			, IIF(srv.ServiceStatusId = 3,MAX(spd.Price),0) Price
		FROM 
			dbo.SenderReceiver sr
			JOIN 
				dbo.SettlementPickupStation sps 
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			JOIN 
				dbo.SettlementPickupStationDetail spd 
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			JOIN 
				dbo.ServiceManagement srv
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			JOIN 
				dbo.SchedulePickup scp 
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			JOIN 
				dbo.DeliveryOrderPaymentDetail dop 
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			JOIN 
				dbo.DeliveryOrder ord 
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE sr.Phone LIKE '%'+@Phone +'%'
		GROUP BY
			srv.IdServiceManagement
			, ord.Sender_FirstName
			, srv.ServiceStatusId
			, CSS.Name
			, spd.SettlementDate

		-- TOTALES
		-- total de guías reconocidas
		SELECT
			COUNT(1) 'TotalGuias'
		FROM
			@Guides

		-- LISTAR PIEZAS DE GUÍAS
		-- Se listan las piezas las cuales no han sido liquidadas
		SELECT
			dop.GuideSerie
			, dop.GuideNumber
			, ordp.NoPiece
			, CONCAT (dop.GuideSerie, dop.GuideNumber, '-', ordp.NoPiece) Guide
			, srv.ServiceStatusId
			, ISNULL(spd.Price,0) Price
			, srv.IdServiceManagement
		FROM 
			dbo.SenderReceiver sr
			JOIN 
				dbo.SettlementPickupStation sps 
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			JOIN 
				dbo.SettlementPickupStationDetail spd 
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			JOIN 
				dbo.ServiceManagement srv
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			JOIN 
				dbo.SchedulePickup scp 
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			JOIN 
				dbo.DeliveryOrderPaymentDetail dop 
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			JOIN 
				dbo.DeliveryOrder ord 
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
			LEFT JOIN 
				DeliveryOrderPiece ordp
				ON 
					ord.Guide_Number = ordp.GuideNumber
					AND 
					ord.Guide_Serie = ordp.GuideSerie
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE sr.Phone LIKE '%'+@Phone +'%'
		and
		spd.SettlementDate is null

		-- MANIFIESTO
		SELECT
			sps.IdSettlementPickupStation idManifest
		FROM 
			dbo.SenderReceiver sr
			JOIN 
				dbo.SettlementPickupStation sps 
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
		WHERE sr.Phone LIKE '%'+@Phone +'%'

		-- Totales de piezas por guía las cuales no han sido liquidadas
		SELECT DISTINCT
			dop.GuideSerie
			, dop.GuideNumber
			, (ord.Pieces_Dry + ord.Pieces_Cold) 'Pieces'
		FROM 
			dbo.SenderReceiver sr
			JOIN 
				dbo.SettlementPickupStation sps 
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			JOIN 
				dbo.SettlementPickupStationDetail spd 
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			JOIN 
				dbo.ServiceManagement srv
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			JOIN 
				dbo.SchedulePickup scp 
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			JOIN 
				dbo.DeliveryOrderPaymentDetail dop 
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			JOIN 
				dbo.DeliveryOrder ord 
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
		WHERE sr.Phone LIKE '%'+@Phone +'%'
		and
		spd.SettlementDate is null

	END TRY
	BEGIN CATCH

        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

	END CATCH

END;


/*




sgasgsgsdgasfasfsafasfasfasfasf
afasfasfasfsafasfasasfasfa
asfasfasf

sadgsgasgsdgasgasfa



sfasfasas
asgag



asgasgasgsag
asgasgasg
fasfasfa

sfasfsafasfas





sadgasdgasgsdg


*/