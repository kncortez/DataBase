-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2024-09-02>
-- Description:	<Sp para reactivar>
-- =============================================

CREATE PROCEDURE [dbo].[SupportSetActivateCorporateUser]
    @Code INT
  , @UserName NVARCHAR(100)
  , @Token NVARCHAR(60)
  , @Comment NVARCHAR(200)
AS
BEGIN

IF EXISTS(SELECT * FROM dbo.InternalUser  it WITH(NOLOCK) WHERE it.IdUser =@Code AND it.Username = @UserName) --AND it.RowStatus = 0)
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;


		-- Activar Usuario Interno
        UPDATE dbo.InternalUser
        SET RowStatus = 1
		, TokenUpdated = @Token
		, DateUpdated = GETDATE()
		, Comment = @Comment
        WHERE IdUser = @Code
              AND Username = @UserName
			  AND RowStatus =0;

		-- Activar register user
        UPDATE rg
        SET rg.UsrRowStatus = 1
		, rg.UsrTokenUpdated =@Token
		, rg.UsrDateUpdated = GETDATE()
        FROM dbo.InternalUser it WITH(NOLOCK)
            INNER JOIN dbo.RegisterUser rg WITH(NOLOCK)
                ON rg.UsrIdUser = it.RegisterUserID
        WHERE it.IdUser = @Code
              AND it.Username = @UserName --AND RowStatus =0;

		-- Activar Persona
		 UPDATE per
        SET per.PerRowStatus =1
			, per.PerTokenUpdated = @Token
			, per.PerDateUpdated = GETDATE()
        FROM dbo.InternalUser           it WITH(NOLOCK)
            INNER JOIN dbo.RegisterUser rg WITH(NOLOCK)
			INNER JOIN dbo.Person per WITH(NOLOCK) ON per.PerIdPerson = rg.UsrIdPerson
                ON rg.UsrIdUser = it.RegisterUserID
        WHERE it.IdUser = @Code
              AND it.Username = @UserName --AND RowStatus =0;


		-- Inactivar VisitPointByUser
		--UPDATE vu
  --      SET vu.RowStatus =0
  --      FROM dbo.InternalUser           it
  --          INNER JOIN dbo.RegisterUser rg
  --              ON rg.UsrIdUser = it.RegisterUserID
		--	INNER JOIN dbo.VisitPointByUser vu ON vu.RegisterUserID = rg.UsrIdUser
  --      WHERE it.IdUser = @Code
  --            AND it.Username = @UserName;

		-- Activate Restiction
		UPDATE res
        SET res.UstStatus ='ACTIVE'
		, res.UstOperationDate = GETDATE()
		, res.UstAccessRetries =10
		, res.UstRetries =0
        FROM dbo.InternalUser           it WITH(NOLOCK)
            INNER JOIN dbo.RegisterUser rg WITH(NOLOCK)
                ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.UserSystemRestriction res WITH(NOLOCK) ON res.UstIdUser = rg.UsrIdUser
        WHERE it.IdUser = @Code
              AND it.Username = @UserName AND res.UstStatus ='BLOCKED';
		
		
		---- Inactivar Puntos de visita asociados (VisitPointByUser)
		--UPDATE rus
  --      SET rus.RusRowStatus =0
		--, rus.RusTokenUpdated = @Token
		--, rus.RusDateUpdated = GETDATE()
		--, rus
  --      FROM dbo.InternalUser           it
  --          INNER JOIN dbo.RegisterUser rg
  --              ON rg.UsrIdUser = it.RegisterUserID
		--	INNER JOIN dbo.RolByUserBySystem rus ON rus.RusIdUser = rg.UsrIdUser
  --      WHERE it.IdUser = @Code
  --            AND it.Username = @UserName;

		-- Inactivar Usuarios Denarius

		UPDATE DenariusUser_Dev.dbo.LGN_Restriction
		SET	 RST_Status ='ACTIVE'
		, RST_Retries =0
		WHERE RST_IdUser = @Code AND RST_Username =@UserName AND RST_Status ='BLOCKED'


        COMMIT TRANSACTION;

		SELECT 'EL usuario se activó correctamete'
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
	    SELECT 'Usuario no existe o no esta de baja consulta el estado de este usuario con el sp [SupportGetStatusCorporateUser] '
	END
END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportSetActivateCorporateUser] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportSetActivateCorporateUser] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportSetActivateCorporateUser] TO [cvaldes]
    AS [dbo];

