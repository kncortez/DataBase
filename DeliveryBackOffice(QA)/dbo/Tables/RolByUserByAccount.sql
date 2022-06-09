CREATE TABLE [dbo].[RolByUserByAccount] (
    [RuaIdRol]        INT          NOT NULL,
    [RuaIdUser]       BIGINT       NOT NULL,
    [RuaIdAccount]    BIGINT       NOT NULL,
    [RuaRowStatus]    BIT          NOT NULL,
    [RuaTokenCreated] VARCHAR (50) NOT NULL,
    [RuaDateCreated]  DATETIME     NOT NULL,
    [RuaTokenUpdated] VARCHAR (50) NULL,
    [RuaDateUpdated]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([RuaIdRol] ASC, [RuaIdUser] ASC, [RuaIdAccount] ASC),
    CONSTRAINT [FKAccountRUA] FOREIGN KEY ([RuaIdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FKRolRUA] FOREIGN KEY ([RuaIdRol]) REFERENCES [dbo].[CatRol] ([RolIdRol]),
    CONSTRAINT [FKUserRUA] FOREIGN KEY ([RuaIdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);


GO
CREATE NONCLUSTERED INDEX [idx_RuaIdAccount_RuaRowStatus]
    ON [dbo].[RolByUserByAccount]([RuaIdAccount] ASC, [RuaRowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_RuaIdUser]
    ON [dbo].[RolByUserByAccount]([RuaIdUser] ASC);

