CREATE TABLE [dbo].[LinehaulRoutePreparation] (
    [IdLinehaulRoutePreparation]      INT            IDENTITY (1, 1) NOT NULL,
    [StationDispatchedId]             INT            NULL,
    [CatLinehaulStatusId]             INT            CONSTRAINT [DF_LinehaulRoutePreparation_CatLinehaulStatusId] DEFAULT ((1)) NOT NULL,
    [CatRouteId]                      INT            NOT NULL,
    [SenderReceiverId]                INT            NULL,
    [CatVehicleId]                    INT            NULL,
    [VehicleKms]                      INT            CONSTRAINT [DF_LinehaulRoutePreparation_VehicleKms] DEFAULT ((0)) NULL,
    [DriverCUI]                       NVARCHAR (50)  NULL,
    [DriverName]                      NVARCHAR (100) NULL,
    [DriverPhone]                     NVARCHAR (25)  NULL,
    [VehicleID]                       NVARCHAR (25)  NULL,
    [VehicleDescription]              NVARCHAR (100) NULL,
    [SecurityManName]                 NVARCHAR (100) NULL,
    [SecurityManPhone]                NVARCHAR (25)  NULL,
    [SecurityManCUI]                  NVARCHAR (25)  NULL,
    [DateLinehaulRoutePreparation]    DATE           NOT NULL,
    [EndDateLinehaulRoutePreparation] DATETIME       NULL,
    [ContainerQuantity]               INT            NOT NULL,
    [GuideQuantity]                   INT            NOT NULL,
    [DryPieceQuantity]                INT            NOT NULL,
    [ColdPieceQuantity]               INT            NOT NULL,
    [RowStatus]                       BIT            CONSTRAINT [DF__LinehaulR__RowSt__70F39DC8] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                    NVARCHAR (50)  NOT NULL,
    [DateCreated]                     DATETIME       NOT NULL,
    [TokenUpdated]                    NVARCHAR (50)  NULL,
    [DateUpdated]                     DATETIME       NULL,
    CONSTRAINT [PK__Linehaul__06DFAFE72F82A119] PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparation] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparation_Courier] FOREIGN KEY ([SenderReceiverId]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FK_LinehaulRoutePreparation_Route] FOREIGN KEY ([CatRouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_LinehaulRoutePreparation_Station] FOREIGN KEY ([StationDispatchedId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_LinehaulRoutePreparation_Status] FOREIGN KEY ([CatLinehaulStatusId]) REFERENCES [dbo].[CatLinehaulStatus] ([IdCatLinehaulStatus]),
    CONSTRAINT [FK_LinehaulRoutePreparation_Vehicle] FOREIGN KEY ([CatVehicleId]) REFERENCES [dbo].[CatVehicle] ([IdVehicle])
);










GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas frías asignadas a la preparación de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'ColdPieceQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas secas asignadas a la preparación de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'DryPieceQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías asignadas a la preparación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'GuideQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de contenedores asignados a la preparación de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'ContainerQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de la preparación de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'DateLinehaulRoutePreparation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del piloto asignado a la preparación de ruta | Tabla SenderReceiver', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'SenderReceiverId';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la ruta asignada | Tabla CatRoute.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'CatRouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado de la preparación de ruta | Tabla CatLinehaulStatus.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'CatLinehaulStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la estación de despacho | Tabla CatStation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'StationDispatchedId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de preparación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del vehículo asignado a la preparación de ruta | Tabla CatVehicleId', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'CatVehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del vehículo asignado, placa u otros (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'VehicleID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del vehículo asignado (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'VehicleDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de teléfono del agente de seguridad asignado (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'SecurityManPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del agente de seguridad asignado (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'SecurityManName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CUI del agente de seguridad asignado (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'SecurityManCUI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de teléfono del piloto asignado (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'DriverPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del piloto asignado (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'DriverName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CUI del piloto asignado (OPCIONAL)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'DriverCUI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro de kilometraje de salida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'VehicleKms';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de finalización de despacho', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparation', @level2type = N'COLUMN', @level2name = N'EndDateLinehaulRoutePreparation';

