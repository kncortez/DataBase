
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
CREATE PROCEDURE [dbo].[sp_get_visitPointClientParser]
@IdVisitClient AS int,
@IdCustomer AS int  
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
		   ISNULL(CountryId, 'GT') AS CountryId,
		   IdSettlement
	FROM VisitPointClient WITH(NOLOCK)
	WHERE CodeOfReference = @IdVisitClient and CustomerId = @IdCustomer

END