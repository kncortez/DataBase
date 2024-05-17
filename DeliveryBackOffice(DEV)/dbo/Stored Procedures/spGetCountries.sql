CREATE PROCEDURE [dbo].[spGetCountries]
	@IdUser INT,
	@Username NVARCHAR(50)
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-15>
-- Description:	<Obtener pais que tiene asignado un usuario en login Hermes Desktop>
-- =============================================

AS
SELECT DISTINCT C.IdCountry		[IdCountry], 
			    C.CountryNameES [Name],
				CASE C.IdCountry WHEN 'HN' THEN '-2' ELSE '-1' END AS[Station]
FROM DenariusUser_Dev.dbo.LGN_RolByUserByRegion R
INNER JOIN DeliveryBackOffice.dbo.CatCountry C on  R.RUR_IdCountry = C.IdCountry
WHERE R.RUR_IdUser =@IdUser AND R.RUR_Username = @Username
