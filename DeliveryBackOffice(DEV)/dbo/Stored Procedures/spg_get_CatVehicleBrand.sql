
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-02>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicleBrand]
@value bit = 1
AS
BEGIN
	SELECT IdCatVehicleBrand, Name FROM CatVehicleBrand
	where RowStatus = 1
END