CREATE TABLE [dbo].[CatTypeIdentifationDocument] (
    [Id]           INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Code]         NVARCHAR (5)   NOT NULL,
    [Name]         NVARCHAR (10)  NOT NULL,
    [Description]  NVARCHAR (100) NOT NULL,
    [Rowstatus]    BIT            NOT NULL,
    [TokenCreated] NVARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [TokenUpdated] NVARCHAR (50)  NULL,
    [DateUpdated]  DATETIME       NULL,
    CONSTRAINT [PK_CatTypeIdentifationDocument] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único', 
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument',
    @level2type = N'COLUMN', @level2name = 'Id';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Código del tipo de documento para Digifact', 
    @level2type = N'COLUMN', @level2name = 'Code',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre corto del tipo de documento', 
    @level2type = N'COLUMN', @level2name = 'Name',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Descripción detallada del tipo de documento', 
    @level2type = N'COLUMN', @level2name = 'Description',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Estado del registro (1 = activo, 0 = inactivo)', 
    @level2type = N'COLUMN', @level2name = 'Rowstatus',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token del usuario que creó el registro', 
    @level2type = N'COLUMN', @level2name = 'TokenCreated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha de creación del registro', 
    @level2type = N'COLUMN', @level2name = 'DateCreated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token del usuario que actualizó el registro', 
    @level2type = N'COLUMN', @level2name = 'TokenUpdated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';

GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha de última actualización del registro', 
    @level2type = N'COLUMN', @level2name = 'DateUpdated',
    @level0type = N'SCHEMA', @level0name = 'dbo', 
    @level1type = N'TABLE',  @level1name = 'CatTypeIdentifationDocument';
