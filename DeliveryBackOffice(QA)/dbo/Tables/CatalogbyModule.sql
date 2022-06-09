CREATE TABLE [dbo].[CatalogbyModule] (
    [IdCatModule]  INT           IDENTITY (1, 1) NOT NULL,
    [NameCatalog]  NVARCHAR (50) NULL,
    [ModuleID]     INT           NULL,
    [SystemID]     INT           NULL,
    [RowStatus]    BIT           CONSTRAINT [DF_CatalogbyModule_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated] NVARCHAR (50) NULL,
    [DateCreated]  DATETIME      NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_CatalogbyModule] PRIMARY KEY CLUSTERED ([IdCatModule] ASC),
    CONSTRAINT [FK_CatalogbyModule_CatModule] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_CatalogbyModule_CatSystem] FOREIGN KEY ([SystemID]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);

