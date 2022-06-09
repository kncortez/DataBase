-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-16>
-- Update date: <2021-01-29>
-- Description:	<spws_get_TokenValidator>
-- =============================================

create PROCEDURE [dbo].[spws_get_TokenValidator]
-- Add the parameters for the stored procedure here	
@Token     NVARCHAR(MAX), 
@TokenType CHAR(1)
AS
    BEGIN
        DECLARE @jsonResult NVARCHAR(MAX);
        DECLARE @MESAGGE VARCHAR(100);
        DECLARE @STATUS VARCHAR(1);
        IF @TokenType = 'R' --R = RESET EMAIL
            BEGIN
                SELECT @STATUS = STATUS_, 
                       @MESAGGE = MESAGGE
                FROM
                (
                    SELECT 'A' STATUS_, 
                           'Su token aún se encuentra activo' MESAGGE
                    FROM GeneratedTokens
                    WHERE GeneratedToken = @Token
                          AND ExpirationDate >= GETDATE()
                          AND [Status] = 1
                    UNION
                    SELECT 'E' STATUS_, 
                           'Su token ha expirado' MESAGGE
                    FROM GeneratedTokens
                    WHERE GeneratedToken = @Token
                          AND ExpirationDate < GETDATE() 
                    --OR [Status] = 0
                    UNION
                    SELECT 'U' STATUS_, 
                           'Ya ha utilizado anteriormente este token' MESAGGE
                    FROM GeneratedTokens
                    WHERE GeneratedToken = @Token
                          AND ExpirationDate > GETDATE()
                          AND [Status] = 0
                    UNION
                    SELECT 'I' STATUS_, 
                           'El token no es correcto' MESAGGE
                    FROM GeneratedTokens
                    WHERE @Token NOT IN
                    (
                        SELECT GeneratedToken
                        FROM GeneratedTokens rpv
                    )
                ) AS X;
                IF @STATUS = 'E'
                    BEGIN
                        UPDATE GeneratedTokens
                          SET 
                              [Status] = 0, 
                              [DateOfTokenUse] = GETDATE()
                        WHERE GeneratedToken = @Token;
                    END;
            END;
            ELSE
            IF @TokenType = 'V' --V = VALIDATION EMAIL
                BEGIN
                    SELECT @STATUS = STATUS_, 
                           @MESAGGE = MESAGGE
                    FROM
                    (
                        SELECT 'A' STATUS_, 
                               'Su token aún se encuentra activo' MESAGGE
                        FROM GeneratedTokens
                        WHERE GeneratedToken = @Token
                              AND ExpirationDate >= GETDATE()
                              AND VerificationStatus = 1
                        UNION
                        SELECT 'E' STATUS_, 
                               'Su token ha expirado' MESAGGE
                        FROM GeneratedTokens
                        WHERE GeneratedToken = @Token
                              AND ExpirationDate < GETDATE()
                        --OR VerificationStatus = 0
						 UNION
                    SELECT 'U' STATUS_, 
                           'Ya ha utilizado anteriormente este token' MESAGGE
                    FROM GeneratedTokens
                    WHERE GeneratedToken = @Token
                          AND ExpirationDate > GETDATE()
                          AND VerificationStatus = 0
                        UNION
                        SELECT 'I' STATUS_, 
                               'Su token no es correcto' MESAGGE
                        FROM GeneratedTokens
                        WHERE @Token NOT IN
                        (
                            SELECT GeneratedToken
                            FROM GeneratedTokens rpv
                        )
                    ) AS X;
                    IF @STATUS = 'E'
                        BEGIN
                            UPDATE GeneratedTokens
                              SET 
                                  [VerificationStatus] = 0, 
                                  [DateOfTokenUse] = GETDATE()
                            WHERE GeneratedToken = @Token;
                        END;
                END;
        SET @jsonResult =
        (
            SELECT STUFF(
        (
            SELECT '{"IdResult":200' + ',' + '"Status":"' + @STATUS + '",' + '"Message":"' + @MESAGGE + '"}' FOR XML PATH(''), TYPE
        ).value('.', 'varchar(max)'), 1, 1, '')
        );

        -- Retornar el resultado en formato JSON

        SELECT('[{' + @jsonResult + ']') jsonResult;
    END;