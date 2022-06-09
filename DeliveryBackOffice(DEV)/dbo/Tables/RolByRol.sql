CREATE TABLE [dbo].[RolByRol] (
    [RbrIdRolAdmin] INT NOT NULL,
    [RbrIdRolChild] INT NOT NULL,
    [RbrRowStatus]  BIT NOT NULL,
    PRIMARY KEY CLUSTERED ([RbrIdRolAdmin] ASC, [RbrIdRolChild] ASC),
    CONSTRAINT [FKRolAdmin] FOREIGN KEY ([RbrIdRolAdmin]) REFERENCES [dbo].[CatRol] ([RolIdRol]),
    CONSTRAINT [FKRolChild] FOREIGN KEY ([RbrIdRolChild]) REFERENCES [dbo].[CatRol] ([RolIdRol])
);

