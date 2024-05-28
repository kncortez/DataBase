-- =============================================
-- Author:        <Hugo, Gomez>
-- Create date: <2021-04-14>
-- Description:    <Retorna las rutas de devoluci�n>
-- =============================================
-- =============================================
-- Author:      <Cristian Suazo>
-- Create date: <2024-05-27>
-- Description:    <Se agrega la condicion del pais>
-- =============================================
CREATE PROCEDURE [dbo].[get_VehicleReturn]
AS
BEGIN

    select IdVehicle Id, concat(CodeName,'-', Plate ) Name from CatVehicle
    where  RowStatus = 1
	AND ISNULL(IdCountry,'GT') = @Country

END