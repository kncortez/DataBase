
-- =============================================
-- Description:	<SP para obtener información de la tabla VisitPointClient por medio del ID del VisitPoint>
-- Nota: Este SP solamente es utilizado por el parser
-- =============================================

CREATE PROCEDURE [dbo].[sp_get_visitPointClientParser]
@IdVisitClient AS int
AS
BEGIN

	SELECT CodeOfReference, 
		   CustomerID, 
		   Address, 
		   Zone, 
		   Town, 
		   Department, 
		   Phone, 
		   DescriptionOfClient, 
		   CASE WHEN CountryId != 'GT' OR CountryId != 'HN' THEN 'GT' ELSE CountryId END AS CountryId
	FROM VisitPointClient
	WHERE CodeOfReference = @IdVisitClient

END