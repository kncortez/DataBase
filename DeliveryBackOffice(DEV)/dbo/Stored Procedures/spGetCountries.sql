CREATE PROCEDURE [dbo].[spGetCountries]
	@IdUser INT,
	@Username NVARCHAR(50)
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-15>
-- Description:	<Obtener pais que tiene asignado un usuario en login Hermes Desktop>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-31>
-- Description:	<Se modifica sp para mostrar unicamente pais donde el usuario esta registrado para login Hermes Desktop>
-- =============================================
AS
SELECT DISTINCT ISNULL(C.IdCountry, 'GT') [IdCountry],
				ISNULL(C.CountryNameES, 'Guatemala') [Name],
				CASE C.IdCountry WHEN 'HN' THEN '-2' ELSE '-1' END AS[Station]
FROM DeliveryBackOffice.dbo.Person p WITH(NOLOCK)
INNER JOIN DeliveryBackOffice.dbo.RegisterUser R WITH(NOLOCK)
ON  P.PerIdPerson = R.UsrIdPerson
INNER JOIN DeliveryBackOffice.dbo.InternalUser I WITH (NOLOCK)
ON I.RegisterUserID = R.UsrIdUser AND I.Username = R.UsrNickName
LEFT JOIN DeliveryBackOffice.dbo.CatCountry C WITH (NOLOCK)
ON P.PerCountryOrigin = C.IdCountry
WHERE I.IdUser = @IdUser AND I.Username = @Username