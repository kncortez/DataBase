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
    [TknReferrer]     VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([TknIdToken] ASC),
    CONSTRAINT [FKTokenSystem] FOREIGN KEY ([TknIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FKTokenUser] FOREIGN KEY ([TknIdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Host en donde se realizó el ingreso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TokenLog', @level2type = N'COLUMN', @level2name = N'TknReferrer';

