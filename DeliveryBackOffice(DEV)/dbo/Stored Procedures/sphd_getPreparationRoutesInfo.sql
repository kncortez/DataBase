
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-12-21>
-- Description: <Obtiene la información de rutas para la preparación de ruta, se manda como parametro el día y el id de la ruta.>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getPreparationRoutesInfo]
	@DayOfVisit TINYINT,
	@IdRoute SMALLINT,
    @IdCountry VARCHAR(2) = 'GT'
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
	FROM dbo.VisitPointItinerary TT WITH(NOLOCK)
	INNER JOIN dbo.VisitPointFrequency FQ WITH(NOLOCK)
		ON FQ.IdVPFrequency = TT.VPFrequencyID
			AND FQ.RowStatus = 'true'
	INNER JOIN dbo.VisitPointConfiguration CF WITH(NOLOCK)
		ON CF.IdVPConfiguration = FQ.VPConfigurationID
			AND CF.RowStatus = 'true'
	INNER JOIN dbo.VisitPointClient VP WITH(NOLOCK)
		ON VP.CodeOfReference = CF.VisitPointId
			AND VP.StatusClient = 'true'
	INNER JOIN dbo.Customer CS WITH(NOLOCK)
		ON CS.IdCustomer = VP.CustomerID
			AND CS.RowSatus = 'true'
	LEFT JOIN dbo.CatRoute RT WITH(NOLOCK)
		ON RT.IdRoute = TT.RouteCodeID
	WHERE TT.DayOfVisit = @DayOfVisit
	AND TT.RowStatus = 'TRUE'
	AND RT.IdRoute = @IdRoute
	AND TT.InitializationTimeOfVisit IS NOT NULL AND TT.InitializationTimeOfVisit NOT IN ('__:__','0','',' ')
	AND TT.FinalizationTimeOfVisit IS NOT NULL AND TT.FinalizationTimeOfVisit NOT IN ('__:__','0','',' ')
    AND IIF(VP.CountryId IS NULL, 'GT', VP.CountryId) = @IdCountry
	ORDER BY TT.InitializationTimeOfVisit, TT.FinalizationTimeOfVisit, CS.IdCustomer, vp.CodeOfReference, RT.IdRoute
END
