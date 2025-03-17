-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <23-06-2022>
-- Description:	<Login para app de operaciones HERMES MOBILE>
-- =============================================
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
		RUS.RusIdUser, RUS.RusIdRol, RUS.RusIdSystem, RUS.RusRowStatus, RUS.StationId
	FROM InternalUser IU
		INNER JOIN RegisterUser RU
			ON IU.RegisterUserID = RU.UsrIdUser
		INNER JOIN RolByUserBySystem RUS
			ON IU.RegisterUserID = RUS.RusIdUser
	WHERE IU.IdUser = @Code AND IU.Username = @Username-- COLLATE SQL_LATIN1_GENERAL_CP1_CS_AS
		AND RU.UsrLastPassword = @Password
		AND RUS.RusIdSystem = @SystemId AND RUS.RusRowStatus = 1;
END