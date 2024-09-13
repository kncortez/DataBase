CREATE TABLE [dbo].[CatBillingTime] (
    [IdCatBillingTime]       INT            IDENTITY (1, 1) NOT NULL,
    [DescriptionBillingTime] NVARCHAR (200) NOT NULL,
    [RowStatus]              BIT            CONSTRAINT [DF_CatBillingTime_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50)  NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdated]           NVARCHAR (50)  NULL,
    [DateUpdated]            DATETIME       NULL,
    CONSTRAINT [PK_CatBillingTime] PRIMARY KEY CLUSTERED ([IdCatBillingTime] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingTime', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario que realiza la actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingTime', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingTime', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de usuario que crea el articulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingTime', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indica si el articulo esta activo o inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingTime', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de tiempo de facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingTime', @level2type = N'COLUMN', @level2name = N'DescriptionBillingTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de catalogo de tiempo de facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBillingTime', @level2type = N'COLUMN', @level2name = N'IdCatBillingTime';


GO
