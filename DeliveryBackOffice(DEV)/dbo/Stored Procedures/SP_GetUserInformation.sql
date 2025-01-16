-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-28-10>
-- Description:	<Método para consultar datos del cliente (sin menu)>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetUserInformation]
@IdAccount INT
AS
BEGIN  
DECLARE @IdTypeOfAccount INT;
DECLARE @UserEmail VARCHAR(100);
DECLARE @ProfileImage VARCHAR(300);
DECLARE @ValTAC INT;
DECLARE @TAC VARCHAR(5);
SELECT  @UserEmail = us.UsrEmail,
        @ProfileImage = ISNULL(ac.ImageProfile, '')
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
    SET @ValTAC =   (  
                        SELECT [dbo].[FnValidateTermsAndConditions](@UserEmail, 0, 1)  
                    ); 
    
    SET @TAC = CASE  
                WHEN @ValTAC = 1 THEN  
                    'TRUE'  
                ELSE  
                    'FALSE'  
            END;  
    SELECT pe.PerFirstName AS FirstName,
        pe.PerLastName AS Lastname,
        ISNULL(pe.PerGender,'') AS Gender,
        ISNULL(pe.PerBirthdate,'') AS Birthdate,
        ISNULL(pe.PerIdentification,'') AS Identification,
        ISNULL(pe.PerNationality,'') AS Nationality,
        ISNULL(us.UsrNickName,'') AS NickName,
        ISNULL(us.PrefixCallingCode, '') AS PrefixCallingCode,
        COALESCE(us.Phone, ' ') AS Phone,
        ISNULL(us.VerifiedPhone, 'false') AS VerifiedPhone,
        @TAC AS TAC,
        @ProfileImage AS ProfileImage
        FROM RegisterUser           us WITH (NOLOCK)  
            INNER JOIN [dbo].Person pe WITH (NOLOCK)  
                ON pe.PerIdPerson = us.UsrIdPerson  
        WHERE us.UsrEmail = @UserEmail  
            AND pe.PerRowStatus = 1  
            AND us.UsrRowStatus = 1  
END ;