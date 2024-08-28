-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-05-16>
-- Description:	<Obtener estaciones por pais asignadas al usuario en login Hermes Desktop>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-06-19>
-- Description:	<Agregar filtro de sistema Hermes Mobile Linehaul>
-- =============================================
CREATE PROCEDURE [dbo].[SpHWGetStationForCountry]
	@IdUser INT,
	@Username NVARCHAR(50),
	@IdCountry NVARCHAR(2),
	@IdSystem INT = 2

AS

SET NOCOUNT ON;

SELECT DISTINCT STA.IdStation [IdStation],
                STA.StationName [StationName]
FROM InternalUser IU WITH(NOLOCK)
INNER JOIN RolByUserBySystem RUS WITH(NOLOCK) ON IU.RegisterUserID = RUS.RusIdUser
INNER JOIN CatStation STA WITH(NOLOCK) ON RUS.StationId = STA.IdStation
WHERE IU.IdUser = @IdUser
  AND IU.Username = @Username
  AND RUS.StationId IS NOT NULL
  AND RUS.RusIdSystem = @IdSystem
  AND STA.CountryId = @IdCountry