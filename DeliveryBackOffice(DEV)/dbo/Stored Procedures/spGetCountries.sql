CREATE PROCEDURE [dbo].[spGetCountries]
    @IdUser INT
  , @Username NVARCHAR(50)
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-15>
-- Description:	<Obtener pais que tiene asignado un usuario en login Hermes Desktop>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-31>
-- Description:	<Se modifica sp para mostrar unicamente pais donde el usuario esta registrado para login Hermes Desktop>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-08-29>
-- Description:	<Se modifica condicion en join y agrega row status>
-- =============================================
AS
BEGIN
    SELECT DISTINCT
           ISNULL(C.IdCountry, 'GT')            [IdCountry]
         , ISNULL(C.CountryNameES, 'Guatemala') [Name]
         , CASE C.IdCountry
               WHEN 'HN' THEN
                   '-2'
               ELSE
                   '-1'
           END                                  AS [Station]
    FROM DeliveryBackOffice.dbo.Person                 p WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.RegisterUser R WITH (NOLOCK)
            ON p.PerIdPerson = R.UsrIdPerson
        INNER JOIN DeliveryBackOffice.dbo.InternalUser I WITH (NOLOCK)
            ON I.RegisterUserID = R.UsrIdUser
               AND R.UsrIdPerson = p.PerIdPerson
        LEFT JOIN DeliveryBackOffice.dbo.CatCountry    C WITH (NOLOCK)
            ON p.PerCountryOrigin = C.IdCountry
    WHERE I.IdUser = @IdUser
          AND I.Username = @Username
          AND R.UsrRowStatus = 1
		  AND p.PerRowStatus =1
		  AND i.RowStatus =1
		 

END;