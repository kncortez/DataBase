-- =============================================
-- Author:		<Alberto,Ixchp>
-- Create date: <2021-12-21>
-- Description:	<Obtiene el itinerario de puntos de visita>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-17>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetVisitPointItineraryByVisitPoint]
	@weekday int,
    @IdCountry VARCHAR(2) = 'GT'
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
      FROM dbo.VisitPointItinerary TT WITH(NOLOCK)
          INNER JOIN dbo.VisitPointFrequency FQ WITH (NOLOCK)
              ON FQ.IdVPFrequency = TT.VPFrequencyID AND fq.RowStatus ='true' 
          INNER JOIN dbo.VisitPointConfiguration CF WITH (NOLOCK)
              ON CF.IdVPConfiguration = FQ.VPConfigurationID AND cf.RowStatus ='true'
          INNER JOIN dbo.VisitPointClient VP WITH (NOLOCK)
              ON VP.CodeOfReference = CF.VisitPointID --AND vp.StatusClient ='true'
          INNER JOIN dbo.Customer CS WITH (NOLOCK)
              ON CS.IdCustomer = VP.CustomerID AND cs.RowSatus ='true'
          LEFT JOIN dbo.CatRoute RT WITH(NOLOCK)
              ON RT.IdRoute = TT.RouteCodeID 
      WHERE TT.DayOfVisit = @weekday
            AND TT.RowStatus = 'TRUE'
			AND ISNULL(TT.InitializationTimeOfVisit, '__:__') != '__:__'
			AND ISNULL(TT.FinalizationTimeOfVisit, '__:__') != '__:__'
            AND IIF(VP.CountryId IS NULL, 'GT', VP.CountryId) = @IdCountry;

	  --CANTIDAD DE PUNTOS DE VISITA SIN RUTA ASIGNADA
	SELECT COUNT(*) WITHOUTROUTE  
      FROM dbo.VisitPointItinerary TT WITH(NOLOCK)
          LEFT JOIN dbo.VisitPointFrequency FQ WITH (NOLOCK)
              ON FQ.IdVPFrequency = TT.VPFrequencyID AND fq.RowStatus ='true' 
          LEFT JOIN dbo.VisitPointConfiguration CF WITH (NOLOCK)
              ON CF.IdVPConfiguration = FQ.VPConfigurationID AND cf.RowStatus ='true'
          LEFT JOIN dbo.VisitPointClient VP WITH (NOLOCK)
              ON VP.CodeOfReference = CF.VisitPointID
    WHERE TT.RouteCodeID IS NULL 
      AND TT.DayOfVisit=@weekday 
      AND TT.RowStatus='TRUE'
      AND ISNULL(TT.InitializationTimeOfVisit, '__:__') != '__:__'
      AND ISNULL(TT.FinalizationTimeOfVisit, '__:\__') != '__:__'
      AND ISNULL(VP.CountryId,'GT') = @IdCountry;
END
