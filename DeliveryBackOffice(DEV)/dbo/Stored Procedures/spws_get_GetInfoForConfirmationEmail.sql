-- =============================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-01-19>
-- Update date: <2021-02-04>
-- Description:	<spws_get_GetInfoForConfirmationEmail>
-- =============================================
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-07-08>
-- Description:	<Se agrega campo en la consulta con el correo de información según país del cliente>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_GetInfoForConfirmationEmail]
	@ParamName as VARCHAR(200),
	@IdAccount AS BIGINT,
	@UserName  AS VARCHAR(200),
	@Token     AS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @CorreoPredeterminado AS VARCHAR(100) = (SELECT cp3.Value 
														FROM dbo.ConfigParams cp3	
														WHERE cp3.Name = 'SupportEmailByCountry' 
															AND cp3.IdCountry = 'GT' 
															AND cp3.Status = 1 );
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
	cp1.Value			AS ParamValue,
	ISNULL(cp2.Value, @CorreoPredeterminado)		AS CorreoPais, 
	us.UsrIdUser AS IdUser,
	us.UsrEmail         AS Email,
	us.UsrNickName      AS NickName,
	c.[Name]            AS [Name],
	pe.PerGender        AS Gender
	FROM RegisterUser us WITH (NOLOCK)
		INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK) ON rua.RuaIdUser = us.UsrIdUser
													AND rua.RuaRowStatus = 1
		INNER JOIN [dbo].Account ac WITH (NOLOCK) ON ac.AccIdAccount = rua.RuaIdAccount
									AND ac.AccRowStatus = 1
		INNER JOIN dbo.Customer c WITH (NOLOCK)	ON c.IdCustomer = ac.IdCustomer
		INNER JOIN [dbo].Person pe WITH (NOLOCK) ON pe.PerIdPerson = us.UsrIdPerson AND pe.PerRowStatus = 1
		LEFT JOIN [dbo].[ConfigParams] cp1 ON cp1.Name = @ParamName
		LEFT JOIN [dbo].[ConfigParams] cp2 ON cp2.Name = 'SupportEmailByCountry' 
													AND cp2.IdCountry = c.CountryID 
													AND cp2.Status = 1
	WHERE ac.AccIdAccount = @IdAccount OR us.UsrEmail = LTRIM(RTRIM(@UserName)) OR us.UsrIdUser =  @IdUser
END

