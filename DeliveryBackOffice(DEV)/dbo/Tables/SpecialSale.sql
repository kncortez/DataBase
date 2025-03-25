CREATE TABLE [dbo].[SpecialSale] (
    [IdSpecialSale] INT           IDENTITY (1, 1) NOT NULL,
    [Name]          VARCHAR (50)  NOT NULL,
    [Description]   VARCHAR (200) NULL,
    [StartDate]     DATETIME      NOT NULL,
    [FinishDate]    DATETIME      NULL,
    [IsGlobal]      BIT           NOT NULL,
    [Priority]      INT           NOT NULL,
    [RowStatus]     BIT           NOT NULL,
    [TokenCreated]  VARCHAR (50)  NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [TokenUpdated]  VARCHAR (50)  NULL,
    [DateUpdated]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdSpecialSale] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'IdSpecialSale';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'Name';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'Description';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de inicio de la venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'StartDate';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de finalización de la venta especial. Puede ser NULL si la venta no tiene una fecha de cierre definida.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'FinishDate';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si la venta especial es global (1 Sí, 0 No).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'IsGlobal';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Prioridad de la venta especial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'Priority';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la venta especial (1  Activa, 0  Inactiva).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token que identifica la creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token que identifica la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se realizó la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SpecialSale', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla de catalogo de ventas espciales',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'SpecialSale',
    @level2type = NULL,
    @level2name = NULL
