CREATE TABLE [dbo].[TokenLog] (
    [TknIdToken]      NVARCHAR (75) NOT NULL,
    [TknIdUser]       BIGINT        NOT NULL,
    [TknIdSystem]     INT           NOT NULL,
    [TknIdHub]        INT           NULL,
    [TknIdModule]     INT           NULL,
    [TknIdCountry]    NVARCHAR (2)  NULL,
    [TknIP]           NVARCHAR (30) NULL,
    [TknRowStatus]    BIT           NOT NULL,
    [TknTokenCreated] VARCHAR (50)  NOT NULL,
    [TknDateCreated]  DATETIME      NOT NULL,
    [TknTokenUpdated] VARCHAR (50)  NULL,
    [TknDateUpdated]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TknIdToken] ASC),
    CONSTRAINT [FKTokenSystem] FOREIGN KEY ([TknIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FKTokenUser] FOREIGN KEY ([TknIdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);












GO
CREATE NONCLUSTERED INDEX [IDX_TokenLog_TknTokenCreated]
    ON [dbo].[TokenLog]([TknTokenCreated] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_TknRowStatus_TknDateCreated_include]
    ON [dbo].[TokenLog]([TknRowStatus] ASC, [TknDateCreated] ASC)
    INCLUDE([TknIdUser]);


GO
CREATE NONCLUSTERED INDEX [IDX_TknIdUser_TknRowStatus_TknDateCreated]
    ON [dbo].[TokenLog]([TknIdUser] ASC, [TknRowStatus] ASC, [TknDateCreated] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_TknIdUser]
    ON [dbo].[TokenLog]([TknIdUser] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_TknIdSystem]
    ON [dbo].[TokenLog]([TknIdSystem] ASC);

