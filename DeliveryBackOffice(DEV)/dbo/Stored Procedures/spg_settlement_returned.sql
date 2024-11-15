

-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-11-24>
-- Description:	<Recupera información para generar manifiesto de liquidación (devoluciones)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_returned]
		@IdManifest INT
AS
BEGIN
	
	DECLARE @GuideCount INT

	SET NOCOUNT ON;

	SET @GuideCount = (
		SELECT 
			COUNT(dobs.Guides_Received)
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd  WITH(NOLOCK) 
		   ON dsd.ID_DeliveryOrderBySettlement = dobs.ID 
		--AND dsd.RowStatus = 1
		WHERE dobs.ID = @IdManifest
		AND dsd.Guide_Settlement = 1 -- guía liquidada en bodega
		AND dsd.Guide_Returned = 1  -- guía liquidada vía material devuelto
		AND dsd.Guide_Delivered = 0  -- guía liquidada vía comprobante de entrega
		AND dsd.RowStatus = 1
	)

	SELECT 
			dobs.ID, 
			dobs.Date_Received, 
			--dobs.Pieces_Dry_Received, 
			--dobs.Pieces_Cold_Received, 
			@GuideCount as Guides_Received,
			isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Name,
			dobs.Route_Received,
			CONVERT(NVARCHAR,lbt.SSN_IdUser) + ' - ' + lbt.SSN_Username as IdUser_Username_Received
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] dobs WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr WITH(NOLOCK) ON sr.ID = dobs.ID_Courier
		INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt WITH (NOLOCK) ON lbt.SSN_IdToken = dobs.User_Received
		WHERE dobs.ID = @IdManifest

END