CREATE PROCEDURE [dbo].[SpHWGetStationForCountry]
	@IdUser INT,
	@Username NVARCHAR(50),
	@IdCountry NVARCHAR(2)
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-16>
-- Description:	<Obtener estaciones por pais asignadas al usuario en login Hermes Desktop>
-- =============================================
AS
SELECT DISTINCT STA.IdStation	[IdStation],
				STA.StationName [StationName]
FROM InternalUser IU
INNER JOIN RolByUserBySystem RUS
ON IU.RegisterUserID = RUS.RusIdUser
INNER JOIN CatStation STA
ON RUS.StationId = STA.IdStation
WHERE IU.IdUser = @IdUser
AND IU.Username = @Username
AND RUS.StationId IS NOT NULL
AND RUS.RusIdSystem = 2
AND STA.CountryId = @IdCountry