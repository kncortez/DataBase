/* =================================================
   SP:        [dbo].[GetStationsExc]
   Propósito: Obtener estaciones activas por país.
   Autor:     Keila Cortéz
   Historia:  FDAPI-5784 bloqueocncexc
   Fecha:     2026-05-21
   === CHANGELOG ================================
   2026-05-21 | Historia/épica: FDAPI-5784 bloqueocncexc | Autor: Keila Cortéz
   ============================================
*/
CREATE PROCEDURE GetStationsExc
    @idCountry NVARCHAR(2)
AS
BEGIN
    SELECT 
    IdStation, 
    StationName, 
    CodeOfReference
    FROM DeliveryBackOffice.dbo.CatStation WITH(NOLOCK)
        WHERE StationType = 2
        AND CountryId = @idCountry
        AND RowStatus = 1
END;
