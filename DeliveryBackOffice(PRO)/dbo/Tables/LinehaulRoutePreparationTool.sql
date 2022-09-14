CREATE TABLE [dbo].[LinehaulRoutePreparationTool] (
    [IdLinehaulRoutePreparationTool] INT           IDENTITY (1, 1) NOT NULL,
    [LinehaulRoutePreparationId]     INT           NOT NULL,
    [ToolId]                         INT           NOT NULL,
    [RowStatus]                      BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                   NVARCHAR (50) NOT NULL,
    [DateCreated]                    DATETIME      NOT NULL,
    [TokenUpdated]                   NVARCHAR (50) NULL,
    [DateUpdated]                    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationTool] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationTool_RoutePreparation] FOREIGN KEY ([LinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation]),
    CONSTRAINT [FK_LinehaulRoutePreparationTool_Tool] FOREIGN KEY ([ToolId]) REFERENCES [dbo].[Tool] ([IdTool]),
    CONSTRAINT [UQ_LinehaulRoutePreparation_Tool] UNIQUE NONCLUSTERED ([LinehaulRoutePreparationId] ASC, [ToolId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la herramienta asignada | Tabla Tool', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'ToolId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la preparación de ruta enlazada | Tabla LinehaulRoutePreparation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationTool';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de herramientas asignadas a preparación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationTool';

