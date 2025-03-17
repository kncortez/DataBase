CREATE TABLE [dbo].[RatebyCustomer] (
    [RbcId]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [RbcIdRate]          INT          NOT NULL,
    [RbcIdCustomer]      INT          NOT NULL,
    [RbcRowStatus]       BIT          NOT NULL,
    [RbcTokenCreated]    VARCHAR (50) NOT NULL,
    [RbcDateCreated]     DATETIME     NOT NULL,
    [RbcTokenUpdated]    VARCHAR (50) NULL,
    [RbcDateUpdated]     DATETIME     NULL,
    [RbcCodeOfReference] INT          NULL,
    PRIMARY KEY CLUSTERED ([RbcId] ASC),
    FOREIGN KEY ([RbcCodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FKRbcCustomer] FOREIGN KEY ([RbcIdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FKRbcRate] FOREIGN KEY ([RbcIdRate]) REFERENCES [dbo].[RateHeader] ([RheId])
);










GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para vincular tarifario con un punto de visita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcCodeOfReference';


GO
CREATE NONCLUSTERED INDEX [IX_RatebyCustomer]
    ON [dbo].[RatebyCustomer]([RbcIdCustomer] ASC, [RbcRowStatus] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de tarifas por cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcTokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcTokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcRowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tarifario de la tabla RateHeader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcIdRate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcIdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcDateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RatebyCustomer', @level2type = N'COLUMN', @level2name = N'RbcDateCreated';


GO
CREATE NONCLUSTERED INDEX [idx_RbcIdRate]
    ON [dbo].[RatebyCustomer]([RbcIdRate] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_RbcIdCustomer_RbcRowStatus_RbcCodeOfReference]
    ON [dbo].[RatebyCustomer]([RbcIdCustomer] ASC, [RbcRowStatus] ASC, [RbcCodeOfReference] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_RbcIdCustomer]
    ON [dbo].[RatebyCustomer]([RbcIdCustomer] ASC);

