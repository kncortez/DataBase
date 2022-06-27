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


