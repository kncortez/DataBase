-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-22>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_CatVehicleCategories]
AS
BEGIN

	select IdCatVehicleCategories, Name, Length, Width,High,UnitType from CatVehicleCategories
	where RowStatus = 1




END
