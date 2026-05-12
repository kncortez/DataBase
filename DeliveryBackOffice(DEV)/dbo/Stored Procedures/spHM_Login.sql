/* =================================================
   SP:        [dbo].[spHM_Login]
   Propósito: Login para app de operaciones HERMES MOBILE.
   Autor:     Jerson Ochoa
   Historia:  <FDAPI-????>
   Fecha:     2022-06-23

=== CHANGELOG ============================
2026-05-11 | Historia/épica: FDAPI-6243  | Autor: Caleb Loarca | Se agrega parametro para validar administrador interno.
=========================================== */
CREATE PROCEDURE [dbo].[spHM_Login]
	@Code AS INT,
	@Username AS VARCHAR(20),
	@Password AS VARCHAR(50),
	@SystemId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT IU.IdUser, IU.Username, IU.IdEmployee, IU.RegisterUserID, IU.RowStatus,
		RU.UsrIdUser, RU.UsrIdPerson, RU.UsrNickName, RU.UsrEmail, RU.UsrLastPassword,
		RUS.RusIdUser, RUS.RusIdRol, RUS.RusIdSystem, RUS.RusRowStatus, RUS.StationId,
		CR.RolAdminInternal
	FROM DeliveryBackOffice.dbo.InternalUser IU
		INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU
			ON IU.RegisterUserID = RU.UsrIdUser
		INNER JOIN DeliveryBackOffice.dbo.RolByUserBySystem RUS
			ON IU.RegisterUserID = RUS.RusIdUser
		INNER JOIN DeliveryBackOffice.dbo.CatRol CR
			ON RUS.RusIdRol = CR.RolIdRol 
	WHERE IU.IdUser = @Code AND IU.Username = @Username-- COLLATE SQL_LATIN1_GENERAL_CP1_CS_AS
		AND RU.UsrLastPassword = @Password
		AND RUS.RusIdSystem = @SystemId AND RUS.RusRowStatus = 1;
END