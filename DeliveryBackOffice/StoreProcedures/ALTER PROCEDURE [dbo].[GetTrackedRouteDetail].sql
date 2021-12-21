USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetTrackedRouteDetail]    Script Date: 20/12/2021 14:38:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-01>
-- Description:	< Retorna el detalle de la ruta tomando en cuenta el manifiesto >
-- =============================================
ALTER PROCEDURE [dbo].[GetTrackedRouteDetail]
	@Manifest BIGINT,
	@RouteName NVARCHAR(25) = '',
	@ServiceType BIGINT = 2
AS
BEGIN

	SELECT
		CONCAT(DO.Guide_Serie,DO.Guide_Number) 'Guide'
		,( DOP.TotalCount ) 'TotalPieces'
		,(
			CASE
				WHEN DO.IsCollect = 1 THEN DO.PriceShippment
				ELSE 0
			END
		) 'ServiceCharge'
		,(DO.Collect_OnDelivery) 'CoDCharge'
		,ISNULL( DOAC.TotalCount, 0 ) 'TotalAlerts'
		,ISNULL((
			SELECT TOP 1
				DOA.AlertDescription
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
			WHERE
				DOA.GuideSerie = DO.Guide_Serie
				AND
				DOA.GuideNumber = DO.Guide_Number
				AND
				DOA.ServiceTypeId = @ServiceType
				AND
				DOA.RowStatus = 1
			ORDER BY
				DOA.DateCreated DESC
		),'') 'AlertDescription'
		,SO.OrderDescription 'Status'
	FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS
	JOIN
	[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD
	ON
	DOBS.ID = DSD.ID_DeliveryOrderBySettlement
	AND DSD.RowStatus = 1
	JOIN
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
	ON
	DSD.Guide_Serie = DO.Guide_Serie
	AND
	DSD.Guide_Number = DO.Guide_Number
	JOIN
	(
		SELECT
			DOPA.GuideSerie
			,DOPA.GuideNumber
			,COUNT(DISTINCT DOPA.NoPiece) 'TotalCount'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOPA
		GROUP BY
			DOPA.GuideSerie
			,DOPA.GuideNumber
	) DOP
	ON
	DO.Guide_Serie = DOP.GuideSerie
	AND
	DO.Guide_Number = DOP.GuideNumber
	LEFT JOIN
	(
		SELECT
			DOAA.GuideSerie
			,DOAA.GuideNumber
			,COUNT(DISTINCT DOAA.IdDeliveryOrderAlert) 'TotalCount'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOAA
		WHERE
			DOAA.ServiceTypeId = 2 -- Entrega
			AND
			DOAA.RowStatus = 1
		GROUP BY
			DOAA.GuideSerie
			,DOAA.GuideNumber
	) DOAC
	ON
	DSD.Guide_Serie = DOAC.GuideSerie
	AND
	DSD.Guide_Number = DOAC.GuideNumber
	JOIN
	[DeliveryBackOffice].[dbo].[StatusOrder] SO
	ON
	DO.StatusOrderId = SO.StatusOrderId
	WHERE
	DOBS.ID = @Manifest
	/*AND
	REPLACE(ISNULL(DO.Courier_Route,'N/A'),' ','') = REPLACE(@RouteName,' ','')*/

END