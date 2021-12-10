USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[GetRoutesToTrack]    Script Date: 10/12/2021 15:42:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-11-30>
-- Description:	< Retorna las rutas de un día tomando en cuenta el hub donde se genero el manifiesto >
-- =============================================
CREATE PROCEDURE [dbo].[GetRoutesToTrack]
	@Date DATE,
	@Hub TblExtPlatTextParameterList READONLY,
	@ServiceType BIGINT = 2
AS
BEGIN

	SELECT 
	CONCAT(SR.First_Name,' ',SR.Last_Name) 'Courier'
	,ISNULL(SH.HubAbbreviation,'N/A') 'Hub'
	,ISNULL(DO.Courier_Route,'N/A') 'Route'
	,DOBS.ID 'Manifest'
	,COUNT( DISTINCT DO.Guide_Number) 'TotalServices'
	,ISNULL(SUM( DOA.TotalCount),0) 'TotalAlerts'
	,COUNT( DISTINCT DO2.Guide_Number) 'TotalSuccessfulDeliveries'
	,SUM( 
		CASE 
			WHEN DO2.StatusOrderId IN (5,24,25) AND DO2.IsCollect = 1 THEN ISNULL(DO2.PriceShippment,0) + ISNULL(DO2.Collect_OnDelivery,0)
			WHEN DO2.StatusOrderId IN (5,24,25) THEN ISNULL(DO2.Collect_OnDelivery,0)
			ELSE 0
		END 
	) 'TotalConfirmedCharge'
	,SUM( 
		CASE 
			WHEN DO.IsCollect = 1 THEN ISNULL(DO.PriceShippment,0) + ISNULL(DO.Collect_OnDelivery,0)
			ELSE ISNULL(DO.Collect_OnDelivery,0)
		END 
	) 'TotalToCharge'
	FROM
	[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS
	LEFT JOIN
	[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD
	ON
	DOBS.ID = DSD.ID_DeliveryOrderBySettlement
	LEFT JOIN
	[DeliveryBackOffice].[dbo].[SenderReceiver] SR
	ON
	DOBS.ID_Courier = SR.ID
	JOIN
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
	ON
	DSD.Guide_Serie = DO.Guide_Serie
	AND
	DSD.Guide_Number = DO.Guide_Number
	LEFT JOIN
	(
		SELECT
		DISTINCT
		CS.IdStation
		,CS.StationName
		,HL.HubAbbreviation
		FROM
		[DeliveryBackOffice].[dbo].[CatStation] CS
		JOIN
		[DeliveryBackOffice].[dbo].[HubLogistics] HL
		ON
		CS.HubLogisticId = HL.IdHubLogistic
		UNION
		SELECT
		DISTINCT
		CS.IdStation
		,CS.StationName
		,DSC.Hub
		FROM
		[DeliveryBackOffice].[dbo].[CatStation] CS
		JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC
		ON
		CS.CodeOfReference = VPC.CodeOfReference
		JOIN
		[DeliveryBackOffice].[dbo].[Settlement] S
		ON
		VPC.IdSettlement = S.IdSettlement
		JOIN
		[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC
		ON
		S.IdSettlement = DSC.IdSettlement
	) SH -- Station Hub
	ON 
	DOBS.DispatchedStationId = SH.IdStation
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
	) DOA
	ON
	DSD.Guide_Serie = DOA.GuideSerie
	AND
	DSD.Guide_Number = DOA.GuideNumber
	LEFT JOIN
	[DeliveryBackOffice].[dbo].[DeliveryOrder] DO2 -- Guías las cuales se confirma su entrega y cobro
	ON
	DSD.Guide_Serie = DO2.Guide_Serie
	AND
	DSD.Guide_Number = DO2.Guide_Number
	AND
	DO2.StatusOrderId IN (5,24,25) -- Entregado|COD Liquidado|COD Pagado
	WHERE
	CAST(DOBS.Date_Dispatched AS DATE) = @Date
	AND
	REPLACE(ISNULL(SH.HubAbbreviation,'N/A'),' ','') IN (SELECT REPLACE(TextParameter,' ','') FROM @Hub)/*
	AND
	(
		REPLACE(ISNULL(DO.Courier_Route,'N/A'),' ','') = 'N/A'
		OR
		LEFT(REPLACE(ISNULL(DO.Courier_Route,'N/A'),' ',''),1) = 'U'
	)*/
	GROUP BY
	SR.First_Name
	,SR.Last_Name
	,SH.HubAbbreviation
	,DO.Courier_Route
	,DOBS.ID;


END
GO


