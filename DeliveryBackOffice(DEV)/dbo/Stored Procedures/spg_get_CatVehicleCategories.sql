
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-02>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicleCategories]
@value bit = 1
AS
BEGIN
	SELECT IdCatVehicleCategories, Name FROM CatVehicleCategories
	where RowStatus = 1
END