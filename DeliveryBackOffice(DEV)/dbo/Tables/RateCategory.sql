CREATE TABLE [dbo].[RateCategory] (
    [IdRateCategory]     INT            IDENTITY (1, 1) NOT NULL,
    [TitleName]          NVARCHAR (50)  NULL,
    [RateCatDescription] NVARCHAR (200) NULL,
    [RateCatStatus]      BIT            NULL,
    [TokenCreated]       NVARCHAR (50)  NULL,
    [DateCreated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [DateUpdated]        DATETIME       NULL,
    CONSTRAINT [PK_RateCategory] PRIMARY KEY CLUSTERED ([IdRateCategory] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de la categoría de tarifa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'IdRateCategory';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la categoría de tarifa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'TitleName';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la categoría de tarifa.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'RateCatDescription';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Estatus de la categoría de tarifa (1  Activo, 0  Inactivo).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'RateCatStatus';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token de la creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Token de la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de la última actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateCategory', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla de categorias de tarifarios',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RateCategory',
    @level2type = NULL,
    @level2name = NULL

