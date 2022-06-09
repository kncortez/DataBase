CREATE TABLE [dbo].[CatRol] (
    [RolIdRol]         INT           IDENTITY (1, 1) NOT NULL,
    [RolIdSystem]      INT           NOT NULL,
    [RolName]          VARCHAR (50)  NOT NULL,
    [RolDescription]   VARCHAR (100) NOT NULL,
    [RolAdminBrothers] BIT           NULL,
    [RolAdminClient]   BIT           NOT NULL,
    [RolRowStatus]     BIT           NOT NULL,
    [RolTokenCreated]  VARCHAR (50)  NOT NULL,
    [RolDateCreated]   DATETIME      NOT NULL,
    [RolokenUpdated]   VARCHAR (50)  NULL,
    [RolDateUpdated]   DATETIME      NULL,
    [RolAdminInternal] BIT           NULL,
    PRIMARY KEY CLUSTERED ([RolIdRol] ASC),
    FOREIGN KEY ([RolIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);

