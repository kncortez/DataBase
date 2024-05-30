CREATE TABLE [dbo].[CatArticleSAP] (
    [IdCatArticleSAP]         INT             IDENTITY (1, 1) NOT NULL,
    [CatCategoryArticleSAPId] INT             NOT NULL,
    [Name]                    NVARCHAR (100)  NOT NULL,
    [Description]             NVARCHAR (100)  NULL,
    [SAPCode]                 NVARCHAR (50)   NULL,
    [RowSatus]                BIT             CONSTRAINT [DF_CatArticleSAP_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]            NVARCHAR (50)   NULL,
    [DateCreated]             DATETIME        NULL,
    [TokenUpdated]            NVARCHAR (50)   NULL,
    [DateUpdated]             DATETIME        NULL,
    [Category]                VARCHAR (50)    NULL,
    [Price]                   DECIMAL (14, 2) NULL,
    [CardPercent]             DECIMAL (3, 2)  NULL,
    [CardAmount]              DECIMAL (14, 2) NULL,
    [IsSurcharge]             BIT             NULL,
    [SendAlmacenExp]          BIT             DEFAULT ('false') NULL,
    PRIMARY KEY CLUSTERED ([IdCatArticleSAP] ASC),
    CONSTRAINT [FK_CatArticleSAP_CatCategoryArticleSAP] FOREIGN KEY ([CatCategoryArticleSAPId]) REFERENCES [dbo].[CatArticleCategorySAP] ([IdCatCategoryArticleSAP]) ON DELETE CASCADE
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id CatArticleSAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'IdCatArticleSAP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id CatCategoryArticleSAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'CatCategoryArticleSAPId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código SAP artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'SAPCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RowSatus artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'RowSatus';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TokenCreated artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'TokenCreated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DateCreated artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'DateCreated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TokenUpdated artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'TokenUpdated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DateUpdated artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'DateUpdated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar si es BIEN o SERVICIO.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'Category';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar un precio predefinido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'Price';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el porcentaje de recargo que tendrá si el pago es con tarjeta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'CardPercent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el recargo que tendrá si el pago es con tarjeta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'CardAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si es artículo para recargos por tarjeta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'IsSurcharge';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar valor que indica si se envía o no código de almacén de Express Center.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleSAP', @level2type = N'COLUMN', @level2name = N'SendAlmacenExp';




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogos de articulos SAP',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatArticleSAP',
    @level2type = NULL,
    @level2name = NULL