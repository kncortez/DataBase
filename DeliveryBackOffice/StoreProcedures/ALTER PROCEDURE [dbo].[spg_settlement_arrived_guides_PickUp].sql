USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_settlement_arrived_guides_PickUp]    Script Date: 19/08/2021 23:56:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--drop procedure  [dbo].[spg_settlement_returned_guides_PickUp]
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (PickUp)>
-- =============================================
ALTER PROCEDURE [dbo].[spg_settlement_arrived_guides_PickUp]
		@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Pieces_Cold int,
		Pieces_Dry int,
		Receiver_Fullname nvarchar(201),
		Receiver_Address nvarchar(600),
		Receiver_Zone int,
		Receiver_Town nvarchar(100),
		Receiver_Departament nvarchar(100),
		Preparation_Date nvarchar(50),
		Shipping_Date nvarchar(50),
		Max_Date nvarchar(50),
		Receiver_Phone nvarchar(100),
		Rack_Position nvarchar(MAX),
		Collect_on_Delivery decimal(16,2)
	)

    -- tablix content
	INSERT INTO @temp
	SELECT
	do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide_Code
	,(SELECT SUM(CAST([PiecesCold] AS INT)) FROM DeliveryBackOffice.dbo.SettlementByPickup sbp join SettlementByPickupDetail sbpd on (sbp.Id = sbpd.SettlementByPickupId) where  Id = @IdManifest and GuideSerie = do.Guide_Serie AND GuideNumber = do.Guide_Number AND sbpd.IsPieceLiquidaded = 1 GROUP BY GuideSerie,GuideNumber, Id) AS Pieces_Cold
	,(SELECT SUM(CAST([PiecesDry] AS INT)) FROM DeliveryBackOffice.dbo.SettlementByPickup sbp join SettlementByPickupDetail sbpd on (sbp.Id = sbpd.SettlementByPickupId) where Id = @IdManifest and GuideSerie = do.Guide_Serie AND GuideNumber = do.Guide_Number AND sbpd.IsPieceLiquidaded = 1 GROUP BY GuideSerie,GuideNumber, Id) as Pieces_Dry
	,isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as Receiver_Fullname
	,do.Receiver_Address AS Receiver_Address
	,CONVERT(INT, ISNULL(do.Receiver_Zone,0)) AS Receiver_Zone
	,do.Receiver_Town AS Receiver_Town
	,do.Receiver_Department AS  Receiver_Departament
	,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
	,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
	,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
	,do.Receiver_Phone as Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
	,Collect_OnDelivery
	FROM [DeliveryBackOffice].[dbo].DeliveryOrder do
	INNER JOIN (
		SELECT GuideSerie, GuideNumber 
		FROM [DeliveryBackOffice].[dbo].SettlementByPickupDetail
		WHERE SettlementByPickupId = @IdManifest 
		AND IsPieceLiquidaded = 1 -- Pieza de la guia liquidada
		GROUP BY GuideSerie, GuideNumber
	) dsd ON do.Guide_Serie = dsd.GuideSerie AND do.Guide_Number = dsd.GuideNumber

	SELECT * FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END
