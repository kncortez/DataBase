CREATE TABLE [dbo].[LinehaulRoutePreparationCustomsMark] (
    [IdLinehaulRoutePreparationCustomsMark] INT            IDENTITY (1, 1) NOT NULL,
    [LinehaulRoutePreparationId]            INT            NOT NULL,
    [CustomsMarkSerie]                      NVARCHAR (100) NOT NULL,
    [RowStatus]                             BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]                          NVARCHAR (50)  NOT NULL,
    [DateCreated]                           DATETIME       NOT NULL,
    [TokenUpdated]                          NVARCHAR (50)  NULL,
    [DateUpdated]                           DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationCustomsMark] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationCustomsMark_LinehaulRoutePreparation] FOREIGN KEY ([LinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation]),
    CONSTRAINT [UQ_LinehaulCustomsMark_CustomsMarkSerie] UNIQUE NONCLUSTERED ([CustomsMarkSerie] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie | Número del marchamo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'CustomsMarkSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la preparación de ruta | Tabla LinehaulRoutePreparaion.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationCustomsMark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de asignación de marchamo a preparación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationCustomsMark';

