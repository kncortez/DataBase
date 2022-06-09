CREATE TABLE [dbo].[CustomerConfigurationCOD] (
    [CustomerConfigurationCODId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [CustomerId]                 INT          NOT NULL,
    [IdCatBatchTypeCOD]          BIGINT       NOT NULL,
    [IdCatBatchFrequencyCOD]     BIGINT       NOT NULL,
    [RowStatus]                  BIT          NOT NULL,
    [TokenCreated]               VARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME     NOT NULL,
    [TokenUpdated]               VARCHAR (50) NULL,
    [DateUpdated]                DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([CustomerConfigurationCODId] ASC),
    CONSTRAINT [FK_CustomerConfigurationCOD_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_CustomerConfigurationCOD_IdCatBatchFrequencyCOD] FOREIGN KEY ([IdCatBatchFrequencyCOD]) REFERENCES [dbo].[CatBatchFrequencyCOD] ([CatBatchFrequencyCODId]),
    CONSTRAINT [FK_CustomerConfigurationCOD_IdCatBatchTypeCOD] FOREIGN KEY ([IdCatBatchTypeCOD]) REFERENCES [dbo].[CatBatchTypeCOD] ([CatBatchTypeCODId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id para la tabla CustomerConfigurationCOD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'CustomerConfigurationCODId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de la tabla CatBatchTypeCOD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'IdCatBatchTypeCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id para la tabla CatBatchFrequencyCOD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'IdCatBatchFrequencyCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el estado del registro, para poder deshabilitarlo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el token de usuario con el que se insertó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es la fecha en la que se insertó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el token de usuario con el que se actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es la fecha en que se actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerConfigurationCOD', @level2type = N'COLUMN', @level2name = N'DateUpdated';

