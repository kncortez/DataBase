
-- =============================================
-- Description:	<SP para obtener información de la tabla VisitPointClient por medio del ID del VisitPoint>
-- Nota: Este SP solamente es utilizado por el parser
-- =============================================
-- =============================================
-- Author:	<CRTISTIAN SUAZO>
-- Description: Muestra el pais del punto de visita
-- =============================================
-- =============================================
-- Author:	<Oscar Rodriguez>
-- Description: Se regresa informacion de poblado asociado al punto de visita
-- =============================================
-- =============================================
-- Author:	<Bilkar Moratayaz>
-- Description: Regresa información sobre los tipos de guías que puede crear
-- Date: 2025-12-23
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_visitPointClientParser]
@IdVisitClient AS int
AS
BEGIN

	SELECT CodeOfReference, 
		   CustomerID, 
		   [Address], 
		   [Zone], 
		   Town, 
		   Department, 
		   Phone, 
		   DescriptionOfClient, 
		   CountryId,
		   IdSettlement,
		   ParserGuideTypes
	FROM VisitPointClient WITH(NOLOCK)
	WHERE CodeOfReference = @IdVisitClient

END