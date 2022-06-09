CREATE TABLE [dbo].[CatSystem] (
    [SysIdSystem]     INT           IDENTITY (1, 1) NOT NULL,
    [SysNameSystem]   VARCHAR (100) NOT NULL,
    [SysPlataform]    VARCHAR (50)  NOT NULL,
    [SysDescription]  VARCHAR (50)  NULL,
    [SysRowStatus]    BIT           NOT NULL,
    [SysTokenCreated] VARCHAR (50)  NOT NULL,
    [SysDateCreated]  DATETIME      NOT NULL,
    [SysTokenUpdated] VARCHAR (50)  NULL,
    [SysDateUpdated]  DATETIME      NULL,
    [SysShow]         BIT           NULL,
    PRIMARY KEY CLUSTERED ([SysIdSystem] ASC)
);

