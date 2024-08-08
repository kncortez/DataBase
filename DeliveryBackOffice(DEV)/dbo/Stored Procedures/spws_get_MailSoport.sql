-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-07-22>
-- Description:	<Obtener correo de soporte según país>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_MailSoport]
	-- Add the parameters for the stored procedure here	
	@username VARCHAR(200) 
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CountryId NVARCHAR(3);
	DECLARE @EmailSoport NVARCHAR(50);
	
-- validar país de usuario
	   SET @CountryId =(SELECT TOP 1  
	                                  CASE WHEN LEFT(ISNULL(UsrCurrency,'GTQ'),2)='HN' 
									  THEN 'HN' ELSE 'GT' END  
						FROM dbo.RegisterUser WHERE UsrEmail=@Username);

--validar que correo de soporte correspondiente segun país
	  SET @EmailSoport =( SELECT ISNULL([Value],'info.gt@forzadelivery.com')  FROM [dbo].[ConfigParams] 
	                           WHERE [Name]='SupportEmailByCountry' AND IdCountry = @CountryId 
	                        )

	SELECT @EmailSoport AS 'EmailSoport'

END