CREATE TABLE [dbo].[CatTypeServiceClosure] (
    [IdTypeService]          INT            IDENTITY (1, 1) NOT NULL,
    [NameTypeService]        NVARCHAR (55)  NOT NULL,
    [DescriptionTypeService] NVARCHAR (100) NOT NULL,
    [StatusTypeService]      INT            NOT NULL,
    [TokenCreated]           NVARCHAR (50)  NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdate]            NVARCHAR (50)  NULL,
    [DateUpdate]             DATETIME       NULL,
    CONSTRAINT [Pk_CatTypeService] PRIMARY KEY CLUSTERED ([IdTypeService] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del tipo de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'IdTypeService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'NameTypeService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'DescriptionTypeService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeServiceClosure', @level2type = N'COLUMN', @level2name = N'DateUpdate';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo,0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeServiceClosure',
    @level2type = N'COLUMN',
    @level2name = N'StatusTypeService'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de tipo cierre de servicio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatTypeServiceClosure',
    @level2type = NULL,
    @level2name = NULL