-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2022-06-24>
-- Description:	<Iniciar sesión para varios sistemas>
-- =============================================
CREATE PROCEDURE [dbo].[Login_GeneralSystem]
-- Add the parameters for the stored procedure here
@UserName VARCHAR(200), 
@Password VARCHAR(200),
@IdSystem INT 

AS
    BEGIN
	 DECLARE @UserExist INT = 0
	  DECLARE @Active INT = 0
	 -- insertar en tabla temporal posbibles mensajes de error

        IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
            DROP TABLE #errormessageApp;
        SELECT *
        INTO #errormessageApp
        FROM
        (
		SELECT 200 AS IdResult, 
                   'Sesión iniciada exitosamente' AS Message, 
                   'Valid' AS Id
            UNION
            SELECT 400 AS IdResult, 
                   'Usuario o contraseña invalida' AS Message, 
                   'Invalid' AS Id
            UNION
            SELECT 403 AS IdResult, 
                   'Usuario bloqueado' AS Message, 
                   'Blocked' AS Id
        ) AS errror;
	

	IF(@IdSystem = 3)
		BEGIN

			SET @UserExist = (SELECT Count(UsrIdUser) FROM RegisterUser 
			 WHERE UsrEmail = @UserName 
			 AND UsrLastPassword = @Password
			 AND UsrRowStatus = 1)

			 IF(@UserExist > 0)
				BEGIN
				
					SET @Active = (SELECT Count(rgu.UsrIdUser) FROM RegisterUser rgu
									INNER JOIN UserSystemRestriction usr
									ON rgu.UsrIdUser = usr.UstIdUser
									WHERE rgu.UsrEmail = @UserName
									AND usr.UstStatus = 'ACTIVE' )

						 IF(@Active > 0)

							 BEGIN
							   SELECT *FROM #errormessageApp
									  WHERE Id = 'Valid'

							   --SELECT UsrNickName, UsrEmail, Phone FROM RegisterUser 
									 --WHERE UsrEmail = @UserName 
									 --AND UsrLastPassword = @Password
									 --AND UsrRowStatus = 1
							 END

						 ELSE
							 BEGIN
								 SELECT *FROM #errormessageApp
									  WHERE Id = 'Blocked'

							 END


				END
			 ELSE
				BEGIN

				   SELECT *FROM #errormessageApp
						  WHERE Id = 'Invalid'
				 END


		END



	END