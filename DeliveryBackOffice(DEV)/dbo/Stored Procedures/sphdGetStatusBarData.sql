-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-07-15>
-- Description:	<Obtiene los datos para mostrar en status bar HermesDesktop>
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-08-30>
-- Description:	<Se coloca validacion para obtener unicamente roles del sistema HermesDesktop>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetStatusBarData]
    @IdUser AS NVARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @NameOfUser NVARCHAR(200)
    DECLARE @UserName NVARCHAR(100)
    DECLARE @RolName NVARCHAR(100)
    DECLARE @CountryName NVARCHAR(100)
    DECLARE @StationName VARCHAR(200)
    DECLARE @RolId INT

    SELECT TOP 1
        @RolId = TBL.RolIdRol,
        @RolName = TBL.RolName
    --,TBL.COUNTADOR 
    FROM
    (
        SELECT A3.RolIdRol,
               dbo.CapitalizeFirstLetter(A3.RolName) AS RolName,
               count(A2.RmsIdModulE) AS COUNTADOR
        FROM RolByUserBySystem A1 WITH (NOLOCK)
            INNER JOIN RolByModuleBySystem A2 WITH (NOLOCK)
                ON A1.RusIdRol = A2.RmsIdRol
            INNER JOIN CatRol A3 WITH (NOLOCK)
                ON A1.RusIdRol = A3.RolIdRol
            INNER JOIN InternalUser A4 WITH (NOLOCK)
                ON A1.RusIdUser = A4.RegisterUserID
        WHERE A4.IdUser = @IdUser
			AND A1.RusIdSystem =  2
        GROUP BY A3.RolIdRol,
                 A3.RolName
    ) TBL
    ORDER BY TBL.COUNTADOR DESC


    SELECT TOP 1
        @NameOfUser = dbo.CapitalizeFirstLetter(CONCAT(A3.PerFirstName, ' ', A3.PerLastName)),
        @Username = A1.Username,
        @CountryName = C.CountryNameES,
        @StationName = IIF(STA.StationType = 1, 'HUB ', '') + STA.StationName
    FROM InternalUser A1 WITH (NOLOCK)
        INNER JOIN RegisterUser A2 WITH (NOLOCK)
            ON A1.RegisterUserID = A2.UsrIdUser
        INNER JOIN Person A3 WITH (NOLOCK)
            ON A2.UsrIdPerson = A3.PerIdPerson
        INNER JOIN RolByUserBySystem RUS WITH (NOLOCK)
            ON A1.RegisterUserID = RUS.RusIdUser
        INNER JOIN CatStation STA WITH (NOLOCK)
            ON RUS.StationId = STA.IdStation
        LEFT JOIN CatCountry C WITH (NOLOCK)
            ON ISNULL(A3.PerCountryOrigin, 'GT') = C.IdCountry
    WHERE A1.IdUser = @IdUser
          AND RUS.RusIdRol = @RolId
          AND RUS.RusIdSystem = 2

    SELECT @NameOfUser NameOfUser,
           @Username Username,
           @RolName RolName,
           @CountryName CountryName,
           @StationName StationName

END
GO
