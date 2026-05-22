/* =================================================
   SP:        [dbo].[sp_UnlockOperatorAsync]
   Propósito: Desbloquear operador mediante actualización de contraseña y estado de cambio de contraseña.
   Autor:     Keila Cortéz
   Historia:  FDAPI-5784 bloqueocncexc
   Fecha:     2026-05-21
   === CHANGELOG ================================
   2026-05-21 | Historia/épica: FDAPI-5784 bloqueocncexc | Autor: Keila Cortéz 
   ============================================
*/
CREATE PROCEDURE sp_UnlockOperatorAsync
    @userId INT,
    @encryptedPassword NVARCHAR(100),
    @updatedBy INT
AS
BEGIN
    UPDATE DeliveryBackOffice.dbo.RegisterUser
                    SET 
                    UsrLastPassword = @encryptedPassword,
                    ChangePassword = 0,
                    UsrPasswordLastUpdate = GETDATE(),
                    UsrPasswordUpdatedBy = @updatedBy
                WHERE UsrIdUser = @userId
END;