USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[GetTrackedRouteDetail]    Script Date: 02/12/2021 10:41:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-01>
-- Description:	< Retorna el detalle de la ruta tomando en cuenta el manifiesto >
-- =============================================
CREATE PROCEDURE [dbo].[GetTrackedRouteDetail]
	@Manifest BIGINT,
	@RouteName NVARCHAR(25),
	@ServiceType BIGINT = 2
AS
BEGIN

	SELECT
		CONCAT(DO.Guide_Serie,DO.Guide_Number) 'Guide'
		,COUNT(DISTINCT DOP.NoPiece) 'TotalPieces'
		,SUM(
			CASE
				WHEN DO.IsCollect = 1 THEN DO.PriceShippment
				ELSE 0
			END
		) 'ServiceCharge'
		,MAX(DO.Collect_OnDelivery) 'CoDCharge'
		,COUNT( DISTINCT DOA.IdDeliveryOrderAlert ) 'TotalAlerts'
		,SO.OrderDescription 'Status'
	FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS
	JOIN
	[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD
	ON
	DOBS.ID = DSD.ID_DeliveryOrderBySettlement
	JOIN
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
	ON
	DSD.Guide_Serie = DO.Guide_Serie
	AND
	DSD.Guide_Number = DO.Guide_Number
	JOIN
	[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP
	ON
	DO.Guide_Serie = DOP.GuideSerie
	AND
	DO.Guide_Number = DOP.GuideNumber
	LEFT JOIN
	[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
	ON
	DO.Guide_Serie = DOA.GuideSerie
	AND
	DO.Guide_Number = DOA.GuideNumber
	AND
	DOA.ServiceTypeId = @ServiceType
	AND
	DOA.RowStatus = 1
	JOIN
	[DeliveryBackOffice].[dbo].[StatusOrder] SO
	ON
	DO.StatusOrderId = SO.StatusOrderId
	WHERE
	DOBS.ID = @Manifest
	AND
	REPLACE(ISNULL(DO.Courier_Route,'N/A'),' ','') = REPLACE(@RouteName,' ','')
	GROUP BY
	DO.Guide_Serie
	,DO.Guide_Number
	,SO.OrderDescription

END
GO


