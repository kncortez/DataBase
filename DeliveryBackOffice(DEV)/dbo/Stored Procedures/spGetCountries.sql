CREATE PROCEDURE [dbo].[spGetCountries]
	@IdUser INT,
	@Username NVARCHAR(50)
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-15>
-- Description:	<Obtener pais que tiene asignado un usuario en login Hermes Desktop>
-- =============================================

AS
SELECT DISTINCT C.CNT_IdCountry		[IdCountry], 
			    C.CNT_ContryName [Name],
				CASE C.CNT_IdCountry WHEN 'HN' THEN '-2' ELSE '-1' END AS[Station]
FROM DenariusUser_Dev.dbo.LGN_RolByUserByRegion R WITH(NOLOCK)
INNER JOIN DenariusUser_Dev.dbo.LGN_Country C WITH(NOLOCK)
ON  R.RUR_IdCountry = C.CNT_IdCountry
WHERE R.RUR_IdUser =@IdUser AND R.RUR_Username = @Username