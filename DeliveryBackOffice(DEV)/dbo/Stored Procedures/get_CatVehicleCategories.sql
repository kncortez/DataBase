-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-22>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_CatVehicleCategories]
(
 @IdCountry AS NVARCHAR(2) = 'GT'
)
AS
BEGIN

	select IdCatVehicleCategories, Name--, Length, Width,High,UnitType 
	,COALESCE(Length,0) Length,COALESCE(Width,0) Width,COALESCE(High,0)High
	,COALESCE(UnitType,0) UnitType
	from CatVehicleCategories
	where RowStatus = 1
      AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry




END
