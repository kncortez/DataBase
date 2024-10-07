CREATE PROCEDURE SupportChangeIdSation
    @StationId INT
  , @RusIdUSer INT
AS
BEGIN
    UPDATE RolByUserBySystem
    SET StationId = @StationId
    WHERE RusIdUser = @RusIdUSer;
END;