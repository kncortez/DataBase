CREATE TABLE [dbo].[CatStation] (
    [IdStation]            INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [StationName]          NVARCHAR (100) NOT NULL,
    [CountryId]            VARCHAR (2)    NOT NULL,
    [StationType]          INT            NOT NULL,
    [HubLogisticId]        INT            NULL,
    [CodeOfReference]      INT            NULL,
    [RowStatus]            BIT            NULL,
    [TokenCreated]         NVARCHAR (50)  NULL,
    [DateCreated]          DATETIME       NULL,
    [TokenUpdated]         NVARCHAR (50)  NULL,
    [DateUpdated]          DATETIME       NULL,
    [TownshipId]           INT            NULL,
    [RackPositionDefault]  NVARCHAR (60)  NULL,
    [IsStatusCheckEnabled] BIT            CONSTRAINT [DF_CatStation_IsStatusCheckEnabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CatStation] PRIMARY KEY CLUSTERED ([IdStation] ASC),
    CONSTRAINT [FK_CatStation_CatCountry] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [FK_CatStation_HubLogistics] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_CatStation_Township] FOREIGN KEY ([TownshipId]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_CatStation_VisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estaciones Delivery', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificación de estación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'IdStation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de estación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'StationName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'País al que pertenece la estación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'CountryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de estación 1. Hub 2. Express Center', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'StationType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hub relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'HubLogisticId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Punto de visita relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'CodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Activo o Inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Posición de rack por defecto de la estación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatStation',
    @level2type = N'COLUMN',
    @level2name = N'RackPositionDefault'
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Municipio relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'TownshipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si la validación de estados predecesores está habilitada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'IsStatusCheckEnabled';

