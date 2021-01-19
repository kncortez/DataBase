-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-16>
-- Description:	<spws_set_UpdatePassword>
-- =============================================


ALTER PROCEDURE [dbo].[spws_set_UpdatePassword]
-- Add the parameters for the stored procedure here	
@Token        NVARCHAR(MAX), 
@Password     NVARCHAR(MAX), 
@OldPassword  NVARCHAR(MAX), 
@SessionToken NVARCHAR(MAX),
@IdAccount    BIGINT,
@ChangeType   VARCHAR(1)    -- R = Reset  |  U = Update
AS
    BEGIN
        DECLARE @jsonResult NVARCHAR(MAX); 	
        -- 90 dias para cambio de contraseña
        DECLARE @ExpirationDate AS DATE=
        (
            SELECT DATEADD(DAY, 90, GETDATE())
        );
        DECLARE @IdUser AS BIGINT;
        DECLARE @Email AS VARCHAR(200);
        DECLARE @PasswordVerification AS NVARCHAR(MAX);
		DECLARE @IdUserUPDATE AS BIGINT;
		DECLARE @IdResult AS INT

        --Obtener info de usuarios
        SELECT @IdUser = rp.UserId, 
               @Email = rp.UserName
        FROM ResetPasswordVerification rp
        WHERE GeneratedToken = @Token;

        --Validar historia de contraseña
        SET @PasswordVerification =
        (
            SELECT COUNT(1) AS PasswordVerification
            FROM dbo.PasswordLog pl
            WHERE pl.PslPassword = @Password
        );
        IF @PasswordVerification > 0
            BEGIN
			   SET @IdResult = 500;
                SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Contraseña ya usada anteriormente, Para proteger su cuenta, debe elegir una nueva contraseña cada vez que la restablezca."}' FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );
            END;
            ELSE
            BEGIN
                IF @ChangeType = 'R'
                    BEGIN
                        UPDATE RegisterUser
                          SET 
                              UsrLastPassword = @Password, 
                              UsrPasswordExpiration = @ExpirationDate, 
                              UsrDateUpdated = GETDATE()
                        WHERE RegisterUser.UsrIdUser = @IdUser;

                        --desactivar token
                        UPDATE ResetPasswordVerification
                          SET 
                              [Status] = 0, 
                              [VerificationStatus] = 1, 
                              [VerificationDate] = GETDATE()
                        WHERE GeneratedToken = @Token;

                        --Almacenar en el log de contraseñas
                        INSERT INTO [dbo].[PasswordLog]
                        ([PslIdUser], 
                         [PslPassword], 
                         [PslTokenCreated], 
                         [PslDateCreated]
                        )
                        VALUES
                        (@IdUser, 
                         @Password, 
                         @Email, 
                         GETDATE()
                        );
						SET @IdResult = 200;
                        SET @jsonResult =
                        (
                            SELECT STUFF(
                        (
                            SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Se actualizó la contraseña correctamente."}' FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'), 1, 1, '')
                        );
                    END;
                    ELSE
                    IF @ChangeType = 'U'
                        BEGIN
                            IF @OldPassword !=
                            (
                                SELECT us.UsrLastPassword
													  FROM RegisterUser us
													  	 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
													  												  AND rua.RuaRowStatus = 1
													  	 INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
													  									AND ac.AccRowStatus = 1
													  WHERE ac.AccIdAccount = @IdAccount
                            )
                                BEGIN
								SET @IdResult = 500;
                                    SET @jsonResult =
                                    (
                                        SELECT STUFF(
                                    (
                                        SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Contraseña anterior no coincide con la contraseña almacenada."}' FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'), 1, 1, '')
                                    );
                                END;
                                ELSE
                                BEGIN

								SET @IdUserUPDATE = (SELECT us.UsrIdUser
													  FROM RegisterUser us
													  	 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
													  												  AND rua.RuaRowStatus = 1
													  	 INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
													  									AND ac.AccRowStatus = 1
													  WHERE ac.AccIdAccount = @IdAccount)
                                    UPDATE RegisterUser
                                      SET 
                                          UsrLastPassword = @Password, 
                                          UsrPasswordExpiration = @ExpirationDate, 
                                          UsrDateUpdated = GETDATE()
                                    WHERE RegisterUser.UsrIdUser = @IdUserUPDATE;

                                    --Almacenar en el log de contraseñas
                                    INSERT INTO [dbo].[PasswordLog]
                                    ([PslIdUser], 
                                     [PslPassword], 
                                     [PslTokenCreated], 
                                     [PslDateCreated]
                                    )
                                    VALUES
                                    (@IdUserUPDATE, 
                                     @Password, 
                                     @SessionToken, 
                                     GETDATE()
                                    );
									SET @IdResult = 200;
                                    SET @jsonResult =
                                    (
                                        SELECT STUFF(
                                    (
                                        SELECT '{"IdResult":'+ CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Se actualizó la contraseña correctamente."}' FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'), 1, 1, '')
                                    );
                                END;
                        END;
            END;

        -- retornar resultado en formato json

        SELECT @IdResult AS IdResult,('[{' + @jsonResult + ']') jsonResult;
    END;

