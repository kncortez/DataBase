CREATE TABLE [dbo].[GeofencePoint] (
    [IdGeofencePoint]    INT           IDENTITY (1, 1) NOT NULL,
    [IdGeofence]         INT           NOT NULL,
    [IdPoint]            INT           NOT NULL,
    [GeofencePointOrder] INT           NOT NULL,
    [RowStatus]          BIT           NOT NULL,
    [TokenCreated]       NVARCHAR (50) NOT NULL,
    [DateCreated]        DATETIME      NOT NULL,
    [TokenUpdated]       NVARCHAR (50) NULL,
    [DateUpdated]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdGeofencePoint] ASC),
    CONSTRAINT [FK_GeofencePoint_Geofence] FOREIGN KEY ([IdGeofence]) REFERENCES [dbo].[Geofence] ([IdGeofence]),
    CONSTRAINT [FK_GeofencePoint_Point] FOREIGN KEY ([IdPoint]) REFERENCES [dbo].[Point] ([IdPoint])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para relacionar geocercas con puntos (ubicaciones)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'IdGeofencePoint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla Geofence', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'IdGeofence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla Point', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'IdPoint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden de referencia del punto en la geocerca, para poder generar el polígono de forma correcta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'GeofencePointOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GeofencePoint', @level2type = N'COLUMN', @level2name = N'DateUpdated';

