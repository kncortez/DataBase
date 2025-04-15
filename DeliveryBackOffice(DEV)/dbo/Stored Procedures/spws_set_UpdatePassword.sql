-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-16>
-- Update date: <2021-02-01>
-- Description:	<spws_set_UpdatePassword>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <2023-01-25>
-- Description: <Set changePassword field to 0 when it is a successfull update>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Update date: <2025-04-15>
-- Description: <Se pasa a tablas el Json>
-- =============================================

CREATE procedure [dbo].[spws_set_UpdatePassword]
-- Add the parameters for the stored procedure here	
@Token        nvarchar(max), 
@Password     nvarchar(max), 
@OldPassword  nvarchar(max), 
@SessionToken nvarchar(max), 
@IdAccount    bigint, 
@ChangeType   varchar(1)    -- R = Reset  |  U = Update
as
    begin
        declare @Message nvarchar(max); 	
        -- 90 dias para cambio de contraseña
        DECLARE @ExpirationDate AS DATE=
        (
            SELECT DATEADD(DAY, 90, GETDATE())
        );
        DECLARE @IdUser					AS BIGINT;
        DECLARE @Email					AS VARCHAR(200);
		DECLARE @UserName				AS VARCHAR(200);
        DECLARE @IdUserUPDATE			AS BIGINT;
        DECLARE @IdResult				AS INT;
        DECLARE @ValToken				AS INT;
		DECLARE @IdAccount_				AS BIGINT
        SET @ValToken =
        (
            SELECT COUNT(1)
            FROM GeneratedTokens rp WITH(NOLOCK)
            WHERE GeneratedToken = @Token
                  AND ([Status] = 1
                       OR VerificationStatus = 1)
        );
        IF((@ValToken > 0 AND  @ChangeType = 'R') OR (@SessionToken != '' AND  @ChangeType = 'U'))
            BEGIN

                --Obtener info de usuarios
                SELECT @IdUser = rp.UserId, 
                       @Email = rp.UserName
                FROM GeneratedTokens rp WITH(NOLOCK)
                WHERE GeneratedToken = @Token;

                --Validar historia de contraseña
					IF EXISTS
					(
						SELECT TOP 1
							1 AS PasswordVerification
						FROM dbo.PasswordLog pl WITH (NOLOCK)
						WHERE pl.PslPassword = @Password
							  AND pl.PslIdUser = @IdUser
					)
					BEGIN
						SET @IdResult = 500;
						SET @Message
							= 'Contraseña ya usada anteriormente, Para proteger su cuenta, debe elegir una nueva contraseña cada vez que la restablezca.'
					END;
                    ELSE
                    BEGIN
                        IF @ChangeType = 'R'
                            BEGIN
                            
                            --### CAMBIO PARA PODER DESBLOQUEAR.INI ###
                                UPDATE DeliveryBackOffice.dbo.UserSystemRestriction
                                SET UstRetries = 0 , UstStatus = 'ACTIVE'
                                ,UstOperationDate = GETDATE()
                                WHERE UstIdUser = @IdUser
                                AND UstRowStatus = 1
							--### CAMBIO PARA PODER DESBLOQUEAR.FIN ###


                                UPDATE RegisterUser
                                  SET 
                                      UsrLastPassword = @Password, 
                                      UsrPasswordExpiration = @ExpirationDate, 
                                      UsrDateUpdated = GETDATE()
                                WHERE RegisterUser.UsrIdUser = @IdUser;

                                --desactivar token
                                UPDATE GeneratedTokens
                                  SET 
                                      [Status] = 0, 
                                      DateOfTokenUse = GETDATE()
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
                                SET @Message = 'Se actualizó la contraseña correctamente.'
                            END;
                            ELSE
                            IF @ChangeType = 'U'
                                BEGIN
								SET @IdAccount_ = (SELECT COUNT(1) FROM Account ac WITH(NOLOCK) WHERE ac.AccIdAccount =  @IdAccount );
                                    IF @IdAccount_ > 0 
									BEGIN
									IF @OldPassword !=
                                    (
                                        SELECT us.UsrLastPassword
                                        FROM RegisterUser us WITH(NOLOCK)
                                             INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK) 
												ON rua.RuaIdUser = us.UsrIdUser                                                  
                                             INNER JOIN [dbo].Account ac WITH(NOLOCK) 
												ON ac.AccIdAccount = rua.RuaIdAccount                                                   
                                        WHERE ac.AccIdAccount = @IdAccount 
										AND rua.RuaRowStatus = 1 
										AND ac.AccRowStatus = 1
                                    )
                                        BEGIN
                                            SET @IdResult = 500;
                                            SET @Message = 'Contraseña anterior no coincide con la contraseña almacenada.'
                                        END;
                                        ELSE
                                        BEGIN

                                        --### CAMBIO PARA PODER DESBLOQUEAR.INI ###
                                                UPDATE DeliveryBackOffice.dbo.UserSystemRestriction
                                                SET UstRetries = 0 , UstStatus = 'ACTIVE'
                                                ,UstOperationDate = GETDATE()
                                                WHERE UstIdUser = @IdUser
                                                AND UstRowStatus = 1
                                            --### CAMBIO PARA PODER DESBLOQUEAR.FIN ###

                                            SELECT 
												@IdUserUPDATE = us.UsrIdUser,
												@UserName = prs.PerFirstName,
												@Email = us.UsrEmail
                                            FROM RegisterUser us WITH(NOLOCK)
												INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
													ON rua.RuaIdUser = us.UsrIdUser													
												INNER JOIN [dbo].Account ac WITH(NOLOCK)
													ON ac.AccIdAccount = rua.RuaIdAccount													
												LEFT JOIN [dbo].Person prs WITH(NOLOCK)
													ON us.UsrIdPerson= prs.PerIdPerson
                                                                                    
                                            WHERE ac.AccIdAccount = @IdAccount 
											AND rua.RuaRowStatus = 1 
											AND ac.AccRowStatus = 1

                                            UPDATE RegisterUser
                                              SET 
                                                  UsrLastPassword = @Password, 
                                                  UsrPasswordExpiration = @ExpirationDate, 
                                                  UsrDateUpdated = GETDATE(),
												  ChangePassword = 0
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
                                            SET @Message = 'Se actualizó la contraseña correctamente.'
                                        END;
									END;
									ELSE
									BEGIN
									SET @IdResult = 500;
									SET @Message = 'Cuenta no existe'

									END;
                                END;
                    END;
            END;
            ELSE
            BEGIN
                SET @IdResult = 500;
                SET @Message = 'Su token no existe.'
            END;
        -- retornar resultado 

        SELECT @IdResult AS IdResult, 
               @Message AS [Message],
			   @Email AS email, 
			   @UserName AS username;
    END;