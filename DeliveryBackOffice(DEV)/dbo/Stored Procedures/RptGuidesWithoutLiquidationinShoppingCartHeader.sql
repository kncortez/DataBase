-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-03-03>
-- Description:	<Description, SP para cabecera de reporte de guías que no estan liquidadas y no son collect>
-- =============================================
CREATE PROCEDURE [dbo].[RptGuidesWithoutLiquidationinShoppingCartHeader] 
@IdManifiesto int	
AS
BEGIN

	    DECLARE @TotalGuide int
	    DECLARE @temp TABLE (
		Liquidator	nvarchar(max),
		Courier nvarchar(201),	
		SettlementDate datetime,
        NumberofGuides int,
	    TotalAmount  Decimal(18,2)
	                         )
		DECLARE @GuideCount INT

	SET NOCOUNT ON;

	SET @GuideCount = (
		SELECT 
			COUNT(dobs.GuidesQuantity)
		FROM [DeliveryBackOffice].[dbo].[SettlementByPickup] dobs
		INNER JOIN 
		     [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] dsd 
		ON dsd.SettlementByPickupId = dobs.Id
		WHERE dobs.ID = @IdManifiesto
		AND dsd.IsPieceLiquidaded = 0 -- guía y pieza liquidada
	)


	     SET @TotalGuide= ( SELECT
									 
								Sum([DO].[PriceShippment])
							FROM
								[DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH(NOLOCK)
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
							ON
							    [DO].[Guide_Serie] = [AccSCD].[GuideSerie] AND [DO].[Guide_Number] = [AccSCD].[GuideNumber]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[Cost] Co WITH(NOLOCK)
							ON
								[Co].[GuideSerie] = [DO].[Guide_Serie] AND [Co].[GuideNumber] = [DO].[Guide_Number]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD
							ON  Co.GuideSerie = DSD.Guide_Serie And  Co.GuideNumber= DSD.Guide_Number
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH(NOLOCK)
							ON DSD.ID_DeliveryOrderBySettlement = DOBS.ID AND dsd.RowStatus = 1
							Inner Join   
							    [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] spd WITH(NOLOCK)
							ON   DO.Guide_Serie = spd.GuideSerie AND DO.Guide_Number = spd.GuideNumber
							INNER JOIN 
							    [DeliveryBackOffice].[dbo].[SettlementByPickup] sp WITH(NOLOCK)
			                ON spd.SettlementByPickupId = sp.Id
							WHERE  [AccSCD].[RowStatus] = 1 AND
								   [DO].[IsCollect] = 0 AND
								   [Co].[TotalAmountPaid] IS NULL AND
								   [sp].Id = @IdManifiesto 
							)

	-- tablix content
	INSERT INTO @temp


		SELECT 
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username,
			isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,''),
			dobs.DateCreated,
			@GuideCount,
			@TotalGuide
		FROM [DeliveryBackOffice].[dbo].[SettlementByPickup] dobs
		INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.IdCourier
		INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = dobs.TokenCreated
		INNER JOIN RouteAssigment ra on (ra.IdRouteAssigment = dobs.RouteAssigmentId)
		INNER JOIN CatRoute cr on (cr.IdRoute = ra.IdRoute)
		WHERE dobs.ID = @IdManifiesto
	





SELECT Liquidator,
       Courier,
	   SettlementDate,
	   NumberofGuides,
	   TotalAmount,
	   @IdManifiesto
FROM @temp
	order by SettlementDate desc

	


END