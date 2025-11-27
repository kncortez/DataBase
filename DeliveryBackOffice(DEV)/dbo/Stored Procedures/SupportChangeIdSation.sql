CREATE PROCEDURE SupportChangeIdSation
    @StationId INT
  , @RusIdUSer INT
AS
BEGIN
    UPDATE RolByUserBySystem
    SET StationId = @StationId
    WHERE RusIdUser = @RusIdUSer;
END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportChangeIdSation] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportChangeIdSation] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportChangeIdSation] TO [cvaldes]
    AS [dbo];

