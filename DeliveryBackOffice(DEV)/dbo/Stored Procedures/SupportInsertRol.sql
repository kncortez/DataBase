CREATE PROCEDURE SupportInsertRol
    @RusIdRol INT,
    @RusIdSystem INT,
    @RusIdUser BIGINT,
    @RusTokenCreated VARCHAR(50),
    @StationId INT
AS
BEGIN
    INSERT INTO dbo.RolByUserBySystem
    (
        RusIdRol,
        RusIdSystem,
        RusIdUser,
        RusRowStatus,
        RusTokenCreated,
        RusDateCreated,
        RusTokenUpdated,
        RusDateUpdated,
        StationId
    )
    VALUES
    (
        @RusIdRol,
        @RusIdSystem,
        @RusIdUser,
        1, -- RusRowStatus, siempre 1
        @RusTokenCreated,
        GETDATE(), -- RusDateCreated
        NULL, -- RusTokenUpdated
        NULL, -- RusDateUpdated
        @StationId
    )
END