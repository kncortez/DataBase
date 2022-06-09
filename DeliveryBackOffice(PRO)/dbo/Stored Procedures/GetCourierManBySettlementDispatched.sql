
-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2021-12-17>
-- Description:	<Obtiene información  del Courier Man si ya se genero manifiesto de despacho en el día actual>
-- =============================================
CREATE PROCEDURE [dbo].[GetCourierManBySettlementDispatched]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	SELECT TOP 1 sr.First_Name, sr.Last_Name, sr.CUI
	FROM DeliverySettlementDetail dsd
	JOIN DeliveryOrderBySettlement dobs 
		ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
	JOIN SenderReceiver sr
		ON dobs.ID_Courier = sr.ID
	WHERE dsd.RowStatus = 1 
		AND Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
		AND CONVERT(date,dobs.Date_Dispatched) = CONVERT(date, GETDATE())
	ORDER BY dobs.Date_Dispatched DESC
END