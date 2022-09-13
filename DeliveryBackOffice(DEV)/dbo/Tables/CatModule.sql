CREATE TABLE [dbo].[CatModule] (
    [ModIdModule]       INT           IDENTITY (1, 1) NOT NULL,
    [ModName]           VARCHAR (100) NOT NULL,
    [ModIdModuleParent] INT           NULL,
    [ModPath]           VARCHAR (200) NOT NULL,
    [ModDescription]    VARCHAR (150) NULL,
    [ModOrder]          INT           NOT NULL,
    [ModMetadata]       VARCHAR (50)  NULL,
    [ModVisible]        BIT           NOT NULL,
    [ModRowStatus]      BIT           NOT NULL,
    [ModTokenCreated]   VARCHAR (50)  NOT NULL,
    [ModDateCreated]    DATETIME      NOT NULL,
    [ModTokenUpdated]   VARCHAR (50)  NULL,
    [ModDateUpdated]    DATETIME      NULL,
    [ModGroup]          INT           CONSTRAINT [DF_CatModule_ModGroup] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ModIdModule] ASC),
    FOREIGN KEY ([ModIdModuleParent]) REFERENCES [dbo].[CatModule] ([ModIdModule])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de módulos del sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el módulo es visible.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModVisible';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModTokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModTokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModRowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL o dirección para acceder al módulo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Order para desplegar el módulo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del módulo, usualmente para despliegue de menú.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Metadatos adicionales del módulo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModMetadata';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de módulo padre de la tabla CatModule.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModIdModuleParent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModIdModule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del módulo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModDateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModDateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del grupo al que pertenece el módulo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatModule', @level2type = N'COLUMN', @level2name = N'ModGroup';

