
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-06-13>
-- Description:	<filtro de vehiculos por país>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicle]
(
  @IdCountry  NVARCHAR(2) = 'GT'
)
AS
BEGIN
	SELECT cv.IdVehicle,
	       cv.UnitNumber,
		    ISNULL(cv.IdCountry,'GT') IdCountry	
	FROM [DeliveryBackOffice].[dbo].[CatVehicle] as cv
	where cv.RowStatus = 1
	AND ISNULL(cv.IdCountry,'GT') = @IdCountry;
END