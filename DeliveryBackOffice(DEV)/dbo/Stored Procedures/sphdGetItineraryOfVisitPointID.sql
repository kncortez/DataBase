-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-06-01>
-- Description:	<Obtener el itinerario de visita por id>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetItineraryOfVisitPointID]
	 -- Add the parameters for the stored procedure here
	@IdVisitPoint AS int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT vcf.IdVPConfiguration,
		   vcf.VisitPointID,
		   vcf.TransportCompanyID,
		   vcf.HubLogisticID,
		   vpf.IdVPFrequency,
		   vpf.SeasonID,
		   vpf.VisitsOnSunday,
		   vpf.VisitsOnMonday,
		   vpf.VisitsOnTuesday,
		   vpf.VisitsOnWednesday,
		   vpf.VisitsOnThursday,
		   vpf.VisitsOnFriday,
		   vpf.VisitsOnSaturday,
		   vpf.RowStatus,
		   vpi.IdVPItinerary,
		   vpi.DayOfVisit,
		   vpi.InitializationTimeOfVisit,
		   vpi.FinalizationTimeOfVisit,
		   vpi.OrderSequence,
		   vpi.RouteCodeID,
		   vpi.HubLogisticID [ItineraryHubLogisticsID],
		   vpi.RowStatus [ItineraryRowStatus],
		   ROW_NUMBER() OVER(PARTITION BY vpi.dayofvisit order by vpi.DateCreated asc) AS RowNumber
	FROM dbo.VisitPointConfiguration vcf
		JOIN dbo.VisitPointFrequency vpf
			ON vpf.VPConfigurationID = vcf.IdVPConfiguration
			   AND vpf.RowStatus = 'true'
		JOIN dbo.VisitPointItinerary vpi
			ON vpi.VPFrequencyID = vpf.IdVPFrequency
				AND vpi.RowStatus = 'true'
	WHERE vcf.VisitPointID = @IdVisitPoint
		  AND vcf.RowStatus = 'TRUE'
	ORDER BY vpi.DayOfVisit 

END
