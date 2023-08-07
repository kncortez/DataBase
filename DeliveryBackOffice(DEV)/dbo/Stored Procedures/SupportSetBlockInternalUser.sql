-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2023-07-07>
-- Description:	<Sp para dar de baja usuario internos>
-- =============================================

CREATE PROCEDURE [dbo].[SupportSetBlockInternalUser]
    @Code INT
  , @UserName NVARCHAR(100)
AS
BEGIN

IF EXISTS(SELECT * FROM dbo.InternalUser it WHERE it.IdUser =@Code AND it.Username = @UserName AND it.RowStatus = 1)
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;


		-- inactivar Usuario Interno
        UPDATE dbo.InternalUser
        SET RowStatus = 0
        WHERE IdUser = @Code
              AND Username = @UserName;

		-- Inactivar register user
        UPDATE rg
        SET rg.UsrRowStatus = 0
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;

		-- Inactivar Persona
		 UPDATE per
        SET per.PerRowStatus =0
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
			INNER JOIN dbo.Person per ON per.PerIdPerson = rg.UsrIdPerson
                ON rg.UsrIdUser = it.RegisterUserID
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;


		-- Inactivar VisitPointByUser
		UPDATE vu
        SET vu.RowStatus =0
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.VisitPointByUser vu ON vu.RegisterUserID = rg.UsrIdUser
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;

		-- Blockear Restiction
		UPDATE res
        SET res.UstStatus ='BLOCKED'
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.UserSystemRestriction res ON res.UstIdUser = rg.UsrIdUser
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;
		
		
		-- Inactivar Puntos de visita asociados (VisitPointByUser)
		UPDATE rus
        SET rus.RusRowStatus =0
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.RolByUserBySystem rus ON rus.RusIdUser = rg.UsrIdUser
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;

		-- Inactivar Usuarios Denarius

		UPDATE DenariusUser_Dev.dbo.LGN_Restriction
		SET	 RST_Status ='BLOCKED'
		WHERE RST_IdUser = @Code AND RST_Username =@UserName


        COMMIT TRANSACTION;

		SELECT 'EL usuario se dio de baja correctamete'
    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER()
             , ERROR_PROCEDURE()
             , ERROR_STATE();
    END CATCH;
	END
	ELSE
	BEGIN
	    SELECT 'Usuario no exite '
	END
END;