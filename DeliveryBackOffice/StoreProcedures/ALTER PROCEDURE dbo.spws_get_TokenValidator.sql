-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-16>
-- Description:	<spws_get_TokenValidator>
-- =============================================


ALTER PROCEDURE [dbo].[spws_get_TokenValidator]
	-- Add the parameters for the stored procedure here	
	@Token NVARCHAR(MAX),
	@TokenType CHAR(1)
AS
BEGIN
	

	DECLARE @jsonResult NVARCHAR(MAX) 	

	IF @TokenType = 'R' --R = RESET MAIL
	BEGIN

SET @jsonResult =(
						SELECT STUFF(
						(
							SELECT TOP 1 '{"IdResult":200'  + ',' + '"Status":"' + X.STATUS_ + '",' + '"Message":"' + X.MESAGGE + '"}'
							FROM
							(
								SELECT 'A' STATUS_, 
									   'ACTIVE' MESAGGE
								FROM GeneratedTokens
								WHERE GeneratedToken = @Token
									  AND ExpirationDate >= GETDATE()
									  AND [Status] = 1
								UNION ALL
								SELECT 'E' STATUS_, 
									   'EXPIRED' MESAGGE
								FROM GeneratedTokens
								WHERE GeneratedToken = @Token
									  AND ExpirationDate < GETDATE()
								UNION ALL
								SELECT 'I' STATUS_, 
									   'INVALID' MESAGGE
								FROM GeneratedTokens
								WHERE @Token NOT IN
								(
									SELECT GeneratedToken
									FROM GeneratedTokens rpv
								)
							) AS X FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'), 1, 1, '')
					)
	END
	ELSE IF @TokenType = 'V' --V = VALIDATION MAIL
	BEGIN

SET @jsonResult =(
						SELECT STUFF(
						(
							SELECT TOP 1 '{"IdResult":200'  + ',' + '"Status":"' + X.STATUS_ + '",' + '"Message":"' + X.MESAGGE + '"}'
							FROM
							(
								SELECT 'A' STATUS_, 
									   'ACTIVE' MESAGGE
								FROM GeneratedTokens
								WHERE GeneratedToken = @Token
									  AND ExpirationDate >= GETDATE()
									  AND VerificationStatus = 1
								UNION ALL
								SELECT 'E' STATUS_, 
									   'EXPIRED' MESAGGE
								FROM GeneratedTokens
								WHERE GeneratedToken = @Token
									  AND ExpirationDate < GETDATE()
								UNION ALL
								SELECT 'I' STATUS_, 
									   'INVALID' MESAGGE
								FROM GeneratedTokens
								WHERE @Token NOT IN
								(
									SELECT GeneratedToken
									FROM GeneratedTokens rpv
								)
							) AS X FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'), 1, 1, '')
					)

 END
					-- Retornar el resultado en formato JSON

				select ('[{' + @jsonResult +  ']') jsonResult



END






