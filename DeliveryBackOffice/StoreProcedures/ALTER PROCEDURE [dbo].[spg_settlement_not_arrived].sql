USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_settlement_not_arrived]    Script Date: 11/02/2022 09:42:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-11>
-- Description:	<Recupera información para generar manifiesto de liquidación (entregas)>
-- =============================================
ALTER PROCEDURE [dbo].[spg_settlement_not_arrived]
		@IdManifest INT
AS
BEGIN

	DECLARE @GuideCount INT
	SET NOCOUNT ON;
	
	SET @GuideCount = (
		SELECT 
			COUNT(dobs.GuidesQuantity)
		FROM [DeliveryBackOffice].[dbo].[SettlementByPickup] dobs
		JOIN DeliveryBackOffice.dbo.SettlementByPickupDetail dsd ON dsd.SettlementByPickupId = dobs.Id
		WHERE dobs.ID = @IdManifest
		AND dsd.IsPieceLiquidaded != 1 ) -- guía y pieza no liquidada

	select sbp.Id as ID, sbp.DatePrinted AS Dateprinted, @GuideCount as CountGuide ,
		isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name,
			sbp.DatePrinted as DatePintedUser,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received,
			cr.CodeRoute
		from DeliveryOrder ord
		left join DeliveryOrderPiece dop on (ord.Guide_Serie = dop.GuideSerie and ord.Guide_Number = dop.GuideNumber)
		left join SettlementByPickupDetail sbpd on (sbpd.GuideNumber = dop.GuideNumber and sbpd.GuideSerie = dop.GuideSerie and sbpd.NoPiece = dop.NoPiece)
		left join SettlementByPickup sbp on (sbpd.SettlementByPickupId = sbp.Id)
		left join SenderReceiver sr on (sr.ID = sbp.IdCourier)
			JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = sbp.TokenCreated
				join RouteAssigment rs on (rs.IdRouteAssigment = sbp.RouteAssigmentId)
			join CatRoute cr on (cr.IdRoute = rs.IdRoute )
		where  sbp.Id = @IdManifest -- and dop.IsPickup is null or dop.IsPickup = 0
		group by sbp.Id, sbp.DatePrinted, sr.First_Name, sr.Last_Name, sbp.DatePrinted, lbt.SSN_IdUser, lbt.SSN_Username, cr.CodeRoute

	SET NOCOUNT OFF;
END