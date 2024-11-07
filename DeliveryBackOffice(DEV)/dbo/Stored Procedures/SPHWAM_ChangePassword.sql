-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-11-04>
-- Description:	<Cambio de contraseña desde la App Móvil>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWAM_ChangePassword]
	-- Add the parameters for the stored procedure here
	@Email AS NVARCHAR(200),
    @Code NVARCHAR(50),  
    @Token NVARCHAR(20),
    @CountryId AS NVARCHAR(2) ='GT'
AS
BEGIN
    DECLARE @FirstName AS NVARCHAR(100); 
	DECLARE @LastName AS NVARCHAR(100);
    DECLARE  @IdAccount  INT;
    DECLARE @IsConfirmed AS NVARCHAR(1);
    SELECT @FirstName = pe.PerFirstName,
			@LastName = pe.PerLastName,
            @IdAccount = ac.AccIdAccount,
            @IsConfirmed = ac.AccConfirm            
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
        WHERE us.UsrEmail = @Email
    IF(@@ROWCOUNT > 0)
    BEGIN
        DECLARE @PBX NVARCHAR (5) = (SELECT [Value] FROM ConfigParams WHERE IdCountry = @CountryId AND Name = 'PBX');  
        DECLARE @CountryName NVARCHAR (50) = (SELECT CountryNameES FROM CatCountry WHERE IdCountry = @CountryId);  
    
        IF(@IsConfirmed = 'V')
        BEGIN 
            SELECT 0 AS [StatusCode], 'La cuenta ya fue verificada' AS[MessageResponse]
        END
        ELSE IF(@IsConfirmed = 'C')
        BEGIN
            BEGIN TRANSACTION  
            UPDATE Account
                SET AccConfirm = 'P', 
                    AccTokenUpdated = @Token,
                    AccDateUpdated = GETDATE()
            WHERE AccIdAccount = @IdAccount;
            UPDATE RegisterUser
                SET UsrLastPassword = @Code, 
                    UsrTokenUpdated = @Token,
                    UsrDateUpdated = GETDATE()
            WHERE UsrEmail = @Email;
            IF @@TRANCOUNT > 0 
            BEGIN  
                COMMIT TRANSACTION;  
                SELECT 1 AS [StatusCode], 'Correo enviado con éxito' AS [MessageResponse], @FirstName AS [FirstName], @LastName AS [LastName], @CountryName AS [CountryName], @Email AS [Email], @PBX AS [PBX], @IdAccount AS AccountId 
            END  
        END
        ELSE
        BEGIN
            SELECT 0 AS [StatusCode], 'La cuenta está pendiente de verificacion' AS[MessageResponse]
        END
    END
    ELSE
    BEGIN
        SELECT 0 AS [StatusCode], 'Correo no encontrado' AS[MessageResponse]
    END
    
	
END