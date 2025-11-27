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

	SELECT TOP 1 rp.DateRoutePreparation, rpd.IsCustomerReschedule
	FROM [dbo].[RoutePreparation] rp WITH(NOLOCK)
		INNER JOIN [dbo].[RoutePreparationDetail] rpd WITH(NOLOCK)
			ON rp.IdRoutePreparation = rpd.RoutePreparationId
	WHERE rpd.Guide_Serie = @GuideSerie
		AND rpd.Guide_Number = 	@GuideNumber	
		AND rp.RowStatus = 1
	ORDER BY rp.IdRoutePreparation DESC
END;