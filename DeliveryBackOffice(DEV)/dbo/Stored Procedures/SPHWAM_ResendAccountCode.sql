-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-11-04>
-- Description:	<Reenvío de código de 4 dígitos desde la App Móvil>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWAM_ResendAccountCode]
	-- Add the parameters for the stored procedure here
 	@IdAccount  INT,
	@CountryId AS NVARCHAR(2) ='GT'
AS
BEGIN
	DECLARE @CodeTemporal AS NVARCHAR(50);
  	DECLARE @IsConfirmed AS NVARCHAR(1);
	DECLARE @FirstName AS NVARCHAR(100); 
	DECLARE @LastName AS NVARCHAR(100); 
    DECLARE @Email AS NVARCHAR(200); 
  	SELECT @IsConfirmed = AccConfirm 
          FROM Account 
          WHERE AccIdAccount = @IdAccount
  	IF(@IsConfirmed != 'C')
  	BEGIN
    SELECT  @CodeTemporal = UsrLastPassword,
			@FirstName = pe.PerFirstName,
			@LastName = pe.PerLastName,
            @Email = us.UsrEmail
        FROM RegisterUser   us WITH (NOLOCK)  
			INNER JOIN [dbo].Person               pe WITH (NOLOCK)  
				ON pe.PerIdPerson = us.UsrIdPerson  
			INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)  
				ON rua.RuaIdUser = us.UsrIdUser  
			INNER JOIN [dbo].CatRol               ro WITH (NOLOCK)  
				ON ro.RolIdRol = rua.RuaIdRol  
			INNER JOIN [dbo].Account              ac WITH (NOLOCK)  
				ON ac.AccIdAccount = rua.RuaIdAccount  
			INNER JOIN [dbo].CatTypeAccount       ta WITH (NOLOCK)  
				ON ta.TacIdTypeAccount = ac.AccIdTypeAccount  
        WHERE ac.AccIdAccount = @IdAccount

	DECLARE @CountryName NVARCHAR (50) = (SELECT CountryNameES FROM CatCountry WHERE IdCountry = @CountryId);  
	SELECT 1 AS [StatusCode], 'Consulta exitosa' AS[MessageResponse], @CodeTemporal AS [Code],@FirstName AS [FirstName], @LastName AS [LastName], @CountryName AS [CountryName], @Email AS [Email]
	END
	ELSE
	BEGIN
		SELECT 0 AS [StatusCode], 'La cuenta ya se encuentra confirmada' AS[MessageResponse]
	END
END