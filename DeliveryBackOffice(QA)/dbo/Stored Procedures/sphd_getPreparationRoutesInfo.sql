
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-21>
-- Description: <Obtiene la información de rutas para la preparación de ruta, se manda como parametro el día y el id de la ruta.>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getPreparationRoutesInfo]
	@DayOfVisit TINYINT,
	@IdRoute SMALLINT
AS
BEGIN
	SELECT
		VP.CodeOfReference
	   ,TT.OrderSequence
	   ,vp.DescriptionOfClient Name
	   ,VP.Department
	   ,VP.Town
	   ,VP.Address
	   ,TT.InitializationTimeOfVisit
	   ,TT.FinalizationTimeOfVisit
	   ,VP.Phone
	   ,VP.IdTownship
	   ,TT.IdVPItinerary
	FROM dbo.VisitPointItinerary TT
	JOIN dbo.VisitPointFrequency FQ
		ON FQ.IdVPFrequency = TT.VPFrequencyID
			AND FQ.RowStatus = 'true'
	JOIN dbo.VisitPointConfiguration CF
		ON CF.IdVPConfiguration = FQ.VPConfigurationID
			AND CF.RowStatus = 'true'
	JOIN dbo.VisitPointClient VP
		ON VP.CodeOfReference = CF.VisitPointId
			AND VP.StatusClient = 'true'
	JOIN dbo.Customer CS
		ON CS.IdCustomer = VP.CustomerID
			AND CS.RowSatus = 'true'
	LEFT JOIN dbo.CatRoute RT
		ON RT.IdRoute = TT.RouteCodeID
	WHERE TT.DayOfVisit = @DayOfVisit
	AND TT.RowStatus = 'TRUE'
	AND RT.IdRoute = @IdRoute
	ORDER BY TT.InitializationTimeOfVisit, TT.FinalizationTimeOfVisit, CS.IdCustomer, vp.CodeOfReference, RT.IdRoute
END
