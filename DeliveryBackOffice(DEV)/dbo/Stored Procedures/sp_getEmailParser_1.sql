-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <23/08/2024>
-- Description:	<Trae el pais del correo utilizado en parser>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getEmailParser] 
	@Email NVARCHAR(40) 
AS
BEGIN
	SELECT IdCountry AS IdCountryParser 
	FROM ConfigParams WHERE Name = 'EmailByParser' AND Value = @Email
END