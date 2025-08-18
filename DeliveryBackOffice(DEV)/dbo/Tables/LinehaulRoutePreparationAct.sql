CREATE TABLE [dbo].[LinehaulRoutePreparationAct] (
    [IdLinehaulRoutePreparationAct] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LinehaulRoutePreparationId]    INT           NOT NULL,
    [CatTypeActId]                  INT           NOT NULL,
    [ActCode]                       NVARCHAR (50) NULL,
    [AuthorizationDate]             DATETIME      NULL,
    [RowStatus]                     BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                  NVARCHAR (50) NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  NVARCHAR (50) NULL,
    [DateUpdated]                   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationAct] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationAct_ActType] FOREIGN KEY ([CatTypeActId]) REFERENCES [dbo].[CatTypeAct] ([IdCatTypeAct]),
    CONSTRAINT [FK_LinehaulRoutePreparationAct_RoutePreparation] FOREIGN KEY ([LinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation]),
    CONSTRAINT [UQ_LinehaulRoutePreparationAct] UNIQUE NONCLUSTERED ([LinehaulRoutePreparationId] ASC, [CatTypeActId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de autorización de acta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'AuthorizationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de acta (justificación) asignada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'ActCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de tipo de acta | Tabla CatTypeAct', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'CatTypeActId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de preparación de ruta de linehaul | Tabla LinehaulRoutePreparation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationAct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de encabezado de actas (justificaciones) asignadas a un proceso de preparación de linehaul.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationAct';

