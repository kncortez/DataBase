CREATE TABLE [dbo].[RolByUserBySystem] (
    [RusIdRol]        INT          NOT NULL,
    [RusIdSystem]     INT          NOT NULL,
    [RusIdUser]       BIGINT       NOT NULL,
    [RusRowStatus]    BIT          NOT NULL,
    [RusTokenCreated] VARCHAR (50) NOT NULL,
    [RusDateCreated]  DATETIME     NOT NULL,
    [RusTokenUpdated] VARCHAR (50) NULL,
    [RusDateUpdated]  DATETIME     NULL,
    [StationId]       INT          NULL,
    [RowID]           INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    CONSTRAINT [PK_RolByUserBySystem] PRIMARY KEY CLUSTERED ([RowID] ASC),
    CONSTRAINT [FK_RolByUserBySystem_CatStation] FOREIGN KEY ([StationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FKRolRMS] FOREIGN KEY ([RusIdRol]) REFERENCES [dbo].[CatRol] ([RolIdRol]),
    CONSTRAINT [FKSystemRMS] FOREIGN KEY ([RusIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FKUserRMS] FOREIGN KEY ([RusIdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);








GO
CREATE NONCLUSTERED INDEX [IX_RolByUserBySystem]
    ON [dbo].[RolByUserBySystem]([RusIdRol] ASC, [RusIdSystem] ASC, [RusIdUser] ASC, [StationId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_RusIdSystem_RusIdUser]
    ON [dbo].[RolByUserBySystem]([RusIdSystem] ASC, [RusIdUser] ASC)
    INCLUDE([StationId]);


GO
CREATE NONCLUSTERED INDEX [idx_RusRowStatus_include]
    ON [dbo].[RolByUserBySystem]([RusRowStatus] ASC)
    INCLUDE([RusIdRol], [RusIdUser], [StationId]);


GO
CREATE NONCLUSTERED INDEX [IDX_RusIdUser_RusRowStatus_INCLUDE]
    ON [dbo].[RolByUserBySystem]([RusIdUser] ASC, [RusRowStatus] ASC)
    INCLUDE([RusIdRol], [StationId]);

