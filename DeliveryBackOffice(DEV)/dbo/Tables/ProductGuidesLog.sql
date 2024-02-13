CREATE TABLE [dbo].[ProductGuidesLog] (
    [IdProductGuideLog] BIGINT          NOT NULL,
    [SystemId]          INT             NOT NULL,
    [ModuleId]          INT             NOT NULL,
    [ProductId]         INT             NOT NULL,
    [GuideSerie]        NVARCHAR (2)    NOT NULL,
    [GuideNumber]       INT             NOT NULL,
    [OriginalValue]     DECIMAL (14, 2) NULL,
    [NewValue]          DECIMAL (14, 2) NULL,
    [ServiceNumber]     INT             NULL,
    [RowStatus]         BIT             NOT NULL,
    [TokenCreated]      NVARCHAR (50)   NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [TokenUpdated]      NVARCHAR (50)   NULL,
    [DateUpdated]       DATETIME        NULL,
    CONSTRAINT [PK_ProductGuidesLog] PRIMARY KEY CLUSTERED ([IdProductGuideLog] ASC),
    CONSTRAINT [FK_ProductGuidesLog_CatModule] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_ProductGuidesLog_CatSystem1] FOREIGN KEY ([SystemId]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_ProductGuidesLog_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_ProductGuidesLog_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([IdProduct])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contador de servicios', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'ServiceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nuevo valor al usar el producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'NewValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor original', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'OriginalValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Seríe de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'ProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del módulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'ModuleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'SystemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog', @level2type = N'COLUMN', @level2name = N'IdProductGuideLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Guías consumidas de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProductGuidesLog';

