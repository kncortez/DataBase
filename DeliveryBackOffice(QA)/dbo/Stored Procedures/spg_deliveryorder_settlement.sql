

-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-09-17>
-- Description:	<Recupera información para generar manifiesto de despacho>
-- =============================================
CREATE PROCEDURE [dbo].[spg_deliveryorder_settlement]
		@IdManifest INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT 
		dobs.ID, 
		dobs.Date_Dispatched, 
		dobs.Pieces_Dry_Dispatched, 
		dobs.Pieces_Cold_Dispatched, 
		dobs.Guides_Dispatched,
		sr.First_Name + ' ' + sr.Last_Name as Courier_Name,
		dobs.Route_Dispatched,
		CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Dispatched
	FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs
	LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = dobs.ID_Courier
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdToken = dobs.User_Dispatched
	WHERE dobs.ID = @IdManifest

END
