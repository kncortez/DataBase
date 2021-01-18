-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-16>
-- Description:	<spws_get_TokenValidator>
-- =============================================


create PROCEDURE [dbo].[spws_get_TokenValidator]
	-- Add the parameters for the stored procedure here	
	@Token NVARCHAR(MAX)
AS
BEGIN
	

	DECLARE @jsonResult NVARCHAR(MAX) 	

SET @jsonResult =(
						SELECT STUFF(
						(
							SELECT TOP 1 '{"IdResult":200'  + ',' + '"Status":"' + X.STATUS_ + '",' + '"Message":"' + X.MESAGGE + '"}'
							FROM
							(
								SELECT 'A' STATUS_, 
									   'ACTIVE' MESAGGE
								FROM [ResetPasswordVerification]
								WHERE dbo.ResetPasswordVerification.GeneratedToken = @Token
									  AND ExpirationDate >= GETDATE()
									  AND [Status] = 1
								UNION ALL
								SELECT 'E' STATUS_, 
									   'EXPIRED' MESAGGE
								FROM [ResetPasswordVerification]
								WHERE dbo.ResetPasswordVerification.GeneratedToken = @Token
									  AND ExpirationDate <= GETDATE()
								UNION ALL
								SELECT 'I' STATUS_, 
									   'INVALID' MESAGGE
								FROM [ResetPasswordVerification]
								WHERE @Token NOT IN
								(
									SELECT dbo.ResetPasswordVerification.GeneratedToken
									FROM dbo.ResetPasswordVerification rpv
								)
							) AS X FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'), 1, 1, '')
					)


					-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult



END






