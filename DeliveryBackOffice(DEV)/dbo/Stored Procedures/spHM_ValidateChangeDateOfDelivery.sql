-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-07-29>
-- Description:	<SP para validar si una Guia tiene asignada otra fecha de entrega. Ref. FDAM-6>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_ValidateChangeDateOfDelivery]
 @GuideSerie NVARCHAR(2) = 'FD',
 @GuideNumber INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT rp.DateRoutePreparation 
	FROM [dbo].[DeliveryOrderBySettlement] dobs
		INNER JOIN [dbo].[RoutePreparation] rp ON dobs.ID = rp.DeliveryOrderBySettlementId
		INNER JOIN [dbo].[DeliverySettlementDetail] dsd ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
	WHERE dsd.Guide_Serie = @GuideSerie
		AND dsd.Guide_Number = @GuideNumber		
END;