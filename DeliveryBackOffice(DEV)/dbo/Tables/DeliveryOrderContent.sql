CREATE TABLE [dbo].[DeliveryOrderContent] (
    [IdDeliveryOrderContent] INT             IDENTITY (1, 1) NOT NULL,
    [GuideSerie]             NVARCHAR (2)    NOT NULL,
    [GuideNumber]            INT             NOT NULL,
    [ContentCode]            NVARCHAR (20)   NOT NULL,
    [ContentDescription]     NVARCHAR (150)  NOT NULL,
    [ContentPrice]           DECIMAL (18, 2) NOT NULL,
    [RowStatus]              BIT             CONSTRAINT [DF_DeliveryOrderContent_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50)   NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenUpdated]           NVARCHAR (50)   NULL,
    [DateUpdated]            DATETIME        NULL,
    CONSTRAINT [FK_DeliveryOrderContent_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrderContent]
    ON [dbo].[DeliveryOrderContent]([GuideSerie] ASC, [GuideNumber] DESC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de modificación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token modificación fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token creó la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, 1 = Activo 1 = Borrado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio del contenido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'ContentPrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del contenido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'ContentDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del contenido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'ContentCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía, foranea DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía, foranea DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de tabla DeliveryOrderContent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent', @level2type = N'COLUMN', @level2name = N'IdDeliveryOrderContent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el contenido de una guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderContent';

