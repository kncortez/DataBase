-- =============================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-01-19>
-- Update date: <2021-02-04>
-- Description:	<spws_get_GetInfoForConfirmationEmail>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_GetInfoForConfirmationEmail]
	@ParamName as VARCHAR(200),
	@IdAccount AS BIGINT,
	@UserName  AS VARCHAR(200),
	@Token     AS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @IdUser AS bigint;
	IF @Token != '0' OR @Token!= ''
	BEGIN
	 SET @IdUser =
                (
                    SELECT rp.UserId
                    FROM GeneratedTokens rp
                    WHERE GeneratedToken = @Token
                );
	END

	SELECT 
	ParamValue = (SELECT cp.[Value] FROM dbo.ConfigParams cp	WHERE cp.[Name] = @ParamName ),
	us.UsrIdUser AS IdUser,
	us.UsrEmail         AS Email,
	us.UsrNickName      AS NickName,
	c.[Name]            AS [Name],
	pe.PerGender        AS Gender
	FROM RegisterUser us
		INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
													AND rua.RuaRowStatus = 1
		INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
									AND ac.AccRowStatus = 1
		INNER JOIN dbo.Customer c	ON c.IdCustomer = ac.IdCustomer
		INNER JOIN [dbo].Person pe ON pe.PerIdPerson = us.UsrIdPerson AND pe.PerRowStatus = 1

	WHERE ac.AccIdAccount = @IdAccount OR us.UsrEmail = LTRIM(RTRIM(@UserName)) OR us.UsrIdUser =  @IdUser
END

