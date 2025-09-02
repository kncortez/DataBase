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
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportInsertRol] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportInsertRol] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportInsertRol] TO [cvaldes]
    AS [dbo];

