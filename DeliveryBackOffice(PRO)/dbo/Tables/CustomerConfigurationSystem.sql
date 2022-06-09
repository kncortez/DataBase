CREATE TABLE [dbo].[CustomerConfigurationSystem] (
    [IdCustomerByModuleBySystem] INT           IDENTITY (1, 1) NOT NULL,
    [CustomerId]                 INT           NOT NULL,
    [SystemId]                   INT           NOT NULL,
    [RowStatus]                  BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdCustomerByModuleBySystem] ASC),
    CONSTRAINT [FK_CustomerBySystem_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CustomerBySystem_System] FOREIGN KEY ([SystemId]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [Unique_CustomerSystem] UNIQUE NONCLUSTERED ([CustomerId] ASC, [SystemId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Configuración de clientes los cuales pueden usar/pasar por sistema.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'IdCustomerByModuleBySystem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del sistema de la tabla CatSystem.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'SystemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationSystem', @level2type = N'COLUMN', @level2name = N'DateUpdated';

