-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <23/08/2024>
-- Description:	<Trae el pais del correo utilizado en parser>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getEmailParser_BNHL] 
	@Email NVARCHAR(40) 
AS
BEGIN
	SELECT 'GT' AS IdCountryParser 	
END