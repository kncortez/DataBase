CREATE TABLE [dbo].[SaleAdvisorbyUser] (
    [idSaleAdvisorbyUser] INT           IDENTITY (1, 1) NOT NULL,
    [UserId]              BIGINT        NOT NULL,
    [UserName]            NVARCHAR (50) NOT NULL,
    [SaleAdvisorId]       INT           NOT NULL,
    [RowStatus]           BIT           NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]         DATETIME      NULL,
    CONSTRAINT [PK_SaleAdvisorbyUser] PRIMARY KEY CLUSTERED ([idSaleAdvisorbyUser] ASC),
    CONSTRAINT [FK_InternalUserSaleAdvisroId] FOREIGN KEY ([SaleAdvisorId]) REFERENCES [dbo].[CatSaleAdvisor] ([IdSaleAdvisor]),
    CONSTRAINT [FK_SaleAdvisorbyUserUserId] FOREIGN KEY ([UserId], [UserName]) REFERENCES [dbo].[InternalUser] ([IdUser], [Username]),
    CONSTRAINT [UK_SaleAdvisorbyUser] UNIQUE NONCLUSTERED ([UserId] ASC, [SaleAdvisorId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_SaleAdvisorbyUserUserId]
    ON [dbo].[SaleAdvisorbyUser]([UserId] ASC, [UserName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UseIdSaleAdvisorId]
    ON [dbo].[SaleAdvisorbyUser]([UserId] ASC, [SaleAdvisorId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del registro ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'idSaleAdvisorbyUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'UserName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del código del vendedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'SaleAdvisorId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SaleAdvisorbyUser', @level2type = N'COLUMN', @level2name = N'DateUpdated';

