CREATE TABLE [dbo].[Geofence] (
    [IdGeofence]          INT           IDENTITY (1, 1) NOT NULL,
    [CountryId]           VARCHAR (2)   NOT NULL,
    [GeofenceDescription] NVARCHAR (50) NOT NULL,
    [RowStatus]           BIT           NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]         DATETIME      NULL,
    [UpdateFlag]          BIT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([IdGeofence] ASC),
    CONSTRAINT [FK_Geofence_Country] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de geocercas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'IdGeofence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla CatCountry', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'CountryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la geocerca', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'GeofenceDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para indicar si una Geocerca es actualizable.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Geofence', @level2type = N'COLUMN', @level2name = N'UpdateFlag';

