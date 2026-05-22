/* =================================================
   SP:        [dbo].[sp_GetOperatorsByStationAsync]
   Propósito: Obtener operadores asociados a una estación.
   Autor:     Keila Cortéz
   Historia:  FDAPI-5784 bloqueocncexc
   Fecha:     2026-05-21
   === CHANGELOG ================================
   2026-05-21 | Historia/épica: FDAPI-5784 bloqueocncexc | Autor: Keila Cortéz 
   ============================================
*/
CREATE PROCEDURE sp_GetOperatorsByStationAsync
    @codeOfReference INT
AS
BEGIN
    SELECT
        RU.UsrIdUser AS UserId,
        RU.UsrEmail AS Email,
        P.PerFirstName AS FirstName,
        P.PerLastName AS LastName,
        RU.UsrPasswordLastUpdate AS LastUpdate,
        P2.PerFirstName AS UserUpdateFirstName,
        P2.PerLastName AS UserUpdateLastName
    FROM DeliveryBackOffice.dbo.VisitPointByUser VPU WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH(NOLOCK)
            ON VPU.RegisterUserID = RU.UsrIdUser
        INNER JOIN DeliveryBackOffice.dbo.Person P WITH(NOLOCK)
            ON RU.UsrIdPerson = P.PerIdPerson
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
            ON VPU.IdVisitPointClient = VPC.IdVisitPointClient
        LEFT JOIN DeliveryBackOffice.dbo.RegisterUser RU2 WITH(NOLOCK)
            ON RU.UsrPasswordUpdatedBy = RU2.UsrIdUser
        LEFT JOIN DeliveryBackOffice.dbo.Person P2 WITH(NOLOCK)
            ON RU2.UsrIdPerson = P2.PerIdPerson
    WHERE VPC.CodeOfReference = @codeOfReference
      AND VPU.RowStatus = 1
      AND RU.UsrRowStatus = 1
END;
GO