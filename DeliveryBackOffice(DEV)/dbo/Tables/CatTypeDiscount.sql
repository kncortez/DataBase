CREATE TABLE [dbo].[CatTypeDiscount] (
    [IdCatTypeDiscount] INT           IDENTITY (1, 1) NOT NULL,
    [Name]              VARCHAR (50)  NOT NULL,
    [ShortName]         VARCHAR (10)  NOT NULL,
    [Description]       VARCHAR (100) NULL,
    [RowStatus]         BIT           NOT NULL,
    [TokenCreated]      VARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME      NOT NULL,
    [TokenUpdated]      VARCHAR (50)  NULL,
    [DateUpdated]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdCatTypeDiscount] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de tipos de descuento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'IdCatTypeDiscount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de descuento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Abreviación del tipo de descuento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'ShortName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de descuento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeDiscount', @level2type = N'COLUMN', @level2name = N'DateUpdated';

