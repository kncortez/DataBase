-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <20/06/2022>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-06-13>
-- Description:	<filtro de vehiculos por país>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <17-02-2025>
-- Description:	<Filter the country.>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicle]
  @IdCountry  NVARCHAR(2) = 'GT'
AS
BEGIN
	SELECT cv.IdVehicle,
	       cv.UnitNumber,
		    ISNULL(cv.IdCountry,'GT') IdCountry	
	FROM [DeliveryBackOffice].[dbo].[CatVehicle] as cv
	where cv.RowStatus = 1
	AND (
		(@IdCountry != 'GT' AND cv.IdCountry = @IdCountry) 
	OR (@IdCountry = 'GT' AND ISNULL(cv.IdCountry, 'GT') = @IdCountry));
END