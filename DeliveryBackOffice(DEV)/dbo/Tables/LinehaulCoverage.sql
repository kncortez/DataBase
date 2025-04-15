CREATE TABLE [dbo].[LinehaulCoverage] (
    [IdLinehaulCoverage] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatRouteId]         INT            NOT NULL,
    [HubOriginId]        INT            NOT NULL,
    [HubDestinyId]       INT            NOT NULL,
    [ReportEmails]       NVARCHAR (MAX) NOT NULL,
    [RowStatus]          BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [DateUpdated]        DATETIME       NULL,
    [ReportPhones]       NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulCoverage] ASC),
    CONSTRAINT [FK_LinehaulCoverage_OriginHubDestiny] FOREIGN KEY ([HubDestinyId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_LinehaulCoverage_OriginHubOrigin] FOREIGN KEY ([HubOriginId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_LinehaulCoverage_Route] FOREIGN KEY ([CatRouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Arreglo de correos separados por comas a donde se enviarán reportes de los linehauls por ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'ReportEmails';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del Hub de destino de la tabla HubLogistics.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'HubDestinyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del Hub de origen de la tabla HubLogistics.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'HubOriginId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la ruta de la tabla CatRoute.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'CatRouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'IdLinehaulCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de coberturas de las rutas de linehauls.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Arreglo de números de telefonos separados por comas a donde se enviarán notificaciones de reportes linehauls.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulCoverage', @level2type = N'COLUMN', @level2name = N'ReportPhones';

