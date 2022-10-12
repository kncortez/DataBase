CREATE TABLE [dbo].[RolByModuleBySystem] (
    [RmsIdRol]          INT          NOT NULL,
    [RmsIdSystem]       INT          NOT NULL,
    [RmsIdModule]       INT          NOT NULL,
    [RmsRowStatus]      BIT          NOT NULL,
    [RmsTokenCreated]   VARCHAR (50) NOT NULL,
    [RmsDateCreated]    DATETIME     NOT NULL,
    [RmsTokenUpdated]   VARCHAR (50) NULL,
    [RmsDateUpdated]    DATETIME     NULL,
    [RmsModuleMenu]     INT          NULL,
    [RmsHasNewFunction] BIT          NULL,
    PRIMARY KEY CLUSTERED ([RmsIdRol] ASC, [RmsIdSystem] ASC, [RmsIdModule] ASC),
    CONSTRAINT [FKModulers] FOREIGN KEY ([RmsIdModule]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FKRolms] FOREIGN KEY ([RmsIdRol]) REFERENCES [dbo].[CatRol] ([RolIdRol]),
    CONSTRAINT [FKSystemrm] FOREIGN KEY ([RmsIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);



