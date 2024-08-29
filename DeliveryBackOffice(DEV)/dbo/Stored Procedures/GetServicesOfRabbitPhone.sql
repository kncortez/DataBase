-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-16>
-- Description:	< Recupera datos de los servicios asignados a un piloto de Rabbit >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-02-21>
-- Description:	< Adición de WITH(NOLOCK) para evitar posibles bloqueos >
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-06-13>
-- Description: < Se agrego el filtro para obtener unicamente datos por pais, por defecto GT>
-- =============================================

CREATE PROCEDURE [dbo].[GetServicesOfRabbitPhone]
    @Phone NVARCHAR(50) = 'Guatemala',
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

    DECLARE @Guides TABLE
    (
        Guide_Serie NVARCHAR(2)
      , Guide_Number INT
      , Guide_Settled BIT
    );

    BEGIN TRY

		-- GUÍAS ASOCIADAS
		INSERT INTO @Guides
			(Guide_Serie, Guide_Number, Guide_Settled)
		SELECT 
			DISTINCT
				dop.GuideSerie
				, dop.GuideNumber
				, IIF(spd.SettlementDate IS NULL, 0 , 1 )
		FROM 
			dbo.SenderReceiver sr WITH(NOLOCK)
			INNER JOIN 
				dbo.SettlementPickupStation sps WITH(NOLOCK)
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			INNER JOIN 
				dbo.SettlementPickupStationDetail spd WITH(NOLOCK)
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			INNER JOIN 
				dbo.ServiceManagement srv WITH(NOLOCK)
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			INNER JOIN 
				dbo.SchedulePickup scp WITH(NOLOCK)
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			INNER JOIN 
				dbo.DeliveryOrderPaymentDetail dop WITH(NOLOCK)
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			INNER JOIN 
				dbo.DeliveryOrder ord WITH(NOLOCK)
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK)
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE (sr.Phone LIKE '%' + @Phone + '%'
				OR
			  [sr].[UniqueCode] = @Phone)
              AND IIF(ord.SenderCountryId IS NULL, 'GT', ord.SenderCountryId) = @IdCountry

		-- TABLAS A DEVOLVER
		-- DATOS DE COURIER
		SELECT SR.ID , CONCAT( SR.First_Name, ' ',SR.Last_Name) Courier FROM dbo.SenderReceiver sr WITH(NOLOCK)
		WHERE (sr.Phone LIKE '%' + @Phone + '%'
				OR
			  [sr].[UniqueCode] = @Phone)
          AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry

		-- DATOS DE SERVICIOS
		SELECT
			srv.IdServiceManagement
			, scp.SenderName 'Sender_FirstName'
			, CSS.Name
			, spd.SettlementDate
			, COUNT(DISTINCT ord.Guide_Number) totalGuides
			, ISNULL(SUM(ord.Pieces_Dry + ord.Pieces_Cold),0) totalPieces
			, IIF(srv.ServiceStatusId = 3,MAX(spd.Price),0) Price
		FROM 
			dbo.SenderReceiver sr WITH(NOLOCK)
			LEFT JOIN 
				dbo.SettlementPickupStation sps WITH(NOLOCK)
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			LEFT JOIN 
				dbo.SettlementPickupStationDetail spd WITH(NOLOCK)
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			LEFT JOIN 
				dbo.ServiceManagement srv WITH(NOLOCK)
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			LEFT JOIN 
				dbo.SchedulePickup scp WITH(NOLOCK)
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			LEFT JOIN 
				dbo.DeliveryOrderPaymentDetail dop WITH(NOLOCK)
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			LEFT JOIN 
				dbo.DeliveryOrder ord WITH(NOLOCK)
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
					AND
					ord.StatusOrderId = 2
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK)
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE (sr.Phone LIKE '%' + @Phone + '%'
				OR
			  [sr].[UniqueCode] = @Phone)
              AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry
		AND spd.SettlementDate IS NULL
		GROUP BY
			srv.IdServiceManagement
			, scp.SenderName
			, srv.ServiceStatusId
			, CSS.Name
			, spd.SettlementDate

        -- TOTALES
        -- total de guías reconocidas
        SELECT COUNT(1) 'TotalGuias'
        FROM @Guides G
        WHERE G.Guide_Settled = 0;

		-- LISTAR PIEZAS DE GUÍAS
		-- Se listan las piezas las cuales no han sido liquidadas
		SELECT
			dop.GuideSerie
			, dop.GuideNumber
			, ordp.NoPiece
			, CONCAT (dop.GuideSerie, dop.GuideNumber, '-', ordp.NoPiece) Guide
			, (
				CASE
					WHEN srv.ServiceStatusId = 3 AND ord.StatusOrderId = 2 THEN srv.ServiceStatusId
					WHEN srv.ServiceStatusId = 4 THEN srv.ServiceStatusId
					ELSE 2
				END
			) 'ServiceStatusId'
			, ISNULL(spd.Price,0) Price
			, srv.IdServiceManagement
		FROM 
			dbo.SenderReceiver sr WITH(NOLOCK)
			INNER JOIN 
				dbo.SettlementPickupStation sps WITH(NOLOCK)
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			INNER JOIN 
				dbo.SettlementPickupStationDetail spd WITH(NOLOCK)
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			INNER JOIN 
				dbo.ServiceManagement srv WITH(NOLOCK)
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			INNER JOIN 
				dbo.SchedulePickup scp WITH(NOLOCK)
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			INNER JOIN 
				dbo.DeliveryOrderPaymentDetail dop WITH(NOLOCK)
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			INNER JOIN 
				dbo.DeliveryOrder ord WITH(NOLOCK)
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
			LEFT JOIN 
				DeliveryOrderPiece ordp WITH(NOLOCK)
				ON 
					ord.Guide_Number = ordp.GuideNumber
					AND 
					ord.Guide_Serie = ordp.GuideSerie
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK)
				ON
					srv.ServiceStatusId = CSS.IdServiceStatus
		WHERE (sr.Phone LIKE '%' + @Phone + '%'
				OR
			  [sr].[UniqueCode] = @Phone)
		and
		spd.SettlementDate is null
        AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry

		-- MANIFIESTO
		SELECT
			sps.IdSettlementPickupStation idManifest
		FROM 
			dbo.SenderReceiver sr WITH(NOLOCK)
			INNER JOIN 
				dbo.SettlementPickupStation sps WITH(NOLOCK) 
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
		WHERE (sr.Phone LIKE '%' + @Phone + '%'
				OR
			  [sr].[UniqueCode] = @Phone)
          AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry

		-- Totales de piezas por guía las cuales no han sido liquidadas
		SELECT DISTINCT
			dop.GuideSerie
			, dop.GuideNumber
			, (ord.Pieces_Dry + ord.Pieces_Cold) 'Pieces'
		FROM 
			dbo.SenderReceiver sr WITH(NOLOCK)
			INNER JOIN 
				dbo.SettlementPickupStation sps WITH(NOLOCK)
				ON 
					sps.CouriermanId = sr.ID 
					AND 
					sps.TransactionDate  = CONVERT(DATE,GETDATE())
					AND
					sps.RowStatus = 1
			INNER JOIN 
				dbo.SettlementPickupStationDetail spd WITH(NOLOCK)
				ON 
					spd.SettlementPickupStationId = sps.IdSettlementPickupStation
					AND
					spd.RowStatus = 1
			INNER JOIN 
				dbo.ServiceManagement srv WITH(NOLOCK)
				ON 
					srv.IdServiceManagement = spd.ServiceManagementId
			INNER JOIN 
				dbo.SchedulePickup scp WITH(NOLOCK)
				ON 
					scp.SchedulePickupId = srv.IdSchedulePickup
			INNER JOIN 
				dbo.DeliveryOrderPaymentDetail dop WITH(NOLOCK)
				ON 
					dop.IdHeaderRecolection = scp.SchedulePickupId
			INNER JOIN 
				dbo.DeliveryOrder ord WITH(NOLOCK)
				ON 
					ord.Guide_Serie = dop.GuideSerie
					AND 
					ord.Guide_Number = dop.GuideNumber
		WHERE (sr.Phone LIKE '%' + @Phone + '%'
				OR
			  [sr].[UniqueCode] = @Phone)
		and
		spd.SettlementDate is null
        AND IIF(sr.IdCountry IS NULL, 'GT', sr.IdCountry) = @IdCountry

    END TRY
    BEGIN CATCH

        SELECT 0                 [blnResult]
             , ERROR_NUMBER()    AS [ErrorNumber]
             , ERROR_SEVERITY()  AS [ErrorSeverity]
             , ERROR_STATE()     AS [ErrorState]
             , ERROR_PROCEDURE() AS [ErrorProcedure]
             , ERROR_LINE()      AS [ErrorLine]
             , ERROR_MESSAGE()   AS [ErrorMessage];

    END CATCH;

END;