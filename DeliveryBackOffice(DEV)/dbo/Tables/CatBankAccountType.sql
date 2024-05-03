CREATE TABLE [dbo].[CatBankAccountType] (
    [IdBankAccountType] INT           IDENTITY (1, 1) NOT NULL,
    [BankAccountType]   NVARCHAR (50) NOT NULL,
    [RowStatus]         BIT           CONSTRAINT [DF_CatBankAccountType_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]      NVARCHAR (50) NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [TokenUpdated]      NVARCHAR (50) NULL,
    [DateUpdated]       DATETIME      NULL,
    CONSTRAINT [PK_CatBankAccountType] PRIMARY KEY CLUSTERED ([IdBankAccountType] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = N'COLUMN',
    @level2name = N'IdBankAccountType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de tipo de cuenta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = N'COLUMN',
    @level2name = N'BankAccountType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de tipo de cuenta de bancos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatBankAccountType',
    @level2type = NULL,
    @level2name = NULL