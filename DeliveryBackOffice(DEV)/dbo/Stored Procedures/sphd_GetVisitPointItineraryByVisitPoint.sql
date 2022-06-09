-- =============================================
-- Author:		<Alberto,Ixchp>
-- Create date: <2021-12-21>
-- Description:	<Obtiene el itinerario de puntos de visita>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetVisitPointItineraryByVisitPoint]
	@weekday int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
      SELECT
			--ROW_NUMBER() OVER(ORDER BY IdCustomer ASC) Row_Number,			
			CS.IdCustomer ,
            CS.Name	Customer,
            VP.CodeOfReference,
            VP.DescriptionOfClient Client,
			vp.Address ,
            --TT.DayOfVisit,
            TT.InitializationTimeOfVisit StartTime,
            TT.FinalizationTimeOfVisit	 EndTime,
            TT.OrderSequence,
            RT.CodeRoute	Route,
			RT.IdRoute		IdRoute,
			TT.IdVPItinerary IdItinerary,
			VP.Department Province,
			VP.Town Township
      FROM dbo.VisitPointItinerary TT
          JOIN dbo.VisitPointFrequency FQ WITH (NOLOCK)
              ON FQ.IdVPFrequency = TT.VPFrequencyID AND fq.RowStatus ='true' 
          JOIN dbo.VisitPointConfiguration CF WITH (NOLOCK)
              ON CF.IdVPConfiguration = FQ.VPConfigurationID AND cf.RowStatus ='true'
          JOIN dbo.VisitPointClient VP WITH (NOLOCK)
              ON VP.CodeOfReference = CF.VisitPointID --AND vp.StatusClient ='true'
          JOIN dbo.Customer CS WITH (NOLOCK)
              ON CS.IdCustomer = VP.CustomerID AND cs.RowSatus ='true'
          LEFT JOIN dbo.CatRoute RT
              ON RT.IdRoute = TT.RouteCodeID 
      WHERE TT.DayOfVisit = @weekday
            AND TT.RowStatus = 'TRUE'
      --ORDER BY TT.InitializationTimeOfVisit, TT.FinalizationTimeOfVisit, CS.IdCustomer,vp.CodeOfReference,RT.IdRoute
	  --ORDER BY TT.OrderSequence
	  --CANTIDAD DE PUNTOS DE VISITA SIN RUTA ASIGNADA
	SELECT COUNT(*) WITHOUTROUTE  FROM dbo.VisitPointItinerary 
		WHERE RouteCodeID IS NULL AND DayOfVisit=@weekday AND RowStatus='TRUE'
END
