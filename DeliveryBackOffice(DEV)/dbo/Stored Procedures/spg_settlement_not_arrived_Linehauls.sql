
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-11>
-- Description:	<Recupera información para generar manifiesto de liquidación (entregas)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_not_arrived_Linehauls]
		@IdManifest INT
AS
BEGIN

	declare @manifestsequence int = (select Id from SettlementByPickup where SequenceCode = @IdManifest and SubTypeServiceManagmentId = 4)

	select sbp.SequenceCode as ID, sbp.DatePrinted AS Dateprinted, count(ord.Guide_Number) as CountGuide ,
		isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name,
			sbp.DatePrinted as DatePintedUser,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received,
			cr.CodeRoute
		from DeliveryOrder ord
		left join DeliveryOrderPiece dop on (ord.Guide_Serie = dop.GuideSerie and ord.Guide_Number = dop.GuideNumber)
		left join SettlementByPickupDetail sbpd on (sbpd.GuideNumber = dop.GuideNumber and sbpd.GuideSerie = dop.GuideSerie and sbpd.NoPiece = dop.NoPiece)
		left join SettlementByPickup sbp on (sbpd.SettlementByPickupId = sbp.Id)
		left join SenderReceiver sr on (sr.ID = sbp.IdCourier)
			JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK) ON lbt.SSN_IdToken = sbp.TokenCreated
				join RouteAssigment rs on (rs.IdRouteAssigment = sbp.RouteAssigmentId)
			join CatRoute cr on (cr.IdRoute = rs.IdRoute )
		where  sbp.Id = @manifestsequence -- and dop.IsPickup is null or dop.IsPickup = 0
		group by sbp.SequenceCode, sbp.DatePrinted, sr.First_Name, sr.Last_Name, sbp.DatePrinted, lbt.SSN_IdUser, lbt.SSN_Username, cr.CodeRoute

END


