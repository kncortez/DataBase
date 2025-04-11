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
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-08-29>
-- Description:	<Se agregan mejoras para multipais>
-- =============================================
AS
BEGIN

	DECLARE @StationDenariusUser TABLE (
		IdStation INT PRIMARY KEY,
		StationName NVARCHAR(100),
		IdCountry NVARCHAR(2)
	);

	INSERT INTO @StationDenariusUser (IdStation, StationName, IdCountry)
	SELECT 
		  STN_IdStation
		, STN_StationName
		, STN_IdCountry
	FROM DenariusUser_Dev.dbo.LGN_Station
	WHERE STN_StationName = 'Todas las estaciones'

    SELECT DISTINCT
           ISNULL(C.IdCountry, 'GT')            [IdCountry]
         , ISNULL(C.CountryNameES, 'Guatemala') [Name]
         , CAST(IdStation AS NVARCHAR(10))		[Station]
    FROM DeliveryBackOffice.dbo.Person                 p WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.RegisterUser R WITH (NOLOCK)
            ON p.PerIdPerson = R.UsrIdPerson
        INNER JOIN DeliveryBackOffice.dbo.InternalUser I WITH (NOLOCK)
            ON I.RegisterUserID = R.UsrIdUser
               AND R.UsrIdPerson = p.PerIdPerson
        LEFT JOIN DeliveryBackOffice.dbo.CatCountry    C WITH (NOLOCK)
            ON p.PerCountryOrigin = C.IdCountry
		LEFT JOIN @StationDenariusUser S
			ON ISNULL(C.IdCountry,'GT') = S.IdCountry
    WHERE I.IdUser = @IdUser
          AND I.Username = @Username
          AND R.UsrRowStatus = 1
		  AND p.PerRowStatus =1
		  AND i.RowStatus =1
		 

END;