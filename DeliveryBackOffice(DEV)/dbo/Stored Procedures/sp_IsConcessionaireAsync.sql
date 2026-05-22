/* =================================================
   SP:        [dbo].[sp_IsConcessionaireAsync]
   Propósito: Validar si el VisitPoint es un concesionario válido según país.
   Autor:     Keila Cortéz
   Historia:  FDAPI-5784 bloqueocncexc
   Fecha:     2026-05-21
   === CHANGELOG ================================
   2026-05-21 | Historia/épica: FDAPI-5784 bloqueocncexc | Autor: Keila Cortéz 
   ============================================
*/
CREATE PROCEDURE sp_IsConcessionaireAsync
    @CodeOfReference INT,
    @IdCountry NVARCHAR(2)
AS
BEGIN
    SELECT 1
    FROM DeliveryBackOffice.dbo.VisitPointClient WITH(NOLOCK)
    WHERE CodeOfReference = @CodeOfReference
      AND IdKindOfVPClient IN (3, 14, 25)
      AND CountryId = @IdCountry
END;