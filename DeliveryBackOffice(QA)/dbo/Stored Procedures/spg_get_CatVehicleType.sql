
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-02>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_CatVehicleType]
@value bit = 1
AS
BEGIN
	SELECT IdTypeVehicle, Name FROM CatTypeVehicle
	where RowStatus = 1
END