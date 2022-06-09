


-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-12-08>
-- Description:	<Recupera información para generar manifiesto de liquidación (COD)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_cod]
		@IdManifest INT
AS
BEGIN
	
	DECLARE @GuideCount INT

	SET NOCOUNT ON;

	SET @GuideCount = (
		SELECT 
			COUNT(dobs.Guides_Received_COD)
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs
		JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd ON dsd.ID_DeliveryOrderBySettlement = dobs.ID AND dsd.RowStatus = 1
		WHERE dobs.ID = @IdManifest
		AND dsd.Guide_Settlement = 1 -- guía liquidada en bodega
		AND dsd.Guide_Discharged = 1  -- guía liquidada vía COD
	)

	SELECT 
			dobs.ID, 
			dobs.Date_Received_COD as Date_Received, 
			--dobs.Pieces_Dry_Received, 
			--dobs.Pieces_Cold_Received, 
			@GuideCount as Guides_Received,
			isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name,
			dobs.Route_Received_COD as Route_Received,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received,
			(SELECT SUM(mdos.Quantity*cm.Value) TotalAmountCount
				FROM MoneyByDeliveryOrderBySettlement mdos
				INNER JOIN CatMoney cm
					ON mdos.CatMoneyId = cm.IdCatMoney
				WHERE DeliveryOrderBySettlementId = @IdManifest) Amount_Received,
			(SELECT Value
				FROM Contingency 
				WHERE DeliveryOrderBySettlementId = @IdManifest) Amount_Difference,
			cs.StationName Hub
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs
		JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.ID_Courier
		JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = dobs.User_Received_COD
		LEFT JOIN CatStation cs ON cs.IdStation = dobs.SettlementStationId  
		WHERE dobs.ID = @IdManifest

END
