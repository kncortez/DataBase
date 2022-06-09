-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_CatTypeRoute]
AS
BEGIN
	SELECT IdTypeRoute, Name 
	FROM DeliveryBackOffice.dbo.CatTypeRoute
	WHERE RowStatus = 1


END
