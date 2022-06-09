
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicle]
AS
BEGIN
	SELECT cv.IdVehicle,
	cv.UnitNumber	
	FROM [DeliveryBackOffice].[dbo].[CatVehicle] as cv
	where cv.RowStatus = 1
END