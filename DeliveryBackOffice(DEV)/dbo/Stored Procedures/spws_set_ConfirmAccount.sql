-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-19>
-- Description:	<spws_set_ConfirmAccount>
-- =============================================
CREATE PROCEDURE [dbo].[spws_set_ConfirmAccount] @Token VARCHAR(MAX)
AS
    BEGIN
        DECLARE @jsonResult NVARCHAR(MAX);
        DECLARE @ValidaInfo INT;
        DECLARE @IdUser BIGINT;
        DECLARE @IdAccount BIGINT;
        DECLARE @IdResult INT;
		DECLARE @AccConfirm CHAR(1);
        SET @ValidaInfo =
        (
            SELECT COUNT(1)
            FROM GeneratedTokens rp
            WHERE GeneratedToken = @Token
        );
		 SET @IdUser =
                (
                    SELECT rp.UserId
                    FROM GeneratedTokens rp
                    WHERE GeneratedToken = @Token
                );
                SET @IdAccount =
                (
                    SELECT ac.AccIdAccount
                    FROM RegisterUser us
                         INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                      AND rua.RuaRowStatus = 1
                         INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
                                                        AND ac.AccRowStatus = 1
                    WHERE us.UsrIdUser = @IdUser
                );
        IF (@ValidaInfo > 0	) AND (@IdAccount > 0)	 
            BEGIN
               SET @AccConfirm =
                (
                    SELECT ac.AccConfirm
                    FROM RegisterUser us
                         INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                      AND rua.RuaRowStatus = 1
                         INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
                                                        AND ac.AccRowStatus = 1
                    WHERE us.UsrIdUser = @IdUser
                );
				 --desactivar token
                UPDATE GeneratedTokens
                  SET 
                      VerificationStatus = 0, 
                      DateOfTokenUse = GETDATE()
                WHERE GeneratedToken = @Token;

				IF @AccConfirm = 'P'
				BEGIN 
				UPDATE dbo.Account
                  SET 
                      dbo.Account.AccConfirm = 'C'
                WHERE dbo.Account.AccIdAccount = @IdAccount;			

                SET @IdResult = 200;
                SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Su cuenta ha sido confirmada correctamente."}' FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );
				END
				ELSE IF @AccConfirm = 'C'
				BEGIN
				SET @IdResult = 200;
                SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Su cuenta ya se había confirmado anteriormente."}' FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );

                
				END;
            END;
            ELSE
            BEGIN
                SET @IdResult = 500;
                SET @jsonResult =
                (
                    SELECT STUFF(
                (
                    SELECT '{"IdResult":' + CAST(@IdResult AS VARCHAR(3)) + ',' + '"Message":"Información Incorrecta."}' FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'), 1, 1, '')
                );
            END;

        -- retornar resultado en formato json

        SELECT @IdResult AS IdResult, 
               ('[{' + @jsonResult + ']') jsonResult;
    END;