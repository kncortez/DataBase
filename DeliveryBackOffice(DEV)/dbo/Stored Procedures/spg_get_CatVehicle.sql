
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <20/06/2022>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicle]
(
  @IdCountry  NVARCHAR(2) = 'GT'
)
AS
BEGIN
	SELECT cv.IdVehicle,
	cv.UnitNumber	
	FROM [DeliveryBackOffice].[dbo].[CatVehicle] as cv
	where cv.RowStatus = 1
    AND IIF(cv.IdCountry IS NULL,'GT',cv.IdCountry) = @IdCountry;
END