-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-16>
-- Description:	<spws_get_TokenValidator>
-- =============================================


CREATE PROCEDURE [dbo].[spws_set_UpdatePassword]
	-- Add the parameters for the stored procedure here	
	@Token NVARCHAR(MAX),
	@Password NVARCHAR(MAX)
AS
BEGIN
	
	
	DECLARE @jsonResult NVARCHAR(MAX) 	
	-- 90 dias para cambio de contraseña
	DECLARE @ExpirationDate as date = (SELECT DATEADD(DAY,90,GETDATE()));

			UPDATE RegisterUser
		  SET 
			  UsrLastPassword = @Password, 
			  UsrPasswordExpiration = @ExpirationDate, 
			  UsrDateUpdated = GETDATE()
		WHERE RegisterUser.UsrIdUser =
		(
			SELECT UserId
			FROM ResetPasswordVerification
			WHERE GeneratedToken = @Token
		)

		--desactivar token
		UPDATE ResetPasswordVerification
		SET
		 [Status] = 0
		,[VerificationStatus] = 1
		,[VerificationDate] = GETDATE()
        WHERE GeneratedToken = @Token


SET @jsonResult =(
						SELECT STUFF(
						(
							SELECT  '{"IdResult":200'  + ','  + '"Message":"Se actualizó la contraseña correctamente."}'
							FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'), 1, 1, '')
					)


					-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult



END






