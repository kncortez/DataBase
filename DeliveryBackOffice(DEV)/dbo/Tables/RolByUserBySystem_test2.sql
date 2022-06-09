CREATE TABLE [dbo].[RolByUserBySystem_test2] (
    [RusIdRol]        INT          NOT NULL,
    [RusIdSystem]     INT          NOT NULL,
    [RusIdUser]       BIGINT       NOT NULL,
    [RusRowStatus]    BIT          NOT NULL,
    [RusTokenCreated] VARCHAR (50) NOT NULL,
    [RusDateCreated]  DATETIME     NOT NULL,
    [RusTokenUpdated] VARCHAR (50) NULL,
    [RusDateUpdated]  DATETIME     NULL,
    [StationId]       INT          NOT NULL,
    [RegisterUserID]  BIGINT       NULL
);

