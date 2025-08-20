
CREATE TABLE [dbo].[CatEconomicActivityBySV] (
	Id INT IDENTITY(1,1) PRIMARY KEY,
    CodeActivity NVARCHAR(10),
    [Description] NVARCHAR(255),
    RowStatus BIT,
    TokenCreated VARCHAR(50),
    DateCreated DATETIME,
    TokenUpdated VARCHAR(50),
    DateUpdated DATETIME
);

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tabla que almacena los códigos y descripciones de actividades económicas para El Salvador',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'Id';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Código único de la actividad económica.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'CodeActivity';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Descripción de la actividad económica.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'Description';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Estado del registro (1 = Activo, 0 = Inactivo).',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Token único generado al crear el registro.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Fecha y hora de creación del registro.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Token único generado al actualizar el registro.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Fecha y hora de la última actualización del registro.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'CatEconomicActivityBySV',
    @level2type = N'COLUMN', @level2name = N'DateUpdated';