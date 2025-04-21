-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2023-07-07>
-- Description:	<Sp para dar de baja usuario corporativos>
-- =============================================

CREATE PROCEDURE [dbo].[SupportSetBlockCorporateUser]
    @Code INT
  , @UserName NVARCHAR(100)
  , @Token NVARCHAR(60)
  , @Comment NVARCHAR(200)
  , @Typeofprocess INT = 0 --- 1 ACTIVAR,0 INACTIVAR USARIOS
AS
BEGIN

IF EXISTS(SELECT top 1 1 FROM dbo.InternalUser it WITH (NOLOCK) WHERE it.IdUser =@Code AND it.Username = @UserName AND it.RowStatus = 1)
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;


		-- inactivar Usuario Interno
        UPDATE dbo.InternalUser
        SET RowStatus = 0
		, TokenUpdated = @Token
		, DateUpdated = GETDATE()
		, Comment = @Comment
        WHERE IdUser = @Code
              AND Username = @UserName;

		-- Inactivar register user
        UPDATE rg
        SET rg.UsrRowStatus = 0
		, rg.UsrTokenUpdated =@Token
		, rg.UsrDateUpdated = GETDATE()
        FROM dbo.InternalUser           it 
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;

		-- Inactivar Persona
		 UPDATE per
        SET per.PerRowStatus = 0
			, per.PerTokenUpdated = @Token
			, per.PerDateUpdated = GETDATE()
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
              ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.Person per 
             ON per.PerIdPerson = rg.UsrIdPerson
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;


		-- Inactivar VisitPointByUser
		--UPDATE vu
  --      SET vu.RowStatus =0
  --      FROM dbo.InternalUser           it
  --          INNER JOIN dbo.RegisterUser rg
  --              ON rg.UsrIdUser = it.RegisterUserID
		--	INNER JOIN dbo.VisitPointByUser vu ON vu.RegisterUserID = rg.UsrIdUser
  --      WHERE it.IdUser = @Code
  --            AND it.Username = @UserName;

		-- Blockear Restiction
		UPDATE res
        SET res.UstStatus ='BLOCKED'
		, res.UstOperationDate = GETDATE()
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.UserSystemRestriction res
               ON res.UstIdUser = rg.UsrIdUser
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;
		
		
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
	   
	  IF (EXISTS(SELECT TOP 1 1 FROM dbo.InternalUser it WITH (NOLOCK) WHERE it.IdUser =@Code AND it.Username = @UserName AND it.RowStatus = 0) AND @Typeofprocess = 1)
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
              AND Username = @UserName;

		-- Activar register user
        UPDATE rg
        SET rg.UsrRowStatus = 1
		, rg.UsrTokenUpdated =@Token
		, rg.UsrDateUpdated = GETDATE()
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;

		-- Activar Persona
		 UPDATE per
        SET per.PerRowStatus = 1
			, per.PerTokenUpdated = @Token
			, per.PerDateUpdated = GETDATE()
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                  ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.Person per 
                  ON per.PerIdPerson = rg.UsrIdPerson
                
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;


		-- ACTIVE Restiction
		UPDATE res
        SET res.UstStatus ='ACTIVE'
		, res.UstOperationDate = GETDATE()
        FROM dbo.InternalUser           it
            INNER JOIN dbo.RegisterUser rg
                ON rg.UsrIdUser = it.RegisterUserID
			INNER JOIN dbo.UserSystemRestriction res ON res.UstIdUser = rg.UsrIdUser
        WHERE it.IdUser = @Code
              AND it.Username = @UserName;
			  
	
        COMMIT TRANSACTION;

		SELECT 'El usuario se dio de alta correctamete'
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
	END
END;