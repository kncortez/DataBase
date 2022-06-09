-- =============================================
-- Author:        <Hugo, Gomez>
-- Create date: <2021-04-14>
-- Description:    <Retorna las rutas de devoluci�n>
-- =============================================
CREATE PROCEDURE [dbo].[get_VehicleReturn]
AS
BEGIN

    select IdVehicle Id, concat(CodeName,'-', Plate ) Name from CatVehicle
    where  RowStatus = 1

END